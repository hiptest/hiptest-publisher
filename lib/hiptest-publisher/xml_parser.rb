require 'nokogiri'
require 'colorize'

require_relative 'nodes'
require_relative 'utils'
require_relative 'formatters/reporter'

module Hiptest
  class XMLParser
    attr_reader :project
    attr_reader :xml

    def initialize(source, reporter = nil)
      @source = source
      @xml = Nokogiri::XML(source)
      @reporter = reporter || NullReporter.new
    end

    def build_nullliteral(value = nil)
      Hiptest::Nodes::NullLiteral.new
    end

    def build_stringliteral(value)
      if value.is_a? String
        Hiptest::Nodes::StringLiteral.new(value)
      else
        Hiptest::Nodes::StringLiteral.new(value.content)
      end
    end

    def build_numericliteral(value)
      if value.is_a? Numeric
        Hiptest::Nodes::NumericLiteral.new(value)
      else
        Hiptest::Nodes::NumericLiteral.new(value.content)
      end
    end

    def build_booleanliteral(value)
      if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        Hiptest::Nodes::BooleanLiteral.new(value)
      else
        Hiptest::Nodes::BooleanLiteral.new(value.content)
      end
    end

    def build_var(variable)
      Hiptest::Nodes::Variable.new(variable.content)
    end

    def build_field(field)
      Hiptest::Nodes::Field.new(
        build_node(css_first(field, '> base > *')),
        css_first_content(field, '> name'))
    end

    def build_index(index)
      Hiptest::Nodes::Index.new(
        build_node(css_first(index, '> base > *')),
        build_node(css_first(index, '> expression > *')))
    end

    def build_binary_expression(operation)
      Hiptest::Nodes::BinaryExpression.new(
        build_node(css_first(operation, '> left > *')),
        css_first_content(operation, '> operator'),
        build_node(css_first(operation, '> right > *')))
    end

    def build_unary_expression(operation)
      Hiptest::Nodes::UnaryExpression.new(
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
      Hiptest::Nodes::Parenthesis.new(
        build_node(css_first(parenthesis)))
    end

    def build_list(list)
      Hiptest::Nodes::List.new(build_node_list(list.css('> item > *')))
    end

    def build_dict(dict)
      items = dict.element_children.map do |item|
        Hiptest::Nodes::Property.new(
          item.name,
          build_node(css_first(item)))
      end
      Hiptest::Nodes::Dict.new(items)
    end

    def build_template(template)
      Hiptest::Nodes::Template.new(build_node_list(template.css('> *')))
    end

    def build_assign(assign)
      Hiptest::Nodes::Assign.new(
        build_node(css_first(assign, 'to > *')),
        build_node(css_first(assign, 'value > *')))
    end

    def build_call(call)
      Hiptest::Nodes::Call.new(
        css_first_content(call, '> actionword'),
        build_arguments(call),
        css_first_content(call, '> annotation'))
    end

    def build_arguments(arguments)
      build_node_list(arguments.css('> arguments > argument'))
    end

    def build_argument(argument)
      value = css_first(argument, '> value')
      Hiptest::Nodes::Argument.new(
        css_first_content(argument, 'name'),
        value ? build_node(value) : nil)
    end

    def build_if(if_then)
      Hiptest::Nodes::IfThen.new(
        build_node(css_first(if_then, '> condition > *')),
        build_node_list(if_then.css('> then > *')),
        build_node_list(if_then.css('> else > *')))
    end

    def build_step(step)
      first_prop = css_first(step)
      step_value_node = css_first(first_prop)
      step_value = step_value_node ? build_node(step_value_node) : first_prop.text
      Hiptest::Nodes::Step.new(
        first_prop.name,
        step_value)
    end

    def build_while(while_loop)
      Hiptest::Nodes::While.new(
        build_node(css_first(while_loop, '> condition > *')),
        build_node_list(while_loop.css('> body > *')))
    end

    def build_tag(tag)
      Hiptest::Nodes::Tag.new(
        css_first_content(tag, '> key'),
        css_first_content(tag, '> value'))
    end

    def build_parameter(parameter)
      default_value = css_first(parameter, '> default_value')

      Hiptest::Nodes::Parameter.new(
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
      Hiptest::Nodes::Actionword.new(
        css_first_content(actionword, '> name'),
        build_tags(actionword),
        build_parameters(actionword),
        build_steps(actionword),
        css_first_content(actionword, '> uid'))
    end

    def build_actionwordSnapshot(actionword)
      Hiptest::Nodes::Actionword.new(
        css_first_content(actionword, '> name'),
        build_tags(actionword),
        build_parameters(actionword),
        build_steps(actionword),
        css_first_content(actionword, '> actionwordUid'))
    end

    def build_scenario(scenario)
      Hiptest::Nodes::Scenario.new(
        css_first_content(scenario, '> name'),
        css_first_content(scenario, '> description'),
        build_tags(scenario),
        build_parameters(scenario),
        build_steps(scenario),
        css_first_content(scenario, '> folderUid'),
        build_node(css_first(scenario, '> datatable'), Hiptest::Nodes::Datatable),
        css_first_content(scenario, 'order_in_parent').to_i)
    end

    def build_scenarioSnapshot(scs)
      scenario = build_scenario(scs)
      datasets = scenario.each_sub_nodes(Hiptest::Nodes::Dataset).to_a

      if datasets.empty?
        scenario.set_uid(css_first_content(scs, 'testSnapshot > uid'))
      else
        scs.css('testSnapshot').each do |testSnapshot|
          uid = css_first_content(testSnapshot, '> uid')
          index = css_first_content(testSnapshot, '> index').to_i

          datasets[index].set_uid(uid) unless index >= datasets.length
        end
      end
      scenario
    end

    def build_datatable(datatable)
      Hiptest::Nodes::Datatable.new(build_node_list(datatable.css('> dataset')))
    end

    def build_dataset(dataset)
      Hiptest::Nodes::Dataset.new(
        css_first_content(dataset, '> name'),
        build_node_list(dataset.css('> arguments argument')))
    end

    def build_actionwords(actionwords, actionwords_query = '> actionword')
      build_node_list(actionwords.css(actionwords_query), Hiptest::Nodes::Actionwords)
    end

    def build_actionwordSnapshots(actionword_snapshots)
      build_actionwords(actionword_snapshots, '> actionwordSnapshot')
    end

    def build_scenarios(scenarios, scenarios_query = '> scenario')
      build_node_list(scenarios.css(scenarios_query), Hiptest::Nodes::Scenarios)
    end

    def build_scenarioSnapshots(scenario_snapshots)
      build_scenarios(scenario_snapshots, '> scenarioSnapshot')
    end

    def build_tests(tests)
      build_node_list(tests.css('> test'), Hiptest::Nodes::Tests)
    end

    def build_test(test)
      Hiptest::Nodes::Test.new(
        css_first_content(test, 'name'),
        css_first_content(test, 'description'),
        build_tags(test),
        build_steps(test)
      )
    end

    def build_folder(folder)
      Hiptest::Nodes::Folder.new(
        css_first_content(folder, 'uid'),
        css_first_content(folder, 'parentUid'),
        css_first_content(folder, 'name'),
        css_first_content(folder, 'description'),
        build_tags(folder),
        css_first_content(folder, 'order_in_parent').to_i)
    end
    alias :build_folderSnapshot :build_folder

    def build_testPlan(test_plan, folders_query = '> folder')
      tp = Hiptest::Nodes::TestPlan.new(
        build_node_list(test_plan.css(folders_query)))

      tp.organize_folders
      return tp
    end

    def build_folderSnapshots(folder_snapshots)
      build_testPlan(folder_snapshots, '> folderSnapshot')
    end

    def build_project
      project = css_first(@xml, 'project')
      test_run = css_first(project, '> testRuns > testRun')

      if test_run.nil?
        test_plan_node = css_first(project, '> testPlan')
        scenarios_node = css_first(project, '> scenarios')
        actionwords_node = css_first(project, '> actionwords')
      else
        test_plan_node = css_first(test_run, '> folderSnapshots')
        scenarios_node = css_first(test_run, '> scenarioSnapshots')
        actionwords_node = css_first(test_run, '> actionwordSnapshots')
      end

      @project = Hiptest::Nodes::Project.new(
        css_first_content(project, '> name'),
        css_first_content(project, '> description'),
        build_node(test_plan_node, Hiptest::Nodes::TestPlan),
        build_node(scenarios_node, Hiptest::Nodes::Scenarios),
        build_node(actionwords_node, Hiptest::Nodes::Actionwords),
        build_node(css_first(project, '> tests'), Hiptest::Nodes::Tests))

      @project.assign_scenarios_to_folders
      return @project
    end

    private

    def build_node(node, default_node=nil)
      if node.nil? && default_node
        return default_node.new
      end
      self.send("build_#{node.name}", node)
    rescue => error
      @reporter.dump_error(error, "Unable to build: \n#{node}")
      nil
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
