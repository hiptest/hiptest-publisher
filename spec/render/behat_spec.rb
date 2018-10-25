require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Behat rendering' do
  include_context "shared render"
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: false do
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
        '   * @Then /^you cannot play croquet$/',
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

    let(:actionword_without_quotes_in_regexp_rendered) {
      [
        '',
        '/**',
        ' * @Given /^the color (.*)$/',
        ' */',
        'public function theColorColor($color){',
        '  $this->actionwords->theColorColor($color);',
        '}'
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

  it_behaves_like 'a BDD renderer with library actionwords', uid_should_be_in_outline: true do
    let(:language) {'behat'}
    let(:framework) {''}

    let(:rendered_library_actionwords) {
      [
        '<?php',
        'use Behat\Behat\Tester\Exception\PendingException;',
        'use Behat\Behat\Context\SnippetAcceptingContext;',
        'use Behat\Gherkin\Node\PyStringNode;',
        'use Behat\Gherkin\Node\TableNode;',
        '',
        'require_once(\'Actionwords.php\');',
        '',
        'class DefaultFeatureContext implements SnippetAcceptingContext {',
        '  public function __construct() {',
        '    $this->actionwords = new Actionwords();',
        '  }',
        '',
        '',
        '  /**',
        '   * @Given /^My first action word$/',
        '   */',
        '  public function myFirstActionWord(){',
        '    $this->actionwords->getDefaultLibrary()->myFirstActionWord();',
        '  }',
        '}',
        '?>'
      ].join("\n")
    }
  end

  it_behaves_like 'a renderer handling libraries' do
    let(:language) {'behat'}
    let(:framework) {''}

    let(:actionwords_rendered) {
      [
        '<?php',
        'require_once(\'ActionwordLibrary.php\');',
        '',
        'class Actionwords extends ActionwordLibrary {',
        '  public function myProjectActionWord() {',
        '',
        '  }',
        '',
        '  public function myHighLevelProjectActionword() {',
        '    $this->myProjectActionWord();',
        '  }',
        '',
        '  public function myHighLevelActionword() {',
        '    $this->getDefaultLibrary()->myFirstActionWord();',
        '  }',
        '}',
        '?>'
      ].join("\n")
    }

    let(:libraries_rendered) {
      [
        '<?php',
        'require_once(\'DefaultLibrary.php\');',
        'require_once(\'WebLibrary.php\');',
        '',
        'class ActionwordLibrary {',
        '  public function getDefaultLibrary() {',
        '    return DefaultLibrary::getInstance();',
        '  }',
        '',
        '  public function getWebLibrary() {',
        '    return WebLibrary::getInstance();',
        '  }',
        '}',
        '?>'
      ].join("\n")
    }

    let(:first_lib_rendered) {
      [
        '<?php',
        'class DefaultLibrary {',
        '  private static $_instance = null;',
        '',
        '  private function __construct(){}',
        '',
        '  public static function getInstance(){',
        '    if (is_null(self::$_instance)) {',
        '      self::$_instance = new DefaultLibrary();',
        '    }',
        '    return self::$_instance;',
        '  }',
        '',
        '  public function myFirstActionWord() {',
        '    // Tags: priority:high wip',
        '  }',
        '}',
        '?>'
      ].join("\n")
    }

    let(:second_lib_rendered) {
      [
        '<?php',
        'class WebLibrary {',
        '  private static $_instance = null;',
        '',
        '  private function __construct(){}',
        '',
        '  public static function getInstance(){',
        '    if (is_null(self::$_instance)) {',
        '      self::$_instance = new WebLibrary();',
        '    }',
        '    return self::$_instance;',
        '  }',
        '',
        '  public function mySecondActionWord() {',
        '    // Tags: priority:low done',
        '  }',
        '}',
        '?>'
      ].join("\n")
    }
  end
end
