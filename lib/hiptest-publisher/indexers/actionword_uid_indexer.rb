module Hiptest
  class ActionwordUidIndexer
    def initialize(project)
      @project = project
      @indexed = {}
      index_actionwords
    end

    def index_actionwords
      @project.children[:actionwords].children[:actionwords].each do |actionword|
        index_actionword(actionword)
      end

      @project.children[:libraries].children[:libraries].each do |library|
        library.children[:actionwords].each do |actionword|
          index_actionword(actionword, library: library)
        end
      end
    end

    def get_index(uid)
      @indexed[uid]
    end

    private

    def index_actionword(actionword, library: nil)
      @indexed[actionword.children[:uid]] = {
        actionword: actionword,
        library: library
      }
    end
  end
end
