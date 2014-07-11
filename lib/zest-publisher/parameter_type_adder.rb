require 'zest-publisher/nodes_walker'

module Zest
  module Nodes
    class ParameterTypeAdder < Zest::Nodes::Walker
      def self.add(project)
        adder = Zest::Nodes::ParameterTypeAdder.new
        adder.walk_project(project)
      end

      def walk_project(project)
        @acc = []
        @call_types = CallTypes.new
        super(project)
        type_writer = TypeWriter.new(@call_types)
        type_writer.walk_project(project)
      end

      def walk_call(call)
        super(call)
        @acc.pop
      end

      def walk_name(name)
        @acc.push(name)
      end

      def walk_nullliteral literal
        argument_name = @acc.pop
        @call_types.add_types(@acc.last, argument_name, :null)
      end

      def walk_value(value)
        @acc.push(value)
      end

      def walk_stringliteral(string)
        argument_name = @acc.pop
        @call_types.add_types(@acc.last, argument_name, :String)
      end

      def walk_template(template)
        argument_name = @acc.pop
        @call_types.add_types(@acc.last, argument_name, :String)
      end

      def walk_booleanliteral(boolean)
        argument_name = @acc.pop
        @call_types.add_types(@acc.last, argument_name, :bool)
      end

      def walk_numericliteral(numericliteral)
        super(numericliteral)
        value = @acc.pop
        argument_name = @acc.pop
        if value.include?('.')
          @call_types.add_types(@acc.last, argument_name, :float)
        else
          @call_types.add_types(@acc.last, argument_name, :int)
        end
      end
    end

    class TypeWriter < Zest::Nodes::Walker
      def initialize(call_types)
        @call_types = call_types
      end

      def walk_project project
        @acc = []
        super(project)
      end

      def walk_actionword actionword
        @acc.push actionword.name
        super(actionword)
        @acc.pop
      end

      def walk_parameter parameter
        actionword_name = @acc.last
        piou = @call_types.type_of(actionword_name, parameter.name)
        parameter.children[:type] = piou
      end
    end

    class CallTypes

      def initialize
        @types = Hash.new(Hash.new([]))
      end

      def add_types(actionword_name, argument_name, type)
        known_types = @types[actionword_name][argument_name]
        unless known_types.include?(type)
          if @types[actionword_name].empty?
            @types[actionword_name] = Hash.new([])
          end
          if @types[actionword_name][argument_name].empty?
            @types[actionword_name][argument_name] = [type]
          else
            @types[actionword_name][argument_name] << type
          end
        end
      end

      def type_of(actionword_name, parameter_name)
        known_types = @types[actionword_name][parameter_name]
        if known_types.size == 1
          known_types.first
        else
          without_null = known_types.select{|t| t != :null}
          if without_null.size == 1
            without_null.first
          elsif without_null.size == 2 && without_null.include?(:int) && without_null.include?(:float)
            :float
          else
            :String
          end
        end
      end

      def to_s
        @types
      end
    end
  end
end