require 'hiptest-publisher/indexers/actionword_indexer'
require 'hiptest-publisher/nodes'

module Hiptest
  class DefaultArgumentAdder
    def self.add(project)
      DefaultArgumentAdder.new(project).update_calls
    end

    def initialize(project)
      @project = project
      @indexer = ActionwordIndexer.new(project)
    end

    def update_calls
      @project.each_sub_nodes(Hiptest::Nodes::Call) do |call|
        aw_data = @indexer.get_index(call.children[:actionword])
        next if aw_data.nil?

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
