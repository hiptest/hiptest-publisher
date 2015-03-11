require_relative 'spec_helper'
require_relative "render_shared"

describe 'Render as Javascript' do
  include_context "shared render"

  before(:each) do
    # In Hiptest: null
    @null_rendered = 'null'

    # In Hiptest: 'What is your quest ?'
    @what_is_your_quest_rendered = "'What is your quest ?'"

    # In Hiptest: 3.14
    @pi_rendered = '3.14'

    # In Hiptest: false
    @false_rendered = 'false'

    # In Hiptest: "${foo}fighters"
    @foo_template_rendered = 'String(foo) + "fighters"'

    # In Hiptest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Hiptest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'

    # In Hiptest: foo.fighters
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In Hiptest: foo['fighters']
    @foo_brackets_fighters_rendered = "foo['fighters']"

    # In Hiptest: -foo
    @minus_foo_rendered = '-foo'

    # In Hiptest: foo - 'fighters'
    @foo_minus_fighters_rendered = "foo - 'fighters'"

    # In Hiptest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In Hiptest: [foo, 'fighters']
    @foo_list_rendered = "[foo, 'fighters']"

    # In Hiptest: foo: 'fighters'
    @foo_fighters_prop_rendered = "foo: 'fighters'"

    # In Hiptest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{foo: 'fighters', Alt: J}"

    # In Hiptest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "foo = 'fighters'"

    # In Hiptest: call 'foo'
    @call_foo_rendered = "foo()"
    # In Hiptest: call 'foo bar'
    @call_foo_bar_rendered = "fooBar()"

    # In Hiptest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "foo('fighters')"
    # In Hiptest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "fooBar('fighters')"

    # In Hiptest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '// TODO: Implement action: String(foo) + "fighters"'

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
        "if (true) {",
        "  foo = 'fighters'",
        "}\n"
      ].join("\n")

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = [
        "if (true) {",
        "  foo = 'fighters'",
        "} else }",
        "  fighters = 'foo'",
        "}\n"
      ].join("\n")

    # In Hiptest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
        "while (foo)",
        "  fighters = 'foo'",
        "  foo('fighters')",
        "end\n"
      ].join("\n")

    # In Hiptest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Hiptest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Hiptest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = 'plic'

    # In Hiptest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = "plic = 'ploc'"

    # In Hiptest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "function myActionWord() {}\n"

    # In Hiptest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "myActionWord: function () {",
      "  // Tags: myTag myTag:somevalue",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "myActionWord: function (plic, flip) {",
      " if (typeof(flip) == 'undefined') {flip = 'flap'}",
      "}"].join("\n")

    # In Hiptest:
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
      "compareToPi(x): function {",
      "  // Tags: myTag",
      "  var foo;",
      "  foo = 3.14",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "myActionWord: function ()",
      "  // TODO: Implement action: basic action",
      "  throw 'Not implemented';",
      "}"].join("\n")

    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "var Actionwords = {",
      "  firstActionWord: function () {",
      "  },",
      "  secondActionWord: function () {",
      "    this.firstActionWord();",
      "  }",
      "}"].join("\n")

    # In Hiptest, correspond to these action words with parameters:
    # actionword 'aw with int param'(x) do end
    # actionword 'aw with float param'(x) do end
    # actionword 'aw with boolean param'(x) do end
    # actionword 'aw with null param'(x) do end
    # actionword 'aw with string param'(x) do end
    #
    # but called by this scenario
    # scenario 'many calls scenarios' do
    #   call 'aw with int param'(x = 3)
    #   call 'aw with float param'(x = 4.2)
    #   call 'aw with boolean param'(x = true)
    #   call 'aw with null param'(x = null)
    #   call 'aw with string param'(x = 'toto')
    #   call 'aw with template param'(x = "toto")
    @actionwords_with_params_rendered = [
      "var Actionwords = {",
      "  awWithIntParam: function (x) {",
      "  },",
      "",
      "  awWithFloatParam: function (x) {",
      "  },",
      "",
      "  awWithBooleanParam: function (x) {",
      "  },",
      "",
      "  awWithNullParam: function (x) {",
      "  },",
      "",
      "  awWithStringParam: function (x) {",
      "  },",
      "",
      "  awWithTemplateParam: function (x) {",
      "  }",
      "}"
    ].join("\n")


    # In Hiptest:
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
      "test('compare to pi', function () {",
      "  // This is a scenario which description ",
      "  // is on two lines",
      "  // Tags: myTag",
      "  var foo;",
      "  foo = 3.14;",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "});"].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = [
      "test('compare to pi', function () {",
      "  // This is a scenario which description ",
      "  // is on two lines",
      "  // Tags: myTag",
      "  var foo;",
      "  foo = 3.14;",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "});"].join("\n")

    # Scenario definition is:
    # call 'fill login' (login = login)
    # call 'fill password' (password = password)
    # call 'press enter'
    # call 'assert "error" is displayed' (error = expected)

    # Scenario datatable is:
    # Dataset name         | login   | password | expected
    # -------------------------------------------------------------------------
    # Wrong login          | invalid | invalid  | 'Invalid username or password
    # Wrong password       | valid   | invalid  | 'Invalid username or password
    # Valid login/password | valid   | valid    | nil

    @scenario_with_datatable_rendered = [
      "function checkLogin (login, password, expected)",
      "  // Ensure the login process",
      "  fillLogin(login);",
      "  fillPassword(password);",
      "  pressEnter();",
      "  assertErrorIsDisplayed(expected);",
      "}",
      "",
      "test(\"check login: Wrong login\", function () {",
      "  checkLogin('invalid', 'invalid', 'Invalid username or password')",
      "});",
      "",
      "test(\"check login: Wrong password\", function () {",
      "  checkLogin('valid', 'invalid', 'Invalid username or password')",
      "});",
      "",
      "test(\"check login: Valid login/password\", function () {",
      "  checkLogin('valid', 'valid', nil)",
      "});",
    ].join("\n")

    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      "(function () {",
      "  module('A project with datatables', {",
      "    setup: function () {",
      "      this.actionWords = Object.create(ActionWords);",
      "    }",
      "  });",
      "",
      "  function checkLogin (login, password, expected)",
      "    // Ensure the login process",
      "    this.actionWords.fillLogin(login);",
      "    this.actionWords.fillPassword(password);",
      "    this.actionWords.pressEnter();",
      "    this.actionWords.assertErrorIsDisplayed(expected);",
      "  }",
      "",
      "  test(\"check login: Wrong login\", function () {",
      "    checkLogin('invalid', 'invalid', 'Invalid username or password');",
      "  });",
      "",
      "  test(\"check login: Wrong password\", function () {",
      "    checkLogin('valid', 'invalid', 'Invalid username or password');",
      "  });",
      "",
      "  test(\"check login: Valid login/password\", function () {",
      "    checkLogin('valid', 'valid', null);",
      "  });",
      "})();"
    ].join("\n")

    # In Hiptest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "(function () {",
      "  module('My project', {",
      "    setup: function () {",
      "      this.actionWords = Object.create(ActionWords);",
      "    }",
      "  });",
      "",
      "  test('first scenario', function () {",
      "  });",
      "  test('second scenario', function () {",
      "    this.actionWords.myActionWord();",
      "  end",
      "end"].join("\n")
  end

  context 'qUnit' do
    it_behaves_like "a renderer" do
      let(:language) {'javascript'}
      let(:framework) {'qUnit'}
    end
  end
end