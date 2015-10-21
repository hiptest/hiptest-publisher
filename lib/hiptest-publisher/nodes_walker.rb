module Hiptest
  module Nodes
    class Walker
      private

      def walk_children(node)
        return unless node.is_a? Hiptest::Nodes::Node
        node.children.each_value {|child| walk_node(child)}
      end

      def call_node_walker(node)
        return unless node.is_a? Hiptest::Nodes::Node

        if respond_to? walk_method_name(node)
          self.send(walk_method_name(node), node)
        end
      end

      def walk_method_name(node)
        walk_method_names[node.class] ||= "walk_#{node.kind}".to_sym
      end

      def walk_method_names
        @walk_method_names ||= {}
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
