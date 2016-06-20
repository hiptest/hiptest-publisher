require_relative 'spec_helper'

shared_examples 'actionword' do
  it 'simple' do
    node = build_node(actionword_maker('a simple actionword'))

    expect(node).to be_a(Hiptest::Nodes::Actionword)
    expect(node.children[:name]).to eq('a simple actionword')
    expect(node.children[:tags]).to eq([])
    expect(node.children[:parameters]).to eq([])
    expect(node.children[:body]).to eq([])
  end

  it 'with tags' do
    node = build_node(actionword_maker('tagged', [@simple_tag, @key_value_tag]))

    expect(node).to be_a(Hiptest::Nodes::Actionword)
    expect(node.children[:tags].length).to eq(2)
    expect(node.children[:tags][0]).to be_a(Hiptest::Nodes::Tag)
    expect(node.children[:tags][1]).to be_a(Hiptest::Nodes::Tag)
  end

  it 'with parameters' do
    node = build_node(
      actionword_maker(
        'parameterized', [], [@simple_parameter, @valued_parameter]
        )
    )

    expect(node).to be_a(Hiptest::Nodes::Actionword)
    expect(node.children[:parameters].length).to eq(2)
    expect(node.children[:parameters][0]).to be_a(Hiptest::Nodes::Parameter)
    expect(node.children[:parameters][1]).to be_a(Hiptest::Nodes::Parameter)
  end

  it 'with steps' do
    node = build_node(
      actionword_maker('with steps', [], [], [@action_step, @result_step]))

    expect(node).to be_a(Hiptest::Nodes::Actionword)
    expect(node.children[:body].length).to eq(2)
    expect(node.children[:body][0]).to be_a(Hiptest::Nodes::Step)
    expect(node.children[:body][1]).to be_a(Hiptest::Nodes::Step)
  end

  it 'with description' do
    node = build_node(
      actionword_maker('my action word', [], [], [], 'Here is some description'))

    expect(node).to be_a(Hiptest::Nodes::Actionword)
    expect(node.children[:description]).to eq('Here is some description')
  end
end

shared_examples 'scenario' do
  it 'simple' do
    node = build_node(scenario_maker('a simple scenario', 'Some description'))

    expect(node).to be_a(Hiptest::Nodes::Scenario)
    expect(node.children[:name]).to eq('a simple scenario')
    expect(node.children[:description]).to eq('Some description')
    expect(node.children[:tags]).to eq([])
    expect(node.children[:parameters]).to eq([])
    expect(node.children[:body]).to eq([])
  end

  it 'with tags' do
    node = build_node(scenario_maker('tagged', '', [@simple_tag, @key_value_tag]))

    expect(node).to be_a(Hiptest::Nodes::Scenario)
    expect(node.children[:tags].length).to eq(2)
    expect(node.children[:tags][0]).to be_a(Hiptest::Nodes::Tag)
    expect(node.children[:tags][1]).to be_a(Hiptest::Nodes::Tag)
  end

  it 'with parameters' do
    node = build_node(
      scenario_maker(
        'parameterized', '', [], [@simple_parameter, @valued_parameter]
        )
    )

    expect(node).to be_a(Hiptest::Nodes::Scenario)
    expect(node.children[:parameters].length).to eq(2)
    expect(node.children[:parameters][0]).to be_a(Hiptest::Nodes::Parameter)
    expect(node.children[:parameters][1]).to be_a(Hiptest::Nodes::Parameter)
  end

  it 'with steps' do
    node = build_node(
      scenario_maker('with steps', '', [], [], [@action_step, @result_step]))

    expect(node).to be_a(Hiptest::Nodes::Scenario)
    expect(node.children[:body].length).to eq(2)
    expect(node.children[:body][0]).to be_a(Hiptest::Nodes::Step)
    expect(node.children[:body][1]).to be_a(Hiptest::Nodes::Step)
  end

  it 'with a datatable' do
    node = build_node([
      '<scenario>',
      '  <name>In a folder</name>',
      '  <datatable>',
      '    <dataset>',
      '      <name>My first set</name>',
      '      <arguments>',
      '        <argument>',
      '          <name>x</name>',
      '          <value>',
      '            <numericliteral>1</numericliteral>',
      '          </value>',
      '        </argument>',
      '        <argument>',
      '          <name>y</name>',
      '          <value>',
      '            <stringliteral>1</stringliteral>',
      '          </value>',
      '        </argument>',
      '      </arguments>',
      '    </dataset>',
      '    <dataset>',
      '      <name>My second set</name>',
      '      <arguments>',
      '        <argument>',
      '          <name>x</name>',
      '          <value>',
      '            <numericliteral>15</numericliteral>',
      '          </value>',
      '        </argument>',
      '        <argument>',
      '          <name>y</name>',
      '          <value>',
      '            <stringliteral>Some value</stringliteral>',
      '          </value>',
      '        </argument>',
      '      </arguments>',
      '    </dataset>',
      '  </datatable>',
      '</scenario>'
    ].join("\n"))

    expect(node.children[:datatable]).to be_a(Hiptest::Nodes::Datatable)
    expect(node.each_sub_nodes(Hiptest::Nodes::Dataset).count).to eq(2)
  end
