require 'nokogiri'
require 'colorize'

require_relative 'nodes'
require_relative 'utils'

module Zest
  class XMLParser
    attr_reader :project

    def initialize(source, options = {})
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

    def build_operation(expr)
      Zest::Nodes::BinaryExpression.new(
        build_node(expr.css('> left > *').first),
        expr.css('> operator').first.content,
        build_node(expr.css('> right > *').first))
    end

    def build_unaryexpression(expr)
      Zest::Nodes::UnaryExpression.new(operator, expression)
    end

    def build_parenthesis(parenthesis)
      Zest::Nodes::Parenthesis.new(content)
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
      arguments = call.css('arguments > *').map{ |arg|
        Zest::Nodes::Argument.new(
          arg.name,
          build_node(arg.element_children.first))
      }
      Zest::Nodes::Call.new(
        call.css('> actionword').first.content,
        arguments)
    end

    def build_if(if_then)
      Zest::Nodes::IfThen.new(
        build_node(if_then.css('> condition > *').first),
        build_node_list(if_then.css('> then > *')),
        build_node_list(if_then.css('> else > *')))
    end

    def build_step(step)
      properties = step.element_children.map{ |item|
        Zest::Nodes::Property.new(
          item.name,
          build_node(item.element_children.first)
        )
      }
      Zest::Nodes::Step.new(properties)
    end

    def build_while(while_loop)
      Zest::Nodes::While.new(
        build_node(while_loop.css('> condition > *').first),
        build_node_list(while_loop.css('> body > *'))
      )
    end

    def build_tag(tag)
      if tag.css('key').size == 0
        # Current API
        Zest::Nodes::Tag.new(tag.content)
      else
        # Incoming API
        Zest::Nodes::Tag.new(tag.css('key').first.content, tag.css('value').first.content)
      end
    end

    def build_parameter(parameter)
      default_value = parameter.css('typed_default_value').first

      Zest::Nodes::Parameter.new(
        parameter.css('name').first.content,
        default_value ? build_node(default_value) : nil)
    end

    def build_typed_default_value(node)
      build_node(node.element_children.first)
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
        build_node_list(actionword.css('tags tag')),
        build_node_list(actionword.css('parameters parameter')),
        build_steps(actionword)
      )
    end

    def build_scenario(scenario)
      Zest::Nodes::Scenario.new(
        scenario.css('name').first.content,
        scenario.css('description').first.content,
        build_node_list(scenario.css('tags > tag')),
        build_node_list(scenario.css('parameters > parameter')),
        build_steps(scenario)
      )
    end

    def build_actionwords(actionwords)
      build_node_list(actionwords.css('> actionword'), Zest::Nodes::Actionwords)
    end

    def build_scenarios(scenarios)
      build_node_list(scenarios.css('> scenario'), Zest::Nodes::Scenarios)
    end

    def build_project
      @project = Zest::Nodes::Project.new(
        @xml.css('project name').first.content,
        @xml.css('project description').first.content,
        build_node(@xml.css('project > scenarios').first),
        build_node(@xml.css('project > actionwords').first)
      )
    end

    private

    def build_node(node)
      self.send("build_#{node.name}", node)
    rescue Exception => exception
      if @options.verbose
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