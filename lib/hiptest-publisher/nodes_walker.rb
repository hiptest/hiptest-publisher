module Hiptest
  module Nodes
    class Walker

      def walk_node(node)
        walk_children(node)

        node.each {|item| walk_node(item)} if node.is_a? Array
        call_node_walker(node)
      end

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

      WALK_METHOD_NAMES = {}

      def walk_method_name(node)
        WALK_METHOD_NAMES[node.class] ||= "walk_#{node.kind}".to_sym
      end
    end
  end
end
