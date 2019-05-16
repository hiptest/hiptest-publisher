require 'hiptest-publisher/indexers/actionword_indexer'
require 'hiptest-publisher/indexers/library_actionword_indexer'
require 'hiptest-publisher/nodes'

module Hiptest
  module NodeModifiers
    class DefaultArgumentAdder
      def self.add(project)
        self.new(project).update_calls
      end

      def initialize(project)
        @project = project
        @library_indexer = LibraryActionwordIndexer.new(project)
        @indexer = ActionwordIndexer.new(project)
      end

      def update_calls
        @project.each_sub_nodes(Hiptest::Nodes::Call) do |call|
          actionword = @library_indexer.get_index(call.children[:actionword])
          actionword = @indexer.get_index(call.children[:actionword]) if actionword.nil?

          update_call(call, actionword)
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
