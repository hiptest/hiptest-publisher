require 'hiptest-publisher/nodes_walker'
require 'hiptest-publisher/handlebars'
require 'hiptest-publisher/handlebars_helper'
require 'hiptest-publisher/render_context_maker'

module Hiptest
  class Renderer < Hiptest::Nodes::Walker
    attr_reader :rendered
    include RenderContextMaker

    def self.render(node, language, context)
      context[:language] = language

      renderer = Hiptest::Renderer.new(context)
      renderer.walk_node(node)
      renderer.rendered[node]
    end

    def initialize(context)
      super(:children_first)
      @rendered = {}
      @context = context
      @handlebars = Hiptest::Handlebars::Context.new
      register_partials()

      Hiptest::HandlebarsHelper.register_helpers(@handlebars, @context)
    end

    def call_node_walker(node)
      if node.is_a? Hiptest::Nodes::Node
        @rendered_children = {}
        node.children.each {|name, child| @rendered_children[name] = @rendered[child]}
        @rendered[node] = render_node(node, super(node))
      elsif node.is_a? Array
        @rendered[node] = node.map {|item| @rendered[item]}
      else
        @rendered[node] = node
      end
    end

    def searched_folders()
      folders = []
      if @context.has_key?(:framework)
        folders << "#{@context[:language]}/#{@context[:framework]}"
      end
      folders << [@context[:language], 'common']
      folders = folders.flatten.map {|path| "#{hiptest_publisher_path}/lib/templates/#{path}"}

      if @context.has_key?(:overriden_templates)
        folders = folders.insert(0, @context[:overriden_templates])
      end
      return folders
    end

    def register_partials()
      searched_folders.reverse.each do |path|
        next unless File.directory?(path)
        Dir.entries(path).select do |file_name|
          file_path = File.join(path, file_name)
          next unless File.file?(file_path) && file_name.start_with?('_')
          @handlebars.register_partial(file_name[1..-5], File.read(file_path))
        end
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

    def get_template_by_name(name, extension)
      searched_folders.map do |path|
        template_path = File.join(path, "#{name}.#{extension}")
        template_path if File.file?(template_path)
      end.compact.first
    end

    def get_template_path(node, extension = 'hbs')
      normalized_name = node.class.name.split('::').last.downcase
      unless @context[:forced_templates][normalized_name].nil?
        normalized_name = @context[:forced_templates][normalized_name]
      end

      get_template_by_name(normalized_name, extension)
    end
  end
end