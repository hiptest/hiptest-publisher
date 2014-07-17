require 'erb'

require 'zest-publisher/string'
require 'zest-publisher/utils'
require 'zest-publisher/renderer'

module Zest
  module Nodes
    class Node
      attr_reader :children, :rendered, :rendered_children, :parent
      attr_writer :parent

      def initialize
        @context = {}
        @rendered = ''
        @rendered_children = {}
      end

      def get_template_path(language)
        normalized_name = self.class.name.split('::').last.downcase

        searched_folders = []
        if @context.has_key?(:framework)
          searched_folders << "#{language}/#{@context[:framework]}"
        end
        searched_folders << [language, 'common']

        searched_folders.flatten.map do |path|
          template_path = "#{zest_publisher_path}/lib/templates/#{path}/#{normalized_name}.erb"
          if File.file?(template_path)
            template_path
          end
        end.compact.first
      end

      def read_template(language)
        File.read(get_template_path(language))
      end

      def render_children(language)
        if @rendered_children.size > 0
          return
        end

        @children.each do |key, child|
          if child.is_a? Array
            @rendered_children[key] = child.map {|c| c.render(language, @context) }
            next
          end

          if child.methods.include? :render
            @rendered_children[key] = child.render(language, @context)
          else
            @rendered_children[key] = child
          end
        end
        post_render_children()
      end

      def post_render_children()
      end

      def render(language = 'ruby', context = {})
        return Zest::Renderer.render(self, language, context)


        @context = context

        render_children(language)
        @rendered = ERB.new(read_template(language), nil, "%<>").result(binding)
        @rendered
      end

      def indent_block(nodes, indentation = nil, separator = '')
        indentation = indentation || @context[:indentation] || '  '

        nodes.map do |node|
          node.split("\n").map do |line|
            "#{indentation}#{line}\n"
          end.join
        end.join(separator)
      end

      def find_sub_nodes(types = [])
        sub_nodes = all_sub_nodes
        types = [types] unless types.is_a?(Array)

        if types.empty?
          sub_nodes
        else
          sub_nodes.keep_if do |node|
            types.map {|type| node.is_a?(type)}.include?(true)
          end
        end
      end

      private

      def all_sub_nodes
        path = [self]
        children = []

        until path.empty?
          current_node = path.pop

          if current_node.is_a?(Node)
            next if children.include? current_node

            children << current_node
            current_node.children.values.reverse.each {|item| path << item}
          elsif current_node.is_a?(Array)
            current_node.reverse.each {|item| path << item}
          end
        end
        children
      end
    end

    class Literal < Node
      def initialize(value)
        super()
        @children = {:value => value}
      end
    end

    class NullLiteral < Node
      def initialize
        super()
        @children = {}
      end
    end

    class StringLiteral < Literal
    end

    class NumericLiteral < Literal
    end

    class BooleanLiteral < Literal
    end

    class Variable < Node
      def initialize(name)
        super()
        @children = {:name => name}
      end
    end

    class Property < Node
      def initialize(key, value)
        super()
        @children = {:key => key, :value => value}
      end
    end

    class Field < Node
      def initialize(base, name)
        super()
        @children = {:base => base, :name => name}
      end
    end

    class Index < Node
      def initialize(base, expression)
        super()
        @children = {:base => base, :expression => expression}
      end
    end

    class BinaryExpression < Node
      def initialize(left, operator, right)
        super()
        @children = {:operator => operator, :left => left, :right => right}
      end
    end

    class UnaryExpression < Node
      def initialize(operator, expression)
        super()
        @children = {:operator => operator, :expression => expression}
      end
    end

    class Parenthesis < Node
      def initialize(content)
        super()
        @children = {:content => content}
      end
    end

    class List < Node
      def initialize(items)
        super()
        @children = {:items => items}
      end
    end

    class Dict < Node
      def initialize(items)
        super()
        @children = {:items => items}
      end
    end

    class Template < Node
      def initialize(chunks)
        super()
        @children = {:chunks => chunks}
      end
    end

    class Assign < Node
      def initialize(to, value)
        super()
        @children = {:to => to, :value => value}
      end
    end

    class Argument < Node
      def initialize(name, value)
        super()
        @children = {:name => name, :value => value}
      end
    end

    class Call < Node
      def initialize(actionword, arguments = [])
        super()
        @children = {:actionword => actionword, :arguments => arguments}
      end

      def has_arguments?
        !@children[:arguments].empty?
      end
    end

    class IfThen < Node
      def initialize(condition, then_, else_ = [])
        super()
        @children = {:condition => condition, :then => then_, :else => else_}
      end
    end

    class Step < Node
      def initialize(key, value)
        super()
        @children = {:key => key, :value => value}
      end
    end

    class While < Node
      def initialize(condition, body)
        super()
        @children = {:condition => condition, :body => body}
      end
    end

    class Tag < Node
      def initialize(key, value = nil)
        super()
        @children = {:key => key, :value => value}
      end
    end

    class Parameter < Node
      def initialize(name, default = nil)
        super()
        @children = {:name => name, :default => default}
      end

      def name
        @children[:name]
      end

      def type
        if @children[:type].nil?
          'String'
        else
          @children[:type].to_s
        end

      end
    end

    class Item < Node
      attr_reader :variables, :non_valued_parameters, :valued_parameters

      def initialize(name, tags = [], parameters = [], body = [])
        super()
        @children = {
          :name => name,
          :tags => tags,
          :parameters => parameters,
          :body => body
        }
      end

      def name
        @children[:name]
      end

      def post_render_children()
        save_parameters_by_type
        find_variables
      end

      def has_parameters?
        !@children[:parameters].empty?
      end

      private

      def find_variables
        names = []

        @variables = find_sub_nodes(Zest::Nodes::Variable).map do |var_node|
          unless names.include?(var_node.children[:name])
            names << var_node.children[:name]
            var_node
          end
        end.compact
      end

      def save_parameters_by_type
        parameters = []
        valued_parameters = []
        children[:parameters].each do |param|
          if param.children[:default].nil?
            parameters << param
          else
            valued_parameters << param
          end
        end

        @non_valued_parameters = parameters
        @valued_parameters = valued_parameters
      end
    end

    class Actionword < Item
      def has_step?
        @children[:body].each do |element|
          if element.instance_of?(Zest::Nodes::Step)
            return true
          end
        end
        false
      end
    end

    class Scenario < Item
      attr_reader :folder_uid

      def initialize(name, description = '', tags = [], parameters = [], body = [], folder_uid = nil, datatable = Datatable.new)
        super(name, tags, parameters, body)
        @children[:description] = description
        @children[:datatable] = datatable

        @folder_uid = folder_uid
      end
    end

    class Datatable < Node
      def initialize(datasets = [])
        super()

        @children = {
          :datasets => datasets
        }
      end
    end

    class Dataset < Node
      def initialize(name, arguments = [])
        super()

        @children = {
          :name => name,
          :arguments => arguments
        }
      end
    end

    class Actionwords < Node
      def initialize(actionwords = [])
        super()
        @children = {:actionwords => actionwords}
      end
    end

    class Scenarios < Node
      def initialize(scenarios = [])
        super()
        @children = {:scenarios => scenarios}
      end
    end

    class Folder < Node
      attr_reader :uid, :parent, :parent_uid
      attr_writer :parent

      def initialize(uid, parent_uid, name)
        super()

        @uid = uid
        @parent_uid = parent_uid

        @children = {
          :name => name,
          :subfolders => [],
          :scenarios => []
        }
      end
    end

    class TestPlan < Node
      def initialize(folders = [])
        super()
        @uids_mapping = {}
        @children = {
          :root_folder => nil,
          :folders => folders
        }
      end

      def organize_folders
        @children[:folders].each do |folder|
          @uids_mapping[folder.uid] = folder
          parent = find_folder_by_uid folder.parent_uid
          if parent.nil?
            @children[:root_folder] = folder
            next
          end

          folder.parent = parent
          parent.children[:subfolders] << folder
        end
      end

      def find_folder_by_uid(uid)
        return @uids_mapping[uid]
      end
    end

    class Project < Node
      def initialize(name, description = '', test_plan = TestPlan.new, scenarios = Scenarios.new, actionwords = Actionwords.new)
        super()
        scenarios.parent = self

        @children = {
          :name => name,
          :description => description,
          :test_plan => test_plan,
          :scenarios => scenarios,
          :actionwords => actionwords
        }
      end

      def assign_scenarios_to_folders
        @children[:scenarios].children[:scenarios].each do |scenario|
          folder = @children[:test_plan].find_folder_by_uid(scenario.folder_uid)
          next if folder.nil?

          folder.children[:scenarios] << scenario
        end
      end
    end
  end
end
