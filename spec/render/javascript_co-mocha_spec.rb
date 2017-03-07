require_relative '../spec_helper'
require_relative "../render_shared"

describe 'Render as Javascript' do
  include_context "shared render"

  before(:each) do
    # In Hiptest: null
    @null_rendered = 'null'

    # In Hiptest: 'What is your quest ?'
    @what_is_your_quest_rendered = "'What is your quest ?'"

    # In Hiptest: 3.14
    @pi_rendered = '3.14'

    # In Hiptest: false
    @false_rendered = 'false'

    # In Hiptest: "${foo}fighters"
    @foo_template_rendered = 'String(foo) + "fighters"'

    # In Hiptest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Hiptest: ""
    @empty_template_rendered = '""'

    # In Hiptest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'

    # In Hiptest: foo.fighters
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In Hiptest: foo['fighters']
    @foo_brackets_fighters_rendered = "foo['fighters']"

    # In Hiptest: -foo
    @minus_foo_rendered = '-foo'

    # In Hiptest: foo - 'fighters'
    @foo_minus_fighters_rendered = "foo - 'fighters'"

    # In Hiptest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In Hiptest: [foo, 'fighters']
    @foo_list_rendered = "[foo, 'fighters']"

    # In Hiptest: foo: 'fighters'
    @foo_fighters_prop_rendered = "foo: 'fighters'"

    # In Hiptest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = "{foo: 'fighters', Alt: J}"

    # In Hiptest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = "foo = 'fighters';"

    # In Hiptest: call 'foo'
    @call_foo_rendered = "yield this.actionwords.foo();"
    # In Hiptest: call 'foo bar'
    @call_foo_bar_rendered = "yield this.actionwords.fooBar();"

    # In Hiptest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = "yield this.actionwords.foo('fighters');"
    # In Hiptest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = "yield this.actionwords.fooBar('fighters');"
    @call_with_special_characters_in_value_rendered = "yield this.actionwords.myCallWithWeirdArguments(\"{\\n  this: 'is',\\n  some: ['JSON', 'outputed'],\\n  as: 'a string'\\n}\");"

    # In Hiptest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '// TODO: Implement action: String(foo) + "fighters"'

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
        "if (true) {",
        "  foo = 'fighters';",
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
        "  foo = 'fighters';",
        "} else {",
        "  fighters = 'foo';",
        "}\n"
      ].join("\n")

    # In Hiptest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
        "while (foo) {",
        "  fighters = 'foo';",
        "  yield this.actionwords.foo('fighters');",
        "}\n"
      ].join("\n")

    # In Hiptest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Hiptest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Hiptest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = 'plic'

    # In Hiptest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = "plic"

    # In Hiptest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "myActionWord: function * () {\n\n}"

    # In Hiptest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "myActionWord: function * () {",
      "  // Tags: myTag myTag:somevalue",
      "}"].join("\n")

    @described_action_word_rendered = [
      "myActionWord: function * () {",
      "  // Some description",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "myActionWord: function * (plic, flip) {",
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
      "compareToPi: function * (x) {",
      "  // Tags: myTag",
      "  var foo;",
      "  foo = 3.14;",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "  throw 'Not implemented';",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "myActionWord: function * () {",
      "  // TODO: Implement action: basic action",
      "  throw 'Not implemented';",
      "}"].join("\n")

    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "var Actionwords = {",
      "  yield firstActionWord: function * () {",
      "",
      "  },",
      "  secondActionWord: function * () {",
      "    yield this.firstActionWord();",
      "  }",
      "};"].join("\n")

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
      "var Actionwords = {",
      "  awWithIntParam: function (x) {",
      "",
      "  },",
      "  awWithFloatParam: function (x) {",
      "",
      "  },",
      "  awWithBooleanParam: function (x) {",
      "",
      "  },",
      "  awWithNullParam: function (x) {",
      "",
      "  },",
      "  awWithStringParam: function (x) {",
      "",
      "  },",
      "  awWithTemplateParam: function (x) {",
      "",
      "  }",
      "};"
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
      "test('compare to pi', function () {",
      "  // This is a scenario which description ",
      "  // is on two lines",
      "  // Tags: myTag",
      "  var foo;",
      "  foo = 3.14;",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "  throw 'Not implemented';",
      "});"].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
      'test(\'Reset password\', function () {',
      '  // Given Page "/login" is opened',
      '  this.actionwords.pageUrlIsOpened(\'/login\');',
      '  // When I click on "Reset password"',
      '  this.actionwords.iClickOnLink(\'Reset password\');',
      '  // Then Page "/reset-password" should be opened',
      '  this.actionwords.pageUrlShouldBeOpened(\'/reset-password\');',
      '});',
    ].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = [
      "(function () {",
      "  module('compare to pi', {",
      "    setup: function () {",
      "      this.actionwords = Object.create(Actionwords);",
      "    }",
      "  });",
      "",
      "  test('compare to pi', function () {",
      "    // This is a scenario which description ",
      "    // is on two lines",
      "    // Tags: myTag",
      "    var foo;",
      "    foo = 3.14;",
      "    if (foo > x) {",
      "      // TODO: Implement result: x is greater than Pi",
      "    } else {",
      "      // TODO: Implement result: x is lower than Pi",
      "      // on two lines",
      "    }",
      "    throw 'Not implemented';",
      "  });",
      "})();",
      ""
    ].join("\n")

    @full_scenario_with_uid_rendered = [
      "test('compare to pi (uid:abcd-1234)', function () {",
      "  // This is a scenario which description ",
      "  // is on two lines",
      "  // Tags: myTag",
      "  var foo;",
      "  foo = 3.14;",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "  throw 'Not implemented';",
      "});"
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
      "function * checkLogin (login, password, expected) {",
      "  // Ensure the login process",
      "  yield this.actionwords.fillLogin(login);",
      "  yield this.actionwords.fillPassword(password);",
      "  yield this.actionwords.pressEnter();",
      "  yield this.actionwords.assertErrorIsDisplayed(expected);",
      "}",
      "",
      "test('check login: Wrong \\'login\\'', function * () {",
      "  yield checkLogin.apply(this, ['invalid', 'invalid', 'Invalid username or password']);",
      "});",
      "",
      "test('check login: Wrong \"password\"', function * () {",
      "  yield checkLogin.apply(this, ['valid', 'invalid', 'Invalid username or password']);",
      "});",
      "",
      "test('check login: Valid \\'login\\'/\"password\"', function * () {",
      "  yield checkLogin.apply(this, ['valid', 'valid', null]);",
      "});",
      ""
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      "function * checkLogin (login, password, expected) {",
      "  // Ensure the login process",
      "  yield this.actionwords.fillLogin(login);",
      "  yield this.actionwords.fillPassword(password);",
      "  yield this.actionwords.pressEnter();",
      "  yield this.actionwords.assertErrorIsDisplayed(expected);",
      "}",
      "",
      "test('check login: Wrong \\'login\\' (uid:a-123)', function * () {",
      "  yield checkLogin.apply(this, ['invalid', 'invalid', 'Invalid username or password']);",
      "});",
      "",
      "test('check login: Wrong \"password\" (uid:b-456)', function * () {",
      "  yield checkLogin.apply(this, ['valid', 'invalid', 'Invalid username or password']);",
      "});",
      "",
      "test('check login: Valid \\'login\\'/\"password\" (uid:c-789)', function * () {",
      "  yield checkLogin.apply(this, ['valid', 'valid', null]);",
      "});",
      ""
    ].join("\n")

    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      "(function () {",
      "  module('check login', {",
      "    setup: function () {",
      "      this.actionwords = Object.create(Actionwords);",
      "    }",
      "  });",
      "",
      "  function * checkLogin (login, password, expected) {",
      "    // Ensure the login process",
      "    yield this.actionwords.fillLogin(login);",
      "    yield this.actionwords.fillPassword(password);",
      "    yield this.actionwords.pressEnter();",
      "    yield this.actionwords.assertErrorIsDisplayed(expected);",
      "  }",
      "",
      "  test('check login: Wrong \\'login\\'', function * () {",
      "    yield checkLogin.apply(this, ['invalid', 'invalid', 'Invalid username or password']);",
      "  });",
      "",
      "  test('check login: Wrong \"password\"', function *() {",
      "    yield checkLogin.apply(this, ['valid', 'invalid', 'Invalid username or password']);",
      "  });",
      "",
      "  test('check login: Valid \\'login\\'/\"password\"', function * () {",
      "    yield checkLogin.apply(this, ['valid', 'valid', null]);",
      "  });",
      "})();",
      ""
    ].join("\n")

    # In Hiptest, correspond to two scenarios in a project called "Miles' project"
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "(function () {",
      "  module('Mike\\'s project', {",
      "    setup: function () {",
      "      this.actionwords = Object.create(Actionwords);",
      "    }",
      "  });",
      "",
      "  test('first scenario', function () {",
      "",
      "  });",
      "",
      "  test('second scenario', function () {",
      "    this.actionwords.myActionWord();",
      "  });",
      "})();",
      ""
    ].join("\n")

    @tests_rendered = [
      "(function () {",
      "  module('Mike\\'s test project', {",
      "    setup: function () {",
      "      this.actionwords = Object.create(Actionwords);",
      "    }",
      "  });",
      "",
      "  test('Login', function () {",
      "    // The description is on ",
      "    // two lines",
      "    // Tags: myTag myTag:somevalue",
      "    this.actionwords.visit('/login');",
      "    this.actionwords.fill('user@example.com');",
      "    this.actionwords.fill('s3cret');",
      "    this.actionwords.click('.login-form input[type=submit]');",
      "    this.actionwords.checkUrl('/welcome');",
      "  });",
      "",
      "  test('Failed login', function () {",
      "    // Tags: myTag:somevalue",
      "    this.actionwords.visit('/login');",
      "    this.actionwords.fill('user@example.com');",
      "    this.actionwords.fill('notTh4tS3cret');",
      "    this.actionwords.click('.login-form input[type=submit]');",
      "    this.actionwords.checkUrl('/login');",
      "  });",
      "})();",
      ""
    ].join("\n")

    @first_test_rendered = [
      "test('Login', function () {",
      "  // The description is on ",
      "  // two lines",
      "  // Tags: myTag myTag:somevalue",
      "  this.actionwords.visit('/login');",
      "  this.actionwords.fill('user@example.com');",
      "  this.actionwords.fill('s3cret');",
      "  this.actionwords.click('.login-form input[type=submit]');",
      "  this.actionwords.checkUrl('/welcome');",
      "});",
    ].join("\n")

    @first_test_rendered_for_single_file = [
      "(function () {",
      "  module('Login', {",
      "    setup: function () {",
      "      this.actionwords = Object.create(Actionwords);",
      "    }",
      "  });",
      "",
      "  test('Login', function () {",
      "    // The description is on ",
      "    // two lines",
      "    // Tags: myTag myTag:somevalue",
      "    this.actionwords.visit('/login');",
      "    this.actionwords.fill('user@example.com');",
      "    this.actionwords.fill('s3cret');",
      "    this.actionwords.click('.login-form input[type=submit]');",
      "    this.actionwords.checkUrl('/welcome');",
      "  });",
      "})();",
      ""
    ].join("\n")
  end

  context 'Co-Mocha' do
    before(:each) do
    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "'use strict';",
      "require('co-mocha');",
      "exports.Actionwords = {",
      "  firstActionWord: function * () {",
      "",
      "  },",
      "  secondActionWord: function * () {",
      "    yield this.firstActionWord();",
      "  }",
      "};"].join("\n")

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
      "'use strict';",
      "require('co-mocha');",
      "exports.Actionwords = {",
      "  awWithIntParam: function * (x) {",
      "",
      "  },",
      "  awWithFloatParam: function * (x) {",
      "",
      "  },",
      "  awWithBooleanParam: function * (x) {",
      "",
      "  },",
      "  awWithNullParam: function * (x) {",
      "",
      "  },",
      "  awWithStringParam: function * (x) {",
      "",
      "  },",
      "  awWithTemplateParam: function * (x) {",
      "",
      "  }",
      "};"
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
        "it('compare to pi', function * () {",
        "  // This is a scenario which description ",
        "  // is on two lines",
        "  // Tags: myTag",
        "  var foo;",
        "  foo = 3.14;",
        "  if (foo > x) {",
        "    // TODO: Implement result: x is greater than Pi",
        "  } else {",
        "    // TODO: Implement result: x is lower than Pi",
        "    // on two lines",
        "  }",
        "  throw 'Not implemented';",
        "});"].join("\n")

      # In hiptest
      # scenario 'reset password' do
      #   call given 'Page "url" is opened'(url='/login')
      #   call when 'I click on "link"'(link='Reset password')
      #   call then 'page "url" should be opened'(url='/reset-password')
      # end
      @bdd_scenario_rendered = [
        'it(\'Reset password\', function * () {',
        '  // Given Page "/login" is opened',
        '  yield this.actionwords.pageUrlIsOpened(\'/login\');',
        '  // When I click on "Reset password"',
        '  yield this.actionwords.iClickOnLink(\'Reset password\');',
        '  // Then Page "/reset-password" should be opened',
        '  yield this.actionwords.pageUrlShouldBeOpened(\'/reset-password\');',
        '});',
      ].join("\n")

      # Same than previous scenario, except that is is rendered
      # so it can be used in a single file (using the --split-scenarios option)
      @full_scenario_rendered_for_single_file = [
        "describe('compare to pi', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('./actionwords.js').Actionwords);",
        "  });",
        "",
        "  it('compare to pi', function * () {",
        "    // This is a scenario which description ",
        "    // is on two lines",
        "    // Tags: myTag",
        "    var foo;",
        "    foo = 3.14;",
        "    if (foo > x) {",
        "      // TODO: Implement result: x is greater than Pi",
        "    } else {",
        "      // TODO: Implement result: x is lower than Pi",
        "      // on two lines",
        "    }",
        "    throw 'Not implemented';",
        "  });",
        "});",
        ""
      ].join("\n")

      @full_scenario_with_uid_rendered = [
        "it('compare to pi (uid:abcd-1234)', function * () {",
        "  // This is a scenario which description ",
        "  // is on two lines",
        "  // Tags: myTag",
        "  var foo;",
        "  foo = 3.14;",
        "  if (foo > x) {",
        "    // TODO: Implement result: x is greater than Pi",
        "  } else {",
        "    // TODO: Implement result: x is lower than Pi",
        "    // on two lines",
        "  }",
        "  throw 'Not implemented';",
        "});"
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
        "describe('check login', function () {",
        "  function * checkLogin (login, password, expected) {",
        "    // Ensure the login process",
        "    yield this.actionwords.fillLogin(login);",
        "    yield this.actionwords.fillPassword(password);",
        "    yield this.actionwords.pressEnter();",
        "    yield this.actionwords.assertErrorIsDisplayed(expected);",
        "  }",
        "",
        "  it('Wrong \\'login\\'', function * () {",
        "    yield checkLogin.apply(this, ['invalid', 'invalid', 'Invalid username or password']);",
        "  });",
        "",
        "  it('Wrong \"password\"', function * () {",
        "    yield checkLogin.apply(this, ['valid', 'invalid', 'Invalid username or password']);",
        "  });",
        "",
        "  it('Valid \\'login\\'/\"password\"', function * () {",
        "    yield checkLogin.apply(this, ['valid', 'valid', null]);",
        "  });",
        "});",
        ""
      ].join("\n")

      @scenario_with_datatable_rendered_with_uids = [
        "describe('check login', function () {",
        "  function * checkLogin (login, password, expected) {",
        "    // Ensure the login process",
        "    yield this.actionwords.fillLogin(login);",
        "    yield this.actionwords.fillPassword(password);",
        "    yield this.actionwords.pressEnter();",
        "    yield this.actionwords.assertErrorIsDisplayed(expected);",
        "  }",
        "",
        "  it('Wrong \\'login\\' (uid:a-123)', function * () {",
        "    yield checkLogin.apply(this, ['invalid', 'invalid', 'Invalid username or password']);",
        "  });",
        "",
        "  it('Wrong \"password\" (uid:b-456)', function * () {",
        "    yield checkLogin.apply(this, ['valid', 'invalid', 'Invalid username or password']);",
        "  });",
        "",
        "  it('Valid \\'login\\'/\"password\" (uid:c-789)', function * () {",
        "    yield checkLogin.apply(this, ['valid', 'valid', null]);",
        "  });",
        "});",
        ""
      ].join("\n")

      # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
      @scenario_with_datatable_rendered_in_single_file = [
        "describe('check login', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('./actionwords.js').Actionwords);",
        "  });",
        "",
        "  describe('check login', function () {",
        "    function * checkLogin (login, password, expected) {",
        "      // Ensure the login process",
        "      yield this.actionwords.fillLogin(login);",
        "      yield this.actionwords.fillPassword(password);",
        "      yield this.actionwords.pressEnter();",
        "      yield this.actionwords.assertErrorIsDisplayed(expected);",
        "    }",
        "",
        "    it('Wrong \\'login\\'', function * () {",
        "      yield checkLogin.apply(this, ['invalid', 'invalid', 'Invalid username or password']);",
        "    });",
        "",
        "    it('Wrong \"password\"', function * () {",
        "      yield checkLogin.apply(this, ['valid', 'invalid', 'Invalid username or password']);",
        "    });",
        "",
        "    it('Valid \\'login\\'/\"password\"', function * () {",
        "      yield checkLogin.apply(this, ['valid', 'valid', null]);",
        "    });",
        "  });",
        "});",
        ""
      ].join("\n")

      # In Hiptest, correspond to two scenarios in a project called "Miles' project"
      # scenario 'first scenario' do
      # end
      # scenario 'second scenario' do
      #   call 'my action word'
      # end
      @scenarios_rendered = [
        "'use strict';",
        "require('co-mocha');",
        "describe('Mike\\'s project', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('./actionwords.js').Actionwords);",
        "  });",
        "",
        "  it('first scenario', function * () {",
        "",
        "  });",
        "",
        "  it('second scenario', function * () {",
        "    yield this.actionwords.myActionWord();",
        "  });",
        "});",
        ""
      ].join("\n")

      @tests_rendered = [
        "describe('Mike\\'s test project', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('./actionwords.js').Actionwords);",
        "  });",
        "",
        "  it('Login', function * () {",
        "    // The description is on ",
        "    // two lines",
        "    // Tags: myTag myTag:somevalue",
        "    yield this.actionwords.visit('/login');",
        "    yield this.actionwords.fill('user@example.com');",
        "    yield this.actionwords.fill('s3cret');",
        "    yield this.actionwords.click('.login-form input[type=submit]');",
        "    yield this.actionwords.checkUrl('/welcome');",
        "  });",
        "",
        "  it('Failed login', function * () {",
        "    // Tags: myTag:somevalue",
        "    yield this.actionwords.visit('/login');",
        "    yield this.actionwords.fill('user@example.com');",
        "    yield this.actionwords.fill('notTh4tS3cret');",
        "    yield this.actionwords.click('.login-form input[type=submit]');",
        "    yield this.actionwords.checkUrl('/login');",
        "  });",
        "});",
        ""
      ].join("\n")

      @first_test_rendered = [
        "it('Login', function * () {",
        "  // The description is on ",
        "  // two lines",
        "  // Tags: myTag myTag:somevalue",
        "  yield this.actionwords.visit('/login');",
        "  yield this.actionwords.fill('user@example.com');",
        "  yield this.actionwords.fill('s3cret');",
        "  yield this.actionwords.click('.login-form input[type=submit]');",
        "  yield this.actionwords.checkUrl('/welcome');",
        "});",
      ].join("\n")

      @first_test_rendered_for_single_file = [
        "describe('Login', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('./actionwords.js').Actionwords);",
        "  });",
        "",
        "  it('Login', function * () {",
        "    // The description is on ",
        "    // two lines",
        "    // Tags: myTag myTag:somevalue",
        "    yield this.actionwords.visit('/login');",
        "    yield this.actionwords.fill('user@example.com');",
        "    yield this.actionwords.fill('s3cret');",
        "    yield this.actionwords.click('.login-form input[type=submit]');",
        "    yield this.actionwords.checkUrl('/welcome');",
        "  });",
        "});",
        ""
      ].join("\n")

      @grand_child_scenario_rendered_for_single_file = [
        "describe('One grand\\'child scenario', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('../../actionwords.js').Actionwords);",
        "  });",
        "",
        "  it('One grand\\'child scenario', function * () {",
        "",
        "  });",
        "});",
        "",
      ].join("\n")

      @root_folder_rendered = [
        "describe('My root folder', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('./actionwords.js').Actionwords);",
        "  });",
        "",
        "  it('One root scenario', function * () {",
        "",
        "  });",
        "",
        "  it('Another root scenario', function * () {",
        "",
        "  });",
        "});",
        "",
      ].join("\n")

      @grand_child_folder_rendered = [
        "describe('A grand-child folder', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('../actionwords.js').Actionwords);",
        "  });",
        "});",
        "",
      ].join("\n")

      @second_grand_child_folder_rendered = [
        "describe('A second grand-child folder', function () {",
        "  beforeEach(function () {",
        "    this.actionwords = Object.create(require('../actionwords.js').Actionwords);",
        "    yield this.actionwords.visit('/login');",
        "    yield this.actionwords.fill('user@example.com');",
        "    yield this.actionwords.fill('notTh4tS3cret');",
        "  });",
        "",
        "  it('One grand\\'child scenario', function * () {",
        "",
        "  });",
        "});",
        ""
      ].join("\n")
    end

    it_behaves_like "a renderer" do
      let(:language) {'javascript'}
      let(:framework) {'co-mocha'}
    end
  end
end
