require 'nokogiri'
require 'colorize'

require_relative 'nodes'
require_relative 'utils'

module Zest
  class XMLParser
    attr_reader :project

    def initialize(source, options = nil)
      @source = source
      @xml = Nokogiri::XML(source)
      @options = options
    end

    def build_nullliteral(value = nil)
      Zest::Nodes::NullLiteral.new
    end

    def build_stringliteral(value)
      if value.is_a? String
        Zest::Nodes::StringLiteral.new(value)
      else
        Zest::Nodes::StringLiteral.new(value.content)
      end
    end

    def build_numericliteral(value)
      if value.is_a? Numeric
        Zest::Nodes::NumericLiteral.new(value)
      else
        Zest::Nodes::NumericLiteral.new(value.content)
      end
    end

    def build_booleanliteral(value)
      if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        Zest::Nodes::BooleanLiteral.new(value)
      else
        Zest::Nodes::BooleanLiteral.new(value.content)
      end
    end

    def build_var(variable)
      Zest::Nodes::Variable.new(variable.content)
    end

    def build_field(field)
      Zest::Nodes::Field.new(
        build_node(css_first(field, '> base > *')),
        css_first_content(field, '> name'))
    end

    def build_index(index)
      Zest::Nodes::Index.new(
        build_node(css_first(index, '> base > *')),
        build_node(css_first(index, '> expression > *')))
    end

    def build_binary_expression(operation)
      Zest::Nodes::BinaryExpression.new(
        build_node(css_first(operation, '> left > *')),
        css_first_content(operation, '> operator'),
        build_node(css_first(operation, '> right > *')))
    end

    def build_unary_expression(operation)
      Zest::Nodes::UnaryExpression.new(
        css_first_content(operation, '> operator'),
        build_node(css_first(operation, '> expression > *')))
    end

    def build_operation(operation)
      if css_first(operation, '> left').nil?
        build_unary_expression(operation)
      else
        build_binary_expression(operation)
      end
    end

    def build_parenthesis(parenthesis)
      Zest::Nodes::Parenthesis.new(
        build_node(css_first(parenthesis)))
    end

    def build_list(list)
      Zest::Nodes::List.new(build_node_list(list.css('> item > *')))
    end

    def build_dict(dict)
      items = dict.element_children.map do |item|
        Zest::Nodes::Property.new(
          item.name,
          build_node(css_first(item)))
      end
      Zest::Nodes::Dict.new(items)
    end

    def build_template(template)
      Zest::Nodes::Template.new(build_node_list(template.css('> *')))
    end

    def build_assign(assign)
      Zest::Nodes::Assign.new(
        build_node(css_first(assign, 'to > *')),
        build_node(css_first(assign, 'value > *')))
    end

    def build_call(call)
      Zest::Nodes::Call.new(
        css_first_content(call, '> actionword'),
        build_arguments(call))
    end

    def build_arguments(arguments)
      build_node_list(arguments.css('> arguments > argument'))
    end

    def build_argument(argument)
      value = css_first(argument, '> value')
      Zest::Nodes::Argument.new(
        css_first_content(argument, 'name'),
        value ? build_node(value) : nil)
    end

    def build_if(if_then)
      Zest::Nodes::IfThen.new(
        build_node(css_first(if_then, '> condition > *')),
        build_node_list(if_then.css('> then > *')),
        build_node_list(if_then.css('> else > *')))
    end

    def build_step(step)
      first_prop = css_first(step)
      Zest::Nodes::Step.new(
        first_prop.name,
        build_node(css_first(first_prop)))
    end

    def build_while(while_loop)
      Zest::Nodes::While.new(
        build_node(css_first(while_loop, '> condition > *')),
        build_node_list(while_loop.css('> body > *')))
    end

    def build_tag(tag)
      Zest::Nodes::Tag.new(
        css_first_content(tag, '> key'),
        css_first_content(tag, '> value'))
    end

    def build_parameter(parameter)
      default_value = css_first(parameter, '> default_value')

      Zest::Nodes::Parameter.new(
        css_first_content(parameter, 'name'),
        default_value ? build_node(default_value) : nil)
    end

    def build_default_value(node)
      build_node(css_first(node))
    end

    def build_value(node)
      build_node(css_first(node))
    end

    def build_tags(item)
      build_node_list(item.css('> tags tag'))
    end

    def build_parameters(item)
      build_node_list(item.css('> parameters > parameter'))
    end

    def build_steps(item)
      build_node_list(item.css('> steps > *'))
    end

    def build_actionword(actionword)
      Zest::Nodes::Actionword.new(
        css_first_content(actionword, 'name'),
        build_tags(actionword),
        build_parameters(actionword),
        build_steps(actionword))
    end

    def build_scenario(scenario)
      Zest::Nodes::Scenario.new(
        css_first_content(scenario, 'name'),
        css_first_content(scenario, 'description'),
        build_tags(scenario),
        build_parameters(scenario),
        build_steps(scenario),
        css_first_content(scenario, 'folderUid'),
        build_node(css_first(scenario, 'datatable'), Zest::Nodes::Datatable))
    end

    def build_datatable(datatable)
      Zest::Nodes::Datatable.new(build_node_list(datatable.css('> dataset')))
    end

    def build_dataset(dataset)
      Zest::Nodes::Dataset.new(
        css_first_content(dataset, '> name'),
        build_node_list(dataset.css('> arguments argument')))
    end

    def build_actionwords(actionwords)
      build_node_list(actionwords.css('> actionword'), Zest::Nodes::Actionwords)
    end

    def build_scenarios(scenarios)
      build_node_list(scenarios.css('> scenario'), Zest::Nodes::Scenarios)
    end

    def build_folder(folder)
      Zest::Nodes::Folder.new(
        css_first_content(folder, 'uid'),
        css_first_content(folder, 'parentUid'),
        css_first_content(folder, 'name'))
    end

    def build_testPlan(test_plan)
      tp = Zest::Nodes::TestPlan.new(
        build_node_list(test_plan.css('> folder')))

      tp.organize_folders
      return tp
    end

    def build_project
      project = css_first(@xml, 'project')

      @project = Zest::Nodes::Project.new(
        css_first_content(project, '> name'),
        css_first_content(project, '> description'),
        build_node(css_first(project, '> testPlan'), Zest::Nodes::TestPlan),
        build_node(css_first(project, '> scenarios'), Zest::Nodes::Scenarios),
        build_node(css_first(project, '> actionwords'), Zest::Nodes::Actionwords))

      @project.assign_scenarios_to_folders
      return @project
    end

    private

    def build_node(node, default_node=nil)
      if node.nil? && default_node
        return default_node.new
      end
      self.send("build_#{node.name}", node)
    rescue Exception => exception
      if @options && @options.verbose
        puts "Unable to build: \n#{node}".blue
        trace_exception(exception)
      end
    end

    def build_node_list(l, container_class=nil)
      items = l.map {|item| build_node(item)}

      unless container_class.nil?
        container_class.new(items)
      else
        items
      end
    end

    def css_first(node, selector = '> *')
      node.css(selector).first
    end

    def css_first_content(node, selector = '> *')
      sub_node = css_first(node, selector)
      sub_node.nil? ? nil : sub_node.content
    end
  end
end
