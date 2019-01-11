require 'set'

require 'hiptest-publisher/string'
require 'hiptest-publisher/utils'
require 'hiptest-publisher/renderer'

module Hiptest
  module Nodes
    class Node
      attr_reader :children, :parent
      attr_writer :parent

      def pretty_print_instance_variables
        super - [:@parent] # do not overload pry output
      end

      def render(rendering_context)
        return Hiptest::Renderer.render(self, rendering_context)
      end

      def each_sub_nodes(*types, deep: false)
        return to_enum(:each_sub_nodes, *types, deep: deep) unless block_given?
        path = [self]
        parsed_nodes_id = Set.new

        until path.empty?
          current_node = path.shift

          if current_node.is_a?(Node)
            next if parsed_nodes_id.include? current_node.object_id
            parsed_nodes_id << current_node.object_id

            if types.empty? || types.any? {|type| current_node.is_a?(type)}
              yield current_node
              next unless deep
            end
            current_node.children.each_value {|item| path << item}
          elsif current_node.is_a?(Array)
            current_node.each {|item| path << item}
          end
        end
      end

      def each_direct_children
        children.each_value do |child|
          if child.is_a? Hiptest::Nodes::Node
            yield child
          elsif child.is_a? Array
            child.each {|c| yield c if c.is_a? Hiptest::Nodes::Node }
          end
        end
      end

      def ==(other)
        other.class == self.class && other.children == @children
      end

      def project
        project = self
        while project && !project.is_a?(Hiptest::Nodes::Project)
          project = project.parent
        end
        project
      end

      def kind
        node_kinds[self.class] ||= begin
          self.class.name.split('::').last.downcase
        end
      end

      def flat_string
        flat_childs = children.map do |key, value|
          "#{key}: #{flatten_child(value)}"
        end.join(", ")
        "<#{self.class.name} [#{flat_childs}]>"
      end

      private

      def node_kinds
        @@node_kinds ||= {}
      end

      def flatten_child(child)
        return child.flat_string if child.is_a?(Node)
        if child.is_a?(Array)
          return child.map {|item| flatten_child(item)}
        end
        child.to_s
      end
    end

    class Literal < Node
      def initialize(value)
        super()
        @children = {value: value}
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
        @children = {name: name}
      end
    end

    class Symbol < Node
      def initialize(value, delimiter)
        super()
        @children = {delimiter: delimiter, value: value}
      end
    end

    class Property < Node
      def initialize(key, value)
        super()
        @children = {key: key, value: value}
      end
    end

    class Field < Node
      def initialize(base, name)
        super()
        @children = {base: base, name: name}
      end
    end

    class Index < Node
      def initialize(base, expression)
        super()
        @children = {base: base, expression: expression}
      end
    end

    class BinaryExpression < Node
      def initialize(left, operator, right)
        super()
        @children = {operator: operator, left: left, right: right}
      end
    end

    class UnaryExpression < Node
      def initialize(operator, expression)
        super()
        @children = {operator: operator, expression: expression}
      end
    end

    class Parenthesis < Node
      def initialize(content)
        super()
        @children = {content: content}
      end
    end

    class List < Node
      def initialize(items)
        super()
        @children = {items: items}
      end
    end

    class Dict < Node
      def initialize(items)
        super()
        @children = {items: items}
      end
    end

    class Template < Node
      def initialize(chunks)
        super()
        @children = {chunks: chunks}
      end
    end

    class Assign < Node
      def initialize(to, value)
        super()
        @children = {to: to, value: value}
      end
    end

    class Argument < Node
      def initialize(name, value)
        super()
        @children = {name: name, value: value}
      end

      def free_text?
        @children[:name] == "__free_text"
      end

      def datatable?
        @children[:name] == "__datatable"
      end
    end

    class Call < Node
      attr_reader :chunks, :extra_inlined_arguments
      attr_writer :chunks, :extra_inlined_arguments

      def initialize(actionword, arguments = [], annotation = nil)
        super()
        annotation = nil if annotation == ""
        @children = {actionword: actionword, arguments: arguments, all_arguments: arguments, annotation: annotation}

        @chunks = []
        @extra_inlined_arguments = []
      end

      def free_text_arg
        children[:arguments].find(&:free_text?)
      end

      def datatable_arg
        children[:arguments].find(&:datatable?)
      end
    end

    class UIDCall < Node
      attr_reader :chunks, :extra_inlined_arguments
      attr_writer :chunks, :extra_inlined_arguments

      def initialize(uid, arguments = [], annotation = nil)
        super()
        annotation = nil if annotation == ''

        @children = {
          uid: uid,
          arguments: arguments,
          all_arguments: arguments,
          annotation: annotation
        }

        @chunks = []
        @extra_inlined_arguments = []
      end

      def free_text_arg
        children[:arguments].find(&:free_text?)
      end

      def datatable_arg
        children[:arguments].find(&:datatable?)
      end
    end

    class IfThen < Node
      def initialize(condition, then_, else_ = [])
        super()
        @children = {condition: condition, then: then_, else: else_}
      end
    end

    class Step < Node
      def initialize(key, value)
        super()
        @children = {key: key, value: value}
      end
    end

    class While < Node
      def initialize(condition, body)
        super()
        @children = {condition: condition, body: body}
      end
    end

    class Tag < Node
      def initialize(key, value = nil)
        super()
        @children = {key: key, value: value}
      end

      def to_s
        "#{@children[:key]}#{@children[:value].nil? ? '' : ':' + @children[:value]}"
      end
    end

    class Parameter < Node
      def initialize(name, default = nil)
        super()
        @children = {name: name, default: default}
      end

      def type
        if @children[:type].nil?
          'String'
        else
          @children[:type].to_s
        end
      end

      def free_text?
        @children[:name] == "__free_text"
      end

      def datatable?
        @children[:name] == "__datatable"
      end
    end

    class Item < Node
      attr_reader :variables, :non_valued_parameters, :valued_parameters

      def initialize(name, tags = [], description = '', parameters = [], body = [])
        super()
        @children = {
          name: name,
          tags: tags,
          description: description,
          parameters: parameters,
          body: body
        }
      end

      def declared_variables_names
        p_names = children[:parameters].map {|p| p.children[:name]}
        each_sub_nodes(Hiptest::Nodes::Variable).map do |var|
          v_name = var.children[:name]
          p_names.include?(v_name) ? nil : v_name
        end.uniq.compact
      end

      def add_tags(tags)
        existing = @children[:tags].map(&:to_s)

        tags.each do |tag|
          next if existing.include? tag.to_s

          existing << tag.to_s
          @children[:tags] << tag
        end
      end
    end

    class Actionword < Item
      attr_reader :chunks, :extra_inlined_parameters, :uniq_name
      attr_writer :chunks, :extra_inlined_parameters, :uniq_name

      def initialize(name, tags = [], parameters = [], body = [], uid = nil, description = '')
        super(name, tags, description, parameters, body)
        @children[:uid] = uid

        @chunks = []
        @extra_inlined_parameters = []
        @uniq_name = name
      end

      def must_be_implemented?
        @children[:body].empty? || @children[:body].map {|step| step.class}.compact.include?(Hiptest::Nodes::Step)
      end
    end

    class Scenario < Item
      attr_reader :folder_uid, :order_in_parent

      def initialize(name, description = '', tags = [], parameters = [], body = [], folder_uid = nil, datatable = Datatable.new, order_in_parent = 0)
        super(name, tags, description, parameters, body)
        @children[:datatable] = datatable

        @folder_uid = folder_uid
        @order_in_parent = order_in_parent
      end

      def set_uid(uid)
        @children[:uid] = uid
      end

      def folder
        project && project.children[:test_plan] && project.children[:test_plan].find_folder_by_uid(folder_uid)
      end
    end

    class Test < Node
      def initialize(name, description = '', tags = [], body = [])
        super()

        @children = {
          name: name,
          description: description,
          tags: tags,
          body: body
        }
      end

      def folder
        nil
      end
    end

    class Datatable < Node
      def initialize(datasets = [])
        super()

        @children = {
          datasets: datasets
        }
      end
    end

    class Dataset < Node
      def initialize(name, arguments = [], uid = nil)
        super()

        @children = {
          name: name,
          uid: uid,
          arguments: arguments
        }
      end

      def set_test_snapshot_uid(uid)
        @children[:test_snapshot_uid] = uid
      end
    end

    class Actionwords < Node
      attr_reader :to_implement, :no_implement
      def initialize(actionwords = [])
        super()
        @children = {actionwords: actionwords}
        mark_actionwords_for_implementation
        index_actionwords
      end

      def find_actionword(name)
        return @actionwords_index[name]
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

      def index_actionwords
        @actionwords_index = {}

        @children[:actionwords].each do |aw|
          @actionwords_index[aw.children[:name]] = aw
        end
      end
    end

    class Scenarios < Node
      def initialize(scenarios = [])
        super()
        @children = {scenarios: scenarios}
        scenarios.each {|sc| sc.parent = self}
      end
    end

    class Tests < Node
      def initialize(tests = [])
        super()
        @children = {tests: tests}
        tests.each {|test| test.parent = self}
      end
    end

    class Folder < Node
      attr_reader :uid, :parent_uid, :order_in_parent

      def initialize(uid, parent_uid, name, description, tags = [], order_in_parent = 0, body = [])
        super()
        @uid = uid
        @parent_uid = parent_uid
        @order_in_parent = order_in_parent

        @children = {
          name: name,
          description: description,
          subfolders: [],
          scenarios: [],
          tags: tags,
          body: body
        }
      end

      def root?
        parent_uid == nil
      end

      def folder
        root? ? nil : parent
      end

      def ancestors
        ancestors = []

        current_ancestor = folder
        until current_ancestor.nil?
          ancestors << current_ancestor
          current_ancestor = current_ancestor.folder
        end

        ancestors
      end
    end

    class TestPlan < Node
      def initialize(folders = [])
        super()
        @uids_mapping = {}
        @children = {
          root_folder: nil,
          folders: folders
        }
      end

      def organize_folders
        @children[:root_folder] = @children[:folders].find(&:root?)
        @children[:root_folder].parent = self if @children[:root_folder]

        @children[:folders].each do |folder|
          @uids_mapping[folder.uid] = folder
        end

        @children[:folders].each do |folder|
          next if folder.root?

          parent = find_folder_by_uid(folder.parent_uid) || @children[:root_folder]
          folder.parent = parent
          parent.children[:subfolders] << folder unless parent.children[:subfolders].include?(folder)
        end
      end

      def find_folder_by_uid(uid)
        return @uids_mapping[uid]
      end
    end

    class Libraries < Node
      def initialize(libraries = [])
        super()
        @children = {
          libraries: libraries
        }
      end
    end

    class Library < Node
      def initialize(name = 'default_library', actionwords = [])
        super()
        @children = {
          name: name,
          actionwords: actionwords
        }
      end
    end

    class Project < Node
      def initialize(name, description = '', test_plan = TestPlan.new, scenarios = Scenarios.new, actionwords = Actionwords.new, tests = Tests.new, libraries = Libraries.new)
        super()
        test_plan.parent = self if test_plan.respond_to?(:parent=)
        scenarios.parent = self
        tests.parent = self

        @children = {
          name: name,
          description: description,
          test_plan: test_plan,
          scenarios: scenarios,
          actionwords: actionwords,
          tests: tests,
          libraries: libraries
        }
      end

      def has_libraries?
        !children[:libraries].children[:libraries].empty?
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
