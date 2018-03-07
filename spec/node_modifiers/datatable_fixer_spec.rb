require_relative "../spec_helper"
require_relative "../../lib/hiptest-publisher/node_modifiers/datatable_fixer"

describe Hiptest::NodeModifiers::DatatableFixer do
  include HelperFactories

  let(:scenario) {
    make_scenario("Incomplete datatable",
      folder: nil,
      parameters: [
        make_parameter("first_color"),
        make_parameter("second_color"),
        make_parameter("got_color"),
      ],
      body: [
        make_call("the color \"color\"",  annotation: "given", arguments: [make_argument("color", variable("first_color"))]),
        make_call("the color \"color\"",  annotation: "and", arguments: [make_argument("color", variable("second_color"))]),
        make_call("you mix colors",       annotation: "when"),
        make_call("you obtain \"color\"", annotation: "then", arguments: [make_argument("color", variable("got_color"))]),
      ],
      datatable: Hiptest::Nodes::Datatable.new([
        Hiptest::Nodes::Dataset.new("Mix to green", [
          make_argument("first_color", template_of_literals("blue")),
          make_argument("second_color", template_of_literals("yellow")),
          make_argument("got_color", template_of_literals("green")),
        ]),
        Hiptest::Nodes::Dataset.new("Mix to orange", [
          make_argument("first_color", template_of_literals("yellow")),
          make_argument("second_color", template_of_literals("red"))
        ]),
        Hiptest::Nodes::Dataset.new("Mix to purple", [
          make_argument("first_color", template_of_literals("red"))
        ]),
      ]))
  }

  let(:bad_order) {
    make_scenario("Wrong order in datatable",
      folder: nil,
      parameters: [
        make_parameter("first_color"),
        make_parameter("second_color"),
        make_parameter("got_color"),
      ],
      body: [
        make_call("the color \"color\"",  annotation: "given", arguments: [make_argument("color", variable("first_color"))]),
        make_call("the color \"color\"",  annotation: "and", arguments: [make_argument("color", variable("second_color"))]),
        make_call("you mix colors",       annotation: "when"),
        make_call("you obtain \"color\"", annotation: "then", arguments: [make_argument("color", variable("got_color"))]),
      ],
      datatable: Hiptest::Nodes::Datatable.new([
        Hiptest::Nodes::Dataset.new("Mix to green", [
          make_argument("first_color", template_of_literals("blue")),
          make_argument("second_color", template_of_literals("yellow")),
          make_argument("got_color", template_of_literals("green")),
        ]),
        Hiptest::Nodes::Dataset.new("Mix to orange", [
          make_argument("second_color", template_of_literals("red")),
          make_argument("first_color", template_of_literals("yellow")),
          make_argument("got_color", template_of_literals("orange"))
        ]),
        Hiptest::Nodes::Dataset.new("Mix to purple", [
          make_argument("second_color", template_of_literals("blue")),
          make_argument("got_color", template_of_literals("purple")),
          make_argument("first_color", template_of_literals("red"))
        ]),
      ]))
  }

  it 'fills unset cells with an empty string' do
    Hiptest::NodeModifiers::DatatableFixer.new.walk_scenario(scenario)

    expected = [
      [
        {type: Hiptest::Nodes::Template, value: ['blue']},
        {type: Hiptest::Nodes::Template, value: ['yellow']},
        {type: Hiptest::Nodes::Template, value: ['green']}
      ],
      [
        {type: Hiptest::Nodes::Template, value: ['yellow']},
        {type: Hiptest::Nodes::Template, value: ['red']},
        {type: Hiptest::Nodes::StringLiteral, value: ''}
      ],
      [
        {type: Hiptest::Nodes::Template, value: ['red']},
        {type: Hiptest::Nodes::StringLiteral, value: ''},
        {type: Hiptest::Nodes::StringLiteral, value: ''}
      ]
    ]

    scenario.children[:datatable].children[:datasets].each_with_index do |dataset, dataset_index|
      dataset.children[:arguments].each_with_index do |argument, argument_index|
        value = argument.children[:value]
        expected_value = expected[dataset_index][argument_index]

        expect(value).to be_a(expected_value[:type])

        if (value).is_a? Hiptest::Nodes::Template
          expect(value.children[:chunks].map {|chunk| chunk.children[:value]}).to eq(expected_value[:value])
        else
          expect(value.children[:value]).to eq(expected_value[:value])
        end
      end
    end
  end

  it 'reorders arguments if needed' do
    Hiptest::NodeModifiers::DatatableFixer.new.walk_scenario(bad_order)

    bad_order.children[:datatable].children[:datasets].map do |dataset|
      expect(dataset.children[:arguments].map {|arg| arg.children[:name]}).to eq(['first_color', 'second_color', 'got_color'])
    end
  end
end
