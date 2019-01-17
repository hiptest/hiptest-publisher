require_relative '../spec_helper'
require_relative '../render_shared'

describe 'JBehave rendering' do
  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: false do
    let(:language) {'jbehave'}
    let(:features_option_name) { "stories" }

    let(:rendered_actionwords) {
      [
        %|package com.example;|,
        %||,
        %|import org.jbehave.core.annotations.*;|,
        %|import org.jbehave.core.model.ExamplesTable;|,
        %||,
        %|public class StepDefinitions {|,
        %|    public Actionwords actionwords;|,
        %||,
        %|    @BeforeScenario|,
        %|    public void beforeEachScenario() {|,
        %|        actionwords = new Actionwords();|,
        %|    }|,
        %||,
        %|    @Given("the color \\"$color\\"")|,
        %|    public void theColorColor(String color) {|,
        %|        actionwords.theColorColor(color);|,
        %|    }|,
        %||,
        %|    @When("you mix colors")|,
        %|    public void youMixColors() {|,
        %|        actionwords.youMixColors();|,
        %|    }|,
        %||,
        %|    @Then("you obtain \\"$color\\"")|,
        %|    public void youObtainColor(String color) {|,
        %|        actionwords.youObtainColor(color);|,
        %|    }|,
        %||,
        %||,
        %|    @Then("you cannot play croquet")|,
        %|    public void youCannotPlayCroquet() {|,
        %|        actionwords.youCannotPlayCroquet();|,
        %|    }|,
        %||,
        %|    @Given("I am on the \\"$site\\" home page \\"\\"\\"$freeText\\"\\"\\"")|,
        %|    public void iAmOnTheSiteHomePage(String site, String freeText) {|,
        %|        actionwords.iAmOnTheSiteHomePage(site, freeText);|,
        %|    }|,
        %||,
        %|    @When("the following users are available on \\"$site\\" $datatable")|,
        %|    public void theFollowingUsersAreAvailableOnSite(String site, ExamplesTable datatable) {|,
        %|        actionwords.theFollowingUsersAreAvailableOnSite(site, datatable);|,
        %|    }|,
        %||,
        %|    @Given("an untrimed action word")|,
        %|    public void anUntrimedActionWord() {|,
        %|        actionwords.anUntrimedActionWord();|,
        %|    }|,
        %||,
        %|    @Given("the \\"$order\\" of \\"$parameters\\" is weird \\"$p0\\" \\"$p1\\"")|,
        %|    public void theOrderOfParametersIsWeird(String order, String parameters, String p0, String p1) {|,
        %|        actionwords.theOrderOfParametersIsWeird(p0, p1, parameters, order);|,
        %|    }|,
        %||,
        %|    @Given("I login on \\"$site\\" \\"$username\\"")|,
        %|    public void iLoginOn(String site, String username) {|,
        %|        actionwords.iLoginOn(site, username);|,
        %|    }|,
        %|}|
      ].join("\n")
    }

    let(:actionword_without_quotes_in_regexp_rendered) {
      [
        '@Given("the color $color")',
        'public void theColorColor(String color) {',
        '    actionwords.theColorColor(color);',
        '}',
        ''
      ].join("\n")
    }

    let(:rendered_free_texted_actionword) {[
      %|public void theFollowingUsersAreAvailable(String freeText) {|,
      %||,
      %|}|
    ].join("\n")}

    let(:rendered_datatabled_actionword) {[
      %|public void theFollowingUsersAreAvailable(ExamplesTable datatable) {|,
      %||,
      %|}|
    ].join("\n")}

    let(:rendered_empty_scenario) { "" }

      let(:scenario_tag_rendered) {
        [
          'Scenario: Create purple',
          'Meta:',
          '@myTag @myTag-some_value',
          'You can have a description',
          'on multiple lines',
          'Given the color "blue"',
          'And the color "red"',
          'When you mix colors',
          'Then you obtain "purple"',
          ''
        ].join("\n")
      }

      let(:folder_tag_rendered) {
        [
          'Cool colors',
          'Meta:',
          '@myTag @myTag-some_value @JIRA-CW-6',
          '',
          'Narrative:',
          'Cool colors calm and relax.',
          'They are the hues from blue green through blue violet, most grays included.',
          '',
          'Scenario: Create green',
          'You can create green by mixing other colors',
          'Given the color "blue"',
          'And the color "yellow"',
          'When you mix colors',
          'Then you obtain "green"',
          'But you cannot play croquet',
          '',
          'Scenario: Create purple',
          'You can have a description',
          'on multiple lines',
          'Given the color "blue"',
          'And the color "red"',
          'When you mix colors',
          'Then you obtain "purple"',
          '',
          ''
        ].join("\n")
      }

      let(:inherited_tags_rendered) {
        [
          'Sub-sub-regression folder',
          'Meta:',
          '@simple @key-value',
          '',
          '',
          'Scenario: Inherit tags',
          'Meta:',
          '@my-own',
          'Given the color "<color_definition>"',
          '',
          ''
        ].join("\n")
      }

      let(:feature_with_no_parent_folder_tags_rendered) {
        [
          'Sub-sub-regression folder',
          'Meta:',
          '@key-value',
          '',
          '',
          'Scenario: Inherit tags',
          'Meta:',
          '@my-own',
          'Given the color "<color_definition>"',
          '',
          ''
        ].join("\n")
      }

      let(:test_rendered) {
        [
          "Scenario: Create white",
          "Given the color \"blue\"",
          "And the color \"red\"",
          "And the color \"green\"",
          "When you mix colors",
          "Then you obtain \"white\"",
          "",
        ].join("\n")
      }

      let(:scenario_rendered) {
        [
          "Scenario: Create green",
          'You can create green by mixing other colors',
          "Given the color \"blue\"",
          "And the color \"yellow\"",
          "When you mix colors",
          "Then you obtain \"green\"",
          "But you cannot play croquet",
          ""
        ].join("\n")
      }

      let(:scenario_with_uid_rendered) {
        [
          "Scenario: Create green (uid:1234-4567)",
          'You can create green by mixing other colors',
          "Given the color \"blue\"",
          "And the color \"yellow\"",
          "When you mix colors",
          "Then you obtain \"green\"",
          "But you cannot play croquet",
          ""
        ].join("\n")
      }

      let(:scenario_without_annotations_rendered) {
        [
          "Scenario: Create orange",
          "* the color \"red\"",
          "* the color \"yellow\"",
          "* you mix colors",
          "* you obtain \"orange\"",
          "",
        ].join("\n")
      }

      let(:scenario_with_datatable_rendered) {
        [
          "Scenario: Create secondary colors#{outline_title_ending}",
          "This scenario has a datatable and a description",
          "Given the color \"<first_color>\"",
          "And the color \"<second_color>\"",
          "When you mix colors",
          "Then you obtain \"<got_color>\"",
          "",
          "Examples:",
          "| first_color | second_color | got_color | priority | hiptest-uid |",
          "| blue | yellow | green | -1 |  |",
          "| yellow | red | orange | 1 |  |",
          "| red | blue | purple | true |  |",
          "",
        ].join("\n")
      }

      let(:scenario_with_datatable_and_dataset_names_rendered) {
        [
          "Scenario: Create secondary colors#{outline_title_ending}",
          "This scenario has a datatable and a description",
          "Given the color \"<first_color>\"",
          "And the color \"<second_color>\"",
          "When you mix colors",
          "Then you obtain \"<got_color>\"",
          "",
          "Examples:",
          "| dataset name | first_color | second_color | got_color | priority | hiptest-uid |",
          "| Mix to green | blue | yellow | green | -1 |  |",
          "| Mix to orange | yellow | red | orange | 1 |  |",
          "| Mix to purple | red | blue | purple | true |  |",
          "",
        ].join("\n")
      }

      let(:scenario_with_datatable_rendered_with_uids_in_outline) {
        [
          "Scenario: Create secondary colors (<hiptest-uid>)",
          "This scenario has a datatable and a description",
          "Given the color \"<first_color>\"",
          "And the color \"<second_color>\"",
          "When you mix colors",
          "Then you obtain \"<got_color>\"",
          "",
          "Examples:",
          "| first_color | second_color | got_color | priority | hiptest-uid |",
          "| blue | yellow | green | -1 | uid:1234 |",
          "| yellow | red | orange | 1 |  |",
          "| red | blue | purple | true | uid:5678 |",
          "",
        ].join("\n")
      }

      let(:scenario_with_datatable_rendered_with_uids) {
        [
          "Scenario: Create secondary colors (uid:abcd-efgh)",
          "This scenario has a datatable and a description",
          "Given the color \"<first_color>\"",
          "And the color \"<second_color>\"",
          "When you mix colors",
          "Then you obtain \"<got_color>\"",
          "",
          "Examples:",
          "| first_color | second_color | got_color | priority | hiptest-uid |",
          "| blue | yellow | green | -1 | uid:1234 |",
          "| yellow | red | orange | 1 |  |",
          "| red | blue | purple | true | uid:5678 |",
          "",
        ].join("\n")
      }

      let(:scenario_with_freetext_argument_rendered) {
        [
          'Scenario: Open a site with comments',
          'When I am on the "http://google.com" home page',
          '"""',
          "Some explanations when opening the site:",
          " - for example one explanation",
          " - and another one",
          '"""',
          'Then stuff happens',
          ''
        ].join("\n")
      }

      let(:scenario_with_datatable_argument_rendered) {
        [
          'Scenario: Check users',
          'When the following users are available on "http://google.com"',
          '| name  | password |',
          '| bob   | plopi    |',
          '| alice | dou      |',
          'Then stuff happens',
          ''
        ].join("\n")
      }

      let(:scenario_using_variables_in_step_datatables_rendered) {
        [
          "Scenario: Check users#{outline_title_ending}",
          'When I login as',
          '| <username> |',
          'Then I am logged in as',
          '"""',
          ' -: <username> :- ',
          '"""',
          '',
          'Examples:',
          '| username | hiptest-uid |',
          '| user@example.com |  |',
          ''
        ].join("\n")
      }

      let(:scenario_with_double_quotes_in_datatable_rendered) {
        [
          "Scenario: Double quote in datatable#{outline_title_ending}",
          'Given the color "<color_definition>"',
          '',
          'Examples:',
          '| color_definition | hiptest-uid |',
          '| {"html": ["#008000", "#50D050"]} |  |',
          '| {"html": ["#D14FD1"]} |  |',
          ''
          ].join("\n")
      }

      let(:scenario_with_capital_parameters_rendered) {
        [
          "Scenario: Validate Nav#{outline_title_ending}",
          'Given I am on the "<SITE_NAME>" home page',
          '',
          'Examples:',
          '| SITE_NAME | hiptest-uid |',
          '| http://google.com |  |',
          ''
          ].join("\n")
      }

      let(:scenario_with_incomplete_datatable_rendered) {
        [
          "Scenario: Incomplete datatable#{outline_title_ending}",
          'Given the color "<first_color>"',
          'And the color "<second_color>"',
          'When you mix colors',
          'Then you obtain "<got_color>"',
          '',
          'Examples:',
          '| first_color | second_color | got_color | hiptest-uid |',
          '| blue | yellow | green |  |',
          '| yellow | red |  |  |',
          '| red |  |  |  |',
          ''
          ].join("\n")
      }

      let(:scenario_calling_untrimed_actionword_rendered) {
        [
           'Scenario: Calling an untrimed action word',
           'Given an untrimed action word',
           ''
           ].join("\n")
       }

       let(:scenario_calling_actionwords_with_extra_params_rendered) {
        [
           'Scenario: Calling an action word with not inlined parameters',
           'Given I login on "preview" "Vincent"',
           ''
           ].join("\n")
       }

      let(:scenario_rendered_without_quotes_around_parameters) {
        [
          'Scenario: Create purple',
          'You can have a description',
          'on multiple lines',
          'Given the color blue',
          'And the color red',
          'When you mix colors',
          'Then you obtain purple',
          ''
        ].join("\n")
      }

      let(:scenario_rendered_with_dollars_around_parameters) {
        # Because why not after all ?
        [
          'Scenario: Create purple',
          'You can have a description',
          'on multiple lines',
          'Given the color $blue$',
          'And the color $red$',
          'When you mix colors',
          'Then you obtain $purple$',
          ''
        ].join("\n")
      }

      let(:scenario_with_steps_annotation_in_description_rendered) {
        [
          'Scenario: Steps annotation in description',
          'First line',
          '"Given a line with steps annotation"',
          'Third line',
          '',
          '"# this line shoud be protected"',
          '" AND this one should be"',
          'Given one step',
          ''
        ].join("\n")
      }

       let(:feature_rendered_with_option_no_uid) {
        [
          "Scenario: Create secondary colors",
          "This scenario has a datatable and a description",
          "Given the color \"<first_color>\"",
          "And the color \"<second_color>\"",
          "When you mix colors",
          "Then you obtain \"<got_color>\"",
          "",
          "Examples:",
          "| first_color | second_color | got_color | priority |",
          "| blue | yellow | green | -1 |",
          "| yellow | red | orange | 1 |",
          "| red | blue | purple | true |",
          "",
          ].join("\n")
      }

      let(:scenario_rendered_with_option_no_uid) {
        [
          "Scenario: Create secondary colors",
          "This scenario has a datatable and a description",
          "Given the color \"<first_color>\"",
          "And the color \"<second_color>\"",
          "When you mix colors",
          "Then you obtain \"<got_color>\"",
          "",
          ].join("\n")
      }

      let(:feature_with_setup_rendered) {
        [
          'Other colors',
          '',
          '',
          'Lifecycle:',
          'Before:',
          'Scope: SCENARIO',
          'Given I have colors to mix',
          'And I know the expected color',
          '',
          "Scenario: Create secondary colors#{outline_title_ending}",
          'This scenario has a datatable and a description',
          'Given the color "<first_color>"',
          'And the color "<second_color>"',
          'When you mix colors',
          'Then you obtain "<got_color>"',
          '',
          'Examples:',
          '| first_color | second_color | got_color | priority | hiptest-uid |',
          '| blue | yellow | green | -1 |  |',
          '| yellow | red | orange | 1 |  |',
          '| red | blue | purple | true |  |',
          '',
          ''
          ].join("\n")
      }

      let(:feature_with_scenario_tag_rendered) {
        [
          'Cool colors',
          'Meta:',
          '@myTag',
          'Narrative:',
          'Cool colors calm and relax.',
          'They are the hues from blue green through blue violet, most grays included.',
          '',
          'Scenario: Create green',
          'You can create green by mixing other colors',
          'Given the color "blue"',
          'And the color "yellow"',
          'When you mix colors',
          'Then you obtain "green"',
          'But you cannot play croquet',
          '',
          'Scenario: Create purple',
          'You can have a description',
          'on multiple lines',
          'Given the color "blue"',
          'And the color "red"',
          'When you mix colors',
          'Then you obtain "purple"',
          '',
          ''
          ].join("\n")
      }
  end
end