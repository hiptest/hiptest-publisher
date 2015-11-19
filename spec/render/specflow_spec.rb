require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Specflow rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'specflow'}

    let(:rendered_actionwords) {
      [
        'namespace  {',
        '',
        '    [Binding]',
        '    public class StepDefinitions {',
        '',
        '        [Given(@"^the color \"(.*)\"$")]',
        '        public void TheColorColor(string color) {',
        '            TheColorColor(string color);',
        '        }',
        '',
        '',
        '        [Given(@"^you mix colors$")]',
        '        public void YouMixColors() {',
        '            YouMixColors();',
        '        }',
        '',
        '',
        '        [Given(@"^you obtain \"(.*)\"$")]',
        '        public void YouObtainColor(string color) {',
        '            YouObtainColor(string color);',
        '        }',
        '',
        '',
        '        [Given(@"")]',
        '        public void UnusedActionWord() {',
        '            UnusedActionWord();',
        '        }',
        '    }',
        '}'
      ].join("\n")
    }
  end
end
