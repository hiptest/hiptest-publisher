require_relative '../spec_helper'
require_relative "../render_shared"

describe 'Render as Java' do
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
    @foo_template_rendered = 'String.format("%sfighters", foo)'

    # In Hiptest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Hiptest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'
    @foo_bar_variable_rendered = 'fooBar'

    # In Hiptest: foo.fighters
    # TODO: Shouldn't have a better manner ?
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In Hiptest: foo['fighters']
    # TODO: foo should be a map in Java, depend usage: getter or setter ?
    @foo_brackets_fighters_rendered = 'foo.get("fighters")'

    # In Hiptest: -foo
    @minus_foo_rendered = '-foo'

    # In Hiptest: foo - 'fighters'
    @foo_minus_fighters_rendered = 'foo - "fighters"'

    # In Hiptest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In Hiptest: [foo, 'fighters']
    @foo_list_rendered = 'new String[]{foo, "fighters"}'

    # In Hiptest: foo: 'fighters'
    # TODO: What is a property in Java ?
    @foo_fighters_prop_rendered = 'foo: "fighters"'

    # In Hiptest: {foo: 'fighters', Alt: J}
    # TODO: What is a dictionary in Java ?
    @foo_dict_rendered = '{foo: "fighters", Alt: J}'

    # In Hiptest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "foo = \"fighters\";"

    # In Hiptest: call 'foo'
    @call_foo_rendered = "actionwords.foo();"
    # In Hiptest: call 'foo bar'
    @call_foo_bar_rendered = "actionwords.fooBar();"

    # In Hiptest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = 'actionwords.foo("fighters");'
    # In Hiptest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = 'actionwords.fooBar("fighters");'

    # In Hiptest: step {action: "${foo}fighters"}
    # TODO: it is a little big strange to use a string format
    @action_foo_fighters_rendered = '// TODO: Implement action: String.format("%sfighters", foo)'

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
      "if (true) {",
      "    foo = \"fighters\";",
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
      '    foo = "fighters";',
      "} else {",
      '    fighters = "foo";',
      "}"
    ].join("\n")

    # In Hiptest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
      "while (foo) {",
      '    fighters = "foo";',
      '    actionwords.foo("fighters");',
      "}"
    ].join("\n")

    # In Hiptest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Hiptest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Hiptest: plic (as in: definition 'foo'(plic))
    # TODO: choose the right type
    @plic_param_rendered = 'String plic'

    # In Hiptest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    # TODO: how render default value ?
    # TODO: test with parameter name: plic_et
    @plic_param_default_ploc_rendered = "String plic"

    # In Hiptest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = [
      "public void myActionWord() {",
      "",
      "}"].join("\n")


    # In Hiptest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "public void myActionWord() {",
      "    // Tags: myTag myTag:somevalue",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "public void myActionWord(String plic, String flip) {",
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
      "public void compareToPi(String x) {",
      "    // Tags: myTag",
      "    foo = 3.14;",
      "    if (foo > x) {",
      "        // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "        // TODO: Implement result: x is lower than Pi",
      "        // on two lines",
      "    }",
      "    throw new UnsupportedOperationException();",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "public void myActionWord() {",
      "    // TODO: Implement action: basic action",
      "    throw new UnsupportedOperationException();",
      "}"].join("\n")

    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "package com.example;",
      "",
      "public class Actionwords {",
      "",
      "    public void firstActionWord() {",
      "",
      "    }",
      "",
      "    public void secondActionWord() {",
      "        firstActionWord();",
      "    }",
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
      "package com.example;",
      "",
      "public class Actionwords {",
      "",
      "    public void awWithIntParam(int x) {",
      "",
      "    }",
      "",
      "    public void awWithFloatParam(float x) {",
      "",
      "    }",
      "",
      "    public void awWithBooleanParam(bool x) {",
      "",
      "    }",
      "",
      "    public void awWithNullParam(String x) {",
      "",
      "    }",
      "",
      "    public void awWithStringParam(String x) {",
      "",
      "    }",
      "",
      "    public void awWithTemplateParam(String x) {",
      "",
      "    }",
      "}"
    ].join("\n")
  end

  context 'JUnit' do
    before(:each) do
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
        "// This is a scenario which description ",
        "// is on two lines",
        "// Tags: myTag",
        "public void testCompareToPi() {",
        "    foo = 3.14;",
        "    if (foo > x) {",
        "        // TODO: Implement result: x is greater than Pi",
        "    } else {",
        "        // TODO: Implement result: x is lower than Pi",
        "        // on two lines",
        "    }",
        "",
        "    throw new UnsupportedOperationException();",
        "}"].join("\n")

      # In hiptest
      # scenario 'reset password' do
      #   call given 'Page "url" is opened'(url='/login')
      #   call when 'I click on "link"'(link='Reset password')
      #   call then 'page "url" should be opened'(url='/reset-password')
      # end
      @bdd_scenario_rendered = [
        '',
        'public void testResetPassword() {',
        '    // Given Page "/login" is opened',
        '    actionwords.pageUrlIsOpened("/login");',
        '    // When I click on "Reset password"',
        '    actionwords.iClickOnLink("Reset password");',
        '    // Then Page "/reset-password" should be opened',
        '    actionwords.pageUrlShouldBeOpened("/reset-password");',
        '}'
      ].join("\n")

      @full_scenario_with_uid_rendered = [
        "// This is a scenario which description ",
        "// is on two lines",
        "// Tags: myTag",
        "public void testCompareToPiUidabcd1234() {",
        "    foo = 3.14;",
        "    if (foo > x) {",
        "        // TODO: Implement result: x is greater than Pi",
        "    } else {",
        "        // TODO: Implement result: x is lower than Pi",
        "        // on two lines",
        "    }",
        "",
        "    throw new UnsupportedOperationException();",
        "}"].join("\n")

      @full_scenario_rendered_for_single_file = [
        "package com.example;",
        "",
        "import junit.framework.TestCase;",
        "",
        "public class MyScenarioTest extends TestCase {",
        "",
        "    public Actionwords actionwords = new Actionwords();",
        "",
        "    // This is a scenario which description ",
        "    // is on two lines",
        "    // Tags: myTag",
        "    public void testCompareToPi() {",
        "        foo = 3.14;",
        "        if (foo > x) {",
        "            // TODO: Implement result: x is greater than Pi",
        "        } else {",
        "            // TODO: Implement result: x is lower than Pi",
        "            // on two lines",
        "        }",
        "",
        "        throw new UnsupportedOperationException();",
        "    }",
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
        "public void checkLogin(String login, String password, String expected) {",
        "    actionwords.fillLogin(login);",
        "    actionwords.fillPassword(password);",
        "    actionwords.pressEnter();",
        "    actionwords.assertErrorIsDisplayed(expected);",
        "}",
        "",
        "public void testCheckLoginWrongLogin() {",
        '    checkLogin("invalid", "invalid", "Invalid username or password");',
        "}",
        "",
        "public void testCheckLoginWrongPassword() {",
        '    checkLogin("valid", "invalid", "Invalid username or password");',
        "}",
        "",
        "public void testCheckLoginValidLoginpassword() {",
        '    checkLogin("valid", "valid", null);',
        "}",
        "",
        ""
      ].join("\n")

      @scenario_with_datatable_rendered_with_uids = [
        "public void checkLogin(String login, String password, String expected) {",
        "    actionwords.fillLogin(login);",
        "    actionwords.fillPassword(password);",
        "    actionwords.pressEnter();",
        "    actionwords.assertErrorIsDisplayed(expected);",
        "}",
        "",
        "public void testCheckLoginWrongLoginUida123() {",
        '    checkLogin("invalid", "invalid", "Invalid username or password");',
        "}",
        "",
        "public void testCheckLoginWrongPasswordUidb456() {",
        '    checkLogin("valid", "invalid", "Invalid username or password");',
        "}",
        "",
        "public void testCheckLoginValidLoginpasswordUidc789() {",
        '    checkLogin("valid", "valid", null);',
        "}",
        "",
        ""
      ].join("\n")


      # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
      @scenario_with_datatable_rendered_in_single_file = [
        "package com.example;",
        "",
        "import junit.framework.TestCase;",
        "",
        "public class MyScenarioTest extends TestCase {",
        "",
        "    public Actionwords actionwords = new Actionwords();",
        "",
        "    public void checkLogin(String login, String password, String expected) {",
        "        actionwords.fillLogin(login);",
        "        actionwords.fillPassword(password);",
        "        actionwords.pressEnter();",
        "        actionwords.assertErrorIsDisplayed(expected);",
        "    }",
        "",
        "    public void testCheckLoginWrongLogin() {",
        '        checkLogin("invalid", "invalid", "Invalid username or password");',
        "    }",
        "",
        "    public void testCheckLoginWrongPassword() {",
        '        checkLogin("valid", "invalid", "Invalid username or password");',
        "    }",
        "",
        "    public void testCheckLoginValidLoginpassword() {",
        '        checkLogin("valid", "valid", null);',
        "    }",
        "}"
      ].join("\n")

      # In Hiptest, correspond to two scenarios in a project called 'My project'
      # scenario 'first scenario' do
      # end
      # scenario 'second scenario' do
      #   call 'my action word'
      # end
      @scenarios_rendered = [
        "package com.example;",
        "",
        "import junit.framework.TestCase;",
        "",
        "public class ProjectTest extends TestCase {",
        "",
        "    public Actionwords actionwords = new Actionwords();",
        "",
        "    public void testFirstScenario() {",
        "    }",
        "",
        "    public void testSecondScenario() {",
        "        actionwords.myActionWord();",
        "    }",
        "}"].join("\n")

      @tests_rendered = [
        'package com.example;',
        '',
        'import junit.framework.TestCase;',
        '',
        'public class ProjectTest extends TestCase {',
        '',
        '    public Actionwords actionwords = new Actionwords();',
        '    // The description is on ',
        '    // two lines',
        '    // Tags: myTag myTag:somevalue',
        '    public void testLogin() {',
        '        actionwords.visit("/login");',
        '        actionwords.fill("user@example.com");',
        '        actionwords.fill("s3cret");',
        '        actionwords.click(".login-form input[type=submit]");',
        '        actionwords.checkUrl("/welcome");',
        '    }',
        '    // ',
        '    // Tags: myTag:somevalue',
        '    public void testFailedLogin() {',
        '        actionwords.visit("/login");',
        '        actionwords.fill("user@example.com");',
        '        actionwords.fill("notTh4tS3cret");',
        '        actionwords.click(".login-form input[type=submit]");',
        '        actionwords.checkUrl("/login");',
        '    }',
        '}'
      ].join("\n")

      @first_test_rendered = [
        '// The description is on ',
        '// two lines',
        '// Tags: myTag myTag:somevalue',
        'public void testLogin() {',
        '    actionwords.visit("/login");',
        '    actionwords.fill("user@example.com");',
        '    actionwords.fill("s3cret");',
        '    actionwords.click(".login-form input[type=submit]");',
        '    actionwords.checkUrl("/welcome");',
        '}'
      ].join("\n")

      @first_test_rendered_for_single_file = [
        'package com.example;',
        '',
        'import junit.framework.TestCase;',
        '',
        'public class MyScenarioTest extends TestCase {',
        '',
        '    public Actionwords actionwords = new Actionwords();',
        '',
        '    // The description is on ',
        '    // two lines',
        '    // Tags: myTag myTag:somevalue',
        '    public void testLogin() {',
        '        actionwords.visit("/login");',
        '        actionwords.fill("user@example.com");',
        '        actionwords.fill("s3cret");',
        '        actionwords.click(".login-form input[type=submit]");',
        '        actionwords.checkUrl("/welcome");',
        '    }',
        '}'
      ].join("\n")
    end

    it_behaves_like "a renderer" do
      let(:language) { 'java' }
      let(:framework) { 'JUnit' }
      let(:test_name) { 'my scenario' }
      let(:package) { 'com.example' }
    end
  end

  context 'TestNG' do
    before(:each) do
      @full_scenario_rendered = [
        "// This is a scenario which description ",
        "// is on two lines",
        "// Tags: myTag",
        "@Test",
        "public void compareToPi() {",
        "    foo = 3.14;",
        "    if (foo > x) {",
        "        // TODO: Implement result: x is greater than Pi",
        "    } else {",
        "        // TODO: Implement result: x is lower than Pi",
        "        // on two lines",
        "    }",
        "",
        "    throw new UnsupportedOperationException();",
        "}"].join("\n")

      # In hiptest
      # scenario 'reset password' do
      #   call given 'Page "url" is opened'(url='/login')
      #   call when 'I click on "link"'(link='Reset password')
      #   call then 'page "url" should be opened'(url='/reset-password')
      # end
      @bdd_scenario_rendered = [
          '',
          '@Test',
          'public void resetPassword() {',
          '    // Given Page "/login" is opened',
          '    actionwords.pageUrlIsOpened("/login");',
          '    // When I click on "Reset password"',
          '    actionwords.iClickOnLink("Reset password");',
          '    // Then Page "/reset-password" should be opened',
          '    actionwords.pageUrlShouldBeOpened("/reset-password");',
          '}'
      ].join("\n")

      @full_scenario_with_uid_rendered = [
        "// This is a scenario which description ",
        "// is on two lines",
        "// Tags: myTag",
        "@Test",
        "public void compareToPiUidabcd1234() {",
        "    foo = 3.14;",
        "    if (foo > x) {",
        "        // TODO: Implement result: x is greater than Pi",
        "    } else {",
        "        // TODO: Implement result: x is lower than Pi",
        "        // on two lines",
        "    }",
        "",
        "    throw new UnsupportedOperationException();",
        "}"].join("\n")

      @full_scenario_rendered_for_single_file = [
        "package com.example;",
        "",
        "import org.testng.annotations.*;",
        "",
        "public class MyScenarioTest {",
        "",
        "    public Actionwords actionwords = new Actionwords();",
        "",
        "    // This is a scenario which description ",
        "    // is on two lines",
        "    // Tags: myTag",
        "    @Test",
        "    public void compareToPi() {",
        "        foo = 3.14;",
        "        if (foo > x) {",
        "            // TODO: Implement result: x is greater than Pi",
        "        } else {",
        "            // TODO: Implement result: x is lower than Pi",
        "            // on two lines",
        "        }",
        "",
        "        throw new UnsupportedOperationException();",
        "    }",
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
        "public void checkLogin(String login, String password, String expected) {",
        "    actionwords.fillLogin(login);",
        "    actionwords.fillPassword(password);",
        "    actionwords.pressEnter();",
        "    actionwords.assertErrorIsDisplayed(expected);",
        "}",
        "",
        "@Test",
        "public void checkLoginWrongLogin() {",
        '    checkLogin("invalid", "invalid", "Invalid username or password");',
        "}",
        "",
        "@Test",
        "public void checkLoginWrongPassword() {",
        '    checkLogin("valid", "invalid", "Invalid username or password");',
        "}",
        "",
        "@Test",
        "public void checkLoginValidLoginpassword() {",
        '    checkLogin("valid", "valid", null);',
        "}",
        "",
        ""
      ].join("\n")

      @scenario_with_datatable_rendered_with_uids = [
        "public void checkLogin(String login, String password, String expected) {",
        "    actionwords.fillLogin(login);",
        "    actionwords.fillPassword(password);",
        "    actionwords.pressEnter();",
        "    actionwords.assertErrorIsDisplayed(expected);",
        "}",
        "",
        "@Test",
        "public void checkLoginWrongLoginUida123() {",
        '    checkLogin("invalid", "invalid", "Invalid username or password");',
        "}",
        "",
        "@Test",
        "public void checkLoginWrongPasswordUidb456() {",
        '    checkLogin("valid", "invalid", "Invalid username or password");',
        "}",
        "",
        "@Test",
        "public void checkLoginValidLoginpasswordUidc789() {",
        '    checkLogin("valid", "valid", null);',
        "}",
        "",
        ""
      ].join("\n")

      # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
      @scenario_with_datatable_rendered_in_single_file = [
        "package com.example;",
        "",
        "import org.testng.annotations.*;",
        "",
        "public class MyScenarioTest {",
        "",
        "    public Actionwords actionwords = new Actionwords();",
        "",
        "    public void checkLogin(String login, String password, String expected) {",
        "        actionwords.fillLogin(login);",
        "        actionwords.fillPassword(password);",
        "        actionwords.pressEnter();",
        "        actionwords.assertErrorIsDisplayed(expected);",
        "    }",
        "",
        "    @Test",
        "    public void checkLoginWrongLogin() {",
        '        checkLogin("invalid", "invalid", "Invalid username or password");',
        "    }",
        "",
        "    @Test",
        "    public void checkLoginWrongPassword() {",
        '        checkLogin("valid", "invalid", "Invalid username or password");',
        "    }",
        "",
        "    @Test",
        "    public void checkLoginValidLoginpassword() {",
        '        checkLogin("valid", "valid", null);',
        "    }",
        "}"
      ].join("\n")

      @scenarios_rendered = [
        "package com.example;",
        "",
        "import org.testng.annotations.*;",
        "",
        "public class ProjectTest {",
        "",
        "    public Actionwords actionwords;",
        "",
        "    @BeforeMethod",
        "    public void setUp() {",
        "        actionwords = new Actionwords();",
        "    }",
        "",
        "    @Test",
        "    public void firstScenario() {",
        "    }",
        "",
        "    @Test",
        "    public void secondScenario() {",
        "        actionwords.myActionWord();",
        "    }",
        "}"].join("\n")

        @tests_rendered = [
          'package com.example;',
          '',
          'import org.testng.annotations.*;',
          '',
          'public class ProjectTest {',
          '',
          '    public Actionwords actionwords;',
          '',
          '    @BeforeMethod',
          '    public void setUp() {',
          '        actionwords = new Actionwords();',
          '    }',
          '    // The description is on ',
          '    // two lines',
          '    // Tags: myTag myTag:somevalue',
          '    @Test',
          '    public void login() {',
          '        actionwords.visit("/login");',
          '        actionwords.fill("user@example.com");',
          '        actionwords.fill("s3cret");',
          '        actionwords.click(".login-form input[type=submit]");',
          '        actionwords.checkUrl("/welcome");',
          '    }',
          '    // ',
          '    // Tags: myTag:somevalue',
          '    @Test',
          '    public void failedLogin() {',
          '        actionwords.visit("/login");',
          '        actionwords.fill("user@example.com");',
          '        actionwords.fill("notTh4tS3cret");',
          '        actionwords.click(".login-form input[type=submit]");',
          '        actionwords.checkUrl("/login");',
          '    }',
          '}'
        ].join("\n")

        @first_test_rendered = [
          '// The description is on ',
          '// two lines',
          '// Tags: myTag myTag:somevalue',
          '@Test',
          'public void login() {',
          '    actionwords.visit("/login");',
          '    actionwords.fill("user@example.com");',
          '    actionwords.fill("s3cret");',
          '    actionwords.click(".login-form input[type=submit]");',
          '    actionwords.checkUrl("/welcome");',
          '}',
        ].join("\n")

        @first_test_rendered_for_single_file = [
         'package com.example;',
         '',
         'import org.testng.annotations.*;',
         '',
         'public class MyScenarioTest {',
         '',
         '    public Actionwords actionwords = new Actionwords();',
         '',
         "    // The description is on ",
         "    // two lines",
         "    // Tags: myTag myTag:somevalue",
         "    @Test",
         "    public void login() {",
         '        actionwords.visit("/login");',
         '        actionwords.fill("user@example.com");',
         '        actionwords.fill("s3cret");',
         '        actionwords.click(".login-form input[type=submit]");',
         '        actionwords.checkUrl("/welcome");',
         '    }',
         '}',
        ].join("\n")
    end

    it_behaves_like "a renderer" do
      let(:language) { 'java' }
      let(:framework) { 'testng' }
      let(:test_name) { 'my scenario' }
      let(:package) { 'com.example' }
    end
  end
end

describe 'default package' do
  it "uses com.example as default package name for Java/JUnit" do
    rendering_context = context_for(language: 'java', framework: 'JUnit')
    expect(rendering_context.package).to eq('com.example')
  end

  it "uses com.example as default package name for Java/JUnit" do
    rendering_context = context_for(language: 'java', framework: 'TestNG')
    expect(rendering_context.package).to eq('com.example')
  end
end

