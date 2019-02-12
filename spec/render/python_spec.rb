require_relative '../spec_helper'
require_relative "../render_shared"

describe 'Render as Python' do
  include_context "shared render"

  before(:each) do
    # In HipTest: null
    @null_rendered = 'None'

    # In HipTest: 'What is your quest ?'
    @what_is_your_quest_rendered = "'What is your quest ?'"

    # In HipTest: 3.14
    @pi_rendered = '3.14'

    # In HipTest: false
    @false_rendered = 'False'

    # In HipTest: "${foo}fighters"
    @foo_template_rendered = '"%sfighters" % (foo)'

    # In HipTest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In HipTest: ""
    @empty_template_rendered = '""'

    # In HipTest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'
    @foo_bar_variable_rendered = 'foo_bar'

    # In HipTest: foo.fighters
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In HipTest: foo['fighters']
    @foo_brackets_fighters_rendered = "foo['fighters']"

    # In HipTest: -foo
    @minus_foo_rendered = '-foo'

    # In HipTest: foo - 'fighters'
    @foo_minus_fighters_rendered = "foo - 'fighters'"

    # In HipTest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In HipTest: [foo, 'fighters']
    @foo_list_rendered = "[foo, 'fighters']"

    # In HipTest: foo: 'fighters'
    @foo_fighters_prop_rendered = "'foo': 'fighters'"

    # In HipTest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{'foo': 'fighters', 'Alt': J}"

    # In HipTest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "foo = 'fighters'"

    # In HipTest: call 'foo'
    @call_foo_rendered = "self.actionwords.foo()"
    # In HipTest: call 'foo bar'
    @call_foo_bar_rendered = "self.actionwords.foo_bar()"

    # In HipTest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "self.actionwords.foo(x = 'fighters')"
    # In HipTest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "self.actionwords.foo_bar(x = 'fighters')"
    @call_with_special_characters_in_value_rendered = "self.actionwords.my_call_with_weird_arguments(free_text = \"{\\n  this: 'is',\\n  some: ['JSON', 'outputed'],\\n  as: 'a string'\\n}\")"

    # In HipTest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '# TODO: Implement action: "%sfighters" % (foo)'

    # In HipTest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
        "if (True):",
        "    foo = 'fighters'"
      ].join("\n")

    # In HipTest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = [
        "if (True):",
        "    foo = 'fighters'",
        "else:",
        "    fighters = 'foo'"
      ].join("\n")

    # In HipTest:
    # while (foo)
    #   fighters := 'foo'
    #   call 'foo' ('fighters')
    # end
    @while_loop_rendered = [
        "while (foo):",
        "    fighters = 'foo'",
        "    self.actionwords.foo(x = 'fighters')"
      ].join("\n")

    # In HipTest: @myTag
    @simple_tag_rendered = 'myTag'

    # In HipTest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In HipTest: plic (as in: call 'foo'(plic))
    @plic_param_rendered = 'plic'

    # In HipTest: plic = 'ploc' (as in: call 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = "plic = 'ploc'"

    # In HipTest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = [
      "def my_action_word(self):",
      "    pass",
      ""].join("\n")

    # In HipTest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "def my_action_word(self):",
      "    # Tags: myTag myTag:somevalue",
      "    pass",
      ""].join("\n")

    @described_action_word_rendered = [
      "def my_action_word(self):",
      "    # Some description",
      "    pass",
      ""].join("\n")

    # In HipTest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "def my_action_word(self, plic, flip = 'flap'):",
      "    pass",
      ""].join("\n")

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
      "def compare_to_pi(self, x):",
      "    # Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x):",
      "        # TODO: Implement result: x is greater than Pi",
      "    else:",
      "        # TODO: Implement result: x is lower than Pi",
      "        # on two lines",
      "    raise NotImplementedError",
      ""].join("\n")

    # In HipTest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "def my_action_word(self):",
      "    # TODO: Implement action: basic action",
      "    raise NotImplementedError",
      ""].join("\n")

    # In HipTest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "# encoding: UTF-8",
      "",
      "class Actionwords:",
      "    def __init__(self, test):",
      "        self.test = test",
      "",
      "    def first_action_word(self):",
      "        pass",
      "",
      "    def second_action_word(self):",
      "        self.first_action_word()",
      ""].join("\n")

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
      "# encoding: UTF-8",
      "",
      "class Actionwords:",
      "    def __init__(self, test):",
      "        self.test = test",
      "",
      "    def aw_with_int_param(self, x):",
      "        pass",
      "",
      "    def aw_with_float_param(self, x):",
      "        pass",
      "",
      "    def aw_with_boolean_param(self, x):",
      "        pass",
      "",
      "    def aw_with_null_param(self, x):",
      "        pass",
      "",
      "    def aw_with_string_param(self, x):",
      "        pass",
      "",
      "    def aw_with_template_param(self, x):",
      "        pass",
      ""].join("\n")

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
      "def test_compare_to_pi(self, x):",
      "    # This is a scenario which description ",
      "    # is on two lines",
      "    # Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x):",
      "        # TODO: Implement result: x is greater than Pi",
      "    else:",
      "        # TODO: Implement result: x is lower than Pi",
      "        # on two lines",
      "    raise NotImplementedError",
      ""].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
      'def test_reset_password(self):',
      '    # Given Page "/login" is opened',
      '    self.actionwords.page_url_is_opened(url = \'/login\')',
      '    # When I click on "Reset password"',
      '    self.actionwords.i_click_on_link(link = \'Reset password\')',
      '    # Then Page "/reset-password" should be opened',
      '    self.actionwords.page_url_should_be_opened(url = \'/reset-password\')',
      ''
    ].join("\n")

    @full_scenario_with_uid_rendered = [
      "def test_compare_to_pi_uidabcd1234(self, x):",
      "    # This is a scenario which description ",
      "    # is on two lines",
      "    # Tags: myTag",
      "    foo = 3.14",
      "    if (foo > x):",
      "        # TODO: Implement result: x is greater than Pi",
      "    else:",
      "        # TODO: Implement result: x is lower than Pi",
      "        # on two lines",
      "    raise NotImplementedError",
      ""].join("\n")

    @full_scenario_rendered_for_single_file = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestCompareToPi(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
      "    def test_compare_to_pi(self, x):",
      "        # This is a scenario which description ",
      "        # is on two lines",
      "        # Tags: myTag",
      "        foo = 3.14",
      "        if (foo > x):",
      "            # TODO: Implement result: x is greater than Pi",
      "        else:",
      "            # TODO: Implement result: x is lower than Pi",
      "            # on two lines",
      "        raise NotImplementedError",
      ""
      ].join("\n")

    @scenario_with_datatable_rendered = [
      "def check_login(self, login, password, expected):",
      "    # Ensure the login process",
      "    self.actionwords.fill_login(login = login)",
      "    self.actionwords.fill_password(password = password)",
      "    self.actionwords.press_enter()",
      "    self.actionwords.assert_error_is_displayed(error = expected)",
      "",
      "def test_check_login_wrong_login(self):",
      "    self.check_login(login = 'invalid', password = 'invalid', expected = 'Invalid username or password')",
      "",
      "def test_check_login_wrong_password(self):",
      "    self.check_login(login = 'valid', password = 'invalid', expected = 'Invalid username or password')",
      "",
      "def test_check_login_valid_loginpassword(self):",
      "    self.check_login(login = 'valid', password = 'valid', expected = None)",
      "",
      "",
      ""
      ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      "def check_login(self, login, password, expected):",
      "    # Ensure the login process",
      "    self.actionwords.fill_login(login = login)",
      "    self.actionwords.fill_password(password = password)",
      "    self.actionwords.press_enter()",
      "    self.actionwords.assert_error_is_displayed(error = expected)",
      "",
      "def test_check_login_wrong_login_uida123(self):",
      "    self.check_login(login = 'invalid', password = 'invalid', expected = 'Invalid username or password')",
      "",
      "def test_check_login_wrong_password_uidb456(self):",
      "    self.check_login(login = 'valid', password = 'invalid', expected = 'Invalid username or password')",
      "",
      "def test_check_login_valid_loginpassword_uidc789(self):",
      "    self.check_login(login = 'valid', password = 'valid', expected = None)",
      "",
      "",
      ""
      ].join("\n")

    @scenario_with_datatable_rendered_in_single_file = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestCheckLogin(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
      "    def check_login(self, login, password, expected):",
      "        # Ensure the login process",
      "        self.actionwords.fill_login(login = login)",
      "        self.actionwords.fill_password(password = password)",
      "        self.actionwords.press_enter()",
      "        self.actionwords.assert_error_is_displayed(error = expected)",
      "",
      "    def test_check_login_wrong_login(self):",
      "        self.check_login(login = 'invalid', password = 'invalid', expected = 'Invalid username or password')",
      "",
      "    def test_check_login_wrong_password(self):",
      "        self.check_login(login = 'valid', password = 'invalid', expected = 'Invalid username or password')",
      "",
      "    def test_check_login_valid_loginpassword(self):",
      "        self.check_login(login = 'valid', password = 'valid', expected = None)",
      "",
      ].join("\n")


    # In HipTest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestMikesProject(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
      "    def test_first_scenario(self):",
      "        pass",
      "",
      "    def test_second_scenario(self):",
      "        self.actionwords.my_action_word()",
      ""].join("\n")

    @tests_rendered = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestMikesTestProject(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
      "    def test_login(self):",
      "        # The description is on ",
      "        # two lines",
      "        # Tags: myTag myTag:somevalue",
      "        self.actionwords.visit(url = '/login')",
      "        self.actionwords.fill(login = 'user@example.com')",
      "        self.actionwords.fill(password = 's3cret')",
      "        self.actionwords.click(path = '.login-form input[type=submit]')",
      "        self.actionwords.check_url(path = '/welcome')",
      "",
      "    def test_failed_login(self):",
      "        # Tags: myTag:somevalue",
      "        self.actionwords.visit(url = '/login')",
      "        self.actionwords.fill(login = 'user@example.com')",
      "        self.actionwords.fill(password = 'notTh4tS3cret')",
      "        self.actionwords.click(path = '.login-form input[type=submit]')",
      "        self.actionwords.check_url(path = '/login')",
      ""
    ].join("\n")

    @first_test_rendered = [
      "def test_login(self):",
      "    # The description is on ",
      "    # two lines",
      "    # Tags: myTag myTag:somevalue",
      "    self.actionwords.visit(url = '/login')",
      "    self.actionwords.fill(login = 'user@example.com')",
      "    self.actionwords.fill(password = 's3cret')",
      "    self.actionwords.click(path = '.login-form input[type=submit]')",
      "    self.actionwords.check_url(path = '/welcome')",
      ""
    ].join("\n")

    @first_test_rendered_for_single_file = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestLogin(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
      "    def test_login(self):",
      "        # The description is on ",
      "        # two lines",
      "        # Tags: myTag myTag:somevalue",
      "        self.actionwords.visit(url = '/login')",
      "        self.actionwords.fill(login = 'user@example.com')",
      "        self.actionwords.fill(password = 's3cret')",
      "        self.actionwords.click(path = '.login-form input[type=submit]')",
      "        self.actionwords.check_url(path = '/welcome')",
      ""
    ].join("\n")

    @grand_child_scenario_rendered_for_single_file = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestOneGrandchildScenario(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
      "    def test_one_grandchild_scenario(self):",
      "        pass",
      "",
    ].join("\n")

    @root_folder_rendered = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestMyRootFolder(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
      "    def test_one_root_scenario(self):",
      "        pass",
      "",
      "    def test_another_root_scenario(self):",
      "        pass",
      "",
    ].join("\n")

    @grand_child_folder_rendered = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestAGrandchildFolder(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "",
    ].join("\n")

    @second_grand_child_folder_rendered = [
      "# encoding: UTF-8",
      "import unittest",
      "from actionwords import Actionwords",
      "",
      "class TestASecondGrandchildFolder(unittest.TestCase):",
      "    def setUp(self):",
      "        self.actionwords = Actionwords(self)",
      "        self.actionwords.visit(url = '/login')",
      "        self.actionwords.fill(login = 'user@example.com')",
      "        self.actionwords.fill(password = 'notTh4tS3cret')",
      "",
      "    def test_one_grandchild_scenario(self):",
      "        pass",
      ""
    ].join("\n")
  end

  context 'UnitTest' do
    it_behaves_like "a renderer" do
      let(:language) {'python'}
      let(:framework) {'unittest'}
    end
  end
end
