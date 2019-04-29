require 'hiptest-publisher/nodes_walker'
require 'hiptest-publisher/project_grapher'

module Hiptest
  module NodeModifiers
    class ParameterTypeAdder
      attr_reader :call_types

      def self.add(project)
        self.new.process(project)
      end

      def initialize
        @call_types = CallTypes.new
      end

      def process(project)
        gather_scenarios_argument_types(project)
        gather_actionwords_default_parameters_types(project)

        # To have the most accurate type, the closest calls must be computed
        # first, and deepest calls must be computed last (because they  depend
        # on previous calls types).
        distances_index = Hiptest::ProjectGrapher.distances_index(project)
        distances_index.each_value do |items|  # distances_index items are sorted by distance, from closest to deepest
          items.each do |item|
            write_parameter_types_to_item(item)
            gather_call_argument_types(item)
          end
        end
      end

      def gather_scenarios_argument_types(project)
        project.children[:scenarios].children[:scenarios].each do |scenario|
          @call_types.add_callable_item(scenario.children[:name], Hiptest::Nodes::Scenario)
          add_arguments_from(scenario.children[:datatable])
        end
      end

      def gather_actionwords_default_parameters_types(project)
        project.children[:actionwords].children[:actionwords].each do |actionword|
          @call_types.add_callable_item(actionword.children[:name], Hiptest::Nodes::Actionword)
          actionword.each_sub_nodes(Hiptest::Nodes::Parameter) do |parameter|
            default = parameter.children[:default]
            next if default.nil?
            @call_types.add_argument_type(parameter.children[:name], get_type(default))
          end
        end
      end

      def gather_call_argument_types(node)
        node.each_sub_nodes(Hiptest::Nodes::Call, Hiptest::Nodes::UIDCall) do |call|
          actionword_name = call.is_a?(Hiptest::Nodes::Call) ? call.children[:actionword] : call.children[:actionword_name]

          @call_types.add_callable_item(actionword_name, Hiptest::Nodes::Actionword)
          add_arguments_from(call, node)
        end
      end

      def write_parameter_types_to_item(callable_item)
        callable_item.each_sub_nodes(Hiptest::Nodes::Parameter) do |parameter|
          parameter.children[:type] = @call_types.type_of(callable_item.children[:name], parameter.children[:name], callable_item.class)
        end
      end

      def add_arguments_from(node, context = nil)
        node.each_sub_nodes(Hiptest::Nodes::Argument) do |argument|
          @call_types.add_argument_type(argument.children[:name], get_type(argument.children[:value], context))
        end
      end

      private

      def get_type(value, context = nil)
        case value
          when Hiptest::Nodes::StringLiteral, Hiptest::Nodes::Template then :String
          when Hiptest::Nodes::NumericLiteral then value.children[:value].to_s.include?(".") ? :float : :int
          when Hiptest::Nodes::BooleanLiteral then :bool
          when Hiptest::Nodes::Variable then get_var_value(value.children[:name], context)
          else :null
        end
      end

      def get_var_value(name, context)
        return :null if context.nil? || context.children[:parameters].nil?

        context.children[:parameters].each do |param|
          if param.children[:name] == name
            return param.children[:type] || :null
          end
        end

        return :null
      end
    end

    class CallTypes
      def initialize
        @callable_items = {}
        @current_callable_item = nil
      end

      def add_callable_item(item_name, item_type)
        name = "#{item_type}-#{item_name}"
        @callable_items[name] ||= {}
        @current_callable_item = @callable_items[name]
      end

      def add_argument_type(name, type)
        @current_callable_item[name] ||= {types: Set.new}
        @current_callable_item[name][:types] << type
      end

      def type_of(item_name, parameter_name, item_type)
        name = "#{item_type}-#{item_name}"
        callable_item =  @callable_items[name]
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
