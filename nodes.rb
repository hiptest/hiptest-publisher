require 'erb'

require_relative 'string'
require_relative 'utils'

module Zest
  module Nodes
    class Node
      attr_reader :childs, :rendered, :rendered_childs, :parent
      attr_writer :parent

      def initialize()
        @rendered = ''
        @rendered_childs = {}
      end

      def get_template_path(language, context = {})
        normalized_name = self.class.name.split('::').last.downcase

        searched_folders = []
        if context.has_key?(:framework)
          searched_folders << "#{language}/#{context[:framework]}"
        end
        searched_folders << [language, 'common']

        searched_folders.flatten.map do |path|
          template_path = "templates/#{path}/#{normalized_name}.erb"
          if File.file?(template_path)
            template_path
          end
        end.compact.first
      end

      def read_template(language, context = {})
        File.read(get_template_path(language, context))
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
        @rendered = ERB.new(read_template(language, context), nil, "%<>").result(binding)
        @rendered
      end

      def indent_block(nodes, indentation = '  ')
        nodes.map do |node|
          node.split("\n").map do |line|
            "#{indentation}#{line}\n"
          end.join
        end.join
      end

      def find_sub_nodes(type = nil, flatten = true)
        sub_nodes = @childs.map do |key, child|
          build_sub_node(child, type)
        end.compact

        if type.nil? || self.is_a?(type)
          result = [self, sub_nodes]
        else
          result = sub_nodes
        end

        flatten ? result.flatten : result
      end

      private

      def build_sub_node (node, type)
        if node.is_a?(Node)
          node.find_sub_nodes(type, flatten = false)
        elsif node.is_a?(Array)
          node.map {|item| build_sub_node(item, type)}.compact
        end
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

      def has_arguments?
        !@childs[:arguments].empty?
      end
    end

    class IfThen < Node
      def initialize(condition, then_, else_ = [])
        super()
        @childs = {:condition => condition, :then => then_, :else => else_}
      end
    end

    class Step < Node
      def initialize(key, value)
        super()
        @childs = {:key => key, :value => value}
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
      attr_reader :variables, :non_valued_parameters, :valued_parameters

      def initialize(name, tags = [], parameters = [], body = [])
        super()
        @childs = {
          :name => name,
          :tags => tags,
          :parameters => parameters,
          :body => body
        }
      end

      def post_render_childs(context = {})
        save_parameters_by_type
        find_variables
      end

      def has_parameters?
        !@childs[:parameters].empty?
      end

      private

      def find_variables
        names = []

        @variables = find_sub_nodes(Zest::Nodes::Variable).map do |var_node|
          unless names.include?(var_node.childs[:name])
            names << var_node.childs[:name]
            var_node
          end
        end.compact
      end

      def save_parameters_by_type
        parameters = []
        valued_parameters = []
        childs[:parameters].each do |param|
          if param.childs[:default].nil?
            parameters << param
          else
            valued_parameters << param
          end
        end

        @non_valued_parameters = parameters
        @valued_parameters = valued_parameters
      end
    end

    class Actionword < Item
      def has_step?
        @childs[:body].each do |element|
          if element.instance_of?(Zest::Nodes::Step)
            return true
          end
        end
        false
      end
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