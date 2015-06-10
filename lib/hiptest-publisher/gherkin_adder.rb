require 'hiptest-publisher/actionword_indexer'
require 'hiptest-publisher/nodes'

module Hiptest
  class GherkinAdder
    def self.add(project)
      GherkinAdder.new(project).update_calls
    end

    def initialize(project)
      @project = project
      @indexer = ActionwordIndexer.new(project)
    end

    def update_calls
      @project.find_sub_nodes(Hiptest::Nodes::Call).each do |call|
        call.children[:gherkin_text] ||= "#{annotation(call)} #{prettified(call)}"
      end
    end

    def annotation(call)
      if call.children[:annotation]
        call.children[:annotation].capitalize
      else
        "Given"
      end
    end

    def prettified(call)
      all_arguments = all_valued_arguments_for(call)
      inline_parameter_names = []

      call_chunks = call.children[:actionword].split("\"", -1)
      call_chunks.each_slice(2) do |text, inline_parameter_name|
        if all_arguments.has_key?(inline_parameter_name)
          inline_parameter_names << inline_parameter_name.clone
          value = all_arguments[inline_parameter_name]
          inline_parameter_name.replace(value)
        end
      end

      missing_parameter_names = all_arguments.keys - inline_parameter_names

      prettified = call_chunks.join("\"")
      missing_parameter_names.each do |missing_parameter_name|
        value = all_arguments[missing_parameter_name]
        prettified << " \"#{value}\""
      end
      prettified
    end

    def all_valued_arguments_for(call)
      evaluated_call_arguments = evaluated_map(call.children[:arguments])
      evaluated_actionword_parameters = evaluated_map(get_actionword_parameters(call))
      names = evaluated_actionword_parameters.keys

      names.map { |name|
        value = evaluated_call_arguments[name] || evaluated_actionword_parameters[name] || ""
        [name, value]
      }.to_h
    end

    def get_actionword_parameters(call)
      actionword = @indexer.get_index(call.children[:actionword])
      if actionword
        actionword[:actionword].children[:parameters]
      else
        []
      end
    end

    def evaluated_map(named_values)
      named_values.map do |named_value|
        name = named_value.children[:name]
        value = evaluate(named_value.children[:value] || named_value.children[:default])
        [name, value]
      end.to_h
    end

    def evaluate(value)
      if value.nil?
        nil
      elsif value.children[:chunks]
        value.children[:chunks].map {|chunk| evaluate(chunk) }.join('')
      elsif value.children[:value]
        value.children[:value]
      else
        nil
      end
    end
  end
end
