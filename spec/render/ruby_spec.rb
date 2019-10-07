require_relative '../spec_helper'
require_relative "../render_shared"

describe 'Render as Ruby' do
  include_context "shared render"
  before(:each) do
    # Literals
    @null_rendered = 'nil'
    @what_is_your_quest_rendered = "'What is your quest ?'"
    # In Hiptest: '{ "key\" : "val" }'
    @string_literal_with_quotes_rendered = "'{ \"key\" : \"val\" }'"

    @pi_rendered = '3.14'
    @false_rendered = 'false'
    @foo_template_rendered = '"#{foo}fighters"'
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'
    @empty_template_rendered = '""'

    # variable
    @foo_variable_rendered = 'foo'
    @foo_bar_variable_rendered = 'foo_bar'

    # symbols
    @foo_symbol_rendered = ':foo'
    @foo_fighters_symbol_rendered = ':"foo(fighters)"'

    # Accessors
    @foo_dot_fighters_rendered = 'foo.fighters'
    @foo_brackets_fighters_rendered = "foo['fighters']"

    # Operation
    @minus_foo_rendered = '-foo'
    @foo_minus_fighters_rendered = "foo - 'fighters'"
    @parenthesis_foo_rendered = '(foo)'

    # List
    @foo_list_rendered = "[foo, 'fighters']"

    # Dictionary and properties
    @foo_fighters_prop_rendered = "foo: 'fighters'"
    @foo_dict_rendered = "{foo: 'fighters', Alt: J}"

    # Statements
    @assign_fighters_to_foo_rendered = "foo = 'fighters'"
    @call_foo_rendered = "foo"
    # In HipTest: call 'foo bar'
    @call_foo_bar_rendered = "foo_bar"

    @call_foo_with_fighters_rendered = "foo('fighters')"
    # In HipTest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "foo_bar('fighters')"
    @call_with_special_characters_in_value_rendered = "my_call_with_weird_arguments(\"{\\n  this: 'is',\\n  some: ['JSON', 'outputed'],\\n  as: 'a string'\\n}\")"

    @action_foo_fighters_rendered = '# TODO: Implement action: "#{foo}fighters"'

    # Control blocks
    @if_then_rendered = [
        "if (true)",
        "  foo = 'fighters'",
        "end"
      ].join("\n")

    @if_then_else_rendered = [
        "if (true)",
        "  foo = 'fighters'",
        "else",
        "  fighters = 'foo'",
        "end"
      ].join("\n")

    @while_loop_rendered = [
        "while (foo)",
        "  fighters = 'foo'",
        "  foo('fighters')",
        "end"
      ].join("\n")

    # Tags
    @simple_tag_rendered = 'myTag'
    @valued_tag_rendered = 'myTag:somevalue'

    # Parameters
    @plic_param_rendered = 'plic'
    @plic_param_default_ploc_rendered = "plic = 'ploc'"


    # Actionwords
    @empty_action_word_rendered = [
      "def my_action_word",
      "",
      "end"].join("\n")

    @tagged_action_word_rendered = [
      "def my_action_word",
      "  # Tags: myTag myTag:somevalue",
      "end"].join("\n")

    @described_action_word_rendered = [
      "def my_action_word",
      "  # Some description",
      "end"].join("\n")

    @parameterized_action_word_rendered = [
      "def my_action_word(plic, flip = 'flap')",
      "",
      "end"].join("\n")

    @full_actionword_rendered = [
      "def compare_to_pi(x)",
      "  # Tags: myTag",
      "  foo = 3.14",
      "  if (foo > x)",
      "    # TODO: Implement result: x is greater than Pi",
      "  else",
      "    # TODO: Implement result: x is lower than Pi",
      "    # on two lines",
      "  end",
      "  raise NotImplementedError",
      "end"].join("\n")

    @step_action_word_rendered = [
      "def my_action_word",
      "  # TODO: Implement action: basic action",
      "  raise NotImplementedError",
      "end"].join("\n")

    @actionwords_rendered = [
      "# encoding: UTF-8",
      "",
      "module Actionwords",
      "  def first_action_word",
      "",
      "  end",
      "",
      "  def second_action_word",
      "    first_action_word",
      "  end",
      "end"].join("\n")

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
    @actionwords_with_params_rendered = [
      "# encoding: UTF-8",
      "",
      "module Actionwords",
      "  def aw_with_int_param(x)",
      "",
      "  end",
      "",
      "  def aw_with_float_param(x)",
      "",
      "  end",
      "",
      "  def aw_with_boolean_param(x)",
      "",
      "  end",
      "",
      "  def aw_with_null_param(x)",
      "",
      "  end",
      "",
      "  def aw_with_string_param(x)",
      "",
      "  end",
      "",
      "  def aw_with_template_param(x)",
      "",
      "  end",
      "end"
    ].join("\n")
  end

  context 'Rspec' do
    before(:each) do
      @full_scenario_rendered = [
        "it \"compare to pi\" do",
        "  # This is a scenario which description ",
        "  # is on two lines",
        "  # Tags: myTag",
        "  foo = 3.14",
        "  if (foo > x)",
        "    # TODO: Implement result: x is greater than Pi",
        "  else",
        "    # TODO: Implement result: x is lower than Pi",
        "    # on two lines",
        "  end",
        "  raise NotImplementedError",
        "end"].join("\n")

      # In hiptest
      # scenario 'reset password' do
      #   call given 'Page "url" is opened'(url='/login')
      #   call when 'I click on "link"'(link='Reset password')
      #   call then 'page "url" should be opened'(url='/reset-password')
      # end
      @bdd_scenario_rendered = [
        'it "Reset password" do',
        '  # Given Page "/login" is opened',
        '  page_url_is_opened(\'/login\')',
        '  # When I click on "Reset password"',
        '  i_click_on_link(\'Reset password\')',
        '  # Then Page "/reset-password" should be opened',
        '  page_url_should_be_opened(\'/reset-password\')',
        'end'
      ].join("\n")

      @full_scenario_rendered_for_single_file = [
        "# encoding: UTF-8",
        "require 'spec_helper'",
        "require_relative 'actionwords'",
        "",
        "describe 'compare to pi' do",
        "  include Actionwords",
        "",
        "",
        "  it \"compare to pi\" do",
        "    # This is a scenario which description ",
        "    # is on two lines",
        "    # Tags: myTag",
        "    foo = 3.14",
        "    if (foo > x)",
        "      # TODO: Implement result: x is greater than Pi",
        "    else",
        "      # TODO: Implement result: x is lower than Pi",
        "      # on two lines",
        "    end",
        "    raise NotImplementedError",
        "  end",
        "end"].join("\n")

      @full_scenario_with_uid_rendered = [
        "it \"compare to pi (uid:abcd-1234)\" do",
        "  # This is a scenario which description ",
        "  # is on two lines",
        "  # Tags: myTag",
        "  foo = 3.14",
        "  if (foo > x)",
        "    # TODO: Implement result: x is greater than Pi",
        "  else",
        "    # TODO: Implement result: x is lower than Pi",
        "    # on two lines",
        "  end",
        "  raise NotImplementedError",
        "end"].join("\n")

      @scenario_with_datatable_rendered = [
        "context \"check login\" do",
        "  def check_login(login, password, expected)",
        "    \# Ensure the login process",
        "    fill_login(login)",
        "    fill_password(password)",
        "    press_enter",
        "    assert_error_is_displayed(expected)",
        "  end",
        "",
        "  it \"Wrong 'login'\" do",
        "    check_login('invalid', 'invalid', 'Invalid username or password')",
        "  end",
        "",
        "  it \"Wrong \\\"password\\\"\" do",
        "    check_login('valid', 'invalid', 'Invalid username or password')",
        "  end",
        "",
        "  it \"Valid 'login'/\\\"password\\\"\" do",
        "    check_login('valid', 'valid', nil)",
        "  end",
        "end"
      ].join("\n")

      @scenario_with_datatable_rendered_with_uids = [
        "context \"check login\" do",
        "  def check_login(login, password, expected)",
        "    \# Ensure the login process",
        "    fill_login(login)",
        "    fill_password(password)",
        "    press_enter",
        "    assert_error_is_displayed(expected)",
        "  end",
        "",
        "  it \"Wrong 'login' (uid:a-123)\" do",
        "    check_login('invalid', 'invalid', 'Invalid username or password')",
        "  end",
        "",
        "  it \"Wrong \\\"password\\\" (uid:b-456)\" do",
        "    check_login('valid', 'invalid', 'Invalid username or password')",
        "  end",
        "",
        "  it \"Valid 'login'/\\\"password\\\" (uid:c-789)\" do",
        "    check_login('valid', 'valid', nil)",
        "  end",
        "end"
      ].join("\n")

      @scenario_with_datatable_rendered_in_single_file = [
        "# encoding: UTF-8",
        "require 'spec_helper'",
        "require_relative 'actionwords'",
        "",
        "describe 'check login' do",
        "  include Actionwords",
        "",
        "",
        "  context \"check login\" do",
        "    def check_login(login, password, expected)",
        "      \# Ensure the login process",
        "      fill_login(login)",
        "      fill_password(password)",
        "      press_enter",
        "      assert_error_is_displayed(expected)",
        "    end",
        "",
        "    it \"Wrong 'login'\" do",
        "      check_login('invalid', 'invalid', 'Invalid username or password')",
        "    end",
        "",
        "    it \"Wrong \\\"password\\\"\" do",
        "      check_login('valid', 'invalid', 'Invalid username or password')",
        "    end",
        "",
        "    it \"Valid 'login'/\\\"password\\\"\" do",
        "      check_login('valid', 'valid', nil)",
        "    end",
        "  end",
        "end"
      ].join("\n")

      @scenarios_rendered = [
        "# encoding: UTF-8",
        "require 'spec_helper'",
        "require_relative 'actionwords'",
        "",
        "describe 'Mike\\'s project' do",
        "  include Actionwords",
        "",
        "  it \"first scenario\" do",
        "",
        "  end",
        "",
        "  it \"second scenario\" do",
        "    my_action_word",
        "  end",
        "end",
        "",
      ].join("\n")

      @tests_rendered = [
       "# encoding: UTF-8",
       "require 'spec_helper'",
       "require_relative 'actionwords'",
       "",
       "describe 'Mike\\'s test project' do",
       "  include Actionwords",
       "",
       "  it \"Login\" do",
       "    # The description is on ",
       "    # two lines",
       "    # Tags: myTag myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('s3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/welcome')",
       "  end",
       "",
       "  it \"Failed login\" do",
       "    # Tags: myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('notTh4tS3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/login')",
       "  end",
       "end"
      ].join("\n")

      @first_test_rendered = [
        "it \"Login\" do",
        "  # The description is on ",
        "  # two lines",
        "  # Tags: myTag myTag:somevalue",
        "  visit('/login')",
        "  fill('user@example.com')",
        "  fill('s3cret')",
        "  click('.login-form input[type=submit]')",
        "  check_url('/welcome')",
        "end"
      ].join("\n")

      @first_test_rendered_for_single_file = [
       "# encoding: UTF-8",
       "require 'spec_helper'",
       "require_relative 'actionwords'",
       "",
       "describe 'Login' do",
       "  include Actionwords",
       "",
       "",
       "  it \"Login\" do",
       "    # The description is on ",
       "    # two lines",
       "    # Tags: myTag myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('s3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/welcome')",
       "  end",
       "end"
      ].join("\n")

      @grand_child_scenario_rendered_for_single_file = [
        "# encoding: UTF-8",
        "require 'spec_helper'",
        "require_relative '../../actionwords'",
        "",
        "describe 'One grand\\'child scenario' do",
        "  include Actionwords",
        "",
        "",
        "  it \"One grand'child scenario\" do",
        "",
        "  end",
        "end",
      ].join("\n")

      @root_folder_rendered = [
        "# encoding: UTF-8",
        "require 'spec_helper'",
        "require_relative 'actionwords'",
        "",
        "describe 'My root folder' do",
        "  include Actionwords",
        "",
        "  it \"One root scenario\" do",
        "",
        "  end",
        "",
        "  it \"Another root scenario\" do",
        "",
        "  end",
        "end",
      ].join("\n")

      @grand_child_folder_rendered = [
        "# encoding: UTF-8",
        "require 'spec_helper'",
        "require_relative '../actionwords'",
        "",
        "describe 'A grand-child folder' do",
        "  include Actionwords",
        "end",
      ].join("\n")

      @second_grand_child_folder_rendered = [
          "# encoding: UTF-8",
          "require 'spec_helper'",
          "require_relative '../actionwords'",
          "",
          "describe 'A second grand-child folder' do",
          "  include Actionwords",
          "",
          "  before(:each) do",
          "    visit('/login')",
          "    fill('user@example.com')",
          "    fill('notTh4tS3cret')",
          "  end",
          "",
          "  it \"One grand'child scenario\" do",
          "",
          "  end",
          "end"
        ].join("\n")
    end

    it_behaves_like "a renderer" do
      let(:language) {'ruby'}
      let(:framework) {'rspec'}
    end
  end

  context 'Minitest' do
    before(:each) do
      @full_scenario_rendered = [
        "def test_compare_to_pi",
        "  # This is a scenario which description ",
        "  # is on two lines",
        "  # Tags: myTag",
        "  foo = 3.14",
        "  if (foo > x)",
        "    # TODO: Implement result: x is greater than Pi",
        "  else",
        "    # TODO: Implement result: x is lower than Pi",
        "    # on two lines",
        "  end",
        "  raise NotImplementedError",
        "end"].join("\n")

      # In hiptest
      # scenario 'reset password' do
      #   call given 'Page "url" is opened'(url='/login')
      #   call when 'I click on "link"'(link='Reset password')
      #   call then 'page "url" should be opened'(url='/reset-password')
      # end
      @bdd_scenario_rendered = [
        'def test_Reset_password',
        '  # Given Page "/login" is opened',
        '  page_url_is_opened(\'/login\')',
        '  # When I click on "Reset password"',
        '  i_click_on_link(\'Reset password\')',
        '  # Then Page "/reset-password" should be opened',
        '  page_url_should_be_opened(\'/reset-password\')',
        'end',
      ].join("\n")

      @full_scenario_with_uid_rendered = [
        "def test_compare_to_pi_uidabcd1234",
        "  # This is a scenario which description ",
        "  # is on two lines",
        "  # Tags: myTag",
        "  foo = 3.14",
        "  if (foo > x)",
        "    # TODO: Implement result: x is greater than Pi",
        "  else",
        "    # TODO: Implement result: x is lower than Pi",
        "    # on two lines",
        "  end",
        "  raise NotImplementedError",
        "end"].join("\n")

      @full_scenario_rendered_for_single_file = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative 'actionwords'",
        "",
        "class TestCompareToPi < MiniTest::Unit::TestCase",
        "  include Actionwords",
        "",
        "  def test_compare_to_pi",
        "    # This is a scenario which description ",
        "    # is on two lines",
        "    # Tags: myTag",
        "    foo = 3.14",
        "    if (foo > x)",
        "      # TODO: Implement result: x is greater than Pi",
        "    else",
        "      # TODO: Implement result: x is lower than Pi",
        "      # on two lines",
        "    end",
        "    raise NotImplementedError",
        "  end",
        "end"].join("\n")

      @scenario_with_datatable_rendered = [
        "def check_login(login, password, expected)",
        "  \# Ensure the login process",
        "  fill_login(login)",
        "  fill_password(password)",
        "  press_enter",
        "  assert_error_is_displayed(expected)",
        "end",
        "",
        "def test_check_login_wrong_login",
        "  check_login('invalid', 'invalid', 'Invalid username or password')",
        "end",
        "",
        "def test_check_login_wrong_password",
        "  check_login('valid', 'invalid', 'Invalid username or password')",
        "end",
        "",
        "def test_check_login_valid_loginpassword",
        "  check_login('valid', 'valid', nil)",
        "end",
        ""
      ].join("\n")

      @scenario_with_datatable_rendered_with_uids = [
        "def check_login(login, password, expected)",
        "  \# Ensure the login process",
        "  fill_login(login)",
        "  fill_password(password)",
        "  press_enter",
        "  assert_error_is_displayed(expected)",
        "end",
        "",
        "def test_check_login_wrong_login_uida123",
        "  check_login('invalid', 'invalid', 'Invalid username or password')",
        "end",
        "",
        "def test_check_login_wrong_password_uidb456",
        "  check_login('valid', 'invalid', 'Invalid username or password')",
        "end",
        "",
        "def test_check_login_valid_loginpassword_uidc789",
        "  check_login('valid', 'valid', nil)",
        "end",
        ""
      ].join("\n")

      @scenario_with_datatable_rendered_in_single_file = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative 'actionwords'",
        "",
        "class TestCheckLogin < MiniTest::Unit::TestCase",
        "  include Actionwords",
        "",
        "  def check_login(login, password, expected)",
        "    \# Ensure the login process",
        "    fill_login(login)",
        "    fill_password(password)",
        "    press_enter",
        "    assert_error_is_displayed(expected)",
        "  end",
        "",
        "  def test_check_login_wrong_login",
        "    check_login('invalid', 'invalid', 'Invalid username or password')",
        "  end",
        "",
        "  def test_check_login_wrong_password",
        "    check_login('valid', 'invalid', 'Invalid username or password')",
        "  end",
        "",
        "  def test_check_login_valid_loginpassword",
        "    check_login('valid', 'valid', nil)",
        "  end",
        "end"
      ].join("\n")

      @scenarios_rendered = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative 'actionwords'",
        "",
        "class TestMikesProject < MiniTest::Unit::TestCase",
        "  include Actionwords",
        "",
        "  def test_first_scenario",
        "",
        "  end",
        "",
        "  def test_second_scenario",
        "    my_action_word",
        "  end",
        "end",
        "",
      ].join("\n")

      @tests_rendered = [
       "# encoding: UTF-8",
       "",
       "require 'minitest/autorun'",
       "require_relative 'actionwords'",
       "",
       "class TestMikesTestProject < MiniTest::Unit::TestCase",
       "  include Actionwords",
       "",
       "  def test_Login",
       "    # The description is on ",
       "    # two lines",
       "    # Tags: myTag myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('s3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/welcome')",
       "  end",
       "",
       "  def test_Failed_login",
       "    # Tags: myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('notTh4tS3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/login')",
       "  end",
       "end"
      ].join("\n")

      @first_test_rendered = [
        "def test_Login",
        "  # The description is on ",
        "  # two lines",
        "  # Tags: myTag myTag:somevalue",
        "  visit('/login')",
        "  fill('user@example.com')",
        "  fill('s3cret')",
        "  click('.login-form input[type=submit]')",
        "  check_url('/welcome')",
        "end"
      ].join("\n")

      @first_test_rendered_for_single_file = [
       "# encoding: UTF-8",
       "",
       "require 'minitest/autorun'",
       "require_relative 'actionwords'",
       "",
       "class TestLogin < MiniTest::Unit::TestCase",
       "  include Actionwords",
       "",
       "  def test_Login",
       "    # The description is on ",
       "    # two lines",
       "    # Tags: myTag myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('s3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/welcome')",
       "  end",
       "end"
      ].join("\n")

      @grand_child_scenario_rendered_for_single_file = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative '../../actionwords'",
        "",
        "class TestOneGrandchildScenario < MiniTest::Unit::TestCase",
        "  include Actionwords",
        "",
        "  def test_One_grandchild_scenario",
        "",
        "  end",
        "end",
      ].join("\n")

      @root_folder_rendered = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative 'actionwords'",
        "",
        "class TestMyRootFolder < MiniTest::Unit::TestCase",
        "  include Actionwords",
        "",
        "  def test_One_root_scenario",
        "",
        "  end",
        "",
        "  def test_Another_root_scenario",
        "",
        "  end",
        "end",
      ].join("\n")

      @grand_child_folder_rendered = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative '../actionwords'",
        "",
        "class TestAGrandchildFolder < MiniTest::Unit::TestCase",
        "  include Actionwords",
        "end",
      ].join("\n")

      @second_grand_child_folder_rendered = [
        "# encoding: UTF-8",
        "",
        "require 'minitest/autorun'",
        "require_relative '../actionwords'",
        "",
        "class TestASecondGrandchildFolder < MiniTest::Unit::TestCase",
        "  include Actionwords",
        "",
        "  def setup",
        "      visit('/login')",
        "      fill('user@example.com')",
        "      fill('notTh4tS3cret')",
        "  end",
        "",
        "  def test_One_grandchild_scenario",
        "",
        "  end",
        "end"
      ].join("\n")

    end

    it_behaves_like "a renderer" do
      let(:language) {'ruby'}
      let(:framework) {'minitest'}
    end
  end
end
