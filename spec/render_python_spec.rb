require_relative "render_shared"

describe 'Render as Python' do
  include_context "shared render"

  before(:each) do
    # In Zest: null
    @null_rendered = 'None'

    # In Zest: 'What is your quest ?'
    @what_is_your_quest_rendered = "'What is your quest ?'"

    # In Zest: 3.14
    @pi_rendered = '3.14'

    # In Zest: false
    @false_rendered = 'false'

    # In Zest: "${foo}fighters"
    @foo_template_rendered = '"%sfighters" % (foo)'

    # In Zest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Zest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'

    # In Zest: foo.fighters
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In Zest: foo['fighters']
    @foo_brackets_fighters_rendered = "foo['fighters']"

    # In Zest: -foo
    @minus_foo_rendered = '-foo'

    # In Zest: foo - 'fighters'
    @foo_minus_fighters_rendered = "foo - 'fighters'"

    # In Zest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In Zest: [foo, 'fighters']
    @foo_list_rendered = "[foo, 'fighters']"

    # In Zest: foo: 'fighters'
    @foo_fighters_prop_rendered = "foo: 'fighters'"

    # In Zest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{foo: 'fighters', Alt: J}"

    # In Zest: foo = 'fighters'
    @assign_fighters_to_foo_rendered = "foo = 'fighters'\n"

    # In Zest: call 'foo'
    @call_foo_rendered = "self.foo()\n"

    # In Zest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "self.foo(x = 'fighters')\n"

    # In Zest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '# TODO: Implement action: "%sfighters" % (foo)'

    # In Zest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
        "if (true):",
        "    foo = 'fighters'",
        ""
      ].join("\n")

    # In Zest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = [
        "if (true):",
        "    foo = 'fighters'",
        "else:",
        "    fighters = 'foo'",
        ""
      ].join("\n")

    # In Zest:
    # while (foo)
    #   fighters := 'foo'
    #   call 'foo' ('fighters')
    # end
    @while_loop_rendered = [
        "while (foo):",
        "    fighters = 'foo'",
        "    self.foo(x = 'fighters')",
        ""
      ].join("\n")

    # In Zest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Zest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Zest: plic (as in: call 'foo'(plic))
    @plic_param_rendered = 'plic'

    # In Zest: plic = 'ploc' (as in: call 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = "plic = 'ploc'"

    # In Zest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "def my_action_word(self):\n    pass"

    # In Zest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "def my_action_word(self):",
      "    # Tags: myTag myTag:somevalue",
      ""].join("\n")

    # In Zest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "def my_action_word(self, plic, flip = 'flap'):",
      "    pass"
    ].join("\n")

    # In Zest:
    # @myTag
    # actionword 'compare to pi' (x) do
    #   foo := 3.14
    #   if (foo > x)
    #     step {result: "x is greater than Pi"}
    #   else
    #     step {result: "x is lower than Pi
    #       on two lines"}
    #   end
    # end
    @full_actionword_rendered = [
      "def compare_to_pi(self, x):",
      "    # Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x):",
      "        # TODO: Implement result: x is greater than Pi",
      "    else:",
      "        # TODO: Implement result: x is lower than Pi",
      "        # on two lines",
      ""].join("\n")

    # In Zest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "def my_action_word(self):",
      "    # TODO: Implement action: basic action",
      ""].join("\n")

    # In Zest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "# encoding: UTF-8",
      "",
      "class Actionwords:",
      "    def first_action_word(self):",
      "        pass",
      "    def second_action_word(self):",
      "        self.first_action_word()",
      ""].join("\n")


    # In Zest:
    # @myTag
    # scenario 'compare to pi' (x) do
    #   foo := 3.14
    #   if (foo > x)
    #     step {result: "x is greater than Pi"}
    #   else
    #     step {result: "x is lower than Pi
    #       on two lines"}
    #   end
    # end
    @full_scenario_rendered = [
      "def test_compare_to_pi(self):",
      "    # This is a scenario which description ",
      "    # is on two lines",
      "    # Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x):",
      "        # TODO: Implement result: x is greater than Pi",
      "    else:",
      "        # TODO: Implement result: x is lower than Pi",
      "        # on two lines",
      ""].join("\n")


    # In Zest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestMyProject(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords()",
      "",
      "    def test_first_scenario(self):",
      "        pass",
      "    def test_second_scenario(self):",
      "        self.actionwords.my_action_word()",
      ""].join("\n")

    @context[:indentation] = '    '
  end

  context 'UnitTest' do
    it_behaves_like "a renderer" do
      let(:language) {'python'}
      let(:framework) {'unittest'}
    end
  end
end