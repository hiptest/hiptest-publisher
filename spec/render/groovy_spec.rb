require_relative '../spec_helper'
require_relative "../render_shared"

describe 'Render as Groovy' do
  include_context "shared render"

  before(:each) do
    # In Hiptest: null
    @null_rendered = 'null'

    # In Hiptest: 'What is your quest ?'
    @what_is_your_quest_rendered = '"What is your quest ?"'

    # In Hiptest: 3.14
    @pi_rendered = '3.14'

    # In Hiptest: false
    @false_rendered = 'false'

    # In Hiptest: "${foo}fighters"
    @foo_template_rendered = '"${foo}fighters"'

    # In Hiptest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Hiptest: ""
    @empty_template_rendered = '""'

    # In Hiptest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'

    # In Hiptest: foo.fighters
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In Hiptest: foo['fighters']
    @foo_brackets_fighters_rendered = 'foo["fighters"]'

    # In Hiptest: -foo
    @minus_foo_rendered = '-foo'

    # In Hiptest: foo - 'fighters'
    @foo_minus_fighters_rendered = 'foo - "fighters"'

    # In Hiptest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In Hiptest: [foo, 'fighters']
    @foo_list_rendered = '[foo, "fighters"]'

    # In Hiptest: foo: 'fighters'
    @foo_fighters_prop_rendered = 'foo: "fighters"'

    # In Hiptest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = '[foo: "fighters", Alt: J]'

    # In Hiptest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = 'foo = "fighters"'

    # In Hiptest: call 'foo'
    @call_foo_rendered = "actionwords.foo()"
    # In Hiptest: call 'foo bar'
    @call_foo_bar_rendered = "actionwords.fooBar()"

    # In Hiptest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = 'actionwords.foo("fighters")'
    # In Hiptest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = 'actionwords.fooBar("fighters")'

    # In Hiptest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '// TODO: Implement action: "${foo}fighters"'

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
        "if (true) {",
        '  foo = "fighters"',
        "}"
      ].join("\n")

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = [
        "if (true) {",
        '  foo = "fighters"',
        "} else {",
        '  fighters = "foo"',
        "}"
      ].join("\n")

    # In Hiptest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
        "while (foo) {",
        '  fighters = "foo"',
        '  actionwords.foo("fighters")',
        "}"
      ].join("\n")

    # In Hiptest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Hiptest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Hiptest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = 'plic'

    # In Hiptest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = 'plic = "ploc"'

    # In Hiptest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "def myActionWord() {\n}"

    # In Hiptest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "def myActionWord() {",
      "  // Tags: myTag myTag:somevalue",
      "}"].join("\n")

    @described_action_word_rendered = [
      "def myActionWord() {",
      "  // Some description",
      "}"
    ].join("\n")

    # In Hiptest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      'def myActionWord(plic, flip = "flap") {',
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
      "def compareToPi(x) {",
      "  // Tags: myTag",
      "",
      "  foo = 3.14",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "",
      "  throw new UnsupportedOperationException()",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "def myActionWord() {",
      "  // TODO: Implement action: basic action",
      "",
      "  throw new UnsupportedOperationException()",
      "}"].join("\n")

    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "class Actionwords {",
      "  def firstActionWord() {",
      "  }",
      "",
      "  def secondActionWord() {",
      "    firstActionWord()",
      "  }",
      "}"].join("\n")

    @call_with_special_characters_in_value_rendered = [
      'actionwords.myCallWithWeirdArguments("{\n  this: \'is\',\n  some: [\'JSON\', \'outputed\'],\n  as: \'a string\'\n}")'
    ].join("\n")

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
      "class Actionwords {",
      "  def awWithIntParam(x) {",
      "  }",
      "",
      "  def awWithFloatParam(x) {",
      "  }",
      "",
      "  def awWithBooleanParam(x) {",
      "  }",
      "",
      "  def awWithNullParam(x) {",
      "  }",
      "",
      "  def awWithStringParam(x) {",
      "  }",
      "",
      "  def awWithTemplateParam(x) {",
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
      'def "compare to pi"() {',
      "  // This is a scenario which description ",
      "  // is on two lines",
      "",
      "  // Tags: myTag",
      "",
      "  expect:",
      "",
      "  foo = 3.14",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "",
      "  throw new UnsupportedOperationException()",
      "}"].join("\n")

    @full_scenario_with_uid_rendered = [
      'def "compare to pi (uid:abcd-1234)"() {',
      "  // This is a scenario which description ",
      "  // is on two lines",
      "",
      "  // Tags: myTag",
      "",
      "  expect:",
      "",
      "  foo = 3.14",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "",
      "  throw new UnsupportedOperationException()",
      "}"].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = [
      'import spock.lang.*',
      '',
      'class CompareToPiSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '  def "compare to pi"() {',
      "    // This is a scenario which description ",
      "    // is on two lines",
      "",
      "    // Tags: myTag",
      "",
      "    expect:",
      "",
      "    foo = 3.14",
      "    if (foo > x) {",
      "      // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "      // TODO: Implement result: x is lower than Pi",
      "      // on two lines",
      "    }",
      "",
      "    throw new UnsupportedOperationException()",
      "  }",
      "}"].join("\n")

    # Scenario definition is:
    # call 'fill login' (login = login)
    # call 'fill password' (password = password)
    # call 'press enter'
    # call 'assert "error" is displayed' (error = expected)

    # Scenario datatable is:
    # Dataset name             | login   | password | expected
    # -----------------------------------------------------------------------------
    # Wrong 'login'            | invalid | invalid  | 'Invalid username or password
    # Wrong "password"         | valid   | invalid  | 'Invalid username or password
    # Valid 'login'/"password" | valid   | valid    | nil

    @scenario_with_datatable_rendered = [
      '@Unroll("check login #hiptestUid")',
      'def "check login"() {',
      '  // Ensure the login process',
      '',
      '  expect:',
      '',
      '  actionwords.fillLogin(login)',
      '  actionwords.fillPassword(password)',
      '  actionwords.pressEnter()',
      '  actionwords.assertErrorIsDisplayed(expected)',
      '',
      '  where:',
      '  login | password | expected | hiptestUid',
      '  "invalid" | "invalid" | "Invalid username or password" | "uid:"',
      '  "valid" | "invalid" | "Invalid username or password" | "uid:"',
      '  "valid" | "valid" | null | "uid:"',
      '}'
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      '@Unroll("check login #hiptestUid")',
      'def "check login"() {',
      '  // Ensure the login process',
      '',
      '  expect:',
      '',
      '  actionwords.fillLogin(login)',
      '  actionwords.fillPassword(password)',
      '  actionwords.pressEnter()',
      '  actionwords.assertErrorIsDisplayed(expected)',
      '',
      '  where:',
      '  login | password | expected | hiptestUid',
      '  "invalid" | "invalid" | "Invalid username or password" | "uid:a-123"',
      '  "valid" | "invalid" | "Invalid username or password" | "uid:b-456"',
      '  "valid" | "valid" | null | "uid:c-789"',
      '}'
    ].join("\n")


    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      'import spock.lang.*',
      '',
      'class CheckLoginSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '  @Unroll("check login #hiptestUid")',
      '  def "check login"() {',
      '    // Ensure the login process',
      '',
      '    expect:',
      '',
      '    actionwords.fillLogin(login)',
      '    actionwords.fillPassword(password)',
      '    actionwords.pressEnter()',
      '    actionwords.assertErrorIsDisplayed(expected)',
      '',
      '    where:',
      '    login | password | expected | hiptestUid',
      '    "invalid" | "invalid" | "Invalid username or password" | "uid:"',
      '    "valid" | "invalid" | "Invalid username or password" | "uid:"',
      '    "valid" | "valid" | null | "uid:"',
      '  }',
      '}'
    ].join("\n")

    # In Hiptest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenariocenarios_rendered = [
      'class MyProjectSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '  def "first scenario"() {',
      '  }',
      '',
      '  def "second scenario"() {',
      '    expect:',
      '',
      '    actionwords.myActionWord()',
      '  }',
      '}',
      ''
    ].join("\n")

    @tests_rendered = [
      'import spock.lang.*',
      '',
      'class ProjectSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '  def "Login"() {',
      '    // The description is on ',
      '    // two lines',
      '',
      '    // Tags: myTag myTag:somevalue',
      '',
      '    expect:',
      '',
      '    actionwords.visit("/login")',
      '    actionwords.fill("user@example.com")',
      '    actionwords.fill("s3cret")',
      '    actionwords.click(".login-form input[type=submit]")',
      '    actionwords.checkUrl("/welcome")',
      '  }',
      '',
      '  def "Failed login"() {',
      '    // Tags: myTag:somevalue',
      '',
      '    expect:',
      '',
      '    actionwords.visit("/login")',
      '    actionwords.fill("user@example.com")',
      '    actionwords.fill("notTh4tS3cret")',
      '    actionwords.click(".login-form input[type=submit]")',
      '    actionwords.checkUrl("/login")',
      '  }',
      '}'
    ].join("\n")

    @first_test_rendered = [
      'def "Login"() {',
      '  // The description is on ',
      '  // two lines',
      '',
      '  // Tags: myTag myTag:somevalue',
      '',
      '  expect:',
      '',
      '  actionwords.visit("/login")',
      '  actionwords.fill("user@example.com")',
      '  actionwords.fill("s3cret")',
      '  actionwords.click(".login-form input[type=submit]")',
      '  actionwords.checkUrl("/welcome")',
      '}',
      ''
    ].join("\n")

    @first_test_rendered_for_single_file = [
      'import spock.lang.*',
      '',
      'class LoginSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '  def "Login"() {',
      '    // The description is on ',
      '    // two lines',
      '',
      '    // Tags: myTag myTag:somevalue',
      '',
      '    expect:',
      '',
      '    actionwords.visit("/login")',
      '    actionwords.fill("user@example.com")',
      '    actionwords.fill("s3cret")',
      '    actionwords.click(".login-form input[type=submit]")',
      '    actionwords.checkUrl("/welcome")',
      '  }',
      '}'
    ].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
      'def "Reset password"() {',
      '',
      '  given:',
      '  actionwords.pageUrlIsOpened("/login")',
      '  when:',
      '  actionwords.iClickOnLink("Reset password")',
      '  then:',
      '  actionwords.pageUrlShouldBeOpened("/reset-password")',
      '}'
    ].join("\n")

    @scenarios_rendered = [
      'import spock.lang.*',
      '',
      'class ProjectSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '  def "first scenario"() {',
      '  }',
      '  def "second scenario"() {',
      '    expect:',
      '',
      '    actionwords.myActionWord()',
      '  }',
      '}'
    ].join("\n")

    @root_folder_rendered = [
      'import spock.lang.*',
      '',
      'class MyRootFolderSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '',
      '',
      '  def "One root scenario"() {',
      '  }',
      '  def "Another root scenario"() {',
      '  }',
      '}',
    ].join("\n")

    @grand_child_folder_rendered = [
      'import spock.lang.*',
      '',
      'class AGrandchildFolderSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '}'
    ].join("\n")

    @grand_child_scenario_rendered_for_single_file = [
      'import spock.lang.*',
      '',
      'class OneGrandchildScenarioSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '  def "One grand\'child scenario"() {',
      '  }',
      '}'
    ].join("\n")

    @second_grand_child_folder_rendered = [
      'import spock.lang.*',
      '',
      'class ASecondGrandchildFolderSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '',
      '  def setup() {',
      '    actionwords.visit("/login")',
      '    actionwords.fill("user@example.com")',
      '    actionwords.fill("notTh4tS3cret")}',
      '',
      '',
      '  def "One grand\'child scenario"() {',
      '  }',
      '}'
    ].join("\n")
  end

  context 'Groovy/Spock' do
    it_behaves_like "a renderer" do
      let(:language) {'groovy'}
      let(:framework) {'spock'}
    end
  end
end
