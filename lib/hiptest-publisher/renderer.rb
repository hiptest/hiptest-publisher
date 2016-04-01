require 'ruby-handlebars'

require 'hiptest-publisher/gherkin_adder'
require 'hiptest-publisher/nodes_walker'
require 'hiptest-publisher/handlebars_helper'
require 'hiptest-publisher/render_context_maker'

module Hiptest
  class Renderer < Hiptest::Nodes::Walker
    attr_reader :rendered
    include RenderContextMaker

    def self.render(node, context)
      renderer = Hiptest::Renderer.new(context)
      renderer.walk_node(node)
      renderer.rendered[node]
    end

    def initialize(context)
      @rendered = {}
      @context = context
      @template_finder = context.template_finder
    end

    def call_node_walker(node)
      if node.is_a? Hiptest::Nodes::Node
        @rendered_children = {}

        if node.is_a? Hiptest::Nodes::Folder
          # For Robot framework, we need direct access to every scenario
          # datatables and body rendered ....
          datatables = []
          scenarios = []

          node.children[:scenarios].each {|sc| 
            datatables << @rendered[sc.children[:datatable]]
            scenarios << {
              name: @rendered[sc.children[:name]],
              body: @rendered[sc.children[:body]]
            }
          }

          @rendered_children[:scenario_datatables] = datatables
          @rendered_children[:scenarios_content] = scenarios
        end

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
  end
end
