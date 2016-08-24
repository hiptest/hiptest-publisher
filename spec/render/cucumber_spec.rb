require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Cucumber rendering' do
  it_behaves_like 'a BDD renderer' do
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
        ""
      ].join("\n")
    }
  end
end

describe 'Cucumber/Java rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'cucumber'}
    let(:framework) {'java'}

    let(:rendered_actionwords) {
      [
        'package com.example;',
        '',
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
        '}'
      ].join("\n")
    }
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
  it_behaves_like 'a BDD renderer' do
    let(:language) {'cucumber'}
    let(:framework) {'javascript'}

    let(:rendered_actionwords) {
      [
        'module.exports = function () {',
        '    this.Around(function (scenario, runScenario) {',
        '        this.actionwords = Object.create(require(\'./actionwords.js\').Actionwords);',
        '        runScenario(null, function () {',
        '            this.actionwords = null;',
        '        });',
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
        '}',
        ''
      ].join("\n")
    }
  end
end
