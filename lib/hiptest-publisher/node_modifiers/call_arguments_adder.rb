require 'hiptest-publisher/indexers/actionword_indexer'
require 'hiptest-publisher/nodes'

module Hiptest
  module NodeModifiers
    class DefaultArgumentAdder
      def self.add(project)
        self.new(project).update_all_calls
      end

      def initialize(project)
        @project = project
        @indexer = ActionwordIndexer.new(project)
      end

      def update_all_calls
        update_calls
        update_uid_calls
      end

      def update_calls
        @project.each_sub_nodes(Hiptest::Nodes::Call) do |call|
          update_call(call, @indexer.get_index(call.children[:actionword]))
        end
      end

      def update_uid_calls
        @project.each_sub_nodes(Hiptest::Nodes::UIDCall) do |uid_call|
          update_call(uid_call, @indexer.get_uid_index(uid_call.children[:uid]))
        end
      end

      private

      def update_call(call, aw_data)
        return if aw_data.nil?

        arguments = {}
        call.children[:arguments].each do |arg|
          arguments[arg.children[:name]] = arg.children[:value]
        end

        call.children[:all_arguments] = aw_data[:parameters].map do |p_name, default_value|
          Hiptest::Nodes::Argument.new(
            p_name,
            arguments.has_key?(p_name) ? arguments[p_name] : default_value
          )
        end
      end
    end
  end
end
