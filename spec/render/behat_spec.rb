require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Behat rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'behat'}

    let(:rendered_actionwords) {
      [
        '<?php',
        'use Behat\Behat\Tester\Exception\PendingException;',
        'use Behat\Behat\Context\SnippetAcceptingContext;',
        'use Behat\Gherkin\Node\PyStringNode;',
        'use Behat\Gherkin\Node\TableNode;',
        '',
        "require_once('Actionwords.php');",
        '',
        'class FeatureContext implements SnippetAcceptingContext {',
        '  public function __construct() {',
        '    $this->actionwords = new Actionwords();',
        '  }',
        '',
        '',
        '  /**',
        '   * @Given /^the color "(.*)"$/',
        '   */',
        '  public function theColorColor($color){',
        '    $this->actionwords->theColorColor($color);',
        '  }',
        '',
        '  /**',
        '   * @When /^you mix colors$/',
        '   */',
        '  public function youMixColors(){',
        '    $this->actionwords->youMixColors();',
        '  }',
        '',
        '  /**',
        '   * @Then /^you obtain "(.*)"$/',
        '   */',
        '  public function youObtainColor($color){',
        '    $this->actionwords->youObtainColor($color);',
        '  }',
        '',
        '',
        '  /**',
        '   * @But /^you cannot play croquet$/',
        '   */',
        '  public function youCannotPlayCroquet(){',
        '    $this->actionwords->youCannotPlayCroquet();',
        '  }',
        '}',
        '?>'
      ].join("\n")
    }
  end
end
