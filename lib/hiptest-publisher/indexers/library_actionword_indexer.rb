module Hiptest
  class LibraryActionwordIndexer
    def initialize(project)
      @project = project
      @indexed = {}
      index_library_actionwords
    end

    def index_library_actionwords
      @project.each_sub_nodes(Hiptest::Nodes::LibraryActionword) do |aw|
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
      end
    end

    def get_index(name)
      @indexed[name]
    end
  end
end
