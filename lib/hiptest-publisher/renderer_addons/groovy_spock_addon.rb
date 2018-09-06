require 'hiptest-publisher/nodes'

module Hiptest
  module GroovySpockAddon
    def walk_call(call)
      base = super(call)
      base[:use_expect_annotation] = needs_fixing?(call)
      base[:use_main_annotation?] = !(call.children[:annotation].nil? || ['and', 'but'].include?(call.children[:annotation]))

      return base
    end

    private

    def needs_fixing?(call)
      scenario = call.parent

      return false unless scenario.is_a?(Hiptest::Nodes::Scenario)
      return false unless call.children[:annotation].nil? || call.children[:annotation].downcase == 'then'

      return call.parent.children[:body].select do |step|
        step.is_a?(Hiptest::Nodes::Call) && !step.children[:annotation].nil? && step.children[:annotation].downcase == 'when'
      end.empty?
    end
  end
end
