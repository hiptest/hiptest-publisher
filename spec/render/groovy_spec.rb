require_relative '../spec_helper'
require_relative "../render_shared"

describe 'Render as Groovy' do
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
    @foo_template_rendered = '"${foo}fighters"'

    # In HipTest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In HipTest: ""
    @empty_template_rendered = '""'

    # In HipTest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'

    # In HipTest: foo.fighters
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
    @foo_list_rendered = '[foo, "fighters"]'

    # In HipTest: foo: 'fighters'
    @foo_fighters_prop_rendered = 'foo: "fighters"'

    # In HipTest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = '[foo: "fighters", Alt: J]'

    # In HipTest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = 'foo = "fighters"'

    # In HipTest: call 'foo'
    @call_foo_rendered = "actionwords.foo()"
    # In HipTest: call 'foo bar'
    @call_foo_bar_rendered = "actionwords.fooBar()"

    # In HipTest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = 'actionwords.foo("fighters")'
    # In HipTest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = 'actionwords.fooBar("fighters")'

    # In HipTest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '// TODO: Implement action: "${foo}fighters"'

    # In HipTest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
        "if (true) {",
        '  foo = "fighters"',
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
        '  foo = "fighters"',
        "} else {",
        '  fighters = "foo"',
        "}"
      ].join("\n")

    # In HipTest:
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

    # In HipTest: @myTag
    @simple_tag_rendered = 'myTag'

    # In HipTest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In HipTest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = 'plic'

    # In HipTest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = 'plic = "ploc"'

    # In HipTest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "def myActionWord() {\n}"

    # In HipTest:
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

    # In HipTest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      'def myActionWord(plic, flip = "flap") {',
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

    # In HipTest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "def myActionWord() {",
      "  // TODO: Implement action: basic action",
      "",
      "  throw new UnsupportedOperationException()",
      "}"].join("\n")

    # In HipTest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "package com.example",
      "",
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
      "package com.example",
      "",
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
      'package com.example',
      '',
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
      '',
      '@Unroll("check login")',
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
      '  login | password | expected',
      '  "invalid" | "invalid" | "Invalid username or password"',
      '  "valid" | "invalid" | "Invalid username or password"',
      '  "valid" | "valid" | null',
      '}'
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      '',
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
      'package com.example',
      '',
      'import spock.lang.*',
      '',
      'class CheckLoginSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '',
      '',
      '  @Unroll("check login")',
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
      '    login | password | expected',
      '    "invalid" | "invalid" | "Invalid username or password"',
      '    "valid" | "invalid" | "Invalid username or password"',
      '    "valid" | "valid" | null',
      '  }',
      '}'
    ].join("\n")

    # In HipTest, correspond to two scenarios in a project called 'My project'
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
      'package com.example',
      '',
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
      'package com.example',
      '',
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
      'package com.example',
      '',
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
      'package com.example',
      '',
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
      'package com.example',
      '',
      'import spock.lang.*',
      '',
      'class AGrandchildFolderSpec extends Specification {',
      '  def actionwords = Actionwords.newInstance()',
      '}'
    ].join("\n")

    @grand_child_scenario_rendered_for_single_file = [
      'package com.example',
      '',
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
      'package com.example',
      '',
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

    it 'handles correctly a folder where multiple scenarios with datatable are present' do
      container = make_folder("Multiple datatables", parent: @root_folder)
      sc1 = make_scenario("First scenario",
        folder: container,
        parameters: [make_parameter('x'), make_parameter('y')],
        datatable: Hiptest::Nodes::Datatable.new([
          Hiptest::Nodes::Dataset.new('First line', [
            Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('1')),
            Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('2')),
          ]),
          Hiptest::Nodes::Dataset.new('Second line', [
            Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('3')),
            Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('4')),
          ])
        ])
      )
      sc2 = make_scenario("Second scenario",
        folder: container,
        parameters: [make_parameter('x'), make_parameter('y')],
        datatable: Hiptest::Nodes::Datatable.new([
          Hiptest::Nodes::Dataset.new('First line', [
            Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('1')),
            Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('2')),
          ]),
          Hiptest::Nodes::Dataset.new('Second line', [
            Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('3')),
            Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('4')),
          ])
        ])
      )

      Hiptest::NodeModifiers::ParentAdder.add(@folders_project)
      render_context = context_for(
        node: container,
        # only to select the right config group: we render [actionwords], [tests] and others differently
        language: 'groovy',
        framework: 'spock',
        uids: true,
        with_folders: true)

      expect(container.render(render_context)).to eq([
        'package com.example',
        '',
        'import spock.lang.*',
        '',
        'class MultipleDatatablesSpec extends Specification {',
        '  def actionwords = Actionwords.newInstance()',
        '',
        '',
        '',
        '',
        '  @Unroll("First scenario #hiptestUid")',
        '  def "First scenario"() {',
        '',
        '',
        '    where:',
        '    x | y | hiptestUid',
        '    "1" | "2" | "uid:"',
        '    "3" | "4" | "uid:"',
        '  }',
        '',
        '  @Unroll("Second scenario #hiptestUid")',
        '  def "Second scenario"() {',
        '',
        '',
        '    where:',
        '    x | y | hiptestUid',
        '    "1" | "2" | "uid:"',
        '    "3" | "4" | "uid:"',
        '  }',
        '}',
      ].join("\n"))
    end

    it_behaves_like 'a renderer handling libraries' do
      let(:language) {'groovy'}
      let(:framework) {'spock'}

      let(:libraries_rendered) {
        [
          'package com.example',
          '',
          'class ActionwordLibrary {',
          '  DefaultLibrary getDefaultLibrary() {',
          '    return DefaultLibrary.instance',
          '  }',
          '',
          '  WebLibrary getWebLibrary() {',
          '    return WebLibrary.instance',
          '  }',
          '}'
        ].join("\n")
      }

      let(:actionwords_rendered) {
        [
          'package com.example',
          '',
          'class Actionwords extends ActionwordLibrary{',
          '  def myProjectActionWord() {',
          '  }',
          '',
          '  def myHighLevelProjectActionword() {',
          '    myProjectActionWord()',
          '  }',
          '',
          '  def myHighLevelActionword() {',
          '    getDefaultLibrary().myFirstActionWord()',
          '  }',
          '}'
        ].join("\n")
      }

      let(:first_lib_rendered) {[
        'package com.example',
        '',
        '@Singleton',
        'class DefaultLibrary {',
        '  def myFirstActionWord() {',
        '    // Tags: priority:high wip',
        '  }',
        '}'
      ].join("\n")}

      let(:second_lib_rendered) {[
        'package com.example',
        '',
        '@Singleton',
        'class WebLibrary {',
        '  def mySecondActionWord() {',
        '    // Tags: priority:low done',
        '  }',
        '}'
      ].join("\n")}
    end

    context 'with library actionwords' do
      let(:aw_name) { 'some trigger' }
      let(:aw) {
        make_library_actionword(aw_name)
      }

      it 'handles correctly shared actionwords in tests' do
        library_name = 'default'
        default_library = make_library(library_name, [aw])
        container = make_folder("A folder", parent: @root_folder)

        shared_call = make_call(aw_name, annotation: 'when')
        shared_call.children[:library_name] = library_name

        sc1 = make_scenario(
          "When-Then Scenario",
          folder: container,
          body: [
            make_call("go to page", annotation: "given"),
            shared_call,
            make_call('the page contains something', annotation: "then")
          ]
        )

        project = make_project(
          'A project',
          folders: [@root_folder, container],
          scenarios: [sc1],
          libraries: Hiptest::Nodes::Libraries.new([default_library])
        )

        Hiptest::NodeModifiers::ParentAdder.add(@folders_project)
        render_context = context_for(
          node: container,
          # only to select the right config group: we render [actionwords], [tests] and others differently
          language: 'groovy',
          framework: 'spock',
          with_folders: true
        )

        expect(container.render(render_context)).to eq([
          'package com.example',
          '',
          'import spock.lang.*',
          '',
          'class AFolderSpec extends Specification {',
          '  def actionwords = Actionwords.newInstance()',
          '',
          '',
          '',
          '  def "When-Then Scenario"() {',
          '',
          '    given:',
          '    actionwords.goToPage()',
          '    when:',
          '    actionwords.getDefaultLibrary().someTrigger()',
          '    then:',
          '    actionwords.thePageContainsSomething()',
          '  }',
          '}',
      ].join("\n"))
      end
    end

    it 'handles correctly a unroll-spec for spock' do
      container = make_folder("Spock Unroll Variants", parent: @root_folder)

      datatable = Hiptest::Nodes::Datatable.new([
         Hiptest::Nodes::Dataset.new('First line', [
             Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('1')),
             Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('2')),
         ]),
         Hiptest::Nodes::Dataset.new('Second line', [
             Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('3')),
             Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('4')),
         ])
      ])

      sc1 = make_scenario("When-Then Scenario",
        folder: container,
        body: [
          make_call("go to page",  annotation: "given"),
          make_call("some trigger",  annotation: "when"),
          make_call("the page contains something",  annotation: "then"),
        ],
        parameters: [make_parameter('x'), make_parameter('y')],
        datatable: datatable
      )

      sc2 = make_scenario("Expect Scenario",
        folder: container,
        body: [
            make_call("go to page",  annotation: "given"),
            make_call("the page contains something",  annotation: "then"),
        ],
        parameters: [make_parameter('x'), make_parameter('y')],
        datatable: datatable
      )

      Hiptest::NodeModifiers::ParentAdder.add(@folders_project)
      render_context = context_for(
          node: container,
          # only to select the right config group: we render [actionwords], [tests] and others differently
          language: 'groovy',
          framework: 'spock',
          uids: true,
          with_folders: true)

      expect(container.render(render_context)).to eq([
        'package com.example',
        '',
        'import spock.lang.*',
        '',
        'class SpockUnrollVariantsSpec extends Specification {',
        '  def actionwords = Actionwords.newInstance()',
        '',
        '',
        '',
        '',
        '  @Unroll("When-Then Scenario #hiptestUid")',
        '  def "When-Then Scenario"() {',
        '',
        '    given:',
        '    actionwords.goToPage()',
        '    when:',
        '    actionwords.someTrigger()',
        '    then:',
        '    actionwords.thePageContainsSomething()',
        '',
        '    where:',
        '    x | y | hiptestUid',
        '    "1" | "2" | "uid:"',
        '    "3" | "4" | "uid:"',
        '  }',
        '',
        '  @Unroll("Expect Scenario #hiptestUid")',
        '  def "Expect Scenario"() {',
        '',
        '    given:',
        '    actionwords.goToPage()',
        '    expect:',
        '    actionwords.thePageContainsSomething()',
        '',
        '    where:',
        '    x | y | hiptestUid',
        '    "1" | "2" | "uid:"',
        '    "3" | "4" | "uid:"',
        '  }',
        '}',
      ].join("\n"))

      render_context_without_uids = context_for(
          node: container,
          # only to select the right config group: we render [actionwords], [tests] and others differently
          language: 'groovy',
          framework: 'spock',
          uids: false,
          with_folders: true)

      expect(container.render(render_context_without_uids)).to eq([
        'package com.example',
        '',
        'import spock.lang.*',
        '',
        'class SpockUnrollVariantsSpec extends Specification {',
        '  def actionwords = Actionwords.newInstance()',
        '',
        '',
        '',
        '',
        '  @Unroll("When-Then Scenario")',
        '  def "When-Then Scenario"() {',
        '',
        '    given:',
        '    actionwords.goToPage()',
        '    when:',
        '    actionwords.someTrigger()',
        '    then:',
        '    actionwords.thePageContainsSomething()',
        '',
        '    where:',
        '    x | y',
        '    "1" | "2"',
        '    "3" | "4"',
        '  }',
        '',
        '  @Unroll("Expect Scenario")',
        '  def "Expect Scenario"() {',
        '',
        '    given:',
        '    actionwords.goToPage()',
        '    expect:',
        '    actionwords.thePageContainsSomething()',
        '',
        '    where:',
        '    x | y',
        '    "1" | "2"',
        '    "3" | "4"',
        '  }',
        '}',
      ].join("\n"))
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
        language: 'groovy',
        framework: 'spock'
      )

      expect(aws.render(context)).to include('class Actionwords extends ActionwordLibrary')
    end
  end
end
