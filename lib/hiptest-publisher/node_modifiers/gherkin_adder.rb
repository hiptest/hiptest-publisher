require 'hiptest-publisher/indexers/actionword_indexer'
require 'hiptest-publisher/nodes'

module Hiptest
  module NodeModifiers
    class GherkinAdder
      def self.add(project)
        self.new(project).update_calls
      end

      def initialize(project)
        @project = project
        @indexer = ActionwordIndexer.new(project)
        @annotations_counter = AnnotationsCounter.new

        @special_params = ['__free_text', '__datatable']
      end

      def update_calls
        @project.each_sub_nodes(Hiptest::Nodes::Scenario, Hiptest::Nodes::Actionword, Hiptest::Nodes::Test, Hiptest::Nodes::Folder) do |item|
          @last_annotation = nil
          item.each_sub_nodes(Hiptest::Nodes::Call, Hiptest::Nodes::UIDCall) do |call|
            set_call_chunks(call)
            call.children[:gherkin_text] ||= "#{text_annotation(call)} #{prettified(call)}"

            if actionword = get_actionword(call)
              @annotations_counter.increment(actionword, code_annotation(call))
              set_actionwords_chunks(actionword)

              actionword.children[:gherkin_pattern] ||= pattern(actionword)
              actionword.children[:parameters_ordered_by_pattern] ||= order_parameters_by_pattern(actionword)
            end
          end
        end

        @annotations_counter.actionwords.each do |actionword|
          actionword.children[:gherkin_annotation] = @annotations_counter.most_used_annotation(actionword) || "Given"
          actionword.children[:gherkin_used_annotations] = @annotations_counter.all_used_annotations(actionword) || ['Given']
        end
      end

      def annotation(call)
        call.children[:annotation].capitalize if call.children[:annotation]
      end

      def text_annotation(call)
        annotation(call) || "*"
      end

      def code_annotation(call)
        call_annotation = annotation(call)
        if call_annotation
          if ["And", "But"].include?(call_annotation)
            call_annotation = @last_annotation || "Given"
          end
          @last_annotation = call_annotation
        end
      end

      def prettified(call)
        base = call.chunks.map {|chunk| chunk[:value]}.join("\"").strip
        call.extra_inlined_arguments.each do |chunk|
          base += " \"#{chunk[:value]}\""
        end

        base
      end

      def set_call_chunks(call)
        all_arguments = all_valued_arguments_for(call)
        inline_parameter_names = []
        extra_inlined_arguments = []

        call.chunks = []
        call.extra_inlined_arguments = []

        actionword_name = call.is_a?(Hiptest::Nodes::Call) ? call.children[:actionword] : call.children[:actionword_name]
        call_chunks = actionword_name.split("\"", -1)

        call_chunks.each_slice(2) do |text, inline_parameter_name|
          call.chunks << {
            value: text,
            is_argument: false
          }

          if all_arguments.has_key?(inline_parameter_name)
            inline_parameter_names << inline_parameter_name.clone
            value = all_arguments[inline_parameter_name]
            inline_parameter_name.replace(value)

            call.chunks << {
              value: inline_parameter_name,
              is_argument: true
            }
          else
           call.chunks << {
              value: inline_parameter_name,
              is_argument: false
            } unless inline_parameter_name.nil?
          end
        end

        missing_parameter_names = all_arguments.keys - inline_parameter_names - @special_params
        call.extra_inlined_arguments = missing_parameter_names.map do |missing_parameter_name|
          {
            value: all_arguments[missing_parameter_name],
            is_argument: true
          }
        end
      end

      def pattern(actionword)
        patterned = actionword.chunks.map {|chunk| chunk[:value]}.join("\"")
        actionword.extra_inlined_parameters.each do |param|
          patterned += " \"#{param[:value]}\""
        end

        "^#{patterned.strip}$"
      end

      def set_actionwords_chunks(actionword)
        name = actionword.uniq_name
        actionword_parameters = evaluated_map(actionword.children[:parameters])
        name_chunks = name.split("\"", -1)
        inline_parameter_names = []

        actionword.chunks = []
        actionword.extra_inlined_parameters = []

        name_chunks.each_slice(2) do |text, inline_parameter_name|
          actionword.chunks << {
            value: text.gsub(/[.|()\\.+*?\[\]{}^$]/) { |c| "\\#{c}" },
            is_parameter: false
          }

          inline_parameter_names << inline_parameter_name if inline_parameter_name
          if actionword_parameters.has_key?(inline_parameter_name)
            actionword.chunks << {
              value: "(.*)",
              name: inline_parameter_name,
              is_parameter: true
            }
          else
            actionword.chunks << {
              value: inline_parameter_name,
              is_parameter: false
            } if inline_parameter_name
          end
        end
        missing_parameter_names = actionword_parameters.keys - inline_parameter_names - @special_params

        missing_parameter_names.each do |missing_parameter_name|
          actionword.extra_inlined_parameters << {
            value: "(.*)",
            name: missing_parameter_name,
            is_parameter: true
          }
        end
      end

      def order_parameters_by_pattern(actionword)
        inline_parameter_names = actionword.children[:name].scan(/\"(.*?)\"/).flatten
        actionword_parameters = {}
        actionword.children[:parameters].map {|p| actionword_parameters[p.children[:name]] = p}

        missing_parameter_names = actionword_parameters.keys - inline_parameter_names - @special_params
        [inline_parameter_names, missing_parameter_names, @special_params].flatten.map do |name|
          actionword_parameters[name]
        end.compact
      end

      def all_valued_arguments_for(call)
        evaluated_call_arguments = evaluated_map(call.children[:arguments])
        evaluated_actionword_parameters = evaluated_map(get_actionword_parameters(call))
        names = evaluated_actionword_parameters.keys

        hash_array = names.map { |name|
          value = evaluated_call_arguments[name] || evaluated_actionword_parameters[name] || ""
          [name, value]
        }
        Hash[hash_array]
      end

      def get_actionword_parameters(call)
        actionword = get_actionword(call)
        actionword && actionword.children[:parameters] || []
      end

      def get_actionword(call)

        actionword = call.is_a?(Hiptest::Nodes::UIDCall) ? @indexer.get_uid_index(call.children[:uid]) : @indexer.get_index(call.children[:actionword])

        actionword && actionword[:actionword] || nil
      end

      def evaluated_map(named_values)
        hash_array = named_values.map do |named_value|
          name = named_value.children[:name]
          value = evaluate(named_value.children[:value] || named_value.children[:default])
          [name, value]
        end
        Hash[hash_array]
      end

      def evaluate(value)
        if value.nil?
          nil
        elsif Hiptest::Nodes::Variable === value
          "<#{value.children[:name]}>"
        elsif value.children[:chunks]
          value.children[:chunks].map {|chunk| evaluate(chunk) }.join('')
        elsif value.children[:value]
          value.children[:value]
        else
          nil
        end
      end
    end

    class AnnotationsCounter
      def initialize
        @counts_by_actionword = Hash.new {|counts, actionword| counts[actionword] = Hash.new(0) }
      end

      def actionwords
        @counts_by_actionword.keys
      end

      def increment(actionword, annotation)
        counts = @counts_by_actionword[actionword]
        counts[annotation] += 1 if annotation
      end

      def most_used_annotation(actionword)
        max = @counts_by_actionword[actionword].values.max
        @counts_by_actionword[actionword].key(max)
      end

      def all_used_annotations(actionword)
        @counts_by_actionword[actionword].keys
      end
    end
  end
end
