require 'zest-publisher/nodes_walker'

module Zest
  module Nodes
    class ParameterTypeAdder < Zest::Nodes::Walker
      attr_reader :call_types

      def self.add(project)
        walker = Zest::Nodes::ParameterTypeAdder.new
        walker.walk_node(project)

        Zest::Nodes::TypeWriter.new(walker.call_types).walk_node(project)
      end

      def initialize
        super(:parent_first)
      end

      def walk_project(project)
        @call_types = CallTypes.new
      end

      def walk_call(call)
        @call_types.add_actionword(call.children[:actionword])
      end

      def walk_argument(arg)
        get_literal_values(arg).each {|value|
          @call_types.add_argument(arg.children[:name], value[0], value[1])
        }
      end

      def walk_actionword(actionword)
        @call_types.add_actionword(actionword.children[:name])
      end

      private

      def get_literal_values(node)
        literals = node.find_sub_nodes([StringLiteral, NumericLiteral, BooleanLiteral])

        return [[NullLiteral, nil]] if literals.empty?
        literals.map {|literal| [literal.class, literal.children[:value]]}
      end
    end

    class TypeWriter < Zest::Nodes::Walker
      def initialize(call_types)
        super(:parent_first)
        @call_types = call_types
        @actionword_name = nil
      end

      def walk_actionword actionword
        @actionword_name = actionword.children[:name]
      end

      def walk_parameter parameter
        parameter.children[:type] = @call_types.type_of(@actionword_name, parameter.children[:name])
      end
    end

    class CallTypes
      def initialize
        @actionwords = {}
        @current = nil
      end

      def select_actionword(name)
        @current = @actionwords[name]
      end

      def add_actionword(name)
        @actionwords[name] = {} unless @actionwords.keys.include?(name)
        select_actionword(name)
      end

      def add_argument(name, type, value)
        add_parameter(name)
        @current[name][:values] << {type: type, value: value}
      end

      def add_default_value(name, type, value)
        add_parameter(name)
        @current[name][:default] = {type: type, value: value}
      end

      def type_of(actionword_name, parameter_name)
        return unless @actionwords.keys.include?(actionword_name)
        parameter =  @actionwords[actionword_name][parameter_name]

        return :String if parameter.nil? || parameter[:values].empty?
        return type_from_values(parameter[:values])
      end

      private

      def add_parameter(name)
        return if @current.keys.include?(name)
        @current[name] = {default: nil, values: []}
      end

      def type_from_values(values)
        types = values.map {|val| val[:type] unless val[:type] == Zest::Nodes::NullLiteral}.compact.uniq

        if types.empty?
          :null
        elsif types.length == 1
          if types.first == Zest::Nodes::StringLiteral
            :String
          elsif types.first == Zest::Nodes::BooleanLiteral
            :bool
          elsif types.first == Zest::Nodes::NumericLiteral
            determine_numeric(values)
          end
        else
          :String
        end
      end

      def determine_numeric(values)
        types = values.map do |val|
          next unless val[:type] == Zest::Nodes::NumericLiteral
          return :float if val[:value].include?(".")
        end.compact.uniq

        :int
      end
    end
  end
end