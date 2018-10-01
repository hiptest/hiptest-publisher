require 'hiptest-publisher/nodes'

module Hiptest
  module GroovySpockAddon
    def walk_call(call)
      base = super(call)
      use_annotation(call, base)
    end

    def walk_uidcall(uidcall)
      base = super(uidcall)
      use_annotation(uidcall, base)
    end


    private

    def use_annotation(call, base)
      base[:use_expect_annotation] = needs_fixing?(call)
      base[:use_main_annotation?] = !(call.children[:annotation].nil? || ['and', 'but'].include?(call.children[:annotation]))

      base
    end

    def needs_fixing?(call)
      scenario = call.parent

      return false unless scenario.is_a?(Hiptest::Nodes::Scenario)
      return false unless call.children[:annotation].nil? || ignore_case_equal?(call.children[:annotation], 'then')

      return call.parent.children[:body].select do |step|
        (step.is_a?(Hiptest::Nodes::Call) || step.is_a?(Hiptest::Nodes::UIDCall)) && !step.children[:annotation].nil? && ignore_case_equal?(step.children[:annotation], 'when')
      end.empty?
    end

    def ignore_case_equal?(string1, string2)
      string1.casecmp(string2) == 0
    end
  end
end
