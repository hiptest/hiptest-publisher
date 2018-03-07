module Hiptest
  class ActionwordIndexer
    def initialize(project)
      @project = project
      @indexed = {}
      index_actionwords
    end

    def index_actionwords
      @project.each_sub_nodes(Hiptest::Nodes::Actionword) do |aw|
        aw_name = aw.children[:name]
        indexed_parameters = {}

        aw.children[:parameters].map do |param|
          param_name = param.children[:name]
          indexed_parameters[param_name] = param.children[:default]
        end

        @indexed[aw_name] = {
          actionword: aw,
          parameters: indexed_parameters
        }

      end
    end

    def get_index(name)
      @indexed[name]
    end
  end
end
