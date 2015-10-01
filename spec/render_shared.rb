require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/parameter_type_adder'
require_relative '../lib/hiptest-publisher/nodes'
require_relative '../lib/hiptest-publisher/options_parser'

shared_context "shared render" do

  before(:each) do
    @null = Hiptest::Nodes::NullLiteral.new
    @what_is_your_quest = Hiptest::Nodes::StringLiteral.new("What is your quest ?")
    @fighters = Hiptest::Nodes::StringLiteral.new('fighters')
    @pi = Hiptest::Nodes::NumericLiteral.new('3.14')
    @false = Hiptest::Nodes::BooleanLiteral.new(false)
    @true = Hiptest::Nodes::BooleanLiteral.new(true)
    @foo_variable = Hiptest::Nodes::Variable.new('foo')
    @foo_bar_variable = Hiptest::Nodes::Variable.new('foo bar')
    @x_variable = Hiptest::Nodes::Variable.new('x')

    @foo_fighters_prop = Hiptest::Nodes::Property.new(@foo_variable, @fighters)
    @foo_dot_fighters = Hiptest::Nodes::Field.new(@foo_variable, 'fighters')
    @foo_brackets_fighters = Hiptest::Nodes::Index.new(@foo_variable, @fighters)
    @foo_minus_fighters = Hiptest::Nodes::BinaryExpression.new(@foo_variable, '-', @fighters)
    @minus_foo = Hiptest::Nodes::UnaryExpression.new('-', @foo_variable)
    @parenthesis_foo = Hiptest::Nodes::Parenthesis.new(@foo_variable)

    @foo_list = Hiptest::Nodes::List.new([@foo_variable, @fighters])
    @foo_dict =  Hiptest::Nodes::Dict.new([@foo_fighters_prop,
      Hiptest::Nodes::Property.new('Alt', 'J')
    ])

    @simple_template = Hiptest::Nodes::Template.new([
      Hiptest::Nodes::StringLiteral.new('A simple template')
    ])

    @foo_template = Hiptest::Nodes::Template.new([@foo_variable, @fighters])
    @double_quotes_template = Hiptest::Nodes::Template.new([
      Hiptest::Nodes::StringLiteral.new('Fighters said "Foo !"')
    ])

    @assign_fighters_to_foo = Hiptest::Nodes::Assign.new(@foo_variable, @fighters)
    @assign_foo_to_fighters = Hiptest::Nodes::Assign.new(
      Hiptest::Nodes::Variable.new('fighters'),
      Hiptest::Nodes::StringLiteral.new('foo'))
    @call_foo = Hiptest::Nodes::Call.new('foo')
    @call_foo_bar = Hiptest::Nodes::Call.new('foo bar')
    @argument = Hiptest::Nodes::Argument.new('x', @fighters)
    @call_foo_with_fighters = Hiptest::Nodes::Call.new('foo', [@argument])
    @call_foo_bar_with_fighters = Hiptest::Nodes::Call.new('foo bar', [@argument])

    @simple_tag = Hiptest::Nodes::Tag.new('myTag')
    @valued_tag = Hiptest::Nodes::Tag.new('myTag', 'somevalue')

    @plic_param = Hiptest::Nodes::Parameter.new('plic')
    @x_param = Hiptest::Nodes::Parameter.new('x')
    @plic_param_default_ploc = Hiptest::Nodes::Parameter.new(
      'plic',
      Hiptest::Nodes::StringLiteral.new('ploc'))
    @flip_param_default_flap = Hiptest::Nodes::Parameter.new(
      'flip',
      Hiptest::Nodes::StringLiteral.new('flap'))

    @action_foo_fighters = Hiptest::Nodes::Step.new('action', @foo_template)

    @if_then = Hiptest::Nodes::IfThen.new(@true, [@assign_fighters_to_foo])
    @if_then_else = Hiptest::Nodes::IfThen.new(
      @true, [@assign_fighters_to_foo], [@assign_foo_to_fighters])
    @while_loop = Hiptest::Nodes::While.new(
      @foo_variable,
      [
        @assign_foo_to_fighters,
        @call_foo_with_fighters
      ])

    @empty_action_word = Hiptest::Nodes::Actionword.new('my action word')
    @tagged_action_word = Hiptest::Nodes::Actionword.new(
      'my action word',
      [@simple_tag, @valued_tag])
    @parameterized_action_word = Hiptest::Nodes::Actionword.new(
      'my action word',
      [],
      [@plic_param, @flip_param_default_flap])

    full_body = [
      Hiptest::Nodes::Assign.new(@foo_variable, @pi),
      Hiptest::Nodes::IfThen.new(
        Hiptest::Nodes::BinaryExpression.new(
          @foo_variable,
          '>',
          @x_variable),
        [
          Hiptest::Nodes::Step.new('result', "x is greater than Pi")
        ],
        [
          Hiptest::Nodes::Step.new('result', "x is lower than Pi\non two lines")
        ])
      ]

    @full_actionword = Hiptest::Nodes::Actionword.new(
      'compare to pi',
      [@simple_tag],
      [@x_param],
      full_body)

    @step_action_word = Hiptest::Nodes::Actionword.new(
      'my action word',
      [],
      [],
      [Hiptest::Nodes::Step.new('action', "basic action")])

    @full_scenario = Hiptest::Nodes::Scenario.new(
      'compare to pi',
       "This is a scenario which description \nis on two lines",
      [@simple_tag],
      [@x_param],
      full_body)
    @full_scenario.parent = Hiptest::Nodes::Scenarios.new([])
    @full_scenario.parent.parent = Hiptest::Nodes::Project.new('My project')


    @dataset1 = Hiptest::Nodes::Dataset.new('Wrong login', [
      Hiptest::Nodes::Argument.new('login', Hiptest::Nodes::StringLiteral.new('invalid')),
      Hiptest::Nodes::Argument.new('password', Hiptest::Nodes::StringLiteral.new('invalid')),
      Hiptest::Nodes::Argument.new('expected', Hiptest::Nodes::StringLiteral.new('Invalid username or password'))
    ])

    @dataset2 = Hiptest::Nodes::Dataset.new('Wrong password', [
      Hiptest::Nodes::Argument.new('login', Hiptest::Nodes::StringLiteral.new('valid')),
      Hiptest::Nodes::Argument.new('password', Hiptest::Nodes::StringLiteral.new('invalid')),
      Hiptest::Nodes::Argument.new('expected', Hiptest::Nodes::StringLiteral.new('Invalid username or password'))
    ])

    @dataset3 = Hiptest::Nodes::Dataset.new('Valid login/password', [
      Hiptest::Nodes::Argument.new('login', Hiptest::Nodes::StringLiteral.new('valid')),
      Hiptest::Nodes::Argument.new('password', Hiptest::Nodes::StringLiteral.new('valid')),
      Hiptest::Nodes::Argument.new('expected', Hiptest::Nodes::NullLiteral.new())
    ])
    @datatable = Hiptest::Nodes::Datatable.new([@dataset1, @dataset2, @dataset3])
    [@dataset1, @dataset2, @dataset3].each {|dt| dt.parent = @datatable }

    @scenario_with_datatable = Hiptest::Nodes::Scenario.new(
      'check login',
      "Ensure the login process",
      [],
      [
        Hiptest::Nodes::Parameter.new('login'),
        Hiptest::Nodes::Parameter.new('password'),
        Hiptest::Nodes::Parameter.new('expected')
      ],
      [
        Hiptest::Nodes::Call.new('fill login', [
          Hiptest::Nodes::Argument.new('login', Hiptest::Nodes::Variable.new('login')),
        ]),
        Hiptest::Nodes::Call.new('fill password', [
          Hiptest::Nodes::Argument.new('password', Hiptest::Nodes::Variable.new('password')),
        ]),
        Hiptest::Nodes::Call.new('press enter'),
        Hiptest::Nodes::Call.new('assert "error" is displayed', [
          Hiptest::Nodes::Argument.new('error', Hiptest::Nodes::Variable.new('expected')),
        ])
      ],
      nil,
      @datatable)
    @datatable.parent = @scenario_with_datatable
    @scenario_with_datatable.parent = Hiptest::Nodes::Scenarios.new([])
    @scenario_with_datatable.parent.parent = Hiptest::Nodes::Project.new('A project with datatables')

    @actionwords = Hiptest::Nodes::Actionwords.new([
      Hiptest::Nodes::Actionword.new('first action word'),
      Hiptest::Nodes::Actionword.new(
        'second action word', [], [], [
          Hiptest::Nodes::Call.new('first action word')
        ])
    ])

    @scenarios = Hiptest::Nodes::Scenarios.new([
      Hiptest::Nodes::Scenario.new('first scenario'),
      Hiptest::Nodes::Scenario.new(
        'second scenario', '', [], [], [
          Hiptest::Nodes::Call.new('my action word')
        ])
    ])
    @scenarios.parent = Hiptest::Nodes::Project.new('My project')

    @actionwords_with_parameters = Hiptest::Nodes::Actionwords.new([
      Hiptest::Nodes::Actionword.new('aw with int param', [], [Hiptest::Nodes::Parameter.new('x')], []),
      Hiptest::Nodes::Actionword.new('aw with float param', [], [Hiptest::Nodes::Parameter.new('x')], []),
      Hiptest::Nodes::Actionword.new('aw with boolean param', [], [Hiptest::Nodes::Parameter.new('x')], []),
      Hiptest::Nodes::Actionword.new('aw with null param', [], [Hiptest::Nodes::Parameter.new('x')], []),
      Hiptest::Nodes::Actionword.new('aw with string param', [], [Hiptest::Nodes::Parameter.new('x')], []),
      Hiptest::Nodes::Actionword.new('aw with template param', [], [Hiptest::Nodes::Parameter.new('x')], [])
    ])

    @scenarios_with_many_calls = Hiptest::Nodes::Scenarios.new([
      Hiptest::Nodes::Scenario.new('many calls scenarios', '', [], [], [
        Hiptest::Nodes::Call.new('aw with int param', [
          Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::NumericLiteral.new('3'))]),
        Hiptest::Nodes::Call.new('aw with float param', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::NumericLiteral.new('4.2')
          )]),
        Hiptest::Nodes::Call.new('aw with boolean param', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::BooleanLiteral.new(true)
          )]),
        Hiptest::Nodes::Call.new('aw_with_null_param', [
          Hiptest::Nodes::Argument.new('x',
            Hiptest::Nodes::NullLiteral.new
          )]),
        Hiptest::Nodes::Call.new('aw with string param', [
          Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('toto'))]),
        Hiptest::Nodes::Call.new('aw with string param', [
          Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::Template.new(Hiptest::Nodes::StringLiteral.new('toto')))])
      ])])

    @project = Hiptest::Nodes::Project.new('My project', "", nil, @scenarios_with_many_calls, @actionwords_with_parameters)

    @first_test = Hiptest::Nodes::Test.new(
      'Login',
      "The description is on \ntwo lines",
      [@simple_tag, @valued_tag],
      [
        Hiptest::Nodes::Call.new('visit', [
          Hiptest::Nodes::Argument.new('url', Hiptest::Nodes::StringLiteral.new('/login'))
        ]),
        Hiptest::Nodes::Call.new('fill', [
          Hiptest::Nodes::Argument.new('login', Hiptest::Nodes::StringLiteral.new('user@example.com'))
        ]),
        Hiptest::Nodes::Call.new('fill', [
          Hiptest::Nodes::Argument.new('password', Hiptest::Nodes::StringLiteral.new('s3cret'))
        ]),
        Hiptest::Nodes::Call.new('click', [
          Hiptest::Nodes::Argument.new('path', Hiptest::Nodes::StringLiteral.new('.login-form input[type=submit]'))
        ]),
        Hiptest::Nodes::Call.new('checkUrl', [
          Hiptest::Nodes::Argument.new('path', Hiptest::Nodes::StringLiteral.new('/welcome')
        )])
      ])

    @second_test = Hiptest::Nodes::Test.new(
      'Failed login',
      '',
      [@valued_tag],
      [
        Hiptest::Nodes::Call.new('visit', [
          Hiptest::Nodes::Argument.new('url', Hiptest::Nodes::StringLiteral.new('/login'))
        ]),
        Hiptest::Nodes::Call.new('fill', [
          Hiptest::Nodes::Argument.new('login', Hiptest::Nodes::StringLiteral.new('user@example.com'))
        ]),
        Hiptest::Nodes::Call.new('fill', [
          Hiptest::Nodes::Argument.new('password', Hiptest::Nodes::StringLiteral.new('notTh4tS3cret'))
        ]),
        Hiptest::Nodes::Call.new('click', [
          Hiptest::Nodes::Argument.new('path', Hiptest::Nodes::StringLiteral.new('.login-form input[type=submit]'))
        ]),
        Hiptest::Nodes::Call.new('checkUrl', [
          Hiptest::Nodes::Argument.new('path', Hiptest::Nodes::StringLiteral.new('/login')
        )])
      ])
    @second_test

    @tests = Hiptest::Nodes::Tests.new([@first_test, @second_test])
    @first_test.parent = @tests
    @second_test.parent = @tests
    @tests.parent = Hiptest::Nodes::Project.new('My test project')

    @context = context_for(
      # group_name to select in tests if we render from [actionwords] group or [tests] group
      group_name: group_name,
      # test_name to customize the resulting file name (used by java for the class name)
      test_name: test_name,
      # in tests, simulate user options like --language, --framework, --split_scenarios, or package= (in config file)
      language: language,
      framework: framework,
      split_scenarios: split_scenarios,
      package: package)
  end
