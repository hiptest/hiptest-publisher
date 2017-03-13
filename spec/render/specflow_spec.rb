require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Specflow rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'specflow'}

    let(:scenario_tag_rendered) {
      [
        '',
        '@myTag @myTag_some_value',
        'Scenario: Create purple',
        '  # You can have a description',
        '  # on multiple lines',
        '  Given the color "blue"',
        '  And the color "red"',
        '  When you mix colors',
        '  Then you obtain "purple"',
        ''
      ].join("\n")
    }

    let(:folder_tag_rendered) {
      [
        '@myTag @myTag_some_value @JIRA_CW6',
        'Feature: Cool colors',
        '    Cool colors calm and relax.',
        '    They are the hues from blue green through blue violet, most grays included.',
        '',
        '  Scenario: Create green',
        '    # You can create green by mixing other colors',
        '    Given the color "blue"',
        '    And the color "yellow"',
        '    When you mix colors',
        '    Then you obtain "green"',
        '    But you cannot play croquet',
        '',
        '  Scenario: Create purple',
        '    # You can have a description',
        '    # on multiple lines',
        '    Given the color "blue"',
        '    And the color "red"',
        '    When you mix colors',
        '    Then you obtain "purple"',
        ''
      ].join("\n")
    }

    let(:inherited_tags_rendered) {
      [
        '@simple @key_value',
        'Feature: Sub-sub-regression folder',
        '',
        '',
        '  @my_own',
        '  Scenario: Inherit tags',
        '    Given the color "<color_definition>"',
        ''
      ].join("\n")
    }

    let(:rendered_actionwords) {
      [
        'namespace Example {',
        '    using System;',
        '    using TechTalk.SpecFlow;',
        '',
        '    [Binding]',
        '    public class StepDefinitions {',
        '',
        '        public Actionwords Actionwords = new Actionwords();',
        '',
        '        [Given("^the color \"(.*)\"$"), When("^the color \"(.*)\"$"), Then("^the color \"(.*)\"$")]',
        '        public void TheColorColor(string color) {',
        '            Actionwords.TheColorColor(color);',
        '        }',
        '',
        '',
        '        [Given("^you mix colors$"), When("^you mix colors$"), Then("^you mix colors$")]',
        '        public void YouMixColors() {',
        '            Actionwords.YouMixColors();',
        '        }',
        '',
        '',
        '        [Given("^you obtain \"(.*)\"$"), When("^you obtain \"(.*)\"$"), Then("^you obtain \"(.*)\"$")]',
        '        public void YouObtainColor(string color) {',
        '            Actionwords.YouObtainColor(color);',
        '        }',
        '',
        '',
        '        [Given(""), When(""), Then("")]',
        '        public void UnusedActionWord() {',
        '            Actionwords.UnusedActionWord();',
        '        }',
        '',
        '',
        '        [Given("^you cannot play croquet$"), When("^you cannot play croquet$"), Then("^you cannot play croquet$")]',
        '        public void YouCannotPlayCroquet() {',
        '            Actionwords.YouCannotPlayCroquet();',
        '        }',
        '',
        '',
        '        [Given("^I am on the \"(.*)\" home page$"), When("^I am on the \"(.*)\" home page$"), Then("^I am on the \"(.*)\" home page$")]',
        '        public void IAmOnTheSiteHomePage(string site, string freeText) {',
        '            Actionwords.IAmOnTheSiteHomePage(site, freeText);',
        '        }',
        '',
        '',
        '        [Given("^the following users are available on \"(.*)\"$"), When("^the following users are available on \"(.*)\"$"), Then("^the following users are available on \"(.*)\"$")]',
        '        public void TheFollowingUsersAreAvailableOnSite(string site, Table datatable) {',
        '            Actionwords.TheFollowingUsersAreAvailableOnSite(site, datatable);',
        '        }',
        '',
        '',
        '        [Given("^an untrimed action word$"), When("^an untrimed action word$"), Then("^an untrimed action word$")]',
        '        public void AnUntrimedActionWord() {',
        '            Actionwords.AnUntrimedActionWord();',
        '        }',
        '',
        '',
        '        [Given("^the \"(.*)\" of \"(.*)\" is weird \"(.*)\" \"(.*)\"$"), When("^the \"(.*)\" of \"(.*)\" is weird \"(.*)\" \"(.*)\"$"), Then("^the \"(.*)\" of \"(.*)\" is weird \"(.*)\" \"(.*)\"$")]',
        '        public void TheOrderOfParametersIsWeird(string order, string parameters, string p0, string p1) {',
        '            Actionwords.TheOrderOfParametersIsWeird(p0, p1, parameters, order);',
        '        }',
        '    }',
        '}'
      ].join("\n")
    }
  end
end
