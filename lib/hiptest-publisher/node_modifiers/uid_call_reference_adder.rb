require 'hiptest-publisher/indexers/actionword_uid_indexer'
require 'hiptest-publisher/nodes'

module Hiptest
  module NodeModifiers
    class UidCallReferencerAdder
      def self.add(project)
        self.new(project).update_uid_calls
      end

      def initialize(project)
        @project = project
        @indexer = ActionwordUidIndexer.new(project)
      end

      def update_uid_calls
        @project.each_sub_nodes(Hiptest::Nodes::UIDCall) do |uid_call|
          index = @indexer.get_index(uid_call.children[:uid])
          if index.nil?
            uid_call.children[:actionword_name] = "Unknown actionword with UID: #{uid_call.children[:uid]}"
            next
          end

          uid_call.children[:actionword_name] = index[:actionword].children[:name]
          uid_call.children[:library_name] = index[:library].children[:name] unless index[:library].nil?
        end
      end
    end
  end
end
