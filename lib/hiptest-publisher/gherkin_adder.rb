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
      actionword = @indexer.get_index(call.children[:actionword])
      actionword_parameters = actionword ? actionword[:parameters] : {}
      call_arguments = call.children[:arguments].map do |argument|
        [argument.children[:name], argument.children[:value]]
      end.to_h

      arguments = actionword_parameters.map do |name, default_value|
        value = call_arguments.fetch(name, default_value)
        value = value.nil? ? "" : value.children[:value]
        [name, value]
      end
      arguments.to_h
    end
  end
end
