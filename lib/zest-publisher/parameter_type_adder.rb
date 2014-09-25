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
        @call_types.add_callable_item(call.children[:actionword])
      end

      def walk_argument(arg)
        get_literal_values(arg).each {|value|
          @call_types.add_argument(arg.children[:name], value[0], value[1])
        }
      end

      def walk_actionword(actionword)
        @call_types.add_callable_item(actionword.children[:name])
      end

      def walk_scenario(scenario)
        @call_types.add_callable_item(scenario.children[:name])
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
        @callable_item_name = nil
      end

      def walk_actionword actionword
        @callable_item_name = actionword.children[:name]
      end

      def walk_scenario(scenario)
        @callable_item_name = scenario.children[:name]
      end

      def walk_parameter parameter
        parameter.children[:type] = @call_types.type_of(@callable_item_name, parameter.children[:name])
      end
    end

    class CallTypes
      def initialize
        @callable_items = {}
        @current = nil
      end

      def select_callable_item(name)
        @current = @callable_items[name]
      end

      def add_callable_item(name)
        @callable_items[name] = {} unless @callable_items.keys.include?(name)
        select_callable_item(name)
      end

      def add_argument(name, type, value)
        add_parameter(name)
        @current[name][:values] << {type: type, value: value}
      end

      def add_default_value(name, type, value)
        add_parameter(name)
        @current[name][:default] = {type: type, value: value}
      end

      def type_of(item_name, parameter_name)
        return unless @callable_items.keys.include?(item_name)
        parameter =  @callable_items[item_name][parameter_name]

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