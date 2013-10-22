require_relative "render_shared"

describe 'Render as Ruby' do
  include_context "shared render"

  context 'render' do
    it 'NullLiteral' do
      @null.render('ruby').should eq('nil')
    end

    it 'StringLiteral' do
      @what_is_your_quest.render('ruby').should eq("'What is your quest ?'")
    end

    it 'NumericLiteral' do
      @pi.render('ruby').should eq('3.14')
    end

    it 'BooleanLiteral' do
      @false.render('ruby').should eq('false')
    end

    it 'Variable' do
      @foo_variable.render('ruby').should eq('foo')
    end

    it 'Property' do
      @foo_fighters_prop.render('ruby').should eq("foo: 'fighters'")
    end

    it 'Field' do
      @foo_dot_fighters.render('ruby').should eq('foo.fighters')
    end

    it 'Index' do
      @foo_brackets_fighters.render('ruby').should eq("foo['fighters']")
    end

    it 'BinaryExpression' do
      @foo_minus_fighters.render('ruby').should eq("foo - 'fighters'")
    end

    it 'UnaryExpression' do
      @minus_foo.render('ruby').should eq('-foo')
    end

    it 'Parenthesis' do
      @parenthesis_foo.render('ruby').should eq('(foo)')
    end

    it 'List' do
      @foo_list.render('ruby').should eq("[foo, 'fighters']")
    end

    it 'Dict' do
      @foo_dict.render('ruby').should eq("{foo: 'fighters', Alt: J}")
    end

    it 'Template' do
      @foo_template.render('ruby').should eq('"#{foo}fighters"')
    end

    it 'Assign' do
      @assign_fighters_to_foo.render('ruby').should eq("foo = 'fighters'\n")
    end

    it 'Call' do
      @call_foo.render('ruby').should eq("foo()\n")
      @call_foo_with_fighters.render('ruby').should eq("foo('fighters')\n")
    end

    it 'IfThen' do
      @if_then.render('ruby').should eq([
          "if (true)",
          "  foo = 'fighters'",
          "end\n"
        ].join("\n"))

      @if_then_else.render('ruby').should eq([
          "if (true)",
          "  foo = 'fighters'",
          "else",
          "  fighters = 'foo'",
          "end\n"
        ].join("\n"))
    end

    it "Step" do
      @action_foo_fighters.render('ruby').should eq('# TODO: Implement action: "#{foo}fighters"')
    end

    it 'While' do
      @while_loop.render('ruby').should eq([
          "while (foo)",
          "  fighters = 'foo'",
          "  foo('fighters')",
          "end\n"
        ].join("\n"))
    end

    it 'Tag' do
      @simple_tag.render('ruby').should eq('myTag')
      @valued_tag.render('ruby').should eq('myTag:somevalue')
    end

    it 'Parameter' do
      @plic_param.render('ruby').should eq('plic')
      @plic_param_default_ploc.render('ruby').should eq("plic = 'ploc'")
    end

    context 'Actionword' do
      it 'empty' do
        @empty_action_word.render('ruby').should eq("def my_action_word()\nend")
      end

      it 'with tags' do
        @tagged_action_word.render('ruby').should eq([
          "def my_action_word()",
          "  # Tags: myTag myTag:somevalue",
          "end"].join("\n"))
      end

      it 'with parameters' do
        @parameterized_action_word.render('ruby').should eq([
          "def my_action_word(plic, flip = 'flap')",
          "end"].join("\n"))
      end

      it 'with body' do
        @full_actionword.render('ruby').should eq([
          "def compare_to_pi(x)",
          "  # Tags: myTag",
          "  foo = 3.14",
          "  if (foo > x)",
          "    # TODO: Implement result: x is greater than Pi",
          "  else",
          "    # TODO: Implement result: x is lower than Pi",
          "    # on two lines",
          "  end",
          "end"].join("\n"))
      end
    end

    it 'Scenario' do
      @full_scenario.render('ruby').should eq([
        "it 'compare_to_pi' do",
        "  # This is a scenario which description ",
        "  # is on two lines",
        "  # Tags: myTag",
        "  foo = 3.14",
        "  if (foo > x)",
        "    # TODO: Implement result: x is greater than Pi",
        "  else",
        "    # TODO: Implement result: x is lower than Pi",
        "    # on two lines",
        "  end",
        "end"].join("\n"))
    end

    it 'Actionwords' do
      @actionwords.render('ruby').should eq([
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
      @scenarios.render('ruby', {call_prefix: 'actionwords'}).should eq([
        "# encoding: UTF-8",
        "require_relative 'actionwords'",
        "",
        "describe 'MyProject' do",
        "  before(:each) do",
        "    @actionwords = Actionwords.new",
        "  end",
        "",
        "  it 'first_scenario' do",
        "  end",
        "  it 'second_scenario' do",
        "    @actionwords.my_action_word()",
        "  end",
        "end"].join("\n"))
    end
  end
end