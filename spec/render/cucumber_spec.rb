require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Cucumber/Ruby rendering' do
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: false do
    let(:language) {'cucumber'}
    let(:rendered_actionwords) {
      [
        "# encoding: UTF-8",
        "",
        "require_relative 'actionwords'",
        "World(Actionwords)",
        "",
        "Given /^the color \"(.*)\"$/ do |color|",
        "  the_color_color(color)",
        "end",
        "",
        "When /^you mix colors$/ do",
        "  you_mix_colors",
        "end",
        "",
        "Then /^you obtain \"(.*)\"$/ do |color|",
        "  you_obtain_color(color)",
        "end",
        "",
        "But /^you cannot play croquet$/ do",
        "  you_cannot_play_croquet",
        "end",
        "",
        "Given /^I am on the \"(.*)\" home page$/ do |site, __free_text|",
        "  i_am_on_the_site_home_page(site, __free_text)",
        "end",
        "",
        "When /^the following users are available on \"(.*)\"$/ do |site, __datatable|",
        "  the_following_users_are_available_on_site(site, __datatable)",
        "end",
        "",
        "Given /^an untrimed action word$/ do",
        "  an_untrimed_action_word",
        "end",
        "",
        "Given /^the \"(.*)\" of \"(.*)\" is weird \"(.*)\" \"(.*)\"$/ do |order, parameters, p0, p1|",
        "  the_order_of_parameters_is_weird(p0, p1, parameters, order)",
        "end",
        "",
        "Given /^I login on \"(.*)\" \"(.*)\"$/ do |site, username|",
        "  i_login_on(site, username)",
        "end",
        ""
      ].join("\n")
    }

    let(:rendered_free_texted_actionword) {[
      'def the_following_users_are_available(__free_text = \'\')',
      '',
      'end'].join("\n")}

    let(:rendered_datatabled_actionword) {[
      'def the_following_users_are_available(__datatable = \'\')',
      '',
      'end'].join("\n")}

    let(:rendered_empty_scenario) { "\nScenario: Empty Scenario\n" }
  end
end

