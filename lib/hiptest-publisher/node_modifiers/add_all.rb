require 'hiptest-publisher/node_modifiers/actionword_uniq_renamer'
require 'hiptest-publisher/node_modifiers/call_arguments_adder'
require 'hiptest-publisher/node_modifiers/datatable_fixer'
require 'hiptest-publisher/node_modifiers/gherkin_adder'
require 'hiptest-publisher/node_modifiers/items_orderer'
require 'hiptest-publisher/node_modifiers/parameter_type_adder'
require 'hiptest-publisher/node_modifiers/parent_adder'
require 'hiptest-publisher/node_modifiers/uid_call_reference_adder'

module Hiptest
  module NodeModifiers
    def self.add_all(project, sort_method = nil)
      DatatableFixer.add(project)
      ParentAdder.add(project)
      UidCallReferencerAdder.add(project)
      ParameterTypeAdder.add(project)
      DefaultArgumentAdder.add(project)
      ActionwordUniqRenamer.add(project)
      GherkinAdder.add(project)
      ItemsOrderer.add(project, sort_method) unless sort_method.nil?
    end
  end
end
