require 'hiptest-publisher/nodes'

module Hiptest
  module NodeModifiers
    class ItemsOrderer
      def self.add(project, order)
        self.new(project).order_items(order)
      end

      def initialize(project)
        @project = project
      end

      def order_items(order)
        if (order == 'order')
          @project.each_sub_nodes(Hiptest::Nodes::Folder) do |folder|
            folder.children[:scenarios].sort_by! {|sc| sc.order_in_parent}
            folder.children[:subfolders].sort_by! {|f| f.order_in_parent}
          end
        end

        if (order == 'alpha')
          @project.each_sub_nodes(Hiptest::Nodes::Folder) do |folder|
            folder.children[:scenarios].sort_by! {|sc| sc.children[:name] }
            folder.children[:subfolders].sort_by! {|f| f.children[:name] }
          end

          @project.children[:scenarios].children[:scenarios].sort_by! {|sc| sc.children[:name] }
        end
      end
    end
  end
end
