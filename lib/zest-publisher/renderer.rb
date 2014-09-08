require 'handlebars'
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
      @handlebars = Handlebars::Context.new
      register_handlebars_helpers
    end

    def register_handlebars_helpers
      string_helpers = [
        :literate,
        :normalize,
        :underscore,
        :camelize,
        :camelize_lower]

      string_helpers.each do |helper|
        @handlebars.register_helper(helper) do |context, value|
          "#{value.send(helper)}"
        end
      end

      @handlebars.register_helper(:to_string) do |context, value|
        "#{value.to_s}"
      end
    end

    def call_node_walker(node)
      if node.is_a? Zest::Nodes::Node
        @rendered_children = {}
        node.children.each {|name, child| @rendered_children[name] = @rendered[child]}

        @rendered[node] = render_node(node)
      elsif node.is_a? Array
        @rendered[node] = node.map {|item| @rendered[item]}
      else
        @rendered[node] = node
      end
    end

    def render_node(node)
      handlebars_template = get_template_path(node, 'hbs')

      if handlebars_template.nil?
        render_erb(node, get_template_path(node, 'erb'))
      else
        render_handlebars(node, handlebars_template)
      end
    end

    def render_erb(node, template)
      ERB.new(File.read(template), nil, "%<>").result(binding)
    end

    def render_handlebars(node, template)
      @handlebars.compile(File.read(template)).call(node: node, rendered_children: @rendered_children)
    end

    def get_template_path(node, extension)
      normalized_name = node.class.name.split('::').last.downcase

      searched_folders = []
      if @context.has_key?(:framework)
        searched_folders << "#{@context[:language]}/#{@context[:framework]}"
      end
      searched_folders << [@context[:language], 'common']

      searched_folders.flatten.map do |path|
        template_path = "#{zest_publisher_path}/lib/templates/#{path}/#{normalized_name}.#{extension}"
        if File.file?(template_path)
          template_path
        end
      end.compact.first
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