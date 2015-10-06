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
      make_actionword("the color \"color\"", parameters: [make_parameter("color")]),
      make_actionword("you mix colors"),
      make_actionword("you obtain \"color\"", parameters: [make_parameter("color")]),
      make_actionword("unused action word"),
    ]
  }

  let(:create_white_test) {
    make_test("Create white", body: [
      make_annotated_call("given", "the color \"color\"", [make_argument("color", template_of_literals("blue"))]),
      make_annotated_call(  "and", "the color \"color\"", [make_argument("color", template_of_literals("red"))]),
      make_annotated_call(  "and", "the color \"color\"", [make_argument("color", template_of_literals("green"))]),
      make_annotated_call( "when", "you mix colors"),
      make_annotated_call( "then", "you obtain \"color\"", [make_argument("color", template_of_literals("white"))]),
    ])
  }

  let(:create_green_scenario) {
    make_scenario("Create green", body: [
      make_annotated_call("given", "the color \"color\"", [make_argument("color", template_of_literals("blue"))]),
      make_annotated_call(  "and", "the color \"color\"", [make_argument("color", template_of_literals("yellow"))]),
      make_annotated_call( "when", "you mix colors"),
      make_annotated_call( "then", "you obtain \"color\"", [make_argument("color", template_of_literals("green"))]),
    ])
  }

  let(:unannotated_scenario) {
    make_scenario("Create orange", body: [
      make_call("the color \"color\"", arguments: [make_argument("color", template_of_literals("red"))]),
      make_call("the color \"color\"", arguments: [make_argument("color", template_of_literals("yellow"))]),
      make_call("you mix colors"),
      make_call("you obtain \"color\"", arguments: [make_argument("color", template_of_literals("orange"))]),
    ])
  }

  let(:create_secondary_colors_scenario) {
    make_scenario("Create secondary colors",
      parameters: [
        make_parameter("first_color"),
        make_parameter("second_color"),
        make_parameter("got_color"),
      ],
      body: [
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
      scenarios: [create_green_scenario, create_secondary_colors_scenario, unannotated_scenario],
      tests: [create_white_test],
      actionwords: actionwords
    ).tap do |p|
      Hiptest::Nodes::ParentAdder.add(p)
      Hiptest::GherkinAdder.add(p)
    end
  }

  let(:options) {
    context_for(
      only: "features",
      language: "cucumber",
      fallback_template: 'empty',
    )
  }

  subject(:rendered) { node_to_render.render(options) }

  context 'Test' do
    let(:node_to_render) { create_white_test }

    it 'generates an feature file' do
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
    let(:node_to_render) { scenario }
    let(:scenario) { create_green_scenario }

    it 'generates a feature file' do
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

    it 'appends the UID if known' do
      scenario.children[:uid] = '1234-4567'

      expect(rendered).to eq([
        "Feature: Create green",
        "",
        "  Scenario: Create green (uid:1234-4567)",
        "    Given the color \"blue\"",
        "    And the color \"yellow\"",
        "    When you mix colors",
        "    Then you obtain \"green\"",
        "",
      ].join("\n"))
    end

    context 'without annotated calls' do
      let(:scenario) { unannotated_scenario }

      it 'generates a feature file with bullet points steps' do
        expect(rendered).to eq([
          "Feature: Create orange",
          "",
          "  Scenario: Create orange",
          "    * the color \"red\"",
          "    * the color \"yellow\"",
          "    * you mix colors",
          "    * you obtain \"orange\"",
          "",
        ].join("\n"))
      end
    end

    context 'with datatable' do
      let(:scenario) { create_secondary_colors_scenario }

      it 'generates a feature file with an Examples section' do
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
          "      | first_color | second_color | got_color | hiptest-uid |",
          "      | blue | yellow | green |  |",
          "      | yellow | red | orange |  |",
          "      | red | blue | purple |  |",
          "",
        ].join("\n"))
      end

      it 'adds dataset UID as parameters if set (so they appear in output)' do
        datasets = scenario.children[:datatable].children[:datasets]
        datasets.first.children[:uid] = '1234'
        datasets.last.children[:uid] = '5678'

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
          "      | first_color | second_color | got_color | hiptest-uid |",
          "      | blue | yellow | green | uid:1234 |",
          "      | yellow | red | orange |  |",
          "      | red | blue | purple | uid:5678 |",
          "",
        ].join("\n"))
      end
    end
  end

  context 'Scenarios with split_scenarios = false' do
    let(:node_to_render) { project.children[:scenarios] }
    let(:options) {
      context_for(
        only: "features",
        language: "cucumber",
        fallback_template: 'empty',
      )
    }

    it 'generates a features.feature file asking to use --split-scenarios' do
      expect(rendered).to eq([
        "# To export your project to Cucumber correctly, please add the option",
        "# --split-scenarios when calling hiptest-publisher. It will generate one",
        "# feature file per scenario from your project.",
      ].join("\n"))
    end
  end

  context 'Actionwords' do
    let(:node_to_render) { project.children[:actionwords] }

    it 'generates an steps ruby file' do
      expect(rendered).to eq([
        "# encoding: UTF-8",
        "",
        "require_relative 'actionwords'",
        "World(Actionwords)",
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
