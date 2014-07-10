require 'erb'

require 'zest-publisher/string'
require 'zest-publisher/utils'

module Zest
  module Nodes
    class Node
      attr_reader :childs, :rendered, :rendered_childs, :parent
      attr_writer :parent

      def initialize
        @context = {}
        @rendered = ''
        @rendered_childs = {}
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

      def render_childs(language)
        if @rendered_childs.size > 0
          return
        end

        @childs.each do |key, child|
          if child.is_a? Array
            @rendered_childs[key] = child.map {|c| c.render(language, @context) }
            next
          end

          if child.methods.include? :render
            @rendered_childs[key] = child.render(language, @context)
          else
            @rendered_childs[key] = child
          end
        end
        post_render_childs()
      end

      def post_render_childs()
      end

      def render(language = 'ruby', context = {})
        @context = context

        render_childs(language)
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

      def find_sub_nodes(type = nil)
        sub_nodes = all_sub_nodes

        if type.nil?
          sub_nodes
        else
          sub_nodes.keep_if {|node| node.is_a? type}
        end
      end

      private

      def all_sub_nodes
        path = [self]
        childs = []

        until path.empty?
          current_node = path.pop

          if current_node.is_a?(Node)
            next if childs.include? current_node

            childs << current_node
            current_node.childs.values.reverse.each {|item| path << item}
          elsif current_node.is_a?(Array)
            current_node.reverse.each {|item| path << item}
          end
        end
        childs
      end
    end

    class Literal < Node
      def initialize(value)
        super()
        @childs = {:value => value}
      end
    end

    class NullLiteral < Node
      def initialize
        super()
        @childs = {}
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
        @childs = {:name => name}
      end
    end

    class Property < Node
      def initialize(key, value)
        super()
        @childs = {:key => key, :value => value}
      end
    end

    class Field < Node
      def initialize(base, name)
        super()
        @childs = {:base => base, :name => name}
      end
    end

    class Index < Node
      def initialize(base, expression)
        super()
        @childs = {:base => base, :expression => expression}
      end
    end

    class BinaryExpression < Node
      def initialize(left, operator, right)
        super()
        @childs = {:operator => operator, :left => left, :right => right}
      end
    end

    class UnaryExpression < Node
      def initialize(operator, expression)
        super()
        @childs = {:operator => operator, :expression => expression}
      end
    end

    class Parenthesis < Node
      def initialize(content)
        super()
        @childs = {:content => content}
      end
    end

    class List < Node
      def initialize(items)
        super()
        @childs = {:items => items}
      end
    end

    class Dict < Node
      def initialize(items)
        super()
        @childs = {:items => items}
      end
    end

    class Template < Node
      def initialize(chunks)
        super()
        @childs = {:chunks => chunks}
      end
    end

    class Assign < Node
      def initialize(to, value)
        super()
        @childs = {:to => to, :value => value}
      end
    end

    class Argument < Node
      def initialize(name, value)
        super()
        @childs = {:name => name, :value => value}
      end
    end

    class Call < Node
      def initialize(actionword, arguments = [])
        super()
        @childs = {:actionword => actionword, :arguments => arguments}
      end

      def has_arguments?
        !@childs[:arguments].empty?
      end
    end

    class IfThen < Node
      def initialize(condition, then_, else_ = [])
        super()
        @childs = {:condition => condition, :then => then_, :else => else_}
      end
    end

    class Step < Node
      def initialize(key, value)
        super()
        @childs = {:key => key, :value => value}
      end
    end

    class While < Node
      def initialize(condition, body)
        super()
        @childs = {:condition => condition, :body => body}
      end
    end

    class Tag < Node
      def initialize(key, value = nil)
        super()
        @childs = {:key => key, :value => value}
      end
    end

    class Parameter < Node
      def initialize(name, default = nil)
        super()
        @childs = {:name => name, :default => default}
      end

      def name
        @childs[:name]
      end

      def type
        if @childs[:type].nil?
          'String'
        else
          @childs[:type].to_s
        end

      end
    end

    class Item < Node
      attr_reader :variables, :non_valued_parameters, :valued_parameters

      def initialize(name, tags = [], parameters = [], body = [])
        super()
        @childs = {
          :name => name,
          :tags => tags,
          :parameters => parameters,
          :body => body
        }
      end

      def name
        @childs[:name]
      end

      def post_render_childs()
        save_parameters_by_type
        find_variables
      end

      def has_parameters?
        !@childs[:parameters].empty?
      end

      private

      def find_variables
        names = []

        @variables = find_sub_nodes(Zest::Nodes::Variable).map do |var_node|
          unless names.include?(var_node.childs[:name])
            names << var_node.childs[:name]
            var_node
          end
        end.compact
      end

      def save_parameters_by_type
        parameters = []
        valued_parameters = []
        childs[:parameters].each do |param|
          if param.childs[:default].nil?
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
        @childs[:body].each do |element|
          if element.instance_of?(Zest::Nodes::Step)
            return true
          end
        end
        false
      end
    end

    class Scenario < Item
      attr_reader :folder_uid

      def initialize(name, description = '', tags = [], parameters = [], body = [], folder_uid = nil)
        super(name, tags, parameters, body)
        @childs[:description] = description
        @folder_uid = folder_uid
      end
    end

    class Actionwords < Node
      def initialize(actionwords = [])
        super()
        @childs = {:actionwords => actionwords}
      end
    end

    class Scenarios < Node
      def initialize(scenarios = [])
        super()
        @childs = {:scenarios => scenarios}
      end
    end

    class Folder < Node
      attr_reader :uid, :parent, :parent_uid
      attr_writer :parent

      def initialize(uid, parent_uid, name)
        super()

        @uid = uid
        @parent_uid = parent_uid

        @childs = {
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
        @childs = {
          :root_folder => nil,
          :folders => folders
        }
      end

      def organize_folders
        @childs[:folders].each do |folder|
          @uids_mapping[folder.uid] = folder
          parent = find_folder_by_uid folder.parent_uid
          if parent.nil?
            @childs[:root_folder] = folder
            next
          end

          folder.parent = parent
          parent.childs[:subfolders] << folder
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

        @childs = {
          :name => name,
          :description => description,
          :test_plan => test_plan,
          :scenarios => scenarios,
          :actionwords => actionwords
        }
      end

      def assign_scenarios_to_folders
        @childs[:scenarios].childs[:scenarios].each do |scenario|
          folder = @childs[:test_plan].find_folder_by_uid(scenario.folder_uid)
          next if folder.nil?

          folder.childs[:scenarios] << scenario
        end
      end
    end
  end
end
