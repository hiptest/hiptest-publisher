require 'handlebars'
require 'zest-publisher/nodes_walker'
require 'zest-publisher/handlebars_helper'

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
      Zest::HandlebarsHelper.register_helpers(@handlebars, @context)
    end

    def call_node_walker(node)
      if node.is_a? Zest::Nodes::Node
        @rendered_children = {}
        node.children.each {|name, child| @rendered_children[name] = @rendered[child]}

        render_context = super(node)
        @rendered[node] = render_node(node, render_context)
      elsif node.is_a? Array
        @rendered[node] = node.map {|item| @rendered[item]}
      else
        @rendered[node] = node
      end
    end

    def render_node(node, render_context = {})
      handlebars_template = get_template_path(node, 'hbs')

      if handlebars_template.nil?
        render_erb(node, get_template_path(node, 'erb'), render_context)
      else
        render_handlebars(node, handlebars_template, render_context)
      end
    end

    def render_erb(node, template, render_context)
      ERB.new(File.read(template), nil, "%<>").result(binding)
    end

    def render_handlebars(node, template, render_context)
      render_context = {} if render_context.nil?
      render_context[:node] = node
      render_context[:rendered_children] = @rendered_children
      render_context[:context] = @context

      @handlebars.compile(File.read(template)).send(:call, render_context)
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

    def walk_actionword(aw)
      {
        :has_parameters? => aw.has_parameters?,
        :has_tags? => !aw.children[:tags].empty?,
        :has_step? => aw.has_step?,
        :is_empty? => aw.children[:body].empty?
      }
    end

    def walk_scenario(sc)
      {
        :has_parameters? => sc.has_parameters?,
        :has_tags? => !sc.children[:tags].empty?,
        :is_empty? => sc.children[:body].empty?
      }
    end

    def walk_call(c)
      {
        :has_arguments? => !c.children[:arguments].empty?
      }
    end

    def walk_ifthen(it)
      {
        :has_else? => !it.children[:else].empty?
      }
    end

    def walk_parameter(p)
      {
        :has_default_value? => !p.children[:default].nil?
      }
    end

    def walk_tag(t)
      {
        :has_value? => !t.children[:value].nil?
      }
    end

    def walk_template(t)
      treated = t.children[:chunks].map do |chunk|
        {
          :is_variable? => chunk.is_a?(Zest::Nodes::Variable),
          :raw => chunk
        }
      end
      variable_names = treated.map {|item| item[:raw].children[:name] if item[:is_variable?]}.compact

      {
        :treated_chunks => treated,
        :variable_names => variable_names
      }
    end
  end
end