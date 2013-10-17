require 'colorize'
require_relative '../nodes'

describe Zest::Nodes do
  context 'render' do
    it 'NullLiteral' do
      n = Zest::Nodes::NullLiteral.new
      n.render.should eq('nil')
    end

    it 'StringLiteral' do
      n = Zest::Nodes::StringLiteral.new("What is your quest ?")
      n.render.should eq("'What is your quest ?'")
    end

    it 'NumericLiteral' do
      n = Zest::Nodes::NumericLiteral.new(3.14)
      n.render.should eq('3.14')
    end

    it 'BooleanLiteral' do
      n = Zest::Nodes::BooleanLiteral.new(false)
      n.render.should eq('false')
    end

    it 'Variable' do
      n = Zest::Nodes::Variable.new('foo')
      n.render.should eq('foo')
    end

    it 'Property' do
      n = Zest::Nodes::Property.new('foo', 'fighters')
      n.render.should eq('foo: fighters')
    end

    it 'Field' do
      n = Zest::Nodes::Field.new('foo', 'fighters')
      n.render.should eq('foo.fighters')
    end

    it 'Index' do
      n = Zest::Nodes::Index.new('foo', 'fighters')
      n.render.should eq('foo[fighters]')
    end

    it 'BinaryExpression' do
      n = Zest::Nodes::BinaryExpression.new('foo', '-', 'fighters')
      n.render.should eq('foo - fighters')
    end

    it 'UnaryExpression' do
      n = Zest::Nodes::UnaryExpression.new('-', 'foo')
      n.render.should eq('-foo')
    end

    it 'Parenthesis' do
      n = Zest::Nodes::Parenthesis.new('foo fighters')
      n.render.should eq('(foo fighters)')
    end

    it 'List' do
      n = Zest::Nodes::List.new([
        Zest::Nodes::Variable.new('foo'),
        Zest::Nodes::StringLiteral.new('fighters')
      ])
      n.render.should eq("[foo, 'fighters']")
    end

    it 'Dict' do
      n = Zest::Nodes::Dict.new([
        Zest::Nodes::Property.new('foo', 'fighters'),
        Zest::Nodes::Property.new('Alt', 'J')
      ])
      n.render.should eq('{foo: fighters, Alt: J}')
    end

    it 'Template' do
      n = Zest::Nodes::Template.new([
        Zest::Nodes::Variable.new('foo'),
        Zest::Nodes::StringLiteral.new(' fighters')
      ])
      n.render.should eq('"#{foo} fighters"')
    end

    it 'Assign' do
      n = Zest::Nodes::Assign.new(
        Zest::Nodes::Variable.new('foo'),
        Zest::Nodes::StringLiteral.new('fighters')
      )
      n.render.should eq("foo = 'fighters'\n")
    end

    it 'Call' do
      n = Zest::Nodes::Call.new('foo')
      n.render.should eq("foo()\n")

      n = Zest::Nodes::Call.new('foo', [
        Zest::Nodes::StringLiteral.new('fighters')
      ])
      n.render.should eq("foo('fighters')\n")
    end

    it 'IfThen' do
      n = Zest::Nodes::IfThen.new(
        Zest::Nodes::BooleanLiteral.new(true),
        [
          Zest::Nodes::Assign.new(
            Zest::Nodes::Variable.new('foo'),
            Zest::Nodes::StringLiteral.new('fighters')
          )
        ])
      n.render.should eq([
          "if true",
          "  foo = 'fighters'",
          "end\n"
        ].join("\n"))

      n = Zest::Nodes::IfThen.new(
        Zest::Nodes::BooleanLiteral.new(true),
        [
          Zest::Nodes::Assign.new(
            Zest::Nodes::Variable.new('foo'),
            Zest::Nodes::StringLiteral.new('fighters')
          )
        ],
        [
          Zest::Nodes::Assign.new(
            Zest::Nodes::Variable.new('fighters'),
            Zest::Nodes::StringLiteral.new('foo')
          )
        ])
      n.render.should eq([
          "if true",
          "  foo = 'fighters'",
          "else",
          "  fighters = 'foo'",
          "end\n"
        ].join("\n"))
    end

    it "Step" do
      n = Zest::Nodes::Step.new([
        Zest::Nodes::Property.new('action', Zest::Nodes::Template.new([
          Zest::Nodes::Variable.new('foo'),
          Zest::Nodes::StringLiteral.new(' fighters')
        ]))
      ])

      n.render.should eq('# TODO: Implement action: "#{foo} fighters"')
    end

    it 'While' do
      n = Zest::Nodes::While.new(
        Zest::Nodes::Variable.new('foo'),
        [
          Zest::Nodes::Assign.new(
            Zest::Nodes::Variable.new('foo'),
            Zest::Nodes::NumericLiteral.new(0)
          ),
          Zest::Nodes::Call.new('foo', [
            Zest::Nodes::StringLiteral.new('fighters')
          ])
        ])
      n.render.should eq([
          "while foo",
          "  foo = 0",
          "  foo('fighters')",
          "end\n"
        ].join("\n"))
    end

    it 'Tag' do
      n = Zest::Nodes::Tag.new('myTag')
      n.render.should eq('myTag')

      n = Zest::Nodes::Tag.new('myTag', 'somevalue')
      n.render.should eq('myTag:somevalue')
    end

    it 'Parameter' do
      n = Zest::Nodes::Parameter.new('plic')
      n.render.should eq('plic')

      n = Zest::Nodes::Parameter.new(
        'plic',
        Zest::Nodes::StringLiteral.new('ploc'))
      n.render.should eq("plic = 'ploc'")
    end

    context 'Actionword' do
      it 'empty' do
        n = Zest::Nodes::Actionword.new('my action word')
        n.render.should eq("def my_action_word()\nend")
      end

      it 'with tags' do
        n = Zest::Nodes::Actionword.new(
          'my action word',
          [
            Zest::Nodes::Tag.new('myTag'),
            Zest::Nodes::Tag.new('myTag', 'somevalue')
          ])
        n.render.should eq([
          "def my_action_word()",
          "  # Tags: myTag myTag:somevalue",
          "end"].join("\n"))
      end

      it 'with parameters' do
        n = Zest::Nodes::Actionword.new(
          'my action word',
          [],
          [
            Zest::Nodes::Parameter.new('plic'),
            Zest::Nodes::Parameter.new('flip', 'flap')
          ])
        n.render.should eq([
          "def my_action_word(plic, flip = flap)",
          "end"].join("\n"))
      end

      it 'with body' do
        n = Zest::Nodes::Actionword.new(
          'compare to pi',
          [Zest::Nodes::Tag.new('my', 'Tag')],
          [Zest::Nodes::Parameter.new('x')],
          [
            Zest::Nodes::Assign.new(
              Zest::Nodes::Variable.new('y'),
              Zest::Nodes::NumericLiteral.new(3.14)
            ),
            Zest::Nodes::IfThen.new(
              Zest::Nodes::Parenthesis.new(
                Zest::Nodes::BinaryExpression.new(
                  Zest::Nodes::Variable.new('y'),
                  '>',
                  Zest::Nodes::Variable.new('x')
                )
              ),
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
            ])
          n.render.should eq([
            "def compare_to_pi(x)",
            "  # Tags: my:Tag",
            "  y = 3.14",
            "  if (y > x)",
            "    # TODO: Implement result: x is greater than Pi",
            "  else",
            "    # TODO: Implement result: x is lower than Pi",
            "    # on two lines",
            "  end",
            "end"].join("\n"))
      end
    end

    it 'Scenario' do
      n = Zest::Nodes::Scenario.new(
        'compare to pi',
        "This is a scenario which description \nis on two lines",
        [Zest::Nodes::Tag.new('my', 'Tag')],
        [Zest::Nodes::Parameter.new('x')],
        [
          Zest::Nodes::Assign.new(
            Zest::Nodes::Variable.new('y'),
            Zest::Nodes::NumericLiteral.new(3.14)
          ),
          Zest::Nodes::IfThen.new(
            Zest::Nodes::Parenthesis.new(
              Zest::Nodes::BinaryExpression.new(
                Zest::Nodes::Variable.new('y'),
                '>',
                Zest::Nodes::Variable.new('x')
              )
            ),
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
          ])
        n.render.should eq([
          "it 'compare to pi' do",
          "  # This is a scenario which description ",
          "  # is on two lines",
          "  # Tags: my:Tag",
          "  y = 3.14",
          "  if (y > x)",
          "    # TODO: Implement result: x is greater than Pi",
          "  else",
          "    # TODO: Implement result: x is lower than Pi",
          "    # on two lines",
          "  end",
          "end"].join("\n"))
    end

    it 'Actionwords' do
      n = Zest::Nodes::Actionwords.new([
        Zest::Nodes::Actionword.new('first action word'),
        Zest::Nodes::Actionword.new(
          'second action word', [], [], [
            Zest::Nodes::Call.new('first action word')
          ])
      ])
      n.render.should eq([
        "# encoding: UTF-8",
        "",
        "class Actionwords",
        "  def first_action_word()",
        "  end",
        "  def second_action_word()",
        "    first_action_word()",
        "  end",
        "end"].join("\n"))
    end

    it 'Scenarios' do
      n = Zest::Nodes::Scenarios.new([
        Zest::Nodes::Scenario.new('first scenario'),
        Zest::Nodes::Scenario.new(
          'second scenario', '', [], [], [
            Zest::Nodes::Call.new('my action word')
          ])
      ])
      n.parent = Zest::Nodes::Project.new('My_project')
      n.parent.render

      n.render('ruby', {call_prefix: 'actionwords'}).should eq([
        "# encoding: UTF-8",
        "require_relative 'actionwords'",
        "",
        "describe 'My_project' do",
        "  before (:all) do",
        "    @actionwords = My_project::ActionWords.new",
        "  end",
        "",
        "  it 'first scenario' do",
        "  end",
        "  it 'second scenario' do",
        "    @actionwords.my_action_word()",
        "  end",
        "end"].join("\n"))
    end
  end
end