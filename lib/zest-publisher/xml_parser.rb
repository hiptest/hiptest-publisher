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
        build_node(field.css('> base > *').first),
        field.css('> name').first.content)
    end

    def build_index(index)
      Zest::Nodes::Index.new(
        build_node(index.css('> base > *').first),
        build_node(index.css('> expression > *').first))
    end

    def build_operation(operation)
      unless operation.css('> left').first.nil?
        Zest::Nodes::BinaryExpression.new(
          build_node(operation.css('> left > *').first),
          operation.css('> operator').first.content,
          build_node(operation.css('> right > *').first))
      else
        Zest::Nodes::UnaryExpression.new(
          operation.css('> operator').first.content,
          build_node(operation.css('> expression > *').first)
        )
      end
    end

    def build_parenthesis(parenthesis)
      Zest::Nodes::Parenthesis.new(
        build_node(parenthesis.element_children.first))
    end

    def build_list(list)
      items = list.css('> item').map{ |item|
        build_node(item.element_children.first)
      }

      Zest::Nodes::List.new(items)
    end

    def build_dict(dict)
      items = dict.element_children.map{ |item|
        Zest::Nodes::Property.new(
          item.name,
          build_node(item.element_children.first))
      }
      Zest::Nodes::Dict.new(items)
    end

    def build_template(template)
      Zest::Nodes::Template.new(build_node_list(template.css('> *')))
    end

    def build_assign(assign)
      Zest::Nodes::Assign.new(
        build_node(assign.css('to').first.element_children.first),
        build_node(assign.css('value').first.element_children.first))
    end

    def build_call(call)
      Zest::Nodes::Call.new(
        call.css('> actionword').first.content,
        build_arguments(call))
    end

    def build_arguments(action)
      build_node_list(action.css('> arguments > argument'))
    end

    def build_argument(argument)
      value = argument.css('> value').first
      Zest::Nodes::Argument.new(
        argument.css('name').first.content,
        value ? build_node(value) : nil)
    end

    def build_if(if_then)
      Zest::Nodes::IfThen.new(
        build_node(if_then.css('> condition > *').first),
        build_node_list(if_then.css('> then > *')),
        build_node_list(if_then.css('> else > *')))
    end

    def build_step(step)
      first_prop = step.element_children.first
      Zest::Nodes::Step.new(
        first_prop.name,
        build_node(first_prop.element_children.first)
      )
    end

    def build_while(while_loop)
      Zest::Nodes::While.new(
        build_node(while_loop.css('> condition > *').first),
        build_node_list(while_loop.css('> body > *'))
      )
    end

    def build_tag(tag)
      value = tag.css('> value').first
      Zest::Nodes::Tag.new(
        tag.css('> key').first.content,
        value ? value.content : nil
      )
    end

    def build_parameter(parameter)
      default_value = parameter.css('> default_value').first

      Zest::Nodes::Parameter.new(
        parameter.css('name').first.content,
        default_value ? build_node(default_value) : nil)
    end

    def build_default_value(node)
      build_node(node.element_children.first)
    end

    def build_value(node)
      build_node(node.element_children.first)
    end

    def build_tags(item)
      build_node_list(item.css('> tags tag'))
    end

    def build_parameters(item)
      build_node_list(item.css('> parameters > parameter'))
    end

    def build_steps(item)
      steps = item.css('> steps').first
      if steps.nil?
        []
      else
        build_node_list(steps.element_children)
      end
    end

    def build_actionword(actionword)
      Zest::Nodes::Actionword.new(
        actionword.css('name').first.content,
        build_tags(actionword),
        build_parameters(actionword),
        build_steps(actionword)
      )
    end

    def build_scenario(scenario)
      folder_uid_node = scenario.css('folderUid').first
      description_node = scenario.css('description').first

      Zest::Nodes::Scenario.new(
        scenario.css('name').first.content,
        description_node.nil? ? '' : description_node.content,
        build_tags(scenario),
        build_parameters(scenario),
        build_steps(scenario),
        folder_uid_node.nil? ? nil : folder_uid_node.content,
        build_node(scenario.css('datatable').first)
      )
    end

    def build_datatable(datatable)
      Zest::Nodes::Datatable.new(build_node_list(datatable.css('> dataset')))
    end

    def build_dataset(dataset)
      Zest::Nodes::Dataset.new(
        dataset.css('> name').first.content,
        build_node_list(dataset.css('> arguments argument'))
      )
    end

    def build_actionwords(actionwords)
      build_node_list(actionwords.css('> actionword'), Zest::Nodes::Actionwords)
    end

    def build_scenarios(scenarios)
      build_node_list(scenarios.css('> scenario'), Zest::Nodes::Scenarios)
    end

    def build_folder(folder)
      parent_uid_node = folder.css('parentUid').first
      Zest::Nodes::Folder.new(
        folder.css('uid').first.content,
        parent_uid_node ? parent_uid_node.content : nil,
        folder.css('name').first.content
      )
    end

    def build_testPlan(test_plan)
      tp = Zest::Nodes::TestPlan.new(
        build_node_list(test_plan.css('> folder'))
      )

      tp.organize_folders
      return tp
    end

    def build_project
      @project = Zest::Nodes::Project.new(
        @xml.css('project name').first.content,
        @xml.css('project description').first.content,
        build_node(@xml.css('project > testPlan').first, Zest::Nodes::TestPlan),
        build_node(@xml.css('project > scenarios').first, Zest::Nodes::Scenarios),
        build_node(@xml.css('project > actionwords').first, Zest::Nodes::Actionwords)
      )

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
  end
end
