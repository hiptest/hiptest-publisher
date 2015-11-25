require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Specflow rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'specflow'}

    let(:rendered_actionwords) {
      [
        'namespace Example {',
        '',
        '    [Binding]',
        '    public class StepDefinitions {',
        '',
        '        public Actionwords Actionwords = new Actionwords();',
        '',
        '        [Given(@"^the color \"(.*)\"$")]',
        '        public void TheColorColor(string color) {',
        '            Actionwords.TheColorColor(color);',
        '        }',
        '',
        '',
        '        [Given(@"^you mix colors$")]',
        '        public void YouMixColors() {',
        '            Actionwords.YouMixColors();',
        '        }',
        '',
        '',
        '        [Given(@"^you obtain \"(.*)\"$")]',
        '        public void YouObtainColor(string color) {',
        '            Actionwords.YouObtainColor(color);',
        '        }',
        '',
        '',
        '        [Given(@"")]',
        '        public void UnusedActionWord() {',
        '            Actionwords.UnusedActionWord();',
        '        }',
        '    }',
        '}'
      ].join("\n")
    }
  end
end
