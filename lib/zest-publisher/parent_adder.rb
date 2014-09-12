module Zest
  module Nodes
    class ParentAdder < Walker
      def walk_node(node)
        node.chidren.each {|child| child.parent = node if node.is_a? Zest::Nodes::Node}
      end
    end
  end
end