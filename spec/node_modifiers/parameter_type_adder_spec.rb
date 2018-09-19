require 'colorize'

require_relative '../spec_helper'
require_relative '../../lib/hiptest-publisher/nodes'

require_relative '../../lib/hiptest-publisher/node_modifiers/uid_call_reference_adder'
require_relative '../../lib/hiptest-publisher/node_modifiers/parameter_type_adder'

describe Hiptest::NodeModifiers::ParameterTypeAdder do
  include HelperFactories

  describe '.add' do
    it 'adds parameter type information to all parameters of all actionwords' do
      called_aw = Hiptest::Nodes::Actionword.new('called_aw', [], [
        Hiptest::Nodes::Parameter.new('x', Hiptest::Nodes::NumericLiteral.new('3')),
        Hiptest::Nodes::Parameter.new('y', Hiptest::Nodes::NumericLiteral.new('3')),
        Hiptest::Nodes::Parameter.new('z'),
      ])
      not_called_aw = Hiptest::Nodes::Actionword.new('not_called_aw', [], [
        Hiptest::Nodes::Parameter.new('a', Hiptest::Nodes::NumericLiteral.new('3')),
        Hiptest::Nodes::Parameter.new('b'),
      ])

      sc_calling_aw = Hiptest::Nodes::Scenario.new('sc_calling_aw', '', [], [], [
          Hiptest::Nodes::Call.new('called_aw', [Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('My value'))])
      ])

      actionwords = Hiptest::Nodes::Actionwords.new([called_aw, not_called_aw])
      scenarios = Hiptest::Nodes::Scenarios.new([sc_calling_aw])
      project = Hiptest::Nodes::Project.new('My project', '', nil, scenarios, actionwords)

      Hiptest::NodeModifiers::ParameterTypeAdder.add(project)

      expect(called_aw.children[:parameters][0].children).to include(name: 'x', type: :String)
      expect(called_aw.children[:parameters][1].children).to include(name: 'y', type: :int)
      expect(called_aw.children[:parameters][2].children).to include(name: 'z', type: :String)

      expect(not_called_aw.children[:parameters][0].children).to include(name: 'a', type: :int)
      expect(not_called_aw.children[:parameters][1].children).to include(name: 'b', type: :String)
    end
  end

  context 'Actionword parameter typing' do
    it 'gives string type if called nothing' do
      parameter = type_adding(Hiptest::Nodes::Parameter.new('x'))
      expect(parameter.children[:type]).to eq(:String)
    end

    it 'gives default value type if called nothing' do
      default = Hiptest::Nodes::NumericLiteral.new('3')
      parameter = type_adding(Hiptest::Nodes::Parameter.new('x', default))
      expect(parameter.children[:type]).to eq(:int)
    end

    it 'gives integer type if called with an integer value' do
      parameter = type_adding(Hiptest::Nodes::Parameter.new('x'), Hiptest::Nodes::NumericLiteral.new('3'))
      expect(parameter.children[:type]).to eq(:int)
    end

    it 'gives float type if called with a float value' do
      parameter = type_adding(Hiptest::Nodes::Parameter.new('x'), Hiptest::Nodes::NumericLiteral.new('3.14'))
      expect(parameter.children[:type]).to eq(:float)
    end

    it 'gives boolean type if called with boolean value' do
      parameter = type_adding(Hiptest::Nodes::Parameter.new('x'), Hiptest::Nodes::BooleanLiteral.new(true))
      expect(parameter.children[:type]).to eq(:bool)
    end

    it 'gives string type if called with null value' do
      parameter = type_adding(Hiptest::Nodes::Parameter.new('x'), Hiptest::Nodes::NullLiteral.new)
      expect(parameter.children[:type]).to eq(:null)
    end

    it 'gives string type if called with a template value' do
      parameter = type_adding(
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::Template.new([Hiptest::Nodes::StringLiteral.new('My value')])
      )
      expect(parameter.children[:type]).to eq(:String)
    end

    it 'gives string type if called with a variable in a template' do
      parameter = type_adding(
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::Template.new([Hiptest::Nodes::Variable.new('my_variable')])
      )
      expect(parameter.children[:type]).to eq(:String)
    end

    it 'gives string type if called with a string value' do
      parameter = type_adding(Hiptest::Nodes::Parameter.new('x'), Hiptest::Nodes::StringLiteral.new('my string'))
      expect(parameter.children[:type]).to eq(:String)
    end

    it 'gives float type if called with integer and float values' do
      parameter = type_adding(
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::NumericLiteral.new('3'),
        Hiptest::Nodes::NumericLiteral.new('4.12'))
      expect(parameter.children[:type]).to eq(:float)
    end

    it 'gives int type if called with integer value and null values' do
      parameter = type_adding(
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::NullLiteral.new,
        Hiptest::Nodes::NumericLiteral.new('4'))
      expect(parameter.children[:type]).to eq(:int)
    end

    it 'gives float type if called with integer value, float value and null values' do
      parameter = type_adding(
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::NumericLiteral.new('3.14'),
        Hiptest::Nodes::NullLiteral.new,
        Hiptest::Nodes::NumericLiteral.new('4'))
      expect(parameter.children[:type]).to eq(:float)
    end

    it 'gives boolean type if called with boolean values and null value' do
      parameter = type_adding(
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::BooleanLiteral.new(true),
        Hiptest::Nodes::NullLiteral.new,
        Hiptest::Nodes::BooleanLiteral.new(false))
      expect(parameter.children[:type]).to eq(:bool)
    end

    it 'gives string type if impossible to deduce type' do
      parameter = type_adding(
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::BooleanLiteral.new(true),
        Hiptest::Nodes::NumericLiteral.new('3'))
      expect(parameter.children[:type]).to eq(:String)
    end
  end

  context 'Scenario parameter typing' do
    let(:scenario) {
      Hiptest::Nodes::Scenario.new('My scenario', '', [], [
        Hiptest::Nodes::Parameter.new('x'),
        Hiptest::Nodes::Parameter.new('y'),
        Hiptest::Nodes::Parameter.new('z')
      ])
    }

    let(:project) {
      Hiptest::Nodes::Project.new('My project', '', nil,
        Hiptest::Nodes::Scenarios.new([scenario]),
        Hiptest::Nodes::Actionwords.new())
    }

    let(:parameter_types) {
      Hiptest::NodeModifiers::ParameterTypeAdder.add(project)
      scenario.children[:parameters].map {|p| p.type}
    }

    it 'if the datatable is not filled, all parameters will be string' do
      expect(parameter_types).to eq(["String", "String", "String"])
    end

    it 'A single row is enough to deduce the types' do
      scenario.children[:datatable] = Hiptest::Nodes::Datatable.new([
        Hiptest::Nodes::Dataset.new('First row', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::BooleanLiteral.new('true')
          ),
          Hiptest::Nodes::Argument.new('y',
            Hiptest::Nodes::StringLiteral.new('Hi')
          ),
          Hiptest::Nodes::Argument.new('z',
            Hiptest::Nodes::NumericLiteral.new('3.14')
          ),
        ])
      ])

      expect(parameter_types).to eq(["bool", "String", "float"])
    end

    it 'Multiple row work if each value as the same type' do
      scenario.children[:datatable] = Hiptest::Nodes::Datatable.new([
        Hiptest::Nodes::Dataset.new('First row', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::BooleanLiteral.new('true')
          ),
          Hiptest::Nodes::Argument.new('y',
            Hiptest::Nodes::StringLiteral.new('Hi')
          ),
          Hiptest::Nodes::Argument.new('z',
            Hiptest::Nodes::NumericLiteral.new('3.14')
          ),
        ]),
        Hiptest::Nodes::Dataset.new('Second row', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::BooleanLiteral.new('false')
          ),
          Hiptest::Nodes::Argument.new('y',
            Hiptest::Nodes::StringLiteral.new('Ho')
          ),
          Hiptest::Nodes::Argument.new('z',
            Hiptest::Nodes::NumericLiteral.new('16.64')
          ),
        ])
      ])

      expect(parameter_types).to eq(["bool", "String", "float"])
    end

    it 'When a type can not be deduced, it falls back to String' do
      scenario.children[:datatable] = Hiptest::Nodes::Datatable.new([
        Hiptest::Nodes::Dataset.new('First row', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::BooleanLiteral.new('true')
          ),
          Hiptest::Nodes::Argument.new('y',
            Hiptest::Nodes::StringLiteral.new('Hi')
          ),
          Hiptest::Nodes::Argument.new('z',
            Hiptest::Nodes::NumericLiteral.new('3.14')
          ),
        ]),
        Hiptest::Nodes::Dataset.new('Second row', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::NumericLiteral.new('16')
          ),
          Hiptest::Nodes::Argument.new('y',
            Hiptest::Nodes::StringLiteral.new('Ho')
          ),
          Hiptest::Nodes::Argument.new('z',
            Hiptest::Nodes::BooleanLiteral.new('true')
          ),
        ])
      ])

      expect(parameter_types).to eq(["String", "String", "String"])
    end

    context 'when scenario contains calls' do
      let(:scenario) {
        calls = [
          Hiptest::Nodes::Call.new('aw',
            [Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::BooleanLiteral.new(true))])
        ]

        Hiptest::Nodes::Scenario.new('My scenario with calls', '', [], [
          Hiptest::Nodes::Parameter.new('x'),
          Hiptest::Nodes::Parameter.new('y'),
          Hiptest::Nodes::Parameter.new('z')
        ], calls)
      }

      it 'is not confused by the calls presence' do
        scenario.children[:datatable] = Hiptest::Nodes::Datatable.new([
          Hiptest::Nodes::Dataset.new('First row', [
            Hiptest::Nodes::Argument.new('x',
              Hiptest::Nodes::BooleanLiteral.new('true')
            ),
            Hiptest::Nodes::Argument.new('y',
              Hiptest::Nodes::StringLiteral.new('Hi')
            ),
            Hiptest::Nodes::Argument.new('z',
              Hiptest::Nodes::NumericLiteral.new('3.14')
            ),
          ])
        ])

        expect(parameter_types).to eq(["bool", "String", "float"])
      end
    end
  end

  context 'when action word and scenario have the same name' do
    let(:scenario) {
      Hiptest::Nodes::Scenario.new('plopidou', '', [],
        [
          Hiptest::Nodes::Parameter.new('x')
        ],
        [
          Hiptest::Nodes::Call.new('plopidou', [
            Hiptest::Nodes::Argument.new('x',
              Hiptest::Nodes::NumericLiteral.new('16')
            )
          ])
        ],
        nil,
        Hiptest::Nodes::Datatable.new([
          Hiptest::Nodes::Dataset.new('First row', [
            Hiptest::Nodes::Argument.new('x',
              Hiptest::Nodes::BooleanLiteral.new('true')
            )
          ])
        ])
      )
    }

    let(:actionword) {
      Hiptest::Nodes::Actionword.new('plopidou', [],
        [Hiptest::Nodes::Parameter.new('x')], [])
    }

    let(:project) {
      Hiptest::Nodes::Project.new('My project', '', nil,
        Hiptest::Nodes::Scenarios.new([scenario]),
        Hiptest::Nodes::Actionwords.new([actionword]))
    }

    it 'works as expected' do
      Hiptest::NodeModifiers::ParameterTypeAdder.add(project)

      expect(scenario.children[:parameters].map {|p| p.type}).to eq(['bool'])
      expect(actionword.children[:parameters].map {|p| p.type}).to eq(['int'])
    end
  end

  context 'Call imbrication' do
    let(:scenario) {
      # In Hiptest:
      # scenario 'My scenario' (x) do
      #   call 'aw1' (p1 = 16)
      #   call 'aw2' (p1 = x)
      # end
      # With a single dataset where x = false
      # aw1 forwards the parameter to aw3
      # aw2 forwards the parameter to aw4

      Hiptest::Nodes::Scenario.new('My scenario', '', [],
        [Hiptest::Nodes::Parameter.new('x')],
        [
          Hiptest::Nodes::Call.new('aw1', [
            Hiptest::Nodes::Argument.new('p1',
              Hiptest::Nodes::NumericLiteral.new('16')
            )
          ]),
          Hiptest::Nodes::Call.new('aw2', [
            Hiptest::Nodes::Argument.new('p2',
              Hiptest::Nodes::Variable.new('x')
            )
          ]),
        ], nil,
        Hiptest::Nodes::Datatable.new([
          Hiptest::Nodes::Dataset.new('First row', [
            Hiptest::Nodes::Argument.new('x',
              Hiptest::Nodes::BooleanLiteral.new('true')
            )
          ])
        ])
      )
    }

    let(:aw4) {
      Hiptest::Nodes::Actionword.new('aw4', [],
        [Hiptest::Nodes::Parameter.new('p4')]
      )
    }

    let(:aw3) {
      Hiptest::Nodes::Actionword.new('aw3', [],
        [Hiptest::Nodes::Parameter.new('p3')]
      )
    }

    let(:aw2) {
      Hiptest::Nodes::Actionword.new('aw2', [],
        [Hiptest::Nodes::Parameter.new('p2')],
        [Hiptest::Nodes::Call.new('aw4', [
          Hiptest::Nodes::Argument.new('p4',
            Hiptest::Nodes::Variable.new('p2')
          )
        ])]
      )
    }

    let(:aw1) {
      Hiptest::Nodes::Actionword.new('aw1', [],
        [Hiptest::Nodes::Parameter.new('p1')],
        [Hiptest::Nodes::Call.new('aw3', [
          Hiptest::Nodes::Argument.new('p3',
            Hiptest::Nodes::Variable.new('p1')
          )
        ])]
      )
    }

    let(:project) {
      Hiptest::Nodes::Project.new('My project', '', nil,
        Hiptest::Nodes::Scenarios.new([scenario]),
        Hiptest::Nodes::Actionwords.new([aw1, aw2, aw3, aw4]))
    }

    let(:parameters_mapping) {
      project.children[:actionwords].children[:actionwords].map do |aw|
        {
          name: aw.children[:name],
          parameters: aw.children[:parameters].map {|param|
            {name: param.children[:name], type: param.children[:type]}
          }
        }
      end
    }

    it 'forwards correctly the parameter values' do
      Hiptest::NodeModifiers::ParameterTypeAdder.add(project)

      expect(parameters_mapping).to eq([
        {name: "aw1", parameters: [{name: 'p1', type: :int}]},
        {name: "aw2", parameters: [{name: 'p2', type: :bool}]},
        {name: "aw3", parameters: [{name: 'p3', type: :int}]},
        {name: "aw4", parameters: [{name: 'p4', type: :bool}]}])

    end
  end

  context 'UID calls' do
    let(:actionword_uid) {'87654321-4321-4321-4321-098765432121'}
    let(:actionword) {
      make_actionword('My second action word', uid: actionword_uid, parameters: [make_parameter('some_param')])
    }
    let(:scenario) {
      make_scenario('My calling scenario',
        body: [make_uidcall(actionword_uid, arguments: [make_argument('some_param', literal(42))])]
      )
    }
    let(:project) {
      make_project('My project', scenarios: [scenario], actionwords: [actionword])
    }

    it 'are also taken into account when typing the actionword parameters' do
      Hiptest::NodeModifiers::UidCallReferencerAdder.add(project)
      Hiptest::NodeModifiers::ParameterTypeAdder.add(project)

      expect(actionword.children[:parameters].first.children[:type]).to eq(:int)
    end
  end
end


def type_adding(parameter, *called_values)
  calls = called_values.map{|called_value|
    Hiptest::Nodes::Call.new('aw', [Hiptest::Nodes::Argument.new('x', called_value)])
  }

  actionwords = Hiptest::Nodes::Actionwords.new([
    Hiptest::Nodes::Actionword.new('aw', [], [parameter], [])
  ])

  scenarios = Hiptest::Nodes::Scenarios.new([
    Hiptest::Nodes::Scenario.new('many calls scenarios', '', [], [], calls)
  ])
  project = Hiptest::Nodes::Project.new('My project', '', nil, scenarios, actionwords)

  Hiptest::NodeModifiers::ParameterTypeAdder.add(project)
  parameter
end
