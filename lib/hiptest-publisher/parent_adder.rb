require 'hiptest-publisher/nodes_walker'

module Hiptest
  module Nodes
    class ParentAdder
      def self.add(project)
        Hiptest::Nodes::ParentAdder.new.process(project)
      end

      def process(node)
        node.each_direct_children {|child|
          child.parent ||= node
          process(child)
        }
      end
    end
  end
end
