require_relative "render_shared"

describe 'Render as Ruby' do
  include_context "shared render"
  before(:each) do
    # Literals
    @null_rendered = 'nil'
    @what_is_your_quest_rendered = "'What is your quest ?'"
    @pi_rendered = '3.14'
    @false_rendered = 'false'
    @foo_template_rendered = '"#{foo}fighters"'
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # variable
    @foo_variable_rendered = 'foo'

    # Accessors
    @foo_dot_fighters_rendered = 'foo.fighters'
    @foo_brackets_fighters_rendered = "foo['fighters']"

    # Operation
    @minus_foo_rendered = '-foo'
    @foo_minus_fighters_rendered = "foo - 'fighters'"
    @parenthesis_foo_rendered = '(foo)'

    # List
    @foo_list_rendered = "[foo, 'fighters']"

    # Dictionary and properties
    @foo_fighters_prop_rendered = "foo: 'fighters'"
    @foo_dict_rendered = "{foo: 'fighters', Alt: J}"

    # Statements
    @assign_fighters_to_foo_rendered = "foo = 'fighters'\n"
    @call_foo_rendered = "foo()\n"
    @call_foo_with_fighters_rendered = "foo('fighters')\n"
    @action_foo_fighters_rendered = '# TODO: Implement action: "#{foo}fighters"'


    # Control blocks
    @if_then_rendered = [
        "if (true)",
        "  foo = 'fighters'",
        "end\n"
      ].join("\n")

    @if_then_else_rendered = [
        "if (true)",
        "  foo = 'fighters'",
        "else",
        "  fighters = 'foo'",
        "end\n"
      ].join("\n")

    @while_loop_rendered = [
        "while (foo)",
        "  fighters = 'foo'",
        "  foo('fighters')",
        "end\n"
      ].join("\n")

    # Tags
    @simple_tag_rendered = 'myTag'
    @valued_tag_rendered = 'myTag:somevalue'

    # Parameters
    @plic_param_rendered = 'plic'
    @plic_param_default_ploc_rendered = "plic = 'ploc'"


    # Actionwords
    @empty_action_word_rendered = "def my_action_word()\nend"
    @tagged_action_word_rendered = [
      "def my_action_word()",
      "  # Tags: myTag myTag:somevalue",
      "end"].join("\n")

    @parameterized_action_word_rendered = [
      "def my_action_word(plic, flip = 'flap')",
      "end"].join("\n")

    @full_actionword_rendered = [
      "def compare_to_pi(x)",
      "  # Tags: myTag",
      "  foo = 3.14",
      "  if (foo > x)",
      "    # TODO: Implement result: x is greater than Pi",
      "  else",
      "    # TODO: Implement result: x is lower than Pi",
      "    # on two lines",
      "  end",
      "end"].join("\n")

    @actionwords_rendered = [
      "# encoding: UTF-8",
      "",
      "class Actionwords",
      "  def first_action_word()",
      "  end",
      "  def second_action_word()",
      "    first_action_word()",
      "  end",
      "end"].join("\n")
  end

  context 'Rspec' do
    before(:each) do
      @full_scenario_rendered = [
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
        "end"].join("\n")

      @scenarios_rendered = [
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
        "end"].join("\n")
    end

    it_behaves_like "a renderer" do
      let(:language) {'ruby'}
      let(:framework) {'rspec'}
    end
  end

  context 'Minitest' do
    before(:each) do
      @full_scenario_rendered = [
        "def test_compare_to_pi",
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
        "end"].join("\n")

      @scenarios_rendered = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative 'actionwords'",
        "",
        "class TestMyProject < MiniTest::Unit::TestCase",
        "  def setup",
        "    @actionwords = Actionwords.new",
        "  end",
        "",
        "  def test_first_scenario",
        "  end",
        "  def test_second_scenario",
        "    @actionwords.my_action_word()",
        "  end",
        "end"].join("\n")
    end

    it_behaves_like "a renderer" do
      let(:language) {'ruby'}
      let(:framework) {'minitest'}
    end
  end
end