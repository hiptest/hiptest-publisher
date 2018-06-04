require 'ruby-handlebars'

require 'hiptest-publisher/nodes_walker'
require 'hiptest-publisher/render_context_maker'

module Hiptest
  class Renderer < Hiptest::Nodes::Walker
    attr_reader :rendered
    include RenderContextMaker

    def self.render(node, context)
      renderer = self.new(context)
      context.renderer_addons.each do |addon|
        renderer.singleton_class.include(addon)
      end
      renderer.walk_node(node)
      renderer.rendered[node]
    end

    def initialize(context)
      @rendered = {}
      @context = context
      @template_finder = context.template_finder
    end

    def walk_call(call)
      # For Gherkin, we need the special arguments rendered.
      if call.free_text_arg
        @rendered_children[:free_text_arg] = @rendered[call.free_text_arg.children[:value]]
      end

      if call.datatable_arg
        @rendered_children[:datatable_arg] = @rendered[call.datatable_arg.children[:value]]
      end

      super(call)
    end

    def walk_actionword(aw)
      add_splitted_tags(aw)
      super(aw)
    end

    def walk_folder(folder)
      ancestor_tags = folder.ancestors.map {|f| f.children[:tags]}.flatten.uniq
      @rendered_children[:ancestor_tags] = ancestor_tags.map {|t| Hiptest::Renderer.render(t, @context)}

      super(folder)
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

    def render_node(node, render_context)
      render_context ||= {}
      render_context[:node] = node
      render_context[:rendered_children] = @rendered_children
      render_context[:context] = @context

      @template_finder.get_compiled_handlebars(node.kind).call(render_context)
    end

    private

    def add_splitted_tags(context)
      @rendered_children[:splitted_tags] = context.children[:tags].map do |tag|
        @rendered[tag]
      end
    end
  end
end
