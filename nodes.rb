require 'erb'

require_relative 'utils'

module Zest
  module Nodes
    class Node
      attr_reader :childs, :rendered_childs, :parent
      attr_writer :parent

      def initialize()
        @rendered_childs = {}
      end

      def get_template_path(language)
        normalized_name = self.class.name.split('::').last.downcase
        "templates/#{language}/#{normalized_name}.erb"
      end

      def read_template(language)
        File.new(get_template_path(language)).read
      end

      def render_childs(language, context = {})
        if @rendered_childs.size > 0
          return
        end

        @childs.each do |key, child|
          if child.is_a? Array
            @rendered_childs[key] = child.map {|c| c.render(language, context) }
            next
          end

          if child.methods.include? :render
            @rendered_childs[key] = child.render(language, context)
          else
            @rendered_childs[key] = child
          end
        end
        post_render_childs(context)
      end

      def post_render_childs(context = {})
      end

      def render(language = 'ruby', context = {})
        render_childs(language, context)
        ERB.new(read_template(language), nil, "%<>").result(binding)
      end

      def indent_block(nodes, indentation = '  ')
        nodes.map do |node|
          node.split("\n").map do |line|
            "#{indentation}#{line}\n"
          end.join
        end.join
      end
    end

    class Literal < Node
      def initialize(value)
        super()
        @childs = {:value => value}
      end
    end

    class NullLiteral < Node
      def initialize
        super()
        @childs = {}
      end
    end

    class StringLiteral < Literal
    end

    class NumericLiteral < Literal
    end

    class BooleanLiteral < Literal
    end

    class Variable < Node
      def initialize(name)
        super()
        @childs = {:name => name}
      end
    end

    class Property < Node
      def initialize(key, value)
        super()
        @childs = {:key => key, :value => value}
      end
    end

    class Field < Node
      def initialize(base, name)
        super()
        @childs = {:base => base, :name => name}
      end
    end

    class Index < Node
      def initialize(base, expression)
        super()
        @childs = {:base => base, :expression => expression}
      end
    end

    class BinaryExpression < Node
      def initialize(left, operator, right)
        super()
        @childs = {:operator => operator, :left => left, :right => right}
      end
    end

    class UnaryExpression < Node
      def initialize(operator, expression)
        super()
        @childs = {:operator => operator, :expression => expression}
      end
    end

    class Parenthesis < Node
      def initialize(content)
        super()
        @childs = {:content => content}
      end
    end

    class List < Node
      def initialize(items)
        super()
        @childs = {:items => items}
      end
    end

    class Dict < Node
      def initialize(items)
        super()
        @childs = {:items => items}
      end
    end

    class Template < Node
      def initialize(chunks)
        super()
        @childs = {:chunks => chunks}
      end

      def post_render_childs(context = {})
        @rendered_childs[:chunks] = @childs[:chunks].map do |chunk|
          if chunk.is_a? Zest::Nodes::Variable
            "\#{#{chunk.childs[:name]}}"
          else
            "#{chunk.childs[:value]}"
          end
        end
      end
    end

    class Assign < Node
      def initialize(to, value)
        super()
        @childs = {:to => to, :value => value}
      end
    end

    class Argument < Node
      def initialize(name, value)
        super()
        @childs = {:name => name, :value => value}
      end
    end

    class Call < Node
      def initialize(actionword, arguments = [])
        super()
        @childs = {:actionword => actionword, :arguments => arguments}
      end

      def post_render_childs(context = {})
        if context.has_key?(:call_prefix)
          @rendered_childs[:call_prefix] = context[:call_prefix]
        end
      end
    end

    class IfThen < Node
      def initialize(condition, then_, else_ = [])
        super()
        @childs = {:condition => condition, :then => then_, :else => else_}
      end
    end

    class Step < Node
      def initialize(properties)
        super()
        @childs = {:properties => properties}
      end

      def post_render_childs(context = {})
        first_property = @childs[:properties].first
        @rendered_childs[:key] = first_property.rendered_childs[:key]
        @rendered_childs[:value] = first_property.rendered_childs[:value]
      end
    end

    class While < Node
      def initialize(condition, body)
        super()
        @childs = {:condition => condition, :body => body}
      end
    end

    class Tag < Node
      def initialize(key, value = nil)
        super()
        @childs = {:key => key, :value => value}
      end
    end

    class Parameter < Node
      def initialize(name, default = nil)
        super()
        @childs = {:name => name, :default => default}
      end
    end

    class Item < Node
      def initialize(name, tags = [], parameters = [], body = [])
        super()
        @childs = {
          :name => name,
          :tags => tags,
          :parameters => parameters,
          :body => body
        }
      end
    end

    class Actionword < Item
    end

    class Scenario < Item
      def initialize(name, description = '', tags = [], parameters = [], body = [])
        super(name, tags, parameters, body)
        @childs[:description] = description
      end
    end

    class Actionwords < Node
      def initialize(actionwords)
        super()
        @childs = {:actionwords => actionwords}
      end
    end

    class Scenarios < Node
      def initialize(scenarios)
        super()
        @childs = {:scenarios => scenarios}
      end

      def post_render_childs(context = {})
        if context.has_key?(:call_prefix)
          @rendered_childs[:call_prefix] = context[:call_prefix]
        end
      end
    end

    class Project < Node
      def initialize(name, description = '', scenarios = nil, actionwords = nil)
        super()
        unless scenarios.nil?
          scenarios.parent = self
        end

        @childs = {
          :name => name,
          :description => description,
          :scenarios => scenarios,
          :actionwords => actionwords
        }
      end
    end
  end
end