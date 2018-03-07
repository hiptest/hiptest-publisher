require 'hiptest-publisher/nodes_walker'

module Hiptest
  module NodeModifiers
    class ParentAdder
      def self.add(project)
        self.new.process(project)
      end

      def process(node)
        node.each_direct_children do |child|
          child.parent ||= node
          process(child)
        end
      end
    end
  end
end
