require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Behat rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'behat'}

    let(:rendered_actionwords) {
      [
        'use Behat\Behat\Tester\Exception\PendingException;',
        'use Behat\Behat\Context\SnippetAcceptingContext;',
        'use Behat\Gherkin\Node\PyStringNode;',
        'use Behat\Gherkin\Node\TableNode;',
        '',
        'class FeatureContext implements SnippetAcceptingContext {',
        '',
        '',
        '  /**',
        '   * @Given /^the color "(.*)"$/',
        '   */',
        '  public function theColorColor($color){',
        '    $this->actionwords->theColorColor($color)',
        '  }',
        '',
        '  /**',
        '   * @When /^you mix colors$/',
        '   */',
        '  public function youMixColors(){',
        '    $this->actionwords->youMixColors()',
        '  }',
        '',
        '  /**',
        '   * @Then /^you obtain "(.*)"$/',
        '   */',
        '  public function youObtainColor($color){',
        '    $this->actionwords->youObtainColor($color)',
        '  }',
        '}',
      ].join("\n")
    }
  end
end
