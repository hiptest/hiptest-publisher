require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Render as C#' do
  include_context "shared render"

  before(:each) do
    # In HipTest: null
    @null_rendered = 'null'

    # In HipTest: 'What is your quest ?'
    @what_is_your_quest_rendered = '"What is your quest ?"'

    # In Hiptest: '{ "key\" : "val" }'
    @string_literal_with_quotes_rendered = '"{ \"key\" : \"val\" }"'

    # In HipTest: 3.14
    @pi_rendered = '3.14'

    # In HipTest: false
    @false_rendered = 'false'

    # In HipTest: "${foo}fighters"
    @foo_template_rendered = 'foo + "fighters"'

    # In HipTest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In HipTest: ""
    @empty_template_rendered = '""'

    # In HipTest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'
    @foo_bar_variable_rendered = 'fooBar'

    # In HipTest: foo.fighters
    # TODO: Shouldn't have a better manner ?
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In HipTest: foo['fighters']
    @foo_brackets_fighters_rendered = 'foo["fighters"]'

    # In HipTest: -foo
    @minus_foo_rendered = '-foo'

    # In HipTest: foo - 'fighters'
    @foo_minus_fighters_rendered = 'foo - "fighters"'

    # In HipTest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In HipTest: [foo, 'fighters']
    @foo_list_rendered = '{foo, "fighters"}'

    # In HipTest: foo: 'fighters'
    @foo_fighters_prop_rendered = '{foo, "fighters"}'

    # In HipTest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = 'new Dictionary<String, String>() {{foo, "fighters"}, {Alt, J}}'

    # In HipTest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "foo = \"fighters\";"

    # In HipTest: call 'foo'
    @call_foo_rendered = "Actionwords.Foo();"
    # In HipTest: call 'foo bar'
    @call_foo_bar_rendered = "Actionwords.FooBar();"

    # In HipTest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = 'Actionwords.Foo("fighters");'
    # In HipTest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = 'Actionwords.FooBar("fighters");'

    # In HipTest: step {action: "${foo}fighters"}
    # TODO: it is a little big strange to use a string format
    @action_foo_fighters_rendered = '// TODO: Implement action: foo + "fighters"'

    @call_with_special_characters_in_value_rendered = "Actionwords.MyCallWithWeirdArguments(\"{\\n  this: 'is',\\n  some: ['JSON', 'outputed'],\\n  as: 'a string'\\n}\");"

    # In HipTest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
      "if (true) {",
      "    foo = \"fighters\";",
      "}"
    ].join("\n")

    # In HipTest:
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

    # In HipTest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
      "while (foo) {",
      '    fighters = "foo";',
      '    Actionwords.Foo("fighters");',
      "}"
    ].join("\n")

    # In HipTest: @myTag
    @simple_tag_rendered = 'myTag'

    # In HipTest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In HipTest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = 'string plic'

    # In HipTest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    # TODO: how render default value ?
    @plic_param_default_ploc_rendered = "string plic"

    # In HipTest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = [
      "public void MyActionWord() {",
      "",
      "}"].join("\n")


    # In HipTest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "public void MyActionWord() {",
      "    // Tags: myTag myTag:somevalue",
      "}"].join("\n")

    @described_action_word_rendered = [
      "public void MyActionWord() {",
      "    // Some description",
      "}"].join("\n")

    # In HipTest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "public void MyActionWord(string plic, string flip) {",
      "",
      "}"].join("\n")

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
      "public void CompareToPi(string x) {",
      "    // Tags: myTag",
      "    foo = 3.14;",
      "    if (foo > x) {",
      "        // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "        // TODO: Implement result: x is lower than Pi",
      "        // on two lines",
      "    }",
      "    throw new NotImplementedException();",
      "}"].join("\n")

    # In HipTest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "public void MyActionWord() {",
      "    // TODO: Implement action: basic action",
      "    throw new NotImplementedException();",
      "}"].join("\n")

    # In HipTest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "namespace MyProject {",
      "",
      "    public class Actionwords {",
      "",
      "        public void FirstActionWord() {",
      "",
      "        }",
      "",
      "        public void SecondActionWord() {",
      "            this.FirstActionWord();",
      "        }",
      "    }",
      "}"].join("\n")

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
      "namespace MyProject {",
      "",
      "    public class Actionwords {",
      "",
      "        public void AwWithIntParam(int x) {",
      "",
      "        }",
      "",
      "        public void AwWithFloatParam(float x) {",
      "",
      "        }",
      "",
      "        public void AwWithBooleanParam(bool x) {",
      "",
      "        }",
      "",
      "        public void AwWithNullParam(string x) {",
      "",
      "        }",
      "",
      "        public void AwWithStringParam(string x) {",
      "",
      "        }",
      "",
      "        public void AwWithTemplateParam(string x) {",
      "",
      "        }",
      "    }",
      "}"
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
      "// This is a scenario which description ",
      "// is on two lines",
      "// Tags: myTag",
      "[Test]",
      "public void CompareToPi() {",
      "    foo = 3.14;",
      "    if (foo > x) {",
      "        // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "        // TODO: Implement result: x is lower than Pi",
      "        // on two lines",
      "    }",
      "",
      "    throw new NotImplementedException();",
      "}"].join("\n")


    @bdd_scenario_rendered = [
      '',
      '[Test]',
      'public void ResetPassword() {',
      '    // Given Page "/login" is opened',
      '    Actionwords.PageUrlIsOpened("/login");',
      '    // When I click on "Reset password"',
      '    Actionwords.IClickOnLink("Reset password");',
      '    // Then Page "/reset-password" should be opened',
      '    Actionwords.PageUrlShouldBeOpened("/reset-password");',
      '}'
    ].join("\n")

    @full_scenario_with_uid_rendered = [
      "// This is a scenario which description ",
      "// is on two lines",
      "// Tags: myTag",
      "[Test]",
      "public void CompareToPiUidabcd1234() {",
      "    foo = 3.14;",
      "    if (foo > x) {",
      "        // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "        // TODO: Implement result: x is lower than Pi",
      "        // on two lines",
      "    }",
      "",
      "    throw new NotImplementedException();",
      "}"].join("\n")

    @full_scenario_rendered_for_single_file = [
      "namespace MyProject {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "",
      "    [TestFixture]",
      "    public class CompareToPiTest {",
      "",
      "        public Actionwords Actionwords = new Actionwords();",
      "",
      "        // This is a scenario which description ",
      "        // is on two lines",
      "        // Tags: myTag",
      "        [Test]",
      "        public void CompareToPi() {",
      "            foo = 3.14;",
      "            if (foo > x) {",
      "                // TODO: Implement result: x is greater than Pi",
      "            } else {",
      "                // TODO: Implement result: x is lower than Pi",
      "                // on two lines",
      "            }",
      "",
      "            throw new NotImplementedException();",
      "        }",
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
      "public void CheckLogin(string login, string password, string expected) {",
      "    // Ensure the login process",
      "    Actionwords.FillLogin(login);",
      "    Actionwords.FillPassword(password);",
      "    Actionwords.PressEnter();",
      "    Actionwords.AssertErrorIsDisplayed(expected);",
      "}",
      "",
      "[Test]",
      "public void CheckLoginWrongLogin() {",
      '    CheckLogin("invalid", "invalid", "Invalid username or password");',
      "}",
      "",
      "[Test]",
      "public void CheckLoginWrongPassword() {",
      '    CheckLogin("valid", "invalid", "Invalid username or password");',
      "}",
      "",
      "[Test]",
      "public void CheckLoginValidLoginpassword() {",
      '    CheckLogin("valid", "valid", null);',
      "}",
      "",
      ""
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      "public void CheckLogin(string login, string password, string expected) {",
      "    // Ensure the login process",
      "    Actionwords.FillLogin(login);",
      "    Actionwords.FillPassword(password);",
      "    Actionwords.PressEnter();",
      "    Actionwords.AssertErrorIsDisplayed(expected);",
      "}",
      "",
      "[Test]",
      "public void CheckLoginWrongLoginUida123() {",
      '    CheckLogin("invalid", "invalid", "Invalid username or password");',
      "}",
      "",
      "[Test]",
      "public void CheckLoginWrongPasswordUidb456() {",
      '    CheckLogin("valid", "invalid", "Invalid username or password");',
      "}",
      "",
      "[Test]",
      "public void CheckLoginValidLoginpasswordUidc789() {",
      '    CheckLogin("valid", "valid", null);',
      "}",
      "",
      ""
    ].join("\n")


    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      "namespace MyProject {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "",
      "    [TestFixture]",
      "    public class CheckLoginTest {",
      "",
      "        public Actionwords Actionwords = new Actionwords();",
      "",
      "        public void CheckLogin(string login, string password, string expected) {",
      "            // Ensure the login process",
      "            Actionwords.FillLogin(login);",
      "            Actionwords.FillPassword(password);",
      "            Actionwords.PressEnter();",
      "            Actionwords.AssertErrorIsDisplayed(expected);",
      "        }",
      "",
      "        [Test]",
      "        public void CheckLoginWrongLogin() {",
      '            CheckLogin("invalid", "invalid", "Invalid username or password");',
      "        }",
      "",
      "        [Test]",
      "        public void CheckLoginWrongPassword() {",
      '            CheckLogin("valid", "invalid", "Invalid username or password");',
      "        }",
      "",
      "        [Test]",
      "        public void CheckLoginValidLoginpassword() {",
      '            CheckLogin("valid", "valid", null);',
      "        }",
      "    }",
      "}"
    ].join("\n")

    # In HipTest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "namespace MyProject {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "",
      "    [TestFixture]",
      "    public class ProjectTest {",
      "",
      "        public Actionwords Actionwords;",
      "",
      "        [SetUp]",
      "        protected void SetUp() {",
      "            Actionwords = new Actionwords();",
      "        }",
      "",
      "        [Test]",
      "        public void FirstScenario() {",
      "        }",
      "",
      "        [Test]",
      "        public void SecondScenario() {",
      "            Actionwords.MyActionWord();",
      "        }",
      "    }",
      "}"
    ].join("\n")

    @tests_rendered = [
      "namespace MyProject {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "",
      "    [TestFixture]",
      "    public class ProjectTest {",
      "",
      '        public Actionwords Actionwords = new Actionwords();',
      '        // The description is on ',
      '        // two lines',
      '        // Tags: myTag myTag:somevalue',
      "        [Test]",
      '        public void Login() {',
      '            Actionwords.Visit("/login");',
      '            Actionwords.Fill("user@example.com");',
      '            Actionwords.Fill("s3cret");',
      '            Actionwords.Click(".login-form input[type=submit]");',
      '            Actionwords.CheckUrl("/welcome");',
      '        }',
      '        //',
      '        // Tags: myTag:somevalue',
      "        [Test]",
      '        public void FailedLogin() {',
      '            Actionwords.Visit("/login");',
      '            Actionwords.Fill("user@example.com");',
      '            Actionwords.Fill("notTh4tS3cret");',
      '            Actionwords.Click(".login-form input[type=submit]");',
      '            Actionwords.CheckUrl("/login");',
      '        }',
      '    }',
      '}'
    ].join("\n")

    @first_test_rendered = [
      '// The description is on ',
      '// two lines',
      '// Tags: myTag myTag:somevalue',
      '[Test]',
      'public void Login() {',
      '    Actionwords.Visit("/login");',
      '    Actionwords.Fill("user@example.com");',
      '    Actionwords.Fill("s3cret");',
      '    Actionwords.Click(".login-form input[type=submit]");',
      '    Actionwords.CheckUrl("/welcome");',
      '}'
    ].join("\n")

    @first_test_rendered_for_single_file = [
      "namespace MyProject {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "",
      "    [TestFixture]",
      "    public class LoginTest {",
      "",
      "        public Actionwords Actionwords = new Actionwords();",
      '',
      '        // The description is on ',
      '        // two lines',
      '        // Tags: myTag myTag:somevalue',
      '        [Test]',
      '        public void Login() {',
      '            Actionwords.Visit("/login");',
      '            Actionwords.Fill("user@example.com");',
      '            Actionwords.Fill("s3cret");',
      '            Actionwords.Click(".login-form input[type=submit]");',
      '            Actionwords.CheckUrl("/welcome");',
      '        }',
      '    }',
      '}',
    ].join("\n")

    @grand_child_scenario_rendered_for_single_file = [
      "namespace MyProject.ChildFolder.ASecondGrandchildFolder {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "    using MyProject;",
      "",
      "    [TestFixture]",
      "    public class OneGrandchildScenarioTest {",
      "",
      "        public Actionwords Actionwords = new Actionwords();",
      "",
      "",
      "        [Test]",
      "        public void OneGrandchildScenario() {",
      "        }",
      "    }",
      "}",
    ].join("\n")

    @root_folder_rendered = [
      "namespace MyProject {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "",
      "    [TestFixture]",
      "    public class MyRootFolderTest {",
      "",
      "        public Actionwords Actionwords;",
      "",
      "        [SetUp]",
      "        protected void SetUp() {",
      "            Actionwords = new Actionwords();",
      "        }",
      "",
      "        [Test]",
      "        public void OneRootScenario() {",
      "        }",
      "",
      "        [Test]",
      "        public void AnotherRootScenario() {",
      "        }",
      "    }",
      "}",
    ].join("\n")

    @grand_child_folder_rendered = [
      "namespace MyProject.ChildFolder {",
      "",
      "    using System;",
      "    using NUnit.Framework;",
      "    using MyProject;",
      "",
      "    [TestFixture]",
      "    public class AGrandchildFolderTest {",
      "",
      "        public Actionwords Actionwords;",
      "",
      "        [SetUp]",
      "        protected void SetUp() {",
      "            Actionwords = new Actionwords();",
      "        }",
      "    }",
      "}",
    ].join("\n")

    @second_grand_child_folder_rendered = [
      'namespace MyProject.ChildFolder {',
      '',
      '    using System;',
      '    using NUnit.Framework;',
      '    using MyProject;',
      '',
      '    [TestFixture]',
      '    public class ASecondGrandchildFolderTest {',
      '',
      '        public Actionwords Actionwords;',
      '',
      '        [SetUp]',
      '        protected void SetUp() {',
      '            Actionwords = new Actionwords();',
      '',
      '            Actionwords.Visit("/login");',
      '            Actionwords.Fill("user@example.com");',
      '            Actionwords.Fill("notTh4tS3cret");',
      '        }',
      '',
      '        [Test]',
      '        public void OneGrandchildScenario() {',
      '        }',
      '    }',
      '}'
    ].join("\n")
  end

  context 'NUnit' do
    it_behaves_like "a renderer" do
      let(:language) {'csharp'}
      let(:framework) {'nunit'}
      let(:namespace) { 'MyProject' }
    end
  end
end


describe 'default namespace' do
  it 'uses Example for C#' do
    rendering_context = context_for(language: 'csharp')
    expect(rendering_context.namespace).to eq('Example')
  end
end
