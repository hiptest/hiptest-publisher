require 'handlebars'
require 'zest-publisher/nodes_walker'
require 'zest-publisher/handlebars_helper'
require 'zest-publisher/render_context_maker'

module Zest
  class Renderer < Zest::Nodes::Walker
    attr_reader :rendered
    include RenderContextMaker

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
      Zest::HandlebarsHelper.register_helpers(@handlebars, @context)
    end

    def call_node_walker(node)
      if node.is_a? Zest::Nodes::Node
        @rendered_children = {}
        node.children.each {|name, child| @rendered_children[name] = @rendered[child]}
        @rendered[node] = render_node(node, super(node))
      elsif node.is_a? Array
        @rendered[node] = node.map {|item| @rendered[item]}
      else
        @rendered[node] = node
      end
    end

    def render_node(node, render_context)
      render_context = {} if render_context.nil?
      render_context[:node] = node
      render_context[:rendered_children] = @rendered_children
      render_context[:context] = @context

      template = get_template_path(node)

      @handlebars.compile(File.read(template)).send(:call, render_context)
    end

    def get_template_path(node, extension = 'hbs')
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
  end
end