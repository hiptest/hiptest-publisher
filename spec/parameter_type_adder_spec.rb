require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/zest-publisher/nodes'
require_relative '../lib/zest-publisher/parameter_type_adder'

describe Zest::Nodes do
  context 'ParameterTypeAdder' do

    context 'Actionword parameter typing' do
      it 'gives string type if called nothing' do
        parameter = type_adding(Zest::Nodes::Parameter.new('x'))
        expect(parameter.children[:type]).to eq(:String)
      end

      it 'gives integer type if called with an integer value' do
        parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::NumericLiteral.new('3'))
        expect(parameter.children[:type]).to eq(:int)
      end

      it 'gives float type if called with a float value' do
        parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::NumericLiteral.new('3.14'))
        expect(parameter.children[:type]).to eq(:float)
      end

      it 'gives boolean type if called with boolean value' do
        parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::BooleanLiteral.new(true))
        expect(parameter.children[:type]).to eq(:bool)
      end

      it 'gives string type if called with null value' do
        parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::NullLiteral.new)
        expect(parameter.children[:type]).to eq(:null)
      end

      it 'gives string type if called with a template value' do
        parameter = type_adding(
          Zest::Nodes::Parameter.new('x'),
          Zest::Nodes::Template.new([Zest::Nodes::StringLiteral.new('My value')])
        )
        expect(parameter.children[:type]).to eq(:String)
      end

      it 'gives string type if called with a string value' do
        parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::StringLiteral.new('my string'))
        expect(parameter.children[:type]).to eq(:String)
      end

      it 'gives float type if called with integer and float values' do
        parameter = type_adding(
          Zest::Nodes::Parameter.new('x'),
          Zest::Nodes::NumericLiteral.new('3'),
          Zest::Nodes::NumericLiteral.new('4.12'))
        expect(parameter.children[:type]).to eq(:float)
      end

      it 'gives int type if called with integer value and null values' do
        parameter = type_adding(
          Zest::Nodes::Parameter.new('x'),
          Zest::Nodes::NullLiteral.new,
          Zest::Nodes::NumericLiteral.new('4'))
        expect(parameter.children[:type]).to eq(:int)
      end

      it 'gives float type if called with integer value, float value and null values' do
        parameter = type_adding(
          Zest::Nodes::Parameter.new('x'),
          Zest::Nodes::NumericLiteral.new('3.14'),
          Zest::Nodes::NullLiteral.new,
          Zest::Nodes::NumericLiteral.new('4'))
        expect(parameter.children[:type]).to eq(:float)
      end

      it 'gives boolean type if called with boolean values and null value' do
        parameter = type_adding(
          Zest::Nodes::Parameter.new('x'),
          Zest::Nodes::BooleanLiteral.new(true),
          Zest::Nodes::NullLiteral.new,
          Zest::Nodes::BooleanLiteral.new(false))
        expect(parameter.children[:type]).to eq(:bool)
      end

      it 'gives string type if impossible to deduce type' do
        parameter = type_adding(
          Zest::Nodes::Parameter.new('x'),
          Zest::Nodes::BooleanLiteral.new(true),
          Zest::Nodes::NumericLiteral.new('3'))
        expect(parameter.children[:type]).to eq(:String)
      end
    end

    context 'Scenario parameter typing' do
      let(:scenario) {
        Zest::Nodes::Scenario.new('My scenario', '', [], [
          Zest::Nodes::Parameter.new('x'),
          Zest::Nodes::Parameter.new('y'),
          Zest::Nodes::Parameter.new('z')
        ])
      }

      let(:project) {
        Zest::Nodes::Project.new('My project', '', nil,
          Zest::Nodes::Scenarios.new([scenario]),
          Zest::Nodes::Actionwords.new())
      }

      let(:parameter_types) {
        Zest::Nodes::ParameterTypeAdder.add(project)
        scenario.children[:parameters].map {|p| p.type}
      }

      it 'if the datatable is not filled, all parameters will be string' do
        expect(parameter_types).to eq(["String", "String", "String"])
      end

      it 'A single row is enough to deduce the types' do
        scenario.children[:datatable] = Zest::Nodes::Datatable.new([
          Zest::Nodes::Dataset.new('First row', [
            Zest::Nodes::Argument.new('x',
              Zest::Nodes::BooleanLiteral.new('true')
            ),
            Zest::Nodes::Argument.new('y',
              Zest::Nodes::StringLiteral.new('Hi')
            ),
            Zest::Nodes::Argument.new('z',
              Zest::Nodes::NumericLiteral.new('3.14')
            ),
          ])
        ])

        expect(parameter_types).to eq(["bool", "String", "float"])
      end

      it 'Multiple row work if each value as the same type' do
        scenario.children[:datatable] = Zest::Nodes::Datatable.new([
          Zest::Nodes::Dataset.new('First row', [
            Zest::Nodes::Argument.new('x',
              Zest::Nodes::BooleanLiteral.new('true')
            ),
            Zest::Nodes::Argument.new('y',
              Zest::Nodes::StringLiteral.new('Hi')
            ),
            Zest::Nodes::Argument.new('z',
              Zest::Nodes::NumericLiteral.new('3.14')
            ),
          ]),
          Zest::Nodes::Dataset.new('Second row', [
            Zest::Nodes::Argument.new('x',
              Zest::Nodes::BooleanLiteral.new('false')
            ),
            Zest::Nodes::Argument.new('y',
              Zest::Nodes::StringLiteral.new('Ho')
            ),
            Zest::Nodes::Argument.new('z',
              Zest::Nodes::NumericLiteral.new('16.64')
            ),
          ])
        ])

        expect(parameter_types).to eq(["bool", "String", "float"])
      end

      it 'When a type can not be deduced, it falls back to String' do
        scenario.children[:datatable] = Zest::Nodes::Datatable.new([
          Zest::Nodes::Dataset.new('First row', [
            Zest::Nodes::Argument.new('x',
              Zest::Nodes::BooleanLiteral.new('true')
            ),
            Zest::Nodes::Argument.new('y',
              Zest::Nodes::StringLiteral.new('Hi')
            ),
            Zest::Nodes::Argument.new('z',
              Zest::Nodes::NumericLiteral.new('3.14')
            ),
          ]),
          Zest::Nodes::Dataset.new('Second row', [
            Zest::Nodes::Argument.new('x',
              Zest::Nodes::NumericLiteral.new('16')
            ),
            Zest::Nodes::Argument.new('y',
              Zest::Nodes::StringLiteral.new('Ho')
            ),
            Zest::Nodes::Argument.new('z',
              Zest::Nodes::BooleanLiteral.new('true')
            ),
          ])
        ])

        expect(parameter_types).to eq(["String", "String", "String"])
      end
    end

    # context 'Call imbrication' do
    # To be done later, now focus on scenario parameters typing
    #   let(:scenario) {
    #     # In Zest:
    #     # scenario 'My scenario' (x) do
    #     #   call 'aw1' (p1 = 16)
    #     #   call 'aw2' (p1 = x)
    #     # end
    #     # With a single dataset where x = false
    #     # aw1 forwards the parameter to aw3
    #     # aw2 forwards the parameter to aw4

    #     Zest::Nodes::Scenario.new('My scenario', '', [],
    #       [Zest::Nodes::Parameter.new('x')],
    #       [
    #         Zest::Nodes::Call.new('aw1', [
    #           Zest::Nodes::Argument.new('p1',
    #             Zest::Nodes::NumericLiteral.new('16')
    #           )
    #         ]),
    #         Zest::Nodes::Call.new('aw2', [
    #           Zest::Nodes::Argument.new('p1',
    #             Zest::Nodes::Variable.new('x')
    #           )
    #         ]),
    #       ], nil,
    #       Zest::Nodes::Datatable.new([
    #         Zest::Nodes::Dataset.new('First row', [
    #           Zest::Nodes::Argument.new('x',
    #             Zest::Nodes::BooleanLiteral.new('true')
    #           )
    #         ])
    #       ])
    #     )
    #   }

    #   let(:aw4) {
    #     Zest::Nodes::Actionword.new('aw4', [],
    #       [Zest::Nodes::Parameter.new('p4')]
    #     )
    #   }

    #   let(:aw3) {
    #     Zest::Nodes::Actionword.new('aw3', [],
    #       [Zest::Nodes::Parameter.new('p3')]
    #     )
    #   }

    #   let(:aw2) {
    #     Zest::Nodes::Actionword.new('aw2', [],
    #       [Zest::Nodes::Parameter.new('p2')],
    #       [Zest::Nodes::Call.new('aw4', [
    #         Zest::Nodes::Argument.new('p4',
    #           Zest::Nodes::Variable.new('p2')
    #         )
    #       ])]
    #     )
    #   }

    #   let(:aw1) {
    #     Zest::Nodes::Actionword.new('aw1', [],
    #       [Zest::Nodes::Parameter.new('p1')],
    #       [Zest::Nodes::Call.new('aw3', [
    #         Zest::Nodes::Argument.new('p3',
    #           Zest::Nodes::Variable.new('p1')
    #         )
    #       ])]
    #     )
    #   }

    #   let(:project) {
    #     Zest::Nodes::Project.new('My project', '', nil,
    #       Zest::Nodes::Scenarios.new([scenario]),
    #       Zest::Nodes::Actionwords.new([aw1, aw2, aw3, aw4]))
    #   }

    #   let(:parameters_mapping) {
    #     project.children[:actionwords].children[:actionwords].map do |aw|
    #       {
    #         name: aw.children[:name],
    #         parameters: aw.children[:parameters].map {|param|
    #           {name: param.children[:name], type: param.children[:type]}
    #         }
    #       }
    #     end
    #   }

    #   it 'forwards correctly the parameter values' do
    #     Zest::Nodes::ParameterTypeAdder.add(project)

    #     expect(parameters_mapping).to eq([
    #       {:name=>"aw1", :parameters=>[{:name => 'p1', :type => :int}]},
    #       {:name=>"aw2", :parameters=>[{:name => 'p2', :type => :bool}]},
    #       {:name=>"aw3", :parameters=>[{:name => 'p3', :type => :int}]},
    #       {:name=>"aw4", :parameters=>[{:name => 'p4', :type => :bool}]}])

    #   end
    # end
  end
end

def type_adding(parameter, *called_values)
  calls = called_values.map{|called_value|
    Zest::Nodes::Call.new('aw', [Zest::Nodes::Argument.new('x', called_value)])
  }

  actionwords= Zest::Nodes::Actionwords.new([
    Zest::Nodes::Actionword.new('aw', [], [parameter], [])
  ])

  scenarios= Zest::Nodes::Scenarios.new([
    Zest::Nodes::Scenario.new('many calls scenarios', '', [], [], calls)
  ])
  project = Zest::Nodes::Project.new('My project', '', nil, scenarios, actionwords)

  Zest::Nodes::ParameterTypeAdder.add(project)
  parameter
end
