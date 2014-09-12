require_relative 'spec_helper'
require_relative "render_shared"

# ALPHA VERSON: search for "NOT SUPPORTED YET" to found what is not yet supported.

describe 'Render as Robot framework' do
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
    @foo_template_rendered = '"${foo}fighters"'

    # In Zest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Zest: foo (as in 'foo := 1')
    @foo_variable_rendered = '${foo}'

    # In Zest: foo.fighters
    @foo_dot_fighters_rendered = '${foo}.fighters'

    # In Zest: foo['fighters']
    @foo_brackets_fighters_rendered = "${foo}['fighters']"

    # In Zest: -foo
    @minus_foo_rendered = '-${foo}'

    # In Zest: foo - 'fighters'
    @foo_minus_fighters_rendered = "${foo} - 'fighters'"

    # In Zest: (foo)
    @parenthesis_foo_rendered = '(${foo})'

    # In Zest: [foo, 'fighters']
    @foo_list_rendered = "[${foo}, 'fighters']"

    # In Zest: foo: 'fighters'
    @foo_fighters_prop_rendered = "${foo}: 'fighters'"

    # In Zest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{${foo}: 'fighters', Alt: J}"

    # In Zest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "${foo} = 'fighters'"

    # In Zest: call 'foo'
    @call_foo_rendered = "foo"
    # In Zest: call 'foo bar'
    @call_foo_bar_rendered = "foo_bar"

    # In Zest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "foo\t'fighters'"
    # In Zest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "foo_bar\t'fighters'"

    # In Zest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '# TODO: Implement action: "${foo}fighters"'

    # In Zest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = "# NOT SUPPORTED YET"

    # In Zest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = "# NOT SUPPORTED YET"

    # In Zest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = "# NOT SUPPORTED YET"

    # In Zest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Zest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Zest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = '${plic}'

    # In Zest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    # NOT SUPPORTED YET
    @plic_param_default_ploc_rendered = '${plic}'

    # In Zest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "\nmy_action_word\n"

    # In Zest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "# Tags: myTag myTag:somevalue",
      "my_action_word",
      ""
    ].join("\n")

    # In Zest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "",
      "my_action_word",
      "\t[Arguments]\t${plic}\t${flip}",
      ""
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
      "# Tags: myTag",
      "compare_to_pi",
      "\t[Arguments]\t${x}",
      "\t${foo} = 3.14",
      "\t# NOT SUPPORTED YET",
      ""].join("\n")

    # In Zest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "",
      "my_action_word",
      "\t# TODO: Implement action: basic action",
      ""].join("\n")

    # In Zest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "*** Keywords ***",
      "",
      "first_action_word",
      "",
      "",
      "",
      "second_action_word",
      "\tfirst_action_word",
      "",
      "",
      ""
    ].join("\n")

    # In Zest, correspond to these action words with parameters:
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
      "",
      "aw_with_int_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "",
      "aw_with_float_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "",
      "aw_with_boolean_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "",
      "aw_with_null_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "",
      "aw_with_string_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      "",
      "aw_with_template_param",
      "\t[Arguments]\t${x}",
      "",
      "",
      ""
    ].join("\n")


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
      "*** Keywords ***",
      "# This is a scenario which description ",
      "# is on two lines",
      "# Tags: myTag",
      "compare_to_pi",
      "\t[Arguments]\t${x}",
      "\t${foo} = 3.14",
      "\t\# NOT SUPPORTED YET",
      ""
    ].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = @full_scenario_rendered

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
      "*** Test Cases ***\tlogin\tpassword\texpected",
      "Wrong login\tinvalid\tinvalid\tInvalid username or password",
      "Wrong password\tvalid\tinvalid\tInvalid username or password",
      "Valid login/password\tvalid\tvalid\t",
      "",
      "*** Keywords ***",
      "# Ensure the login process",
      "check_login",
      "\t[Arguments]\t${login}\t${password}\t${expected}",
      "\tfill_login\t${login}",
      "\tfill_password\t${password}",
      "\tpress_enter",
      "\tassert_error_is_displayed\t${expected}",
      ""
    ].join("\n")

    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = @scenario_with_datatable_rendered

    # In Zest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = "PLEASE USE THE --split-scenarios OPTION WHEN PUBLISHING"

    @context[:indentation] = "\t"
  end

  context 'Robot framework' do
    it_behaves_like "a renderer" do
      let(:language) {'robotframework'}
      let(:framework) {'robotframework'}
    end
  end
end