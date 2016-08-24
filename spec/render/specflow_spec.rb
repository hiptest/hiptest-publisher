require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Specflow rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'specflow'}

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
        '    }',
        '}'
      ].join("\n")
    }
  end
end
