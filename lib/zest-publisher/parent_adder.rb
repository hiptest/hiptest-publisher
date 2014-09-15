module Zest
  module Nodes
    class ParentAdder < Walker
      def self.add(project)
        Zest::Nodes::ParentAdder.new().walk_node(project)
      end

      def walk_node(node)
        super(node)
        return unless node.is_a? Zest::Nodes::Node

        node.direct_children.each {|child|
          child.parent = node
        }
      end
    end
  end
end