end

shared_examples 'actionwords' do
  it 'generates an ActionWord object' do
    node = build_node("<#{container_name}>#{actionword_maker('My actionword')}</#{container_name}>")

    expect(node).to be_a(Hiptest::Nodes::Actionwords)
    expect(node.children[:actionwords].length).to eq(1)
    expect(node.children[:actionwords][0]).to be_a(Hiptest::Nodes::Actionword)
  end
end

shared_examples 'scenarios' do
  it 'generates a Scenarios object' do
    node = build_node("<#{container_name}>#{scenario_maker('My scenario')}</#{container_name}>")

    expect(node).to be_a(Hiptest::Nodes::Scenarios)
    expect(node.children[:scenarios].length).to eq(1)
    expect(node.children[:scenarios][0]).to be_a(Hiptest::Nodes::Scenario)
  end
end

shared_examples 'folder structure' do
  let(:folder_def) {
    '<name>My folder</name><uid>1234</uid><parentUid>7894</parentUid>'
  }

  let(:folders_defs) {[
    '<name>my project</name><uid>123</uid>',
    '<name>Second subfolder</name><uid>456</uid><parentUid>123</parentUid>',
    '<name>First subfolder</name><uid>789</uid><parentUid>456</parentUid>'
  ]}

  it 'folder' do
    node = build_node("<#{folder_node_type}>#{folder_def}</#{folder_node_type}>")

    expect(node).to be_a(Hiptest::Nodes::Folder)
    expect(node.children).to eq({
      name: "My folder",
      description: nil,
      subfolders: [],
      scenarios: [],
      tags: [],
      body: []
    })
  end

  it 'reads the tags' do
    node = build_node(
      "<#{folder_node_type}>" \
      "  <name>My folder</name>" \
      "  <description>This is a description</description>" \
      "  <tags>" \
      "    <tag>" \
      "      <key>plic</key>" \
      "    </tag>" \
      "  </tags>" \
      "</#{folder_node_type}>")
    expect(node.children[:tags].length).to eq(1)
    expect(node.children[:tags].first).to be_a(Hiptest::Nodes::Tag)
    expect(node.children[:tags].first.children[:key]).to eq('plic')
  end

  it 'reads description tag' do
    node = build_node(
      "<#{folder_node_type}>" \
      "  <name>My folder</name>" \
      "  <description>This is a description</description>" \
      "</#{folder_node_type}>")
    expect(node.children[:description]).to eq("This is a description")

    node = build_node(
      "<#{folder_node_type}>" \
      "  <name>My folder</name>" \
      "</#{folder_node_type}>")
    expect(node.children[:description]).to be_nil
  end

  context 'testPlan' do
    let(:test_plan) {
      folders = folders_defs.map {|n| "<#{folder_node_type}>#{n}</#{folder_node_type}>"}.join("")
      build_node("<#{folder_container}>#{folders}</#{folder_container}>")
    }

    it 'stores all folders' do
      expect(test_plan).to be_a(Hiptest::Nodes::TestPlan)
      expect(test_plan.children[:folders].length).to eq(3)
      expect(test_plan.children[:folders].map(&:class).uniq).to eq([Hiptest::Nodes::Folder])
    end

    it 'updates references' do
      folders = test_plan.children[:folders]

      expect(folders[0].parent).to be(test_plan)
      expect(folders[0].children[:subfolders]).to match_array([folders[1]])

      expect(folders[1].parent).to eq(folders[0])
      expect(folders[1].children[:subfolders]).to match_array([folders[2]])

      expect(folders[2].parent).to eq(folders[1])
      expect(folders[2].children[:subfolders]).to match_array([])
    end
  end
end
