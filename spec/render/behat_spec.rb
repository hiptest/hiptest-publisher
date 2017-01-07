require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Behat rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'behat'}

    let(:rendered_actionwords) {
      [
        '<?php',
        '',
        'namespace Feature\Context;',
        '',
        'use Behat\Behat\Context\Context;',
        'use Behat\Behat\Tester\Exception\PendingException;',
        '',
        'abstract class Actionwords extends Context{',
        '',
        '  /**',
        '   * @Given /^the color "(.*)"$/',
        '   */',
        '  public function theColorColor($color){',
        '    throw new PendingException();',
        '  }',
        '',
        '  /**',
        '   * @When /^you mix colors$/',
        '   */',
        '  public function youMixColors(){',
        '    throw new PendingException();',
        '  }',
        '',
        '  /**',
        '   * @Then /^you obtain "(.*)"$/',
        '   */',
        '  public function youObtainColor($color){',
        '    throw new PendingException();',
        '  }',
        '',
        '',
        '',
        '  /**',
        '   * @But /^you cannot play croquet$/',
        '   */',
        '  public function youCannotPlayCroquet(){',
        '    throw new PendingException();',
        '  }',
        '',
        '  /**',
        '   * @Given /^I am on the "(.*)" home page$/',
        '   */',
        '  public function iAmOnTheSiteHomePage($site, PyStringNode $__free_text){',
        '    throw new PendingException();',
        '  }',
        '}',
      ].join("\n")
    }
  end
end