describe 'Cucumber/Java rendering' do
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'cucumber'}
    let(:framework) {'java'}

    let(:rendered_free_texted_actionword) {[
      'public void theFollowingUsersAreAvailable(String freeText) {',
      '',
      '}'].join("\n")}

    let(:rendered_datatabled_actionword) {[
      'public void theFollowingUsersAreAvailable(DataTable datatable) {',
      '',
      '}'].join("\n")}

    let(:rendered_actionwords) {
      [
        'package com.example;',
        '',
        'import cucumber.api.DataTable;',
        'import cucumber.api.java.en.*;',
        '',
        'public class StepDefinitions {',
        '    public Actionwords actionwords = new Actionwords();',
        '',
        '    @Given("^the color \"(.*)\"$")',
        '    public void theColorColor(String color) {',
        '        actionwords.theColorColor(color);',
        '    }',
        '',
        '    @When("^you mix colors$")',
        '    public void youMixColors() {',
        '        actionwords.youMixColors();',
        '    }',
        '',
        '    @Then("^you obtain \"(.*)\"$")',
        '    public void youObtainColor(String color) {',
        '        actionwords.youObtainColor(color);',
        '    }',
        '',
        '',
        '    @But("^you cannot play croquet$")',
        '    public void youCannotPlayCroquet() {',
        '        actionwords.youCannotPlayCroquet();',
        '    }',
        '',
        '    @Given("^I am on the \"(.*)\" home page$")',
        '    public void iAmOnTheSiteHomePage(String site, String freeText) {',
        '        actionwords.iAmOnTheSiteHomePage(site, freeText);',
        '    }',
        '',
        '    @When("^the following users are available on \"(.*)\"$")',
        '    public void theFollowingUsersAreAvailableOnSite(String site, DataTable datatable) {',
        '        actionwords.theFollowingUsersAreAvailableOnSite(site, datatable);',
        '    }',
        '',
        '    @Given("^an untrimed action word$")',
        '    public void anUntrimedActionWord() {',
        '        actionwords.anUntrimedActionWord();',
        '    }',
        '',
        '    @Given("^the \"(.*)\" of \"(.*)\" is weird \"(.*)\" \"(.*)\"$")',
        '    public void theOrderOfParametersIsWeird(String order, String parameters, String p0, String p1) {',
        '        actionwords.theOrderOfParametersIsWeird(p0, p1, parameters, order);',
        '    }',
        '',
        '    @Given("^I login on \"(.*)\" \"(.*)\"$")',
        '    public void iLoginOn(String site, String username) {',
        '        actionwords.iLoginOn(site, username);',
        '    }',
        '}'
      ].join("\n")
    }

    let(:rendered_empty_scenario) { "" }
  end

  context "special cases in StepDefinitions.java file" do
    include HelperFactories

    let(:actionwords) {
      [
        make_actionword("I use specials \?\{0\} characters \"c\"", parameters: [make_parameter("c")]),
        make_actionword("other special \* - \. - \\ chars"),
      ]
    }

    let(:scenario) {
      make_scenario("Special characters",
        body: [
          make_call("I use specials \?\{0\} characters \"c\"",  annotation: "given", arguments: [make_argument("c", template_of_literals("pil\?ip"))]),
          make_call("other special \* - \. - \\ chars",         annotation: "and"),
        ])
    }

    let!(:project) {
      make_project("Special",
        scenarios: [scenario],
        actionwords: actionwords,
      ).tap do |p|
        Hiptest::Nodes::ParentAdder.add(p)
        Hiptest::GherkinAdder.add(p)
      end
    }

    let(:options) {
      context_for(
        only: 'step_definitions',
        language: 'cucumber',
        framework: 'java',
      )
    }

    # Java needs double back-slash to escape any character in a regexp string.
    it 'escapes special characters with double back slashes' do
      # note: in single-quoted string, \\\\ means two consecutive back-slashes
      rendered = project.children[:actionwords].render(options)
      expect(rendered).to eq([
        'package com.example;',
        '',
        'import cucumber.api.DataTable;',
        'import cucumber.api.java.en.*;',
        '',
        'public class StepDefinitions {',
        '    public Actionwords actionwords = new Actionwords();',
        '',
        '    @Given("^I use specials \\\\?\\\\{0\\\\} characters \"(.*)\"$")',
        '    public void iUseSpecials0CharactersC(String c) {',
        '        actionwords.iUseSpecials0CharactersC(c);',
        '    }',
        '',
        '    @Given("^other special \\\\* - \\\\. - \\\\\\\\ chars$")', # last one is four back-slashes
        '    public void otherSpecialChars() {',
        '        actionwords.otherSpecialChars();',
        '    }',
        '}',
      ].join("\n"))
    end
  end
end

