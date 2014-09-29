require 'zest-publisher/nodes'

module Zest
  class DefaultArgumentAdder
    def self.add(project)
      DefaultArgumentAdder.new(project).update_calls
    end

    def initialize(project)
      @project = project
      @indexer = ActionwordIndexer.new(project)
    end

    def update_calls
      @project.find_sub_nodes(Zest::Nodes::Call).each do |call|
        aw_data = @indexer.get_index(call.children[:actionword])
        next if aw_data.nil?

        arguments = {}
        call.children[:arguments].each do |arg|
          arguments[arg.children[:name]] = arg.children[:value]
        end

        call.children[:all_arguments] = aw_data[:parameters].map do |p_name, default_value|
          Zest::Nodes::Argument.new(
            p_name,
            arguments.has_key?(p_name) ? arguments[p_name] : default_value
          )
        end
      end
    end
  end

  class ActionwordIndexer
    def initialize(project)
      @project = project
      @indexed = {}
      index_actionwords
    end

    def index_actionwords
      @project.find_sub_nodes(Zest::Nodes::Actionword).each do |aw|
        aw_name = aw.children[:name]
        indexed_parameters = {}

        aw.children[:parameters].map do |param|
          param_name = param.children[:name]
          indexed_parameters[param_name] = param.children[:default]
        end

        @indexed[aw_name] = {
          :actionword => aw,
          :parameters => indexed_parameters
        }

      end
    end

    def get_index(name)
      @indexed[name]
    end
  end
end