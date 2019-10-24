require_relative "../spec_helper"
require_relative "../render_shared"

describe "Render as swift" do
  include_context "shared render"

  before(:each) do
    # In HipTest: null
    @null_rendered = "nil"

    # In HipTest: 'What is your quest ?'
    @what_is_your_quest_rendered = "\"What is your quest ?\""

    @string_literal_with_quotes_rendered = '"{ "key" : "val" }"'

    # In HipTest: 3.14
    @pi_rendered = "3.14"

    # In HipTest: false
    @false_rendered = "false"

    # In HipTest: "${foo}fighters"
    @foo_template_rendered = '"#{foo}fighters"'

    # In HipTest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In HipTest: ""
    @empty_template_rendered = '""'

    # In HipTest: foo (as in 'foo := 1')
    @foo_variable_rendered = "foo"

    # In HipTest: foo.fighters
    @foo_dot_fighters_rendered = "foo.fighters"

    # In HipTest: foo['fighters']
    @foo_brackets_fighters_rendered = "foo[\"fighters\"]"

    # In HipTest: -foo
    @minus_foo_rendered = "-foo"

    # In HipTest: foo - 'fighters'
    @foo_minus_fighters_rendered = "foo - \"fighters\""

    # In HipTest: (foo)
    @parenthesis_foo_rendered = "(foo)"

    # In HipTest: [foo, 'fighters']
    @foo_list_rendered = "[foo, \"fighters\"]"

    # In HipTest: foo: 'fighters'
    @foo_fighters_prop_rendered = "foo: \"fighters\""

    # In HipTest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{foo: \"fighters\", Alt: J}"

    # In HipTest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "foo = \"fighters\""

    # In HipTest: call 'foo'
    @call_foo_rendered = "app.foo()"
    # In HipTest: call 'foo bar'
    @call_foo_bar_rendered = "app.foo_bar()"

    # In HipTest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "app.foo(x: \"fighters\")"
    # In HipTest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "app.foo_bar(x: \"fighters\")"

    @call_with_special_characters_in_value_rendered = "app.my_call_with_weird_arguments(__free_text: \"{\\n  this: 'is',\\n  some: ['JSON', 'outputed'],\\n  as: 'a string'\\n}\")"

    # In HipTest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '// TODO: Implement action: "#{foo}fighters"'

    @foo_fighters_symbol_rendered = "\"foo(fighters)\""

    # In HipTest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
      "if (true) {",
      "  foo = \"fighters\"",
      "}",
    ].join("\n")

    # In HipTest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = [
      "if (true) {",
      "  foo = \"fighters\"",
      "} else {",
      "  fighters = \"foo\"",
      "}",
    ].join("\n")

    # In HipTest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
      "while (foo) {",
      "  fighters = \"foo\"",
      "  app.foo(x: \"fighters\")",
      "}",
    ].join("\n")

    # In HipTest: @myTag
    @simple_tag_rendered = "myTag"

    # In HipTest: @myTag:somevalue
    @valued_tag_rendered = "myTag:somevalue"

    # In HipTest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = "plic: String"

    # In HipTest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = "plic: String = \"ploc\""

    # In HipTest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "func my_action_word() {\n}\n"

    # In HipTest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "func my_action_word() {",
      "    // Tags: myTag myTag:somevalue",
      "}\n",
    ].join("\n")

    @described_action_word_rendered = [
      "func my_action_word() {",
      "    // Some description",
      "}\n",
    ].join("\n")

    # In HipTest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "func my_action_word(plic: String, flip: String = \"flap\") {",
      "}\n",
    ].join("\n")

    # In HipTest:
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
      "func compare_to_pi(x: String) {",
      "    // Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x) {",
      "      // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "      // TODO: Implement result: x is lower than Pi",
      "      // on two lines",
      "    }",
      "    raise NotImplementedError",
      "}\n",
    ].join("\n")

    # In HipTest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "func my_action_word() {",
      "    // TODO: Implement action: basic action",
      "    raise NotImplementedError",
      "}\n",
    ].join("\n")

    # In HipTest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "import XCTest",
      "",
      "extension XCUIApplication {",
      "",
      "  func first_action_word() {",
      "  }",
      "",
      "",
      "  func second_action_word() {",
      "      app.first_action_word()",
      "  }}",
    ].join("\n")

    # In HipTest, correspond to these action words with parameters:
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
      "import XCTest",
      "",
      "extension XCUIApplication {",
      "",
      "  func aw_with_int_param(x: String) {",
      "  }",
      "",
      "",
      "  func aw_with_float_param(x: String) {",
      "  }",
      "",
      "",
      "  func aw_with_boolean_param(x: String) {",
      "  }",
      "",
      "",
      "  func aw_with_null_param(x: String) {",
      "  }",
      "",
      "",
      "  func aw_with_string_param(x: String) {",
      "  }",
      "",
      "",
      "  func aw_with_template_param(x: String) {",
      "  }}",
    ].join("\n")

    # In HipTest:
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
      "func testCompareToPi() {",
      "    // This is a scenario which description ",
      "    // is on two lines",
      "    // Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x) {",
      "      // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "      // TODO: Implement result: x is lower than Pi",
      "      // on two lines",
      "    }",
      "    raise NotImplementedError",
      "}\n\n",
    ].join("\n")

    @full_scenario_with_uid_rendered = [
      "func testCompareToPiUidabcd1234() {",
      "    // This is a scenario which description ",
      "    // is on two lines",
      "    // Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x) {",
      "      // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "      // TODO: Implement result: x is lower than Pi",
      "      // on two lines",
      "    }",
      "    raise NotImplementedError",
      "}\n\n",
    ].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
      "func testResetPassword() {",
      "    // Given Page \"/login\" is opened",
      "    app.page_url_is_opened(url: \"/login\")",
      "    // When I click on \"Reset password\"",
      "    app.i_click_on_link(link: \"Reset password\")",
      "    // Then Page \"/reset-password\" should be opened",
      "    app.page_url_should_be_opened(url: \"/reset-password\")",
      "}\n\n",
    ].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = [
      "import XCTest",
      "",
      "class CompareToPiUITest: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "    app.launch()",
      "  }",
      "",
      "  func testCompareToPi() {",
      "      // This is a scenario which description ",
      "      // is on two lines",
      "      // Tags: myTag",
      "      foo = 3.14",
      "      if (foo > x) {",
      "        // TODO: Implement result: x is greater than Pi",
      "      } else {",
      "        // TODO: Implement result: x is lower than Pi",
      "        // on two lines",
      "      }",
      "      raise NotImplementedError",
      "  }",
      "}",
    ].join("\n")

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
      "",
      "func check_login(login: String, password: String, expected: String) {",
      "    // Ensure the login process",
      "    app.fill_login(login: login)",
      "    app.fill_password(password: password)",
      "    app.press_enter()",
      "    app.assert_error_is_displayed(error: expected)",
      "}",
      "",
      "",
      "func WrongLogin() {",
      "    check_login(login: \"invalid\", password: \"invalid\", expected: \"Invalid username or password\")",
      "}",
      "",
      "func WrongPassword() {",
      "    check_login(login: \"valid\", password: \"invalid\", expected: \"Invalid username or password\")",
      "}",
      "",
      "func ValidLoginpassword() {",
      "    check_login(login: \"valid\", password: \"valid\", expected: nil)",
      "}\n\n",
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      "",
      "func check_login(login: String, password: String, expected: String) {",
      "    // Ensure the login process",
      "    app.fill_login(login: login)",
      "    app.fill_password(password: password)",
      "    app.press_enter()",
      "    app.assert_error_is_displayed(error: expected)",
      "}",
      "",
      "",
      "func WrongLogina-123() {",
      "    check_login(login: \"invalid\", password: \"invalid\", expected: \"Invalid username or password\")",
      "}",
      "",
      "func WrongPasswordb-456() {",
      "    check_login(login: \"valid\", password: \"invalid\", expected: \"Invalid username or password\")",
      "}",
      "",
      "func ValidLoginpasswordc-789() {",
      "    check_login(login: \"valid\", password: \"valid\", expected: nil)",
      "}\n\n",
    ].join("\n")

    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      "import XCTest",
      "",
      "class CheckLoginUITest: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "    app.launch()",
      "  }",
      "",
      "",
      "  func check_login(login: String, password: String, expected: String) {",
      "      // Ensure the login process",
      "      app.fill_login(login: login)",
      "      app.fill_password(password: password)",
      "      app.press_enter()",
      "      app.assert_error_is_displayed(error: expected)",
      "  }",
      "",
      "",
      "  func WrongLogin() {",
      "      check_login(login: \"invalid\", password: \"invalid\", expected: \"Invalid username or password\")",
      "  }",
      "",
      "  func WrongPassword() {",
      "      check_login(login: \"valid\", password: \"invalid\", expected: \"Invalid username or password\")",
      "  }",
      "",
      "  func ValidLoginpassword() {",
      "      check_login(login: \"valid\", password: \"valid\", expected: nil)",
      "  }",
      "}",
    ].join("\n")

    # In HipTest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "import XCTest",
      "",
      "class ProjectUITests: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "    app.launch()",
      "  }",
      "",
      "  func testFirstScenario() {",
      "  }",
      "",
      "",
      "",
      "  func testSecondScenario() {",
      "      app.my_action_word()",
      "  }",
      "}",
    ].join("\n")

    @tests_rendered = [
      "import XCTest",
      "",
      "class ProjectUITests: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "    app.launch()",
      "  }",
      "",
      "  func testLogin() {",
      "      // The description is on ",
      "      // two lines",
      "      // Tags: myTag myTag:somevalue",
      "      app.visit(url: \"/login\")",
      "      app.fill(login: \"user@example.com\")",
      "      app.fill(password: \"s3cret\")",
      "      app.click(path: \".login-form input[type=submit]\")",
      "      app.check_url(path: \"/welcome\")",
      "  }",
      "",
      "",
      "",
      "  func testFailedLogin() {",
      "      // Tags: myTag:somevalue",
      "      app.visit(url: \"/login\")",
      "      app.fill(login: \"user@example.com\")",
      "      app.fill(password: \"notTh4tS3cret\")",
      "      app.click(path: \".login-form input[type=submit]\")",
      "      app.check_url(path: \"/login\")",
      "  }",
      "}",
    ].join("\n")

    @first_test_rendered = [
      "func testLogin() {",
      "    // The description is on ",
      "    // two lines",
      "    // Tags: myTag myTag:somevalue",
      "    app.visit(url: \"/login\")",
      "    app.fill(login: \"user@example.com\")",
      "    app.fill(password: \"s3cret\")",
      "    app.click(path: \".login-form input[type=submit]\")",
      "    app.check_url(path: \"/welcome\")",
      "}\n\n",
    ].join("\n")

    @first_test_rendered_for_single_file = [
      "import XCTest",
      "",
      "class LoginUITest: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "",
      "    app.launch()",
      "  }",
      "  func testLogin() {",
      "      // The description is on ",
      "      // two lines",
      "      // Tags: myTag myTag:somevalue",
      "      app.visit(url: \"/login\")",
      "      app.fill(login: \"user@example.com\")",
      "      app.fill(password: \"s3cret\")",
      "      app.click(path: \".login-form input[type=submit]\")",
      "      app.check_url(path: \"/welcome\")",
      "  }",
      "}",
    ].join("\n")

    @root_folder_rendered = [
      "import XCTest",
      "",
      "class MyRootFolderUITest: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "  }",
      "  func testOneRootScenario() {",
      "  }",
      "",
      "",
      "",
      "  func testAnotherRootScenario() {",
      "  }",
      "}",
    ].join("\n")

    @grand_child_folder_rendered = [
      "import XCTest",
      "",
      "class AGrandchildFolderUITest: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "  }",
      "}",
    ].join("\n")

    @grand_child_scenario_rendered_for_single_file = [
      "import XCTest",
      "",
      "class OneGrandchildScenarioUITest: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      "    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered",
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      "    app.launchArguments.append(\"--uitesting\")",
      "    app.launch()",
      "  }",
      "",
      "  func testOneGrandchildScenario() {",
      "  }",
      "}",
    ].join("\n")

    @second_grand_child_folder_rendered = [
      "import XCTest",
      "",
      "class ASecondGrandchildFolderUITest: XCTestCase {",
      "",
      "  var app: XCUIApplication!",
      "",
      "  override func setUp() {",
      "    super.setUp()",
      "",
      '    // Since UI tests are more expensive to run, it\'s usually a good idea to exit if a failure was encountered',
      "    continueAfterFailure = false",
      "",
      "    app = XCUIApplication()",
      "",
      "    // We send a command line argument to our app, to enable it to reset its state",
      '    app.launchArguments.append("--uitesting")',
      "  }",
      "  func testOneGrandchildScenario() {",
      "  }",
      "}",
    ].join("\n")
  end

  context "xctest" do
    it_behaves_like "a renderer" do
      let(:language) { "swift" }
      let(:framework) { "xctest" }
    end
  end
end
