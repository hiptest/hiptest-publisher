require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/project_grapher'

describe Hiptest::ProjectGrapher do
  let(:project) {
    Hiptest::Nodes::Project.new('My project', '')
  }

  let(:first_scenario) {
    Hiptest::Nodes::Scenario.new('My first scenario')
  }

  let(:second_scenario) {
    Hiptest::Nodes::Scenario.new('My second scenario')
  }

  let(:leaf) {
    Hiptest::Nodes::Actionword.new('My leaf actionword')
  }

  let(:first_level) {
    Hiptest::Nodes::Actionword.new('first level', [], [Hiptest::Nodes::Call.new('second level')])
  }

  let(:second_level) {
    Hiptest::Nodes::Actionword.new('second level', [], [Hiptest::Nodes::Call.new('My leaf actionword')])
  }


  def add_scenarios(scs)
    scs.each do |sc|
      project.children[:scenarios].children[:scenarios] << sc
    end
  end

  def add_aws(aws)
    aws.each do |aw|
      project.children[:actionwords].children[:actionwords] << aw
    end
  end

  context '#add_distances' do
    let(:graph) {
      grapher = Hiptest::ProjectGrapher.new(project)
      grapher.compute_graph
      grapher.add_distances
      grapher.graph
    }

    it 'on empty projects, the graph should only contain the root' do
      expect(graph).to eq({
        root: {
          calls: [],
          distance_from_root: 0
        }
      })
    end

    it 'considers scenarios with a distance of 1 from the root' do
      add_scenarios([first_scenario, second_scenario])

      expect(graph).to eq({
        "Hiptest::Nodes::Scenario-My first scenario" => {
          name: "Hiptest::Nodes::Scenario-My first scenario",
          item: first_scenario,
          calls: [],
          distance_from_root: 1
        },
        "Hiptest::Nodes::Scenario-My second scenario" => {
          name: "Hiptest::Nodes::Scenario-My second scenario",
          item: second_scenario,
          calls: [],
          distance_from_root: 1
        },
        :root => {
          calls: [
            "Hiptest::Nodes::Scenario-My first scenario",
            "Hiptest::Nodes::Scenario-My second scenario"
          ],
          distance_from_root: 0
        }
      })
    end

    it 'builds the distance based on the calls' do
      first_scenario.children[:body] << Hiptest::Nodes::Call.new('first level')

      add_aws([first_level, second_level, leaf])
      add_scenarios([first_scenario])

      expect(graph).to eq({
        "Hiptest::Nodes::Scenario-My first scenario" => {
          name: "Hiptest::Nodes::Scenario-My first scenario",
          item: first_scenario,
          calls: ['Hiptest::Nodes::Actionword-first level'],
          distance_from_root: 1
        },
        "Hiptest::Nodes::Actionword-first level" => {
          name: "Hiptest::Nodes::Actionword-first level",
          item: first_level,
          calls: ['Hiptest::Nodes::Actionword-second level'],
          distance_from_root: 2
        },
        "Hiptest::Nodes::Actionword-second level" => {
          name: "Hiptest::Nodes::Actionword-second level",
          item: second_level,
          calls: ['Hiptest::Nodes::Actionword-My leaf actionword'],
          distance_from_root: 3
        },
        "Hiptest::Nodes::Actionword-My leaf actionword" => {
          name: "Hiptest::Nodes::Actionword-My leaf actionword",
          item: leaf,
          calls: [],
          distance_from_root: 4
        },
        :root => {
          calls: ["Hiptest::Nodes::Scenario-My first scenario"],
          distance_from_root: 0
        }
      })
    end

    it 'uses the longest path to compute the distance' do
      first_scenario.children[:body] << Hiptest::Nodes::Call.new('first level')
      second_scenario.children[:body] << Hiptest::Nodes::Call.new('My leaf actionword')


      add_aws([first_level, second_level, leaf])
      add_scenarios([first_scenario, second_scenario])

      expect(graph).to eq({
        "Hiptest::Nodes::Scenario-My first scenario" => {
          name: "Hiptest::Nodes::Scenario-My first scenario",
          item: first_scenario,
          calls: ['Hiptest::Nodes::Actionword-first level'],
          distance_from_root: 1
        },
        "Hiptest::Nodes::Scenario-My second scenario" => {
          name: "Hiptest::Nodes::Scenario-My second scenario",
          item: second_scenario,
          calls: ['Hiptest::Nodes::Actionword-My leaf actionword'],
          distance_from_root: 1
        },
        "Hiptest::Nodes::Actionword-first level" => {
          name: "Hiptest::Nodes::Actionword-first level",
          item: first_level,
          calls: ['Hiptest::Nodes::Actionword-second level'],
          distance_from_root: 2
        },
        "Hiptest::Nodes::Actionword-second level" => {
          name: "Hiptest::Nodes::Actionword-second level",
          item: second_level,
          calls: ['Hiptest::Nodes::Actionword-My leaf actionword'],
          distance_from_root: 3
        },
        "Hiptest::Nodes::Actionword-My leaf actionword" => {
          name: "Hiptest::Nodes::Actionword-My leaf actionword",
          item: leaf,
          calls: [],
          distance_from_root: 4
        },
        :root => {
          calls: [
            "Hiptest::Nodes::Scenario-My first scenario",
            "Hiptest::Nodes::Scenario-My second scenario"
          ],
          distance_from_root: 0
        }
      })
    end

    it 'is not tricked by recursivity in calls' do
      first_scenario.children[:body] << Hiptest::Nodes::Call.new('first level')
      second_level.children[:body] << Hiptest::Nodes::Call.new('first level')

      add_aws([first_level, second_level, leaf])
      add_scenarios([first_scenario])

      expect(graph).to eq({
        "Hiptest::Nodes::Scenario-My first scenario" => {
          name: "Hiptest::Nodes::Scenario-My first scenario",
          item: first_scenario,
          calls: ['Hiptest::Nodes::Actionword-first level'],
          distance_from_root: 1
        },
        "Hiptest::Nodes::Actionword-first level" => {
          name: "Hiptest::Nodes::Actionword-first level",
          item: first_level,
          calls: ['Hiptest::Nodes::Actionword-second level'],
          distance_from_root: 2
        },
        "Hiptest::Nodes::Actionword-second level" => {
          name: "Hiptest::Nodes::Actionword-second level",
          item: second_level,
          calls: [
            'Hiptest::Nodes::Actionword-My leaf actionword',
            'Hiptest::Nodes::Actionword-first level'
          ],
          distance_from_root: 3
        },
        "Hiptest::Nodes::Actionword-My leaf actionword" => {
          name: "Hiptest::Nodes::Actionword-My leaf actionword",
          item: leaf,
          calls: [],
          distance_from_root: 4
        },
        :root => {
          calls: [
            "Hiptest::Nodes::Scenario-My first scenario"
          ],
          distance_from_root: 0
        }
      })
    end

    it 'does not raise error when a called action words is not found' do
      first_scenario.children[:body] << Hiptest::Nodes::Call.new('first level')
      add_scenarios([first_scenario])

      expect(graph).to eq({
        "Hiptest::Nodes::Scenario-My first scenario" => {
          name: "Hiptest::Nodes::Scenario-My first scenario",
          item: first_scenario,
          calls: ['Hiptest::Nodes::Actionword-first level'],
          distance_from_root: 1
        },
        :root => {
          calls: [
            "Hiptest::Nodes::Scenario-My first scenario"
          ],
          distance_from_root: 0
        }
      })
    end

    it 'will not update the distance for an action word unused' do
      add_aws([leaf])
      expect(graph).to eq({
        "Hiptest::Nodes::Actionword-My leaf actionword" => {
          name: "Hiptest::Nodes::Actionword-My leaf actionword",
          item: leaf,
          calls: [],
          distance_from_root: -1
        },
        :root => {calls: [], distance_from_root: 0}
      })
    end
  end

  context '#index_by_distances' do
    it 'stores elements based on the distance from the root' do
      first_scenario.children[:body] << Hiptest::Nodes::Call.new('first level')
      second_scenario.children[:body] << Hiptest::Nodes::Call.new('My leaf actionword')


      add_aws([first_level, second_level, leaf])
      add_scenarios([first_scenario, second_scenario])

      grapher = Hiptest::ProjectGrapher.new(project)
      grapher.compute_graph
      grapher.add_distances
      grapher.index_by_distances

      expect(grapher.distance_index).to eq({
        1 => [first_scenario, second_scenario],
        2 => [first_level],
        3 => [second_level],
        4 => [leaf]
      })
    end
  end

  context '.distances_index' do
    it 'returns hash of elements sorted and keyed by the distance from the root' do
      first_scenario.children[:body] << Hiptest::Nodes::Call.new('first level')
      second_scenario.children[:body] << Hiptest::Nodes::Call.new('My leaf actionword')
      add_aws([first_level, second_level, leaf])
      add_scenarios([first_scenario, second_scenario])

      distance_index = Hiptest::ProjectGrapher.distances_index(project)

      expect(distance_index.keys).to eq([1, 2, 3, 4])
    end
  end
end