end

shared_examples "a renderer" do

  let(:split_scenarios) { nil }
  let(:test_name) { nil }
  let(:package) { nil } # only used for Java

  context "[tests] group" do
    let(:group_name) { 'tests' }

    it 'NullLiteral' do
      expect(@null.render(@context)).to eq(@null_rendered)
    end

    it 'StringLiteral' do
      expect(@what_is_your_quest.render(@context)).to eq(@what_is_your_quest_rendered)
    end

    it 'NumericLiteral' do
      expect(@pi.render(@context)).to eq(@pi_rendered)
    end

    it 'BooleanLiteral' do
      expect(@false.render(@context)).to eq(@false_rendered)
    end

    it 'Variable' do
      expect(@foo_variable.render(@context)).to eq(@foo_variable_rendered)
    end

    it 'Variable' do
      expect(@foo_variable.render(@context)).to eq(@foo_variable_rendered)
    end

    it 'Property' do
      expect(@foo_fighters_prop.render(@context)).to eq(@foo_fighters_prop_rendered)
    end

    it 'Field' do
      expect(@foo_dot_fighters.render(@context)).to eq(@foo_dot_fighters_rendered)
    end

    it 'Index' do
      expect(@foo_brackets_fighters.render(@context)).to eq(@foo_brackets_fighters_rendered)
    end

    it 'BinaryExpression' do
      expect(@foo_minus_fighters.render(@context)).to eq(@foo_minus_fighters_rendered)
    end

    it 'UnaryExpression' do
      expect(@minus_foo.render(@context)).to eq(@minus_foo_rendered)
    end

    it 'Parenthesis' do
      expect(@parenthesis_foo.render(@context)).to eq(@parenthesis_foo_rendered)
    end

    it 'List' do
      expect(@foo_list.render(@context)).to eq(@foo_list_rendered)
    end

    it 'Dict' do
      expect(@foo_dict.render(@context)).to eq(@foo_dict_rendered)
    end

    it 'Template' do
      expect(@foo_template.render(@context)).to eq(@foo_template_rendered)
      expect(@double_quotes_template.render(@context)).to eq(@double_quotes_template_rendered)
    end

    it 'Assign' do
      expect(@assign_fighters_to_foo.render(@context)).to eq(@assign_fighters_to_foo_rendered)
    end

    it 'Call' do
      expect(@call_foo.render(@context)).to eq(@call_foo_rendered)
      expect(@call_foo_bar.render(@context)).to eq(@call_foo_bar_rendered)
      expect(@call_foo_with_fighters.render(@context)).to eq(@call_foo_with_fighters_rendered)
      expect(@call_foo_bar_with_fighters.render(@context)).to eq(@call_foo_bar_with_fighters_rendered)
    end

    it 'IfThen' do
      expect(@if_then.render(@context)).to eq(@if_then_rendered)
      expect(@if_then_else.render(@context)).to eq(@if_then_else_rendered)
    end

    it "Step" do
      expect(@action_foo_fighters.render(@context)).to eq(@action_foo_fighters_rendered)
    end

    it 'While' do
      expect(@while_loop.render(@context)).to eq(@while_loop_rendered)
    end

    it 'Tag' do
      expect(@simple_tag.render(@context)).to eq(@simple_tag_rendered)
      expect(@valued_tag.render(@context)).to eq(@valued_tag_rendered)
    end

    it 'Parameter' do
      expect(@plic_param.render(@context)).to eq(@plic_param_rendered)
      expect(@plic_param_default_ploc.render(@context)).to eq(@plic_param_default_ploc_rendered)
    end

    context 'Actionword' do
      it 'empty' do
        expect(@empty_action_word.render(@context)).to eq(@empty_action_word_rendered)
      end

      it 'with tags' do
        expect(@tagged_action_word.render(@context)).to eq(@tagged_action_word_rendered)
      end

      it 'with parameters' do
        expect(@parameterized_action_word.render(@context)).to eq(@parameterized_action_word_rendered)
      end

      it 'with body' do
        expect(@full_actionword.render(@context)).to eq(@full_actionword_rendered)
      end

      it 'with body that contains only step' do
        expect(@step_action_word.render(@context)).to eq(@step_action_word_rendered)
      end
    end

    context 'Scenario' do
      it 'can be rendered to be inserted in the scenarios list' do
        expect(@full_scenario.render(@context)).to eq(@full_scenario_rendered)
      end

      context 'with splitted files' do
        let(:split_scenarios) { true }

        it 'can also be rendered so it will be in a single file' do
          expect(@full_scenario.render(@context)).to eq(@full_scenario_rendered_for_single_file)
        end
      end

      it 'can be rendered with its datatable' do
        expect(@scenario_with_datatable.render(@context)).to eq(@scenario_with_datatable_rendered)
      end

      context 'with splitted files' do
        let(:split_scenarios) { true }

        it 'can be rendered with its datatable in a single file' do
          expect(@scenario_with_datatable.render(@context)).to eq(@scenario_with_datatable_rendered_in_single_file)
        end
      end

      it 'the UID is displayed in the name if set' do
        @full_scenario.set_uid('abcd-1234')
        expect(@full_scenario.render(@context)).to eq(@full_scenario_with_uid_rendered)
      end

      it 'when the uid is set at the dataset level, it is rendered in the dataset export name' do
        uids = ['a-123', 'b-456', 'c-789']
        @scenario_with_datatable.children[:datatable].children[:datasets].each_with_index do |dataset, index|
          dataset.set_uid(uids[index])
        end

        expect(@scenario_with_datatable.render(@context)).to eq(
          @scenario_with_datatable_rendered_with_uids)
      end
    end


    it 'Scenarios' do
      expect(@scenarios.render(@context)).to eq(@scenarios_rendered)
    end

    context 'Test' do
      it 'can be rendered to be inserted in the tests list' do
        expect(@first_test.render(@context)).to eq(@first_test_rendered)
      end

      context 'with splitted files' do
        let(:split_scenarios) { true }

        it 'can also be rendered so it will be in a single file' do
          expect(@first_test.render(@context)).to eq(@first_test_rendered_for_single_file)
        end
      end
    end

    it 'Tests' do
      expect(@tests.render(@context)).to eq(@tests_rendered)
    end
  end

  context '[actionwords] group' do
    let(:group_name) { 'actionwords' }

    it 'Actionwords' do
      expect(@actionwords.render(@context)).to eq(@actionwords_rendered)
    end

    it 'Actionwords with parameters of different types' do
      Hiptest::Nodes::ParameterTypeAdder.add(@project)
      expect(@project.children[:actionwords].render(@context)).to eq(@actionwords_with_params_rendered)
    end
  end
end
