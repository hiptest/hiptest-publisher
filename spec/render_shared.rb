require_relative '../nodes'

shared_context "shared render" do
  before(:all) do
    @null = Zest::Nodes::NullLiteral.new
    @what_is_your_quest = Zest::Nodes::StringLiteral.new("What is your quest ?")
    @fighters = Zest::Nodes::StringLiteral.new('fighters')
    @pi = Zest::Nodes::NumericLiteral.new(3.14)
    @false = Zest::Nodes::BooleanLiteral.new(false)
    @true = Zest::Nodes::BooleanLiteral.new(true)
    @foo_variable = Zest::Nodes::Variable.new('foo')
    @x_variable = Zest::Nodes::Variable.new('x')

    @foo_fighters_prop = Zest::Nodes::Property.new(@foo_variable, @fighters)
    @foo_dot_fighters = Zest::Nodes::Field.new(@foo_variable, 'fighters')
    @foo_brackets_fighters = Zest::Nodes::Index.new(@foo_variable, @fighters)
    @foo_minus_fighters = Zest::Nodes::BinaryExpression.new(@foo_variable, '-', @fighters)
    @minus_foo = Zest::Nodes::UnaryExpression.new('-', @foo_variable)
    @parenthesis_foo = Zest::Nodes::Parenthesis.new(@foo_variable)

    @foo_list = Zest::Nodes::List.new([@foo_variable, @fighters])
    @foo_dict =  Zest::Nodes::Dict.new([@foo_fighters_prop,
      Zest::Nodes::Property.new('Alt', 'J')
    ])

    @simple_template = Zest::Nodes::Template.new([
      Zest::Nodes::StringLiteral.new('A simple template')
    ])

    @foo_template = Zest::Nodes::Template.new([@foo_variable, @fighters])
    @assign_fighters_to_foo = Zest::Nodes::Assign.new(@foo_variable, @fighters)
    @assign_foo_to_fighters = Zest::Nodes::Assign.new(
      Zest::Nodes::Variable.new('fighters'),
      Zest::Nodes::StringLiteral.new('foo'))
    @call_foo = Zest::Nodes::Call.new('foo')
    @call_foo_with_fighters = Zest::Nodes::Call.new('foo', [@fighters])

    @simple_tag = Zest::Nodes::Tag.new('myTag')
    @valued_tag = Zest::Nodes::Tag.new('myTag', 'somevalue')

    @plic_param = Zest::Nodes::Parameter.new('plic')
    @x_param = Zest::Nodes::Parameter.new('x')
    @plic_param_default_ploc = Zest::Nodes::Parameter.new(
      'plic',
      Zest::Nodes::StringLiteral.new('ploc'))
    @flip_param_default_flap = Zest::Nodes::Parameter.new(
      'flip',
      Zest::Nodes::StringLiteral.new('flap'))

    @action_foo_fighters = Zest::Nodes::Step.new([
      Zest::Nodes::Property.new('action', @foo_template)
    ])

    @if_then = Zest::Nodes::IfThen.new(@true, [@assign_fighters_to_foo])
    @if_then_else = Zest::Nodes::IfThen.new(
      @true, [@assign_fighters_to_foo], [@assign_foo_to_fighters])
    @while_loop = Zest::Nodes::While.new(
      @foo_variable,
      [
        @assign_foo_to_fighters,
        @call_foo_with_fighters
      ])

    @empty_action_word = Zest::Nodes::Actionword.new('my action word')
    @tagged_action_word = Zest::Nodes::Actionword.new(
      'my action word',
      [@simple_tag, @valued_tag])
    @parameterized_action_word = Zest::Nodes::Actionword.new(
      'my action word',
      [],
      [@plic_param, @flip_param_default_flap])

    full_body = [
      Zest::Nodes::Assign.new(@foo_variable, @pi),
      Zest::Nodes::IfThen.new(
        Zest::Nodes::BinaryExpression.new(
          @foo_variable,
          '>',
          @x_variable),
        [
          Zest::Nodes::Step.new([
            Zest::Nodes::Property.new('result', "x is greater than Pi")
            ])
        ],
        [
          Zest::Nodes::Step.new([
            Zest::Nodes::Property.new('result', "x is lower than Pi\n on two lines")
          ])
        ])
      ]

    @full_actionword = Zest::Nodes::Actionword.new(
      'compare to pi',
      [@simple_tag],
      [@x_param],
      full_body)

    @full_scenario = Zest::Nodes::Scenario.new(
      'compare to pi',
       "This is a scenario which description \nis on two lines",
      [@simple_tag],
      [@x_param],
      full_body)

    @actionwords = Zest::Nodes::Actionwords.new([
      Zest::Nodes::Actionword.new('first action word'),
      Zest::Nodes::Actionword.new(
        'second action word', [], [], [
          Zest::Nodes::Call.new('first action word')
        ])
    ])
    @scenarios = Zest::Nodes::Scenarios.new([
      Zest::Nodes::Scenario.new('first scenario'),
      Zest::Nodes::Scenario.new(
        'second scenario', '', [], [], [
          Zest::Nodes::Call.new('my action word')
        ])
    ])
    @scenarios.parent = Zest::Nodes::Project.new('My_project')
  end
end
