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

shared_examples "a renderer" do
  it 'NullLiteral' do
    @null.render(language).should eq(@null_rendered)
  end

  it 'StringLiteral' do
    @what_is_your_quest.render(language).should eq(@what_is_your_quest_rendered)
  end

  it 'NumericLiteral' do
    @pi.render('ruby').should eq(@pi_rendered)
  end

  it 'BooleanLiteral' do
    @false.render('ruby').should eq(@false_rendered)
  end

  it 'Variable' do
    @foo_variable.render('ruby').should eq(@foo_variable_rendered)
  end

  it 'Property' do
    @foo_fighters_prop.render('ruby').should eq(@foo_fighters_prop_rendered)
  end

  it 'Field' do
    @foo_dot_fighters.render('ruby').should eq(@foo_dot_fighters_rendered)
  end

  it 'Index' do
    @foo_brackets_fighters.render('ruby').should eq(@foo_brackets_fighters_rendered)
  end

  it 'BinaryExpression' do
    @foo_minus_fighters.render('ruby').should eq(@foo_minus_fighters_rendered)
  end

  it 'UnaryExpression' do
    @minus_foo.render('ruby').should eq(@minus_foo_rendered)
  end

  it 'Parenthesis' do
    @parenthesis_foo.render('ruby').should eq(@parenthesis_foo_rendered)
  end

  it 'List' do
    @foo_list.render('ruby').should eq(@foo_list_rendered)
  end

  it 'Dict' do
    @foo_dict.render('ruby').should eq(@foo_dict_rendered)
  end

  it 'Template' do
    @foo_template.render('ruby').should eq(@foo_template_rendered)
  end

  it 'Assign' do
    @assign_fighters_to_foo.render('ruby').should eq(@assign_fighters_to_foo_rendered)
  end

  it 'Call' do
    @call_foo.render('ruby').should eq(@call_foo_rendered)
    @call_foo_with_fighters.render('ruby').should eq(@call_foo_with_fighters_rendered)
  end

  it 'IfThen' do
    @if_then.render('ruby').should eq(@if_then_rendered)
    @if_then_else.render('ruby').should eq(@if_then_else_rendered)
  end

  it "Step" do
    @action_foo_fighters.render('ruby').should eq(@action_foo_fighters_rendered)
  end

  it 'While' do
    @while_loop.render('ruby').should eq(@while_loop_rendered)
  end

  it 'Tag' do
    @simple_tag.render('ruby').should eq(@simple_tag_rendered)
    @valued_tag.render('ruby').should eq(@valued_tag_rendered)
  end

  it 'Parameter' do
    @plic_param.render('ruby').should eq(@plic_param_rendered)
    @plic_param_default_ploc.render('ruby').should eq(@plic_param_default_ploc_rendered)
  end

  context 'Actionword' do
    it 'empty' do
      @empty_action_word.render('ruby').should eq(@empty_action_word_rendered)
    end

    it 'with tags' do
      @tagged_action_word.render('ruby').should eq(@tagged_action_word_rendered)
    end

    it 'with parameters' do
      @parameterized_action_word.render('ruby').should eq(@parameterized_action_word_rendered)
    end

    it 'with body' do
      @full_actionword.render('ruby').should eq(@full_actionword_rendered)
    end
  end

  it 'Scenario' do
    @full_scenario.render('ruby').should eq(@full_scenario_rendered)
  end

  it 'Actionwords' do
    @actionwords.render('ruby').should eq(@actionwords_rendered)
  end

  it 'Scenarios' do
    @scenarios.render('ruby', {call_prefix: 'actionwords'}).should eq(@scenarios_rendered)
  end
end