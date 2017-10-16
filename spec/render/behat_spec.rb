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
        '',
        '  /**',
        '   * @Given /^I am on the "(.*)" home page$/',
        '   */',
        '  public function iAmOnTheSiteHomePage($site, PyStringNode $__free_text){',
        '    $this->actionwords->iAmOnTheSiteHomePage($site, $__free_text);',
        '  }',
        '',
        '  /**',
        '   * @When /^the following users are available on "(.*)"$/',
        '   */',
        '  public function theFollowingUsersAreAvailableOnSite($site, TableNode $__datatable){',
        '    $this->actionwords->theFollowingUsersAreAvailableOnSite($site, $__datatable);',
        '  }',
        '',
        '  /**',
        '   * @Given /^an untrimed action word$/',
        '   */',
        '  public function anUntrimedActionWord(){',
        '    $this->actionwords->anUntrimedActionWord();',
        '  }',
        '',
        '  /**',
        '   * @Given /^the "(.*)" of "(.*)" is weird "(.*)" "(.*)"$/',
        '   */',
        '  public function theOrderOfParametersIsWeird($order, $parameters, $p0, $p1){',
        '    $this->actionwords->theOrderOfParametersIsWeird($p0, $p1, $parameters, $order);',
        '  }',
        '',
        '  /**',
        '   * @Given /^I login on "(.*)" "(.*)"$/',
        '   */',
        '  public function iLoginOn($site, $username){',
        '    $this->actionwords->iLoginOn($site, $username);',
        '  }',
        '}',
        '?>'
      ].join("\n")
    }

    let(:rendered_free_texted_actionword) {[
      'public function theFollowingUsersAreAvailable(PyStringNode $__free_text) {',
      '',
      '}'].join("\n")}

    let(:rendered_datatabled_actionword) {[
      'public function theFollowingUsersAreAvailable(TableNode $__datatable) {',
      '',
      '}'].join("\n")}

    let(:rendered_empty_scenario) { "\nScenario: Empty Scenario\n" }
  end
end
