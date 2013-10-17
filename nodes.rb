require 'erb'

module Zest
  module Nodes
    class Node
      attr_reader :childs, :rendered_childs

      def read_template(language)
        path = "templates/#{language}/#{self.class.name.downcase}.erb"
        File.new(path).read
      end

      def render_childs(language)
        @rendered_childs = {}

        @childs.each do |key, child|
          if child.is_a? List
            @rendered_childs[key] = child.map {|c| c.render }
            next
          end

          if child.methods.include? :render
            @rendered_childs[key] = child.render(language)
          else
            @rendered_childs[key] = child
          end
        end
      end

      def render(language)
        render_childs(language)
        ERB.new(read_template(language), nil, "%").result
      end
    end

    class Literal < Node
      def initialize(value)
        @childs = {:value => value}
      end
    end

    class NullLiteral < Literal
    end

    class StringLiteral < Literal
    end

    class NumericLiteral < Literal
    end

    class BooleanLiteral < Literal
    end

    class Variable < Node
      def initialize(name)
        @childs = {:name => name}
      end
    end

    class Property < Node
      def initialize(key, value)
        @childs = {:key => key, :value => value}
      end
    end

    class Field < Node
      def initialize(base, name)
        @childs = {:base => base, :name => name}
      end
    end

    class Index < Node
      def initialize(base, expression)
        @childs = {:base => base, :expression => expression}
      end
    end

    class BinaryExpression < Node
      def initialize(operator, left, right)
        @childs = {:operator => operator, :left => left, :right => right}
      end
    end

    class UnaryExpression < Node
      def initialize(operator, expression)
        @childs = {:operator => operator, :expression => expression}
      end
    end

    class Parenthesis < Node
      def initialize(content)
        @childs = {:content => content}
      end
    end

    class List < Node
      def initialize(items)
        @childs = {:items => items}
      end
    end

    class Dict < Node
      def initialize(items)
        @childs = {:items => items}
      end
    end

    class Template < Node
      def initialize(chunks)
        @childs = {:chunks => chunks}
      end

      def render_childs(language)
        super()
        @rendered_childs[:chunks] = @childs[:chunks].map do |chunk|
          if chunk.is_a? Variable
            "\#{#{chunk.name}}"
          else
            "#{chunk.value}"
          end
        end
      end
    end

    class Assign < Node
      def initialize(to, value)
        @childs = {:to => to, :value => value}
      end
    end

    class Call < Node
      def initialize(name, arguments)
        @childs = {:name => name, :arguments => arguments}
      end
    end

    class IfThen < Node
      def initialize(condition, then_, else_)
        @childs = {:condition => condition, :then => then_, :else => else_}
      end
    end

    class Step < Node
      def initialize(properties)
        @childs = {:properties => properties}
      end

      def render_childs(language)
        super()
        firstProperty = @rendered_childs.first
        @rendered_childs[:key] = firstProperty.rendered_childs[:key]
        @rendered_childs[:value] = firstProperty.rendered_childs[:value]
      end
    end

    class While < Node
      def initialize(condition, body)
        @childs = {:condition => condition, :body => body}
      end
    end

    class Tag < Node
      def initialize(key, value)
        @childs = {:key => key, :value => value}
      end
    end

    class Parameter < Node
      def initialize(name, default)
        @childs = {:name => name, :default => default}
      end
    end

    class Item < Node
      def initialize(name, tags, parameters, body)
        @childs = {
          :name => name,
          :tags => tags,
          :parameters => parameters,
          :body => body
        }
    end

    class Actionword < Item
    end

    class Scenario < Item
      def initialize(name, description, tags, parameters, body)
        super(name, tags, parameters, body)
        @childs[:description] => description
      end
    end

    class Actionwords < Node
      def initialize(action_words)
        @childs = {:actionwords => actionwords}
      end
    end

    class Scenarios < Node
      def initialize(scenarios)
        @childs = {:scenarios => scenarios}
      end
    end

    class Project < Node
      def initialize(name, description, scenarios, actionwords)
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