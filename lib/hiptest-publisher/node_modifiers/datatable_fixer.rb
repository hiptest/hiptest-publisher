require 'hiptest-publisher/nodes_walker'

module Hiptest
  module NodeModifiers
    class DatatableFixer < Nodes::Walker
      def self.add(project)
        self.new.walk_node(project)
      end

      def walk_scenario(scenario)
        return if scenario.children[:datatable].nil?

        @argument_names = scenario.children[:parameters].map{|param| param.children[:name]}

        scenario.children[:datatable].children[:datasets].map do |dataset|
          arguments_mapping = {}
          dataset.children[:arguments].map do |arg|
            arguments_mapping[arg.children[:name]] = arg
          end

          dataset.children[:arguments] = @argument_names.map do |arg_name|
            if arguments_mapping.has_key?(arg_name)
              arguments_mapping[arg_name]
            else
              Hiptest::Nodes::Argument.new(arg_name, Hiptest::Nodes::StringLiteral.new(''))
            end
          end
        end
      end
    end
  end
end
