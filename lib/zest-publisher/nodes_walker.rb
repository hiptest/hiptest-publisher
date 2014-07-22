module Zest
  module Nodes
    class Walker
      def initialize(order = :parent_first)
        @order = order
      end

      def walk_node(node)
        self.send(@order, node)
      end

      private

      def walk_children(node)
        return unless node.is_a? Zest::Nodes::Node
        node.children.values.each {|child| walk_node(child)}
      end

      def call_node_walker(node)
        return unless node.is_a? Zest::Nodes::Node

        node_class = node.class.name.split('::').last.downcase
        walk_method_name = "walk_#{node_class}".to_sym

        if self.methods.include? walk_method_name
          self.send(walk_method_name, node)
        end
      end

      def parent_first(node)
        call_node_walker(node)
        node.each {|item| walk_node(item)} if node.is_a? Array

        walk_children(node)
      end

      def children_first(node)
        walk_children(node)

        node.each {|item| walk_node(item)} if node.is_a? Array
        call_node_walker(node)
      end
    end
  end
end