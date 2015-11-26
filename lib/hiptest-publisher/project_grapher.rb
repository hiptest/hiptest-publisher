require 'hiptest-publisher/nodes'

module Hiptest
  # Builds a graph based on calls and computes
  # longest path from the root.

  class ProjectGrapher
    attr_reader :graph, :distance_index

    def initialize(project)
      @project = project
      @graph = {}
    end

    def compute_graph
      add_nodes
      add_root
    end

    def add_distances
      add_node_weight(@graph[:root], [:root])
    end

    def index_by_distances
      @distance_index = Hash.new { |hash, key| hash[key] = [] }
      @graph.values.each do |value|
        @distance_index[value[:from_root]] << value[:item] unless value[:item].nil?
      end
    end

    private

    def add_nodes
      @project.each_sub_nodes(Hiptest::Nodes::Scenario, Hiptest::Nodes::Actionword) do |item|
        name = node_name(item)
        @graph[name] = {
          name: name,
          item: item,
          calls: [],
          from_root: -1
        }

        item.each_sub_nodes(Hiptest::Nodes::Call) do |call|
          aw_name = node_name(call.children[:actionword], Hiptest::Nodes::Actionword)
          @graph[name][:calls] << aw_name
        end
      end
    end

    def add_root
      @graph[:root] = {
        calls: [],
        from_root: 0
      }

      @project.each_sub_nodes(Hiptest::Nodes::Scenario) do |scenario|
        @graph[:root][:calls] << node_name(scenario)
      end
    end

    def add_node_weight(node, path)
      path << node[:name]

      node[:calls].map do |item_name|
        next if path.include?(item_name)

        called = @graph[item_name]
        next if called.nil?

        if called[:from_root] <= node[:from_root]
          called[:from_root] = node[:from_root] + 1
          add_node_weight(called, path)
        end
      end

      path.pop
    end

    def node_name(node, cls = nil)
      cls ||= node.class
      name = node.is_a?(Hiptest::Nodes::Node) ? node.children[:name] : node
      "#{cls}-#{name}"
    end
  end
end
