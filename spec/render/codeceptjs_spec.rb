require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Cucumber/Javascript rendering' do
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'javascript'}
    let(:framework) {'codeceptjs'}

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
        'const { I } = inject();',
        'let actionwords;',
        '',
        'Before(() => {',
        '    actionwords = Object.create(require(\'./actionwords.js\')).Actionwords;',
        '});',
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
        '',
        'Given(/^I have some "(.*)"$/, function (number) {',
        '    return actionwords.iHaveSomeNumber(number);',
        '});',
        '',
        ''        
      ].join("\n")
    }

    let(:actionword_without_quotes_in_regexp_rendered) {
      [
        '',
        'Given(/^the color (.*)$/, function (color) {',
        '    return actionwords.theColorColor(color);',
        '});'
      ].join("\n")
    }

    let(:rendered_empty_scenario) {"\nScenario: Empty Scenario\n"}
  end
end
