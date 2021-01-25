require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Cucumber Legacy/Java rendering' do
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'cucumber_legacy'}
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
        '    @Then("^you cannot play croquet$")',
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
        '',
        '    @Given("^I have some \"(.*)\"$")',
        '    public void iHaveSomeNumber(int number) {',
        '        actionwords.iHaveSomeNumber(number);',
        '    }',
        '}'
      ].join("\n")
    }

    let(:actionword_without_quotes_in_regexp_rendered) {
      [
        '@Given("^the color (.*)$")',
        'public void theColorColor(String color) {',
        '    actionwords.theColorColor(color);',
        '}',
        ''
      ].join("\n")
    }

    let(:rendered_empty_scenario) {""}
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
                      make_call("I use specials \?\{0\} characters \"c\"", annotation: "given", arguments: [make_argument("c", template_of_literals("pil\?ip"))]),
                      make_call("other special \* - \. - \\ chars", annotation: "and"),
                    ])
    }

    let!(:project) {
      make_project("Special",
                   scenarios: [scenario],
                   actionwords: actionwords,
      ).tap do |p|
        Hiptest::NodeModifiers.add_all(p)
      end
    }

    let(:options) {
      context_for(
        only: 'step_definitions',
        language: 'cucumber_legacy',
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

describe 'Cucumber Legacy/Groovy rendering' do
  include_context "shared render"
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'cucumber_legacy'}
    let(:framework) {'groovy'}
    let(:with_folders) {true}

    let(:rendered_free_texted_actionword) {[
      'def theFollowingUsersAreAvailable(freeText = "") {',
      '}'].join("\n")}

    let(:rendered_datatabled_actionword) {[
      'def theFollowingUsersAreAvailable(datatable = "") {',
      '}'].join("\n")}

    let(:rendered_actionwords) {
      [
        'package com.example',
        '',
        'import cucumber.api.DataTable',
        '',
        'this.metaClass.mixin(cucumber.api.groovy.EN)',
        '',
        'Actionwords actionwords = new Actionwords()',
        '',
        'Given(~"^the color \"(.*)\"\$") { String color ->',
        '    actionwords.theColorColor(color)',
        '}',
        '',
        'When(~"^you mix colors\$") {  ->',
        '    actionwords.youMixColors()',
        '}',
        '',
        'Then(~"^you obtain \"(.*)\"\$") { String color ->',
        '    actionwords.youObtainColor(color)',
        '}',
        '',
        '',
        'Then(~"^you cannot play croquet\$") {  ->',
        '    actionwords.youCannotPlayCroquet()',
        '}',
        '',
        'Given(~"^I am on the \"(.*)\" home page\$") { String site, String freeText ->',
        '    actionwords.iAmOnTheSiteHomePage(site, freeText)',
        '}',
        '',
        'When(~"^the following users are available on \"(.*)\"\$") { String site, DataTable datatable ->',
        '    actionwords.theFollowingUsersAreAvailableOnSite(site, datatable)',
        '}',
        '',
        'Given(~"^an untrimed action word\$") {  ->',
        '    actionwords.anUntrimedActionWord()',
        '}',
        '',
        'Given(~"^the \"(.*)\" of \"(.*)\" is weird \"(.*)\" \"(.*)\"\$") { String order, String parameters, String p0, String p1 ->',
        '    actionwords.theOrderOfParametersIsWeird(p0, p1, parameters, order)',
        '}',
        '',
        'Given(~"^I login on \"(.*)\" \"(.*)\"\$") { String site, String username ->',
        '    actionwords.iLoginOn(site, username)',
        '}',
        '',
        'Given(~"^I have some \"(.*)\"\$") { int number ->',
        '    actionwords.iHaveSomeNumber(number)',
        '}',
        '',
        ''
      ].join("\n")
    }

    let(:actionword_without_quotes_in_regexp_rendered) {
      [
        'Given(~"^the color (.*)\$") { String color ->',
        '    actionwords.theColorColor(color)',
        '}',
        ''
      ].join("\n")
    }

    let(:rendered_empty_scenario) {""}
  end

  it_behaves_like 'a BDD renderer with library actionwords', uid_should_be_in_outline: true do
    let(:language) {'cucumber_legacy'}
    let(:framework) {'groovy'}
    let(:with_folders) {true}

    let(:rendered_library_actionwords) {
      [
        'package com.example',
        '',
        'import cucumber.api.DataTable',
        '',
        'this.metaClass.mixin(cucumber.api.groovy.EN)',
        '',
        'Actionwords actionwords = new Actionwords()',
        '',
        'Given(~"^My first action word\$") {  ->',
        '    actionwords.getDefaultLibrary().myFirstActionWord()',
        '}',
        '',
        '',
        ''
      ].join("\n")
    }
  end

  it_behaves_like 'a renderer handling libraries' do
    let(:language) {'cucumber_legacy'}
    let(:framework) {'groovy'}

    let(:libraries_rendered) {
      [
        'package com.example',
        '',
        'class ActionwordLibrary {',
        '    DefaultLibrary getDefaultLibrary() {',
        '        return DefaultLibrary.instance',
        '    }',
        '',
        '    WebLibrary getWebLibrary() {',
        '        return WebLibrary.instance',
        '    }',
        '}'
      ].join("\n")
    }

    let(:actionwords_rendered) {
        [
          'package com.example',
          '',
          'class Actionwords extends ActionwordLibrary{',
          '    def myProjectActionWord() {',
          '    }',
          '',
          '    def myHighLevelProjectActionword() {',
          '        myProjectActionWord()',
          '    }',
          '',
          '    def myHighLevelActionword() {',
          '        getDefaultLibrary().myFirstActionWord()',
          '    }',
          '}'
        ].join("\n")
      }

    let(:first_lib_rendered) {[
      'package com.example',
      '',
      '@Singleton',
      'class DefaultLibrary {',
      '    def myFirstActionWord() {',
      '        // Tags: priority:high wip',
      '    }',
      '}'
    ].join("\n")}

    let(:second_lib_rendered) {[
      'package com.example',
      '',
      '@Singleton',
      'class WebLibrary {',
      '    def mySecondActionWord() {',
      '        // Tags: priority:low done',
      '    }',
      '}'
    ].join("\n")}
  end

  context "special cases in Actionwords.groovy file" do
    include HelperFactories

    let(:actionwords) {
      [
        make_actionword("An actionword"),
        make_actionword("Another actionword"),
      ]
    }

    let(:scenario) {
      make_scenario("A scenario",
                    body: [
                      make_call("An actionword", annotation: "given"),
                      make_call("Another actionword", annotation: "and"),
                    ])
    }

    let!(:project) {
      make_project("Prohject",
                   scenarios: [scenario],
                   actionwords: actionwords,
      ).tap do |p|
        Hiptest::NodeModifiers::ParentAdder.add(p)
        Hiptest::NodeModifiers::GherkinAdder.add(p)
      end
    }

    let(:options) {
      context_for(
        only: 'actionwords',
        language: 'cucumber_legacy',
        framework: 'groovy',
      )
    }

    it "add package to the top of Actionwords.groovy file" do
      rendered = project.children[:actionwords].render(options)
      expect(rendered).to eq([
                               'package com.example',
                               '',
                               'class Actionwords {',
                               '    def anActionword() {',
                               '    }',
                               '',
                               '    def anotherActionword() {',
                               '    }',
                               '}',
                             ].join("\n"))
    end
  end
end

describe 'Cucumber Legacy/TypeScript rendering' do
  include_context 'shared render'
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'cucumber_legacy'}
    let(:framework) {'typescript'}

    let(:rendered_free_texted_actionword) {[
      'theFollowingUsersAreAvailable(__free_text = \'\') {',
      '',
      '}'].join("\n")}

     let(:rendered_datatabled_actionword) {[
       'theFollowingUsersAreAvailable(__datatable: TableDefinition) {',
       '',
       '}'].join("\n")}

    let(:rendered_actionwords) {
      [
        'import { After, Before, Given, When, Then, TableDefinition } from "cucumber";',
        'import { ActionWords } from \'./actionwords\';',
        '',
        'let actionWords : ActionWords;',
        'Before(async () => {',
        '    actionWords = new ActionWords();',
        '});',
        '',
        'After(async () => {',
        '});',
        '',
        '',
        'Given(/^the color "(.*)"$/, async (color) => {',
        '    actionWords.theColorColor(color);',
        '});',
        '',
        'When(/^you mix colors$/, async () => {',
        '    actionWords.youMixColors();',
        '});',
        '',
        'Then(/^you obtain "(.*)"$/, async (color) => {',
        '    actionWords.youObtainColor(color);',
        '});',
        '',
        '',
        'Then(/^you cannot play croquet$/, async () => {',
        '    actionWords.youCannotPlayCroquet();',
        '});',
        '',
        'Given(/^I am on the "(.*)" home page$/, async (site, __free_text) => {',
        '    actionWords.iAmOnTheSiteHomePage(site, __free_text);',
        '});',
        '',
        'When(/^the following users are available on "(.*)"$/, async (site, __datatable) => {',
        '    actionWords.theFollowingUsersAreAvailableOnSite(site, __datatable);',
        '});',
        '',
        'Given(/^an untrimed action word$/, async () => {',
        '    actionWords.anUntrimedActionWord();',
        '});',
        '',
        'Given(/^the "(.*)" of "(.*)" is weird "(.*)" "(.*)"$/, async (order, parameters, p0, p1) => {',
        '    actionWords.theOrderOfParametersIsWeird(p0, p1, parameters, order);',
        '});',
        '',
        'Given(/^I login on "(.*)" "(.*)"$/, async (site, username) => {',
        '    actionWords.iLoginOn(site, username);',
        '});',
        '',
        'Given(/^I have some "(.*)"$/, async (number) => {',
        '    actionWords.iHaveSomeNumber(number);',
        '});',
        ''
      ].join("\n")
    }

    let(:actionword_without_quotes_in_regexp_rendered) {
      [
        '',
        'Given(/^the color (.*)$/, async (color) => {',
        '    actionWords.theColorColor(color);',
        '});'
      ].join("\n")
    }

    let(:rendered_empty_scenario) {"\nScenario: Empty Scenario\n"}
  end

  it_behaves_like 'a BDD renderer with library actionwords', uid_should_be_in_outline: true do
    let(:language) {'cucumber_legacy'}
    let(:framework) {'typescript'}

    let(:rendered_library_actionwords) {
      [
        'import { After, Before, Given, When, Then, TableDefinition } from "cucumber";',
        'import { ActionwordLibrary } from "./actionword_library";',
        '',
        'let libraryActionWord : ActionwordLibrary',
        'Before(async () => {',
        '    libraryActionWord = new ActionwordLibrary();',
        '});',
        '',
        'After(async () => {',
        '});',
        '',
        '',
        'Given(/^My first action word$/, async () => {',
        '    libraryActionWord.getDefaultLibrary().myFirstActionWord();',
        '});',
        '',
        ''
      ].join("\n")
    }
  end

  it_behaves_like 'a renderer handling libraries' do
    let(:language) {'cucumber_legacy'}
    let(:framework) {'typescript'}

    let(:actionwords_rendered) {
      [
        'import { TableDefinition } from "cucumber";',
        'import { ActionwordLibrary } from "./actionword_library";',
        '',
        'export class ActionWords extends ActionwordLibrary {',
        '    myProjectActionWord() {',
        '',
        '    }',
        '    myHighLevelProjectActionword() {',
        '        this.myProjectActionWord();',
        '    }',
        '    myHighLevelActionword() {',
        '        this.getDefaultLibrary().myFirstActionWord();',
        '    }',
        '}',
        ''
      ].join("\n")
    }

    let(:libraries_rendered) {
      [
        'import { DefaultLibrary } from "./default_library"',
        'import { WebLibrary } from "./web_library"',
        '',
        '',
        'export class ActionwordLibrary {',
        '    getDefaultLibrary() {',
        '        return new DefaultLibrary()',
        '    }',
        '',
        '    getWebLibrary() {',
        '        return new WebLibrary()',
        '    }',
        '}'
      ].join("\n")
    }

    let(:first_lib_rendered) {
      [
        'import { assert } from "chai";',
        'import { TableDefinition } from "cucumber";',
        '',
        'export class DefaultLibrary {',
        '    private static instance: DefaultLibrary;',
        '',
        '    static getInstance() {',
        '        if (!DefaultLibrary.instance){',
        '            DefaultLibrary.instance = new DefaultLibrary();',
        '        }',
        '        return DefaultLibrary.instance;',
        '    }',
        '',
        '    myFirstActionWord() {',
        '        // Tags: priority:high wip',
        '    }',
        '}'
      ].join("\n")
    }

    let(:second_lib_rendered) {
      [
        'import { assert } from "chai";',
        'import { TableDefinition } from "cucumber";',
        '',
        'export class WebLibrary {',
        '    private static instance: WebLibrary;',
        '',
        '    static getInstance() {',
        '        if (!WebLibrary.instance){',
        '            WebLibrary.instance = new WebLibrary();',
        '        }',
        '        return WebLibrary.instance;',
        '    }',
        '',
        '    mySecondActionWord() {',
        '        // Tags: priority:low done',
        '    }',
        '}'
      ].join("\n")
    }
  end
end