describe 'Cucumber/Javascript rendering' do
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'cucumber'}
    let(:framework) {'javascript'}

    let(:rendered_free_texted_actionword) {[
      'theFollowingUsersAreAvailable: function (__free_text) {',
      '',
      '}'].join("\n")}

    let(:rendered_datatabled_actionword) {[
      'theFollowingUsersAreAvailable: function (__datatable) {',
      '',
      '}'].join("\n")}

    let(:rendered_actionwords) {
      [
        'module.exports = function () {',
        '    this.Before(function (scenario) {',
        '        this.actionwords = Object.create(require(\'./actionwords.js\').Actionwords);',
        '    });',
        '',
        '    this.After(function (scenario) {',
        '        this.actionwords = null;',
        '    });',
        '',
        '',
        '    this.Given(/^the color "(.*)"$/, function (color, callback) {',
        '        this.actionwords.theColorColor(color);',
        '        callback();',
        '    });',
        '',
        '    this.When(/^you mix colors$/, function (callback) {',
        '        this.actionwords.youMixColors();',
        '        callback();',
        '    });',
        '',
        '    this.Then(/^you obtain "(.*)"$/, function (color, callback) {',
        '        this.actionwords.youObtainColor(color);',
        '        callback();',
        '    });',
        '',
        '',
        '    this.But(/^you cannot play croquet$/, function (callback) {',
        '        this.actionwords.youCannotPlayCroquet();',
        '        callback();',
        '    });',
        '',
        '    this.Given(/^I am on the "(.*)" home page$/, function (site, __free_text, callback) {',
        '        this.actionwords.iAmOnTheSiteHomePage(site, __free_text);',
        '        callback();',
        '    });',
        '',
        '    this.When(/^the following users are available on "(.*)"$/, function (site, __datatable, callback) {',
        '        this.actionwords.theFollowingUsersAreAvailableOnSite(site, __datatable);',
        '        callback();',
        '    });',
        '',
        '    this.Given(/^an untrimed action word$/, function (callback) {',
        '        this.actionwords.anUntrimedActionWord();',
        '        callback();',
        '    });',
        '',
        '    this.Given(/^the "(.*)" of "(.*)" is weird "(.*)" "(.*)"$/, function (order, parameters, p0, p1, callback) {',
        '        this.actionwords.theOrderOfParametersIsWeird(p0, p1, parameters, order);',
        '        callback();',
        '    });',
        '',
        '    this.Given(/^I login on "(.*)" "(.*)"$/, function (site, username, callback) {',
        '        this.actionwords.iLoginOn(site, username);',
        '        callback();',
        '    });',
        '}',
        ''
      ].join("\n")
    }

    let(:rendered_empty_scenario) { "\nScenario: Empty Scenario\n" }
  end
end

describe 'Cucumber/ECMAScript 2015 Modules rendering' do
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'cucumber'}
    let(:framework) {'esmodules'}

    let(:rendered_free_texted_actionword) {[
      'export async function theFollowingUsersAreAvailable (__free_text) {',
      '',
      '}'].join("\n")}

    let(:rendered_datatabled_actionword) {[
      'export async function theFollowingUsersAreAvailable (__datatable) {',
      '',
      '}'].join("\n")}

    let(:rendered_actionwords) {
      [
        'import { Given, When, Then } from \'cucumber\';',
        'import * as actionwords from \'./actionwords\';',
        '',
        '',
        'Given(/^the color "(.*)"$/, function (color) {',
        '    return actionwords.theColorColor(color);',
        '});',
        '',
        'When(/^you mix colors$/, function () {',
        '    return actionwords.youMixColors();',
        '});',
        '',
        'Then(/^you obtain "(.*)"$/, function (color) {',
        '    return actionwords.youObtainColor(color);',
        '});',
        '',
        '',
        'Then(/^you cannot play croquet$/, function () {',
        '    return actionwords.youCannotPlayCroquet();',
        '});',
        '',
        'Given(/^I am on the "(.*)" home page$/, function (site, __free_text) {',
        '    return actionwords.iAmOnTheSiteHomePage(site, __free_text);',
        '});',
        '',
        'When(/^the following users are available on "(.*)"$/, function (site, __datatable) {',
        '    return actionwords.theFollowingUsersAreAvailableOnSite(site, __datatable);',
        '});',
        '',
        'Given(/^an untrimed action word$/, function () {',
        '    return actionwords.anUntrimedActionWord();',
        '});',
        '',
        'Given(/^the "(.*)" of "(.*)" is weird "(.*)" "(.*)"$/, function (order, parameters, p0, p1) {',
        '    return actionwords.theOrderOfParametersIsWeird(p0, p1, parameters, order);',
        '});',
        '',
        'Given(/^I login on "(.*)" "(.*)"$/, function (site, username) {',
        '    return actionwords.iLoginOn(site, username);',
        '});',
        ''
      ].join("\n")
    }

    let(:rendered_empty_scenario) { "\nScenario: Empty Scenario\n" }
  end
end
