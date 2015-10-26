require 'hiptest-publisher/nodes_walker'

module Hiptest
  module Nodes
    class ParameterTypeAdder
      attr_reader :call_types

      def self.add(project)
        Hiptest::Nodes::ParameterTypeAdder.new.process(project)
      end

      def initialize
        @call_types = CallTypes.new
      end

      def process(project)
        gather_scenarios_argument_types(project)
        gather_call_argument_types(project)
        write_parameter_types(project)
      end

      def gather_scenarios_argument_types(project)
        project.children[:scenarios].children[:scenarios].each do |scenario|
          @call_types.add_callable_item(scenario.children[:name])
          add_arguments_from(scenario.children[:datatable])
        end
      end

      def gather_call_argument_types(project)
        project.each_sub_nodes(Call) do |call|
          @call_types.add_callable_item(call.children[:actionword])
          add_arguments_from(call)
        end
      end

      def write_parameter_types(project)
        project.each_sub_nodes(Actionword, Scenario) do |callable_item|
          callable_item.each_sub_nodes(Parameter) do |parameter|
            parameter.children[:type] = @call_types.type_of(callable_item.children[:name], parameter.children[:name])
          end
        end
      end

      def add_arguments_from(node)
        node.each_sub_nodes(Argument) do |argument|
          @call_types.add_argument_type(argument.children[:name], get_type(argument))
        end
      end

      private

      def get_type(node)
        value = node.children[:value]
        case value
          when StringLiteral, Template then :String
          when NumericLiteral then value.children[:value].include?(".") ? :float : :int
          when BooleanLiteral then :bool
          else :null
        end
      end
    end

    class CallTypes
      def initialize
        @callable_items = {}
        @current_callable_item = nil
      end

      def add_callable_item(name)
        @callable_items[name] ||= {}
        @current_callable_item = @callable_items[name]
      end

      def add_argument_type(name, type)
        @current_callable_item[name] ||= {types: Set.new}
        @current_callable_item[name][:types] << type
      end

      def type_of(item_name, parameter_name)
        callable_item =  @callable_items[item_name]
        return :String if callable_item.nil?
        parameter = callable_item[parameter_name]

        return :String if parameter.nil?
        return type_from_types(parameter[:types])
      end

      private

      def type_from_types(types)
        types = types - [:null]
        if types.empty?
          :null
        elsif types.length == 1
          types.first
        elsif types == Set[:float, :int]
          :float
        else
          :String
        end
      end
    end
  end
end
