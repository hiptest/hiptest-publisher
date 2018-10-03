require_relative '../spec_helper'
require_relative "../render_shared"

describe 'Render as PHP' do
  include_context "shared render"

  before(:each) do
    # In Hiptest: null
    @null_rendered = 'NULL'

    # In Hiptest: 'What is your quest ?'
    @what_is_your_quest_rendered = "'What is your quest ?'"

    # In Hiptest: 3.14
    @pi_rendered = '3.14'

    # In Hiptest: false
    @false_rendered = 'false'

    # In Hiptest: "${foo}fighters"
    @foo_template_rendered = '"{$foo}fighters"'

    # In Hiptest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Hiptest: ""
    @empty_template_rendered = '""'

    # In Hiptest: foo (as in 'foo := 1')
    @foo_variable_rendered = '$foo'

    # In Hiptest: foo.fighters
    @foo_dot_fighters_rendered = '$foo->fighters'

    # In Hiptest: foo['fighters']
    @foo_brackets_fighters_rendered = "$foo['fighters']"

    # In Hiptest: -foo
    @minus_foo_rendered = '-$foo'

    # In Hiptest: foo - 'fighters'
    @foo_minus_fighters_rendered = "$foo - 'fighters'"

    # In Hiptest: (foo)
    @parenthesis_foo_rendered = '($foo)'

    # In Hiptest: [foo, 'fighters']
    @foo_list_rendered = "[$foo, 'fighters']"

    # In Hiptest: foo: 'fighters'
    @foo_fighters_prop_rendered = "$foo => 'fighters'"

    # In Hiptest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{$foo => 'fighters', Alt => J}"

    # In Hiptest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "$foo = 'fighters';"

    # In Hiptest: call 'foo'
    @call_foo_rendered = "$this->actionwords->foo();"
    # In Hiptest: call 'foo bar'
    @call_foo_bar_rendered = "$this->actionwords->fooBar();"

    # In Hiptest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "$this->actionwords->foo('fighters');"
    # In Hiptest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "$this->actionwords->fooBar('fighters');"
    @call_with_special_characters_in_value_rendered = "$this->actionwords->myCallWithWeirdArguments(\"{\\n  this: 'is',\\n  some: ['JSON', 'outputed'],\\n  as: 'a string'\\n}\");"

    # In Hiptest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '// TODO: Implement action: "{$foo}fighters"'

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
      "if (true) {",
      "  $foo = 'fighters';",
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
      "  $foo = 'fighters';",
      "} else {",
      "  $fighters = 'foo';",
      "}\n"
    ].join("\n")

    # In Hiptest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
      "while ($foo) {",
      "  $fighters = 'foo';",
      "  $this->actionwords->foo('fighters');",
      "}\n"
    ].join("\n")

    # In Hiptest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Hiptest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Hiptest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = '$plic'

    # In Hiptest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = "$plic = 'ploc'"

    # In Hiptest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "public function myActionWord() {\n\n}"

    # In Hiptest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "public function myActionWord() {",
      "  // Tags: myTag myTag:somevalue",
      "}"].join("\n")

    @described_action_word_rendered = [
      "public function myActionWord() {",
      "  // Some description",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "public function myActionWord($plic, $flip = 'flap') {",
      "",
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
      "public function compareToPi($x) {",
      "  // Tags: myTag",
      "  $foo = 3.14;",
      "  if ($foo > $x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "  throw new Exception('Not implemented');",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "public function myActionWord() {",
      "  // TODO: Implement action: basic action",
      "  throw new Exception('Not implemented');",
      "}"].join("\n")

    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "<?php",
      "",
      "",
      "class Actionwords {",
      "  public function firstActionWord() {",
      "",
      "  }",
      "",
      "  public function secondActionWord() {",
      "    $this->firstActionWord();",
      "  }",
      "}",
      "?>"].join("\n")

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
      "<?php",
      "",
      "",
      "class Actionwords {",
      "  public function awWithIntParam($x) {",
      "",
      "  }",
      "",
      "  public function awWithFloatParam($x) {",
      "",
      "  }",
      "",
      "  public function awWithBooleanParam($x) {",
      "",
      "  }",
      "",
      "  public function awWithNullParam($x) {",
      "",
      "  }",
      "",
      "  public function awWithStringParam($x) {",
      "",
      "  }",
      "",
      "  public function awWithTemplateParam($x) {",
      "",
      "  }",
      "}",
      "?>"
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
      "public function testCompareToPi() {",
      "  // This is a scenario which description ",
      "  // is on two lines",
      "  // Tags: myTag",
      "  $foo = 3.14;",
      "  if ($foo > $x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "  throw new Exception('Not implemented');",
      "}"].join("\n")

    @full_scenario_with_uid_rendered = [
      "public function testCompareToPiUidAbcd1234() {",
      "  // This is a scenario which description ",
      "  // is on two lines",
      "  // Tags: myTag",
      "  $foo = 3.14;",
      "  if ($foo > $x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "  throw new Exception('Not implemented');",
      "}"].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
      "public function testResetPassword() {",
      "  // Given Page \"/login\" is opened",
      "  $this->actionwords->pageUrlIsOpened('/login');",
      "  // When I click on \"Reset password\"",
      "  $this->actionwords->iClickOnLink('Reset password');",
      "  // Then Page \"/reset-password\" should be opened",
      "  $this->actionwords->pageUrlShouldBeOpened('/reset-password');",
      "}",
    ].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = [
      "<?php",
      "require_once(__DIR__.'/Actionwords.php');",
      "",
      "class CompareToPiTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "",
      "  public function testCompareToPi() {",
      "    // This is a scenario which description ",
      "    // is on two lines",
      "    // Tags: myTag",
      "    $foo = 3.14;",
      "    if ($foo > $x) {",
      "      // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "      // TODO: Implement result: x is lower than Pi",
      "      // on two lines",
      "    }",
      "    throw new Exception('Not implemented');",
      "  }",
      "}",
      "?>"].join("\n")

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
      "public function checkLogin($login, $password, $expected) {",
      "  // Ensure the login process",
      "  $this->actionwords->fillLogin($login);",
      "  $this->actionwords->fillPassword($password);",
      "  $this->actionwords->pressEnter();",
      "  $this->actionwords->assertErrorIsDisplayed($expected);",
      "}",
      "",
      "public function testCheckLoginWrongLogin() {",
      "  $this->checkLogin('invalid', 'invalid', 'Invalid username or password');",
      "}",
      "",
      "public function testCheckLoginWrongPassword() {",
      "  $this->checkLogin('valid', 'invalid', 'Invalid username or password');",
      "}",
      "",
      "public function testCheckLoginValidLoginpassword() {",
      "  $this->checkLogin('valid', 'valid', NULL);",
      "}",
      ""
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      "public function checkLogin($login, $password, $expected) {",
      "  // Ensure the login process",
      "  $this->actionwords->fillLogin($login);",
      "  $this->actionwords->fillPassword($password);",
      "  $this->actionwords->pressEnter();",
      "  $this->actionwords->assertErrorIsDisplayed($expected);",
      "}",
      "",
      "public function testCheckLoginWrongLoginUidA123() {",
      "  $this->checkLogin('invalid', 'invalid', 'Invalid username or password');",
      "}",
      "",
      "public function testCheckLoginWrongPasswordUidB456() {",
      "  $this->checkLogin('valid', 'invalid', 'Invalid username or password');",
      "}",
      "",
      "public function testCheckLoginValidLoginpasswordUidC789() {",
      "  $this->checkLogin('valid', 'valid', NULL);",
      "}",
      ""
    ].join("\n")

    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      "<?php",
      "require_once(__DIR__.'/Actionwords.php');",
      "",
      "class CheckLoginTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "",
      "  public function checkLogin($login, $password, $expected) {",
      "    // Ensure the login process",
      "    $this->actionwords->fillLogin($login);",
      "    $this->actionwords->fillPassword($password);",
      "    $this->actionwords->pressEnter();",
      "    $this->actionwords->assertErrorIsDisplayed($expected);",
      "  }",
      "",
      "  public function testCheckLoginWrongLogin() {",
      "    $this->checkLogin('invalid', 'invalid', 'Invalid username or password');",
      "  }",
      "",
      "  public function testCheckLoginWrongPassword() {",
      "    $this->checkLogin('valid', 'invalid', 'Invalid username or password');",
      "  }",
      "",
      "  public function testCheckLoginValidLoginpassword() {",
      "    $this->checkLogin('valid', 'valid', NULL);",
      "  }",
      "}",
      "?>"
    ].join("\n")

    # In Hiptest, correspond to two scenarios in a project called "Mike's project"
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "<?php",
      "require_once('Actionwords.php');",
      "",
      "class ProjectTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "",
      "  public function testFirstScenario() {",
      "",
      "  }",
      "",
      "  public function testSecondScenario() {",
      "    $this->actionwords->myActionWord();",
      "  }",
      "}",
      "?>"].join("\n")

    @tests_rendered = [
      "<?php",
      "require_once('Actionwords.php');",
      "",
      "class ProjectTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "",
      "  public function testLogin() {",
      "    // The description is on ",
      "    // two lines",
      "    // Tags: myTag myTag:somevalue",
      "    $this->actionwords->visit('/login');",
      "    $this->actionwords->fill('user@example.com');",
      "    $this->actionwords->fill('s3cret');",
      "    $this->actionwords->click('.login-form input[type=submit]');",
      "    $this->actionwords->checkUrl('/welcome');",
      "  }",
      "",
      "  public function testFailedLogin() {",
      "    // Tags: myTag:somevalue",
      "    $this->actionwords->visit('/login');",
      "    $this->actionwords->fill('user@example.com');",
      "    $this->actionwords->fill('notTh4tS3cret');",
      "    $this->actionwords->click('.login-form input[type=submit]');",
      "    $this->actionwords->checkUrl('/login');",
      "  }",
      "}",
      "?>"
    ].join("\n")

    @first_test_rendered = [
      "public function testLogin() {",
      "  // The description is on ",
      "  // two lines",
      "  // Tags: myTag myTag:somevalue",
      "  $this->actionwords->visit('/login');",
      "  $this->actionwords->fill('user@example.com');",
      "  $this->actionwords->fill('s3cret');",
      "  $this->actionwords->click('.login-form input[type=submit]');",
      "  $this->actionwords->checkUrl('/welcome');",
      "}"
    ].join("\n")

    @first_test_rendered_for_single_file = [
      "<?php",
      "require_once('Actionwords.php');",
      "",
      "class LoginTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "",
      "  public function testLogin() {",
      "    // The description is on ",
      "    // two lines",
      "    // Tags: myTag myTag:somevalue",
      "    $this->actionwords->visit('/login');",
      "    $this->actionwords->fill('user@example.com');",
      "    $this->actionwords->fill('s3cret');",
      "    $this->actionwords->click('.login-form input[type=submit]');",
      "    $this->actionwords->checkUrl('/welcome');",
      "  }",
      "}",
      "?>"
    ].join("\n")

    @grand_child_scenario_rendered_for_single_file = [
      "<?php",
      "require_once(__DIR__.'/../../Actionwords.php');",
      "",
      "class OneGrandchildScenarioTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "",
      "  public function testOneGrandchildScenario() {",
      "",
      "  }",
      "}",
      "?>"
    ].join("\n")

    @root_folder_rendered = [
      "<?php",
      "require_once(__DIR__.'/Actionwords.php');",
      "",
      "class MyRootFolderTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "",
      "  public function testOneRootScenario() {",
      "",
      "  }",
      "",
      "  public function testAnotherRootScenario() {",
      "",
      "  }",
      "}",
      "?>"
    ].join("\n")

    @grand_child_folder_rendered = [
      "<?php",
      "require_once(__DIR__.'/../Actionwords.php');",
      "",
      "class AGrandchildFolderTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "  }",
      "}",
      "?>"
    ].join("\n")

    @second_grand_child_folder_rendered = [
      "<?php",
      "require_once(__DIR__.'/../Actionwords.php');",
      "",
      "class ASecondGrandchildFolderTest extends PHPUnit_Framework_TestCase {",
      "  public $actionwords;",
      "  public function setUp() {",
      "    $this->actionwords = new Actionwords();",
      "",
      "    $this->actionwords->visit('/login');",
      "    $this->actionwords->fill('user@example.com');",
      "    $this->actionwords->fill('notTh4tS3cret');",
      "  }",
      "",
      "  public function testOneGrandchildScenario() {",
      "",
      "  }",
      "}",
      "?>"
    ].join("\n")
  end

  context 'PHPUnit' do
    it_behaves_like "a renderer" do
      let(:language) {'php'}
      let(:framework) {'phpunit'}
    end

    it 'Actionwords must extend ActionwordLibrary if there are libraries' do
      aws = Hiptest::Nodes::Actionwords.new([make_actionword('aw')])
      libraries = Hiptest::Nodes::Libraries.new([make_library('default', [])])
      project = Hiptest::Nodes::Project.new(
        'project',
        '',
        Hiptest::Nodes::TestPlan.new,
        Hiptest::Nodes::Scenarios.new,
        aws,
        Hiptest::Nodes::Tests.new,
        libraries
      )

      Hiptest::NodeModifiers.add_all(project)

      context = context_for(
        only: 'actionwords',
        language: 'behat',
        framework: ''
      )

      expect(aws.render(context)).to include('class Actionwords extends ActionwordLibrary')
    end
  end
end
