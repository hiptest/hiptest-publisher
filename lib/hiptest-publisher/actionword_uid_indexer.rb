module Hiptest
  class ActionwordUidIndexer
    def initialize(project)
      @project = project
      @indexed = {}
      index_actionwords
    end

    def index_actionwords
      @project.children[:libraries].children[:libraries].each do |library|
        library.children[:actionwords].each do |actionword|
          @indexed[actionword.children[:uid]] = {
            actionword: actionword,
            library: library
          }
        end
      end
    end

    def get_index(uid)
      @indexed[uid]
    end
  end
end
