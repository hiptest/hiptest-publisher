require 'zest-publisher/nodes_walker'

module Zest
  class Renderer < Zest::Nodes::Walker
    attr_reader :rendered

    def self.render(node, language, context)
      context[:language] = language
      renderer = Zest::Renderer.new(context)
      renderer.walk_node(node)
      renderer.rendered[node]
    end

    def initialize(context)
      super(:children_first)
      @rendered = {}
      @context = context
    end

    def call_node_walker(node)
      if node.is_a? Zest::Nodes::Node
        @rendered_children = {}
        node.children.each {|name, child| @rendered_children[name] = @rendered[child]}

        @rendered[node] = ERB.new(read_template(node), nil, "%<>").result(binding)
      elsif node.is_a? Array
        @rendered[node] = node.map {|item| @rendered[item]}
      else
        @rendered[node] = node
      end
    end

    def get_template_path(node)
      normalized_name = node.class.name.split('::').last.downcase

      searched_folders = []
      if @context.has_key?(:framework)
        searched_folders << "#{@context[:language]}/#{@context[:framework]}"
      end
      searched_folders << [@context[:language], 'common']

      searched_folders.flatten.map do |path|
        template_path = "#{zest_publisher_path}/lib/templates/#{path}/#{normalized_name}.erb"
        if File.file?(template_path)
          template_path
        end
      end.compact.first
    end

    def read_template(node)
      File.read(get_template_path(node))
    end

    def indent_block(nodes, indentation = nil, separator = '')
      indentation = indentation || @context[:indentation] || '  '

      nodes.map do |node|
        node ||= ""
        node.split("\n").map do |line|
          "#{indentation}#{line}\n"
        end.join
      end.join(separator)
    end
  end
end