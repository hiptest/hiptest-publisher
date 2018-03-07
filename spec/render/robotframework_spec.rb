require_relative '../spec_helper'
require_relative "../render_shared"

# ALPHA VERSON: search for "NOT SUPPORTED YET" to found what is not yet supported.

describe 'Render as Robot framework' do
  include_context "shared render"

  before(:each) do
    # In Hiptest: null
    @null_rendered = 'None'

    # In Hiptest: 'What is your quest ?'
    @what_is_your_quest_rendered = "What is your quest ?"

    # In Hiptest: 3.14
    @pi_rendered = '3.14'

    # In Hiptest: false
    @false_rendered = 'False'

    # In Hiptest: "${foo}fighters"
    @foo_template_rendered = '${foo}fighters'

    # In Hiptest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = 'Fighters said \"Foo !\"'

    # In Hiptest: ""
    @empty_template_rendered = ''

    # In Hiptest: foo (as in 'foo := 1')
    @foo_variable_rendered = '${foo}'

    # In Hiptest: foo.fighters
    @foo_dot_fighters_rendered = '${foo}.fighters'

    # In Hiptest: foo['fighters']
    @foo_brackets_fighters_rendered = "${foo}[fighters]"

    # In Hiptest: -foo
    @minus_foo_rendered = '-${foo}'

    # In Hiptest: foo - 'fighters'
    @foo_minus_fighters_rendered = "${foo} - fighters"

    # In Hiptest: (foo)
    @parenthesis_foo_rendered = '(${foo})'

    # In Hiptest: [foo, 'fighters']
    @foo_list_rendered = "[${foo}, fighters]"

    # In Hiptest: foo: 'fighters'
    @foo_fighters_prop_rendered = "${foo}: fighters"

    # In Hiptest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{${foo}: fighters, Alt: J}"

    # In Hiptest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "${foo} = fighters"

    # In Hiptest: call 'foo'
    @call_foo_rendered = "foo"
    # In Hiptest: call 'foo bar'
    @call_foo_bar_rendered = "foo_bar"

    # In Hiptest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "foo\tfighters"
    # In Hiptest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "foo_bar\tfighters"

    @call_with_special_characters_in_value_rendered = "my_call_with_weird_arguments\t{\\n  this: 'is',\\n  some: ['JSON', 'outputed'],\\n  as: 'a string'\\n}"

    # In Hiptest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '# TODO: Implement action: ${foo}fighters'

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = "# NOT SUPPORTED YET"

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = "# NOT SUPPORTED YET"

    # In Hiptest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = "# NOT SUPPORTED YET"

    # In Hiptest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Hiptest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Hiptest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = '${plic}'

    # In Hiptest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = '${plic}=ploc'

    # In Hiptest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "my_action_word\n"

    # In Hiptest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "my_action_word",
      ""
    ].join("\n")

    @described_action_word_rendered = [
      "# Some description",
      "my_action_word",
      ""
    ].join("\n")

    # In Hiptest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "my_action_word",
      "\t[Arguments]\t${plic}\t${flip}=flap",
      ""
    ].join("\n")

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
      "compare_to_pi",
      "\t[Arguments]\t${x}",
      "\t${foo} = 3.14",
      "\t# NOT SUPPORTED YET",
      ""].join("\n")

    # In Hiptest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "my_action_word",
      "\t# TODO: Implement action: basic action",
      ""].join("\n")

    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "*** Keywords ***",
      "first_action_word",
      "",
      "",
      "second_action_word",
      "\tfirst_action_word",
      "",
      "",
      ""
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
      "*** Keywords ***",
      "aw_with_int_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "aw_with_float_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "aw_with_boolean_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "aw_with_null_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "aw_with_string_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "aw_with_template_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      ""
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
      "",
      "*** Test Cases ***",
      "",
      "compare to pi",
      "\t[Arguments]\t${x}",
      "\t${foo} = 3.14",
      "\t\# NOT SUPPORTED YET",
      ""
    ].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
      "",
      "*** Test Cases ***",
      "",
      "Reset password",
      "\tGiven page_url_is_opened\t/login",
      "\tWhen i_click_on_link\tReset password",
      "\tThen page_url_should_be_opened\t/reset-password",
      ""
    ].join("\n")

    @full_scenario_with_uid_rendered = [
      "",
      "*** Test Cases ***",
      "",
      "compare to pi (uid:abcd1234)",
      "\t[Arguments]\t${x}",
      "\t${foo} = 3.14",
      "\t\# NOT SUPPORTED YET",
      ""
    ].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = [
      "*** Settings ***",
      "Documentation",
      "...  This is a scenario which description ",
      "...  is on two lines",
      "Default Tags\tmyTag",
      "",
      "Resource\tkeywords.txt",
      "",
      "",
      "*** Test Cases ***",
      "",
      "compare to pi",
      "\t[Arguments]\t${x}",
      "\t${foo} = 3.14",
      "\t\# NOT SUPPORTED YET",
      ""
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
      "Test Template\tcheck login",
      "",
      "*** Test Cases ***\tlogin\tpassword\texpected",
      "Wrong 'login'\tinvalid\tinvalid\tInvalid username or password",
      "Wrong \"password\"\tvalid\tinvalid\tInvalid username or password",
      "Valid 'login'/\"password\"\tvalid\tvalid\tNone",
      "",
      "",
      "*** Keywords ***",
      "",
      "check login",
      "\t[Arguments]\t${login}\t${password}\t${expected}",
      "\tfill_login\t${login}",
      "\tfill_password\t${password}",
      "\tpress_enter",
      "\tassert_error_is_displayed\t${expected}",
      ""
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      "",
      "Test Template\tcheck login",
      "",
      "*** Test Cases ***\tlogin\tpassword\texpected",
      "Wrong 'login' (uid:a-123)\tinvalid\tinvalid\tInvalid username or password",
      "Wrong \"password\" (uid:b-456)\tvalid\tinvalid\tInvalid username or password",
      "Valid 'login'/\"password\" (uid:c-789)\tvalid\tvalid\tNone",
      "",
      "",
      "*** Keywords ***",
      "",
      "check login",
      "\t[Arguments]\t${login}\t${password}\t${expected}",
      "\tfill_login\t${login}",
      "\tfill_password\t${password}",
      "\tpress_enter",
      "\tassert_error_is_displayed\t${expected}",
      ""
    ].join("\n")

    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      "*** Settings ***",
      "Documentation",
      "...  Ensure the login process",
      "",
      "Resource\tkeywords.txt",
      "",
      "",
      "Test Template\tcheck login",
      "",
      "*** Test Cases ***\tlogin\tpassword\texpected",
      "Wrong 'login'\tinvalid\tinvalid\tInvalid username or password",
      "Wrong \"password\"\tvalid\tinvalid\tInvalid username or password",
      "Valid 'login'/\"password\"\tvalid\tvalid\tNone",
      "",
      "",
      "*** Keywords ***",
      "",
      "check login",
      "\t[Arguments]\t${login}\t${password}\t${expected}",
      "\tfill_login\t${login}",
      "\tfill_password\t${password}",
      "\tpress_enter",
      "\tassert_error_is_displayed\t${expected}",
      ""
    ].join("\n")

    # In Hiptest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "*** Settings ***",
      "Resource\tkeywords.txt",
      "",
      "*** Test Cases ***",
      "",
      "first scenario",
      "",
      "second scenario",
      "\tmy_action_word",
      ""
    ].join("\n")

    @tests_rendered = [
      "*** Settings ***",
      "Resource\tkeywords.txt",
      "",
      "*** Test Cases ***",
      "",
      "Login",
      "\tvisit\t/login",
      "\tfill\tuser@example.com",
      "\tfill\ts3cret",
      "\tclick\t.login-form input[type=submit]",
      "\tcheck_url\t/welcome",
      "",
      "",
      "Failed login",
      "\tvisit\t/login",
      "\tfill\tuser@example.com",
      "\tfill\tnotTh4tS3cret",
      "\tclick\t.login-form input[type=submit]",
      "\tcheck_url\t/login",
      "",
      ""
    ].join("\n")

    @first_test_rendered = [
      "Login",
      "\tvisit\t/login",
      "\tfill\tuser@example.com",
      "\tfill\ts3cret",
      "\tclick\t.login-form input[type=submit]",
      "\tcheck_url\t/welcome",
      ""
    ].join("\n")

    @first_test_rendered_for_single_file = [
      "*** Settings ***",
      "Documentation",
      "...  The description is on ",
      "...  two lines",
      "Default Tags\tmyTag\tmyTag:somevalue",
      "",
      "Resource\tkeywords.txt",
      "",
      "",
      "*** Test Cases ***",
      "",
      "Login",
      "\tvisit\t/login",
      "\tfill\tuser@example.com",
      "\tfill\ts3cret",
      "\tclick\t.login-form input[type=submit]",
      "\tcheck_url\t/welcome",
      ""
    ].join("\n")

    # cbl: I am not sure about this one...
    @grand_child_scenario_rendered_for_single_file = [
      "*** Settings ***",
      "Documentation",
      "",
      "",
      "Resource\tkeywords.txt",
      "",
      "",
      "*** Test Cases ***",
      "",
      "One grand'child scenario",
      "",
    ].join("\n")

    @root_folder_rendered = [
      "*** Settings ***",
      "Documentation",
      "",
      "Resource\tkeywords.txt",
      "",
      "*** Test Cases ***",
      "",
      "One root scenario",
      "",
      "Another root scenario",
      ""
    ].join("\n")

    @grand_child_folder_rendered = [
      "*** Settings ***",
      "Documentation",
      "",
      "Resource\tkeywords.txt",
      "",
      "*** Test Cases ***",
      ""
    ].join("\n")

    @second_grand_child_folder_rendered = [
      "*** Settings ***",
      "Documentation",
      "",
      "Resource\tkeywords.txt",
      "",
      "Test Setup\tRun Keywords\tvisit\t/login",
      "...         AND      \tfill\tuser@example.com",
      "...         AND      \tfill\tnotTh4tS3cret",
      "",
      "*** Test Cases ***",
      "",
      "One grand'child scenario",
      ""
    ].join("\n")
  end

  context 'Robot framework' do
    it_behaves_like "a renderer" do
      let(:language) {'robotframework'}
      let(:framework) {''}
    end

    context 'folder output' do
      let!(:project) {
        Hiptest::Nodes::Project.new('My project', '', Hiptest::Nodes::Scenarios.new([
          sc1_no_datatable,
          sc2_no_datatable,
          sc1_with_datatable,
          sc2_with_datatable,
          sc1_with_incompatible_datatable
        ]))
      }

      let(:folder) {
        Hiptest::Nodes::Folder.new(1, 0, 'My folder', '')
      }

      let(:sc1_no_datatable) {
        Hiptest::Nodes::Scenario.new(
          'scenario without datatable', '', [
            Hiptest::Nodes::Tag.new('firstTag'),
            Hiptest::Nodes::Tag.new('priority', '1'),
          ], [], [
            Hiptest::Nodes::Step.new('action', "Do something")
          ], nil, Hiptest::Nodes::Datatable.new([])
        )
      }

      let(:sc2_no_datatable) {
        Hiptest::Nodes::Scenario.new(
          'second scenario without datatable', '', [], [], [
            Hiptest::Nodes::Step.new('result', "Do something else here")
          ], nil, Hiptest::Nodes::Datatable.new([])
        )
      }

      let(:sc1_with_datatable) {
        Hiptest::Nodes::Scenario.new(
          'scenario with datatable', '', [
            Hiptest::Nodes::Tag.new('anotherTag'),
            Hiptest::Nodes::Tag.new('priority', '2'),
          ], [
            Hiptest::Nodes::Parameter.new('x'),
            Hiptest::Nodes::Parameter.new('y')
          ], [Hiptest::Nodes::Step.new('result', "x is greater than Pi")], nil,
          Hiptest::Nodes::Datatable.new([
            Hiptest::Nodes::Dataset.new('First line', [
              Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('plic')),
              Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('ploc')),
            ]),
            Hiptest::Nodes::Dataset.new('Second line', [
              Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('pluc')),
              Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('plac')),
            ])
          ])
        )
      }

      let(:sc2_with_datatable) {
        Hiptest::Nodes::Scenario.new(
          'second scenario with datatable', '', [], [
            Hiptest::Nodes::Parameter.new('x'),
            Hiptest::Nodes::Parameter.new('y')
          ], [Hiptest::Nodes::Assign.new(@foo_variable, @pi)], nil,
          Hiptest::Nodes::Datatable.new([
            Hiptest::Nodes::Dataset.new('One line', [
              Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('1')),
              Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('2')),
            ]),
            Hiptest::Nodes::Dataset.new('Another line', [
              Hiptest::Nodes::Argument.new('x', Hiptest::Nodes::StringLiteral.new('3')),
              Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('4')),
            ])
          ])
        )
      }

      let(:sc1_with_incompatible_datatable) {
        Hiptest::Nodes::Scenario.new(
          'scenario with datatable', '', [], [
            Hiptest::Nodes::Parameter.new('y'),
            Hiptest::Nodes::Parameter.new('z')
          ], [Hiptest::Nodes::Step.new('result', "Observe some stuff here")], nil,
          Hiptest::Nodes::Datatable.new([
            Hiptest::Nodes::Dataset.new('Will not be rendered anyway ....', [
              Hiptest::Nodes::Argument.new('y', Hiptest::Nodes::StringLiteral.new('plic')),
              Hiptest::Nodes::Argument.new('z', Hiptest::Nodes::StringLiteral.new('ploc')),
            ])
          ])
        )
      }

      let(:render_context) {
        context_for(
          node: folder,
          language: 'robotframework',
          with_folders: true,
        )
      }

      it 'does not render test cases if there is no datatables' do
        folder.children[:scenarios] << sc1_no_datatable
        folder.children[:scenarios] << sc2_no_datatable

        Hiptest::NodeModifiers.add_all(project)
        expect(folder.render(render_context)).to eq([
          "*** Settings ***",
          "Documentation",
          "",
          "Resource\tkeywords.txt",
          "",
          "*** Test Cases ***",
          "",
          "scenario without datatable",
          "\t[Tags]\tfirstTag\tpriority:1",
          "\t# TODO: Implement action: Do something",
          "",
          "second scenario without datatable",
          "\t# TODO: Implement result: Do something else here",
          ""
        ].join("\n"))
      end

      it 'uses datatable for all scenarios in the folder' do
        folder.children[:scenarios] << sc1_no_datatable
        folder.children[:scenarios] << sc1_with_datatable
        folder.children[:scenarios] << sc2_with_datatable
        folder.children[:scenarios] << sc1_with_incompatible_datatable

        Hiptest::NodeModifiers.add_all(project)
        expect(folder.render(render_context)).to eq([
          "*** Settings ***",
          "Documentation",
          "",
          "Resource\tkeywords.txt",
          "",
          "*** Test Cases ***",
          "",
          "scenario without datatable",
          "\t[Tags]\tfirstTag\tpriority:1",
          "\t# TODO: Implement action: Do something",
          "",
          "scenario with datatable First line",
          "\t[Tags]\tanotherTag\tpriority:2",
          "\t[Template]\tscenario with datatable keyword",
          "\tplic\tploc",
          "",
          "scenario with datatable Second line",
          "\t[Tags]\tanotherTag\tpriority:2",
          "\t[Template]\tscenario with datatable keyword",
          "\tpluc\tplac",
          "",
          "",
          "",
          "second scenario with datatable One line",
          "\t[Template]\tsecond scenario with datatable keyword",
          "\t1\t2",
          "",
          "second scenario with datatable Another line",
          "\t[Template]\tsecond scenario with datatable keyword",
          "\t3\t4",
          "",
          "",
          "",
          "scenario with datatable Will not be rendered anyway ",
          "\t[Template]\tscenario with datatable keyword",
          "\tplic\tploc",
          "",
          "",
          "",
          "*** Keywords ***",
          "",
          "scenario with datatable keyword",
          "\t[Arguments]\t${x}\t${y}",
          "\t# TODO: Implement result: x is greater than Pi",
          "",
          "second scenario with datatable keyword",
          "\t[Arguments]\t${x}\t${y}",
          "\t${foo} = 3.14",
          "",
          "scenario with datatable keyword",
          "\t[Arguments]\t${y}\t${z}",
          "\t# TODO: Implement result: Observe some stuff here",
          "",
          ""
        ].join("\n"))
      end
    end
  end
end
