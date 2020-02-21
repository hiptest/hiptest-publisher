require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Cucumber/Typed-TypeScript rendering' do
  include_context 'shared render'
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'cucumber_expressions'}
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
        'Given(\'the color {string}\', async (color) => {',
        '    actionWords.theColorColor(color);',
        '});',
        '',
        'When(\'you mix colors\', async () => {',
        '    actionWords.youMixColors();',
        '});',
        '',
        'Then(\'you obtain {string}\', async (color) => {',
        '    actionWords.youObtainColor(color);',
        '});',
        '',
        '',
        'Then(\'you cannot play croquet\', async () => {',
        '    actionWords.youCannotPlayCroquet();',
        '});',
        '',
        'Given(\'I am on the {string} home page\', async (site, __free_text) => {',
        '    actionWords.iAmOnTheSiteHomePage(site, __free_text);',
        '});',
        '',
        'When(\'the following users are available on {string}\', async (site, __datatable) => {',
        '    actionWords.theFollowingUsersAreAvailableOnSite(site, __datatable);',
        '});',
        '',
        'Given(\'an untrimed action word\', async () => {',
        '    actionWords.anUntrimedActionWord();',
        '});',
        '',
        'Given(\'the {string} of {string} is weird {string} {string}\', async (order, parameters, p0, p1) => {',
        '    actionWords.theOrderOfParametersIsWeird(p0, p1, parameters, order);',
        '});',
        '',
        'Given(\'I login on {string} {string}\', async (site, username) => {',
        '    actionWords.iLoginOn(site, username);',
        '});',
        '',
        'Given(\'I have some {int}\', async (number) => {',
        '    actionWords.iHaveSomeNumber(number);',
        '});',
        ''
      ].join("\n")
    }

    let(:actionword_without_quotes_in_regexp_rendered) {
      [
        '',
        'Given(\'the color {string}\', async (color) => {',
        '    actionWords.theColorColor(color);',
        '});'
      ].join("\n")
    }

    let(:rendered_empty_scenario) {"\nScenario: Empty Scenario\n"}
  end

  it_behaves_like 'a BDD renderer with library actionwords', uid_should_be_in_outline: true do
    let(:language) {'cucumber_expressions'}
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
        'Given(\'My first action word\', async () => {',
        '    libraryActionWord.getDefaultLibrary().myFirstActionWord();',
        '});',
        '',
        ''
      ].join("\n")
    }
  end

  it_behaves_like 'a renderer handling libraries' do
    let(:language) {'cucumber_expressions'}
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