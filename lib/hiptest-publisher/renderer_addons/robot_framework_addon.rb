require 'hiptest-publisher/nodes'

module Hiptest
  module RobotFrameworkAddon
    def walk_folder(folder)
      walk_scenario_container(folder)
      super(folder)
    end

    def walk_scenarios(scenarios)
      walk_scenario_container(scenarios)
      super(scenarios)
    end

    private

    def walk_scenario_container(container)
     # For Robot framework, we need direct access to every scenario
     # datatables and body rendered.

      @rendered_children[:splitted_scenarios] = container.children[:scenarios].map {|sc|
        {
          name: @rendered[sc.children[:name]],
          tags: sc.children[:tags].map {|tag| @rendered[tag]},
          uid: @rendered[sc.children[:uid]],
          datatable: @rendered[sc.children[:datatable]],
          datasets: sc.children[:datatable].children[:datasets].map {|dataset|
            {
              scenario_name: @rendered[sc.children[:name]],
              name: @rendered[dataset.children[:name]],
              uid: @rendered[dataset.children[:uid]],
              test_snapshot_uid: @rendered[dataset.children[:test_snapshot_uid]],
              arguments: @rendered[dataset.children[:arguments]]
            }
          },
          parameters:  @rendered[sc.children[:parameters]],
          body: @rendered[sc.children[:body]]
        }
      }
    end
  end
end
