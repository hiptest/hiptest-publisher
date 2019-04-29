module Hiptest
  class ActionwordIndexer
    def initialize(project)
      @project = project
      @indexed = {}
      @uid_indexed = {}
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

        data = {
          actionword: aw,
          parameters: indexed_parameters
        }

        @indexed[aw_name] = data
        @uid_indexed[aw.children[:uid]] = data
      end
    end

    def get_index(name)
      @indexed[name]
    end

    def get_uid_index(uid)
      @uid_indexed[uid]
    end
  end
end
