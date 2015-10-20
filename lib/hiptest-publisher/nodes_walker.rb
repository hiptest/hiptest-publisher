module Hiptest
  module Nodes
    class Walker
      private

      def walk_children(node)
        return unless node.is_a? Hiptest::Nodes::Node
        node.children.values.each {|child| walk_node(child)}
      end

      def call_node_walker(node)
        return unless node.is_a? Hiptest::Nodes::Node

        node_class = node.class.name.split('::').last.downcase
        walk_method_name = "walk_#{node_class}".to_sym

        if respond_to? walk_method_name
          self.send(walk_method_name, node)
        end
      end
    end

    class ParentFirstWalker < Walker
      def walk_node(node)
        call_node_walker(node)
        node.each {|item| walk_node(item)} if node.is_a? Array

        walk_children(node)
      end
    end

    class ChildrenFirstWalker < Walker
      def walk_node(node)
        walk_children(node)

        node.each {|item| walk_node(item)} if node.is_a? Array
        call_node_walker(node)
      end
    end
  end
end
