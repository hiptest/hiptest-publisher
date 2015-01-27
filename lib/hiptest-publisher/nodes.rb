require 'hiptest-publisher/string'
require 'hiptest-publisher/utils'
require 'hiptest-publisher/renderer'

module Hiptest
  module Nodes
    class Node
      attr_reader :children, :parent
      attr_writer :parent

      def render(language = 'ruby', context = {})
        return Hiptest::Renderer.render(self, language, context)
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

      def direct_children
        direct = []

        children.each do |key, child|
          if child.is_a? Hiptest::Nodes::Node
            direct << child
          elsif child.is_a? Array
            child.each {|c| direct << c if c.is_a? Hiptest::Nodes::Node }
          end
        end

        direct
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
    end

    class Actionword < Item
      def must_be_implemented?
        @children[:body].empty? || @children[:body].map {|step| step.class}.compact.include?(Hiptest::Nodes::Step)
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

      def set_uid(uid)
        @children[:uid] = uid
      end
    end

    class Test < Node
      def initialize(name, description = '', tags = [], body = [])
        super()

        @children = {
          :name => name,
          :description => description,
          :tags => tags,
          :body => body
        }
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

      def set_uid(uid)
        @children[:uid] = uid
      end
    end

    class Actionwords < Node
      attr_reader :to_implement, :no_implement
      def initialize(actionwords = [])
        super()
        @children = {:actionwords => actionwords}
        mark_actionwords_for_implementation
      end

      private
      def mark_actionwords_for_implementation
        @to_implement = []
        @no_implement = []

        @children[:actionwords].each do |aw|
          if aw.must_be_implemented?
            @to_implement << aw
          else
            @no_implement << aw
          end
        end
      end
    end

    class Scenarios < Node
      def initialize(scenarios = [])
        super()
        @children = {:scenarios => scenarios}
        scenarios.each {|sc| sc.parent = self}
      end
    end

    class Tests < Node
      def initialize(tests = [])
        super()
        @children = {:tests => tests}
        tests.each {|test| test.parent = self}
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
      def initialize(name, description = '', test_plan = TestPlan.new, scenarios = Scenarios.new, actionwords = Actionwords.new, tests = Tests.new)
        super()
        scenarios.parent = self
        tests.parent = self

        @children = {
          :name => name,
          :description => description,
          :test_plan => test_plan,
          :scenarios => scenarios,
          :actionwords => actionwords,
          :tests => tests
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
