require_relative "../spec_helper"
require_relative "../../lib/hiptest-publisher/node_modifiers/items_orderer"

describe Hiptest::NodeModifiers::ItemsOrderer do
  context 'orders items inside folders based on' do
    let(:project) {
      p = Hiptest::Nodes::Project.new(
        'My project',
        '',
        Hiptest::Nodes::TestPlan.new([
          Hiptest::Nodes::Folder.new('1', nil, "Root folder", ''),
          Hiptest::Nodes::Folder.new('2', '1', "First folder", '', [], 2),
          Hiptest::Nodes::Folder.new('3', '1', "Second folder", '', [], 1),
          Hiptest::Nodes::Folder.new('4', '1', "Ah ah third folder", '', [], 3)
        ]),
        Hiptest::Nodes::Scenarios.new([
          Hiptest::Nodes::Scenario.new('First scenario', '', [], [], [], '1', Hiptest::Nodes::Datatable.new(), 3),
          Hiptest::Nodes::Scenario.new('Das scenario', '', [], [], [], '1', Hiptest::Nodes::Datatable.new(), 1),
          Hiptest::Nodes::Scenario.new('My scenario', '', [], [], [], '1', Hiptest::Nodes::Datatable.new(), 4),
          Hiptest::Nodes::Scenario.new('Another scenario', '', [], [], [], '1', Hiptest::Nodes::Datatable.new(), 2)
        ])
      )

      p.children[:test_plan].organize_folders
      p.assign_scenarios_to_folders
      p
    }

    let(:root_folder) {project.children[:test_plan].children[:root_folder]}

    let(:root_folder_scenarios_names) {
      root_folder.children[:scenarios].map {|sc| sc.children[:name]}
    }

    let(:root_folder_subfolders_names) {
      root_folder.children[:subfolders].map {|f| f.children[:name]}
    }

    it 'its position in the XML file (using sort="id")' do
      Hiptest::NodeModifiers::ItemsOrderer.add(project, 'id')
      expect(root_folder_subfolders_names).to eq(['First folder', 'Second folder', 'Ah ah third folder'])
      expect(root_folder_scenarios_names).to eq(['First scenario', 'Das scenario', 'My scenario', 'Another scenario'])
    end

    it 'its name (using sort="alpha")' do
      Hiptest::NodeModifiers::ItemsOrderer.add(project, 'alpha')
      expect(root_folder_subfolders_names).to eq(['Ah ah third folder', 'First folder', 'Second folder'])
      expect(root_folder_scenarios_names).to eq(['Another scenario', 'Das scenario', 'First scenario', 'My scenario'])
    end

    it 'its order in Hiptest (using sort="order")' do
      Hiptest::NodeModifiers::ItemsOrderer.add(project, 'order')
      expect(root_folder_subfolders_names).to eq(['Second folder', 'First folder', 'Ah ah third folder'])
      expect(root_folder_scenarios_names).to eq(['Das scenario', 'Another scenario', 'First scenario', 'My scenario'])
    end

    it 'updates scenarios order if order is alpha' do
      expect(project.children[:scenarios].children[:scenarios].map {|sc| sc.children[:name]}).to eq([
        "First scenario", "Das scenario", "My scenario", "Another scenario"
      ])
      Hiptest::NodeModifiers::ItemsOrderer.add(project, 'alpha')

      expect(project.children[:scenarios].children[:scenarios].map {|sc| sc.children[:name]}).to eq([
        "Another scenario", "Das scenario", "First scenario", "My scenario"
      ])
    end
  end
end
