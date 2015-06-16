require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher'
require_relative '../lib/hiptest-publisher/nodes'
require_relative '../lib/hiptest-publisher/gherkin_adder'


describe 'Cucumber rendering' do
  include HelperFactories

  # Note: we do not want to test everything as we'll only render
  # tests and calls.

  let(:actionwords) {
    [
      make_actionword("the color \"color\"", [], [make_parameter("color")]),
      make_actionword("you mix colors"),
      make_actionword("you obtain \"color\"", [], [make_parameter("color")]),
      make_actionword("unused action word"),
    ]
  }

  let(:create_white_test) {
    make_test("Create white", [], [
      make_annotated_call("given", "the color \"color\"", [make_argument("color", template_of_literals("blue"))]),
      make_annotated_call(  "and", "the color \"color\"", [make_argument("color", template_of_literals("red"))]),
      make_annotated_call(  "and", "the color \"color\"", [make_argument("color", template_of_literals("green"))]),
      make_annotated_call( "when", "you mix colors"),
      make_annotated_call( "then", "you obtain \"color\"", [make_argument("color", template_of_literals("white"))]),
    ])
  }

  let(:create_green_scenario) {
    make_scenario("Create green", [], [], [
      make_annotated_call("given", "the color \"color\"", [make_argument("color", template_of_literals("blue"))]),
      make_annotated_call(  "and", "the color \"color\"", [make_argument("color", template_of_literals("yellow"))]),
      make_annotated_call( "when", "you mix colors"),
      make_annotated_call( "then", "you obtain \"color\"", [make_argument("color", template_of_literals("green"))]),
    ])
  }

  let(:create_secondary_colors_scenario) {
    make_scenario("Create secondary colors", [], [
        make_parameter("first_color"),
        make_parameter("second_color"),
        make_parameter("got_color"),
      ], [
        make_annotated_call("given", "the color \"color\"", [make_argument("color", variable("first_color"))]),
        make_annotated_call(  "and", "the color \"color\"", [make_argument("color", variable("second_color"))]),
        make_annotated_call( "when", "you mix colors"),
        make_annotated_call( "then", "you obtain \"color\"", [make_argument("color", variable("got_color"))]),
    ]).tap do |scenario|
      scenario.children[:datatable] = Hiptest::Nodes::Datatable.new([
        Hiptest::Nodes::Dataset.new("Mix to green", [
          make_argument("first_color", template_of_literals("blue")),
          make_argument("second_color", template_of_literals("yellow")),
          make_argument("got_color", template_of_literals("green")),
        ]),
        Hiptest::Nodes::Dataset.new("Mix to orange", [
          make_argument("first_color", template_of_literals("yellow")),
          make_argument("second_color", template_of_literals("red")),
          make_argument("got_color", template_of_literals("orange")),
        ]),
        Hiptest::Nodes::Dataset.new("Mix to purple", [
          make_argument("first_color", literal("red")),
          make_argument("second_color", literal("blue")),
          make_argument("got_color", literal("purple")),
        ]),
      ])
    end
  }

  let!(:project) {
    make_project("Colors",
      [create_green_scenario, create_secondary_colors_scenario],
      [create_white_test],
      actionwords
    ).tap do |p|
      Hiptest::Nodes::ParentAdder.add(p)
      Hiptest::GherkinAdder.add(p)
    end
  }

  let(:options) {
    {
      ignore_unknown_templates: true,
      forced_templates: {
        'scenario' => 'single_scenario',
        'test' => 'single_test',
      }
    }
  }

  context 'Test' do
    it 'generates an feature file' do
      rendered = create_white_test.render('cucumber', options)
      expect(rendered).to eq([
        "Scenario: Create white",
        "  Given the color \"blue\"",
        "  And the color \"red\"",
        "  And the color \"green\"",
        "  When you mix colors",
        "  Then you obtain \"white\"",
        "",
      ].join("\n"))
    end
  end

  context 'Scenario' do
    it 'generates a feature file' do
      rendered = create_green_scenario.render('cucumber', options)
      expect(rendered).to eq([
        "Feature: Create green",
        "",
        "  Scenario: Create green",
        "    Given the color \"blue\"",
        "    And the color \"yellow\"",
        "    When you mix colors",
        "    Then you obtain \"green\"",
        "",
      ].join("\n"))
    end
  end

  context 'Scenario with datatable' do
    it 'generates a feature file with an Examples section' do
      rendered = create_secondary_colors_scenario.render('cucumber', options)
      expect(rendered).to eq([
        "Feature: Create secondary colors",
        "",
        "  Scenario Outline: Create secondary colors",
        "    Given the color \"<first_color>\"",
        "    And the color \"<second_color>\"",
        "    When you mix colors",
        "    Then you obtain \"<got_color>\"",
        "",
        "    Examples:",
        "      | first_color | second_color | got_color |",
        "      | blue | yellow | green |",
        "      | yellow | red | orange |",
        "      | red | blue | purple |",
        "",
      ].join("\n"))
    end
  end

  context 'Actionwords' do
    it 'generates an steps ruby file' do
      rendered = project.children[:actionwords].render('cucumber', options)
      expect(rendered).to eq([
        "# encoding: UTF-8",
        "",
        "Given /^the color \"(.*)\"$/ do |color|",
        "  the_color_color(color)",
        "end",
        "",
        "When /^you mix colors$/ do",
        "  you_mix_colors",
        "end",
        "",
        "Then /^you obtain \"(.*)\"$/ do |color|",
        "  you_obtain_color(color)",
        "end",
        "",
      ].join("\n"))
    end
  end
end
