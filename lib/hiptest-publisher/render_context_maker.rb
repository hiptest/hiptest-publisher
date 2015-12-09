module Hiptest
  module RenderContextMaker
    def walk_item(item)
      {
        :has_parameters? => !item.children[:parameters].empty?,
        :has_tags? => !item.children[:tags].empty?,
        :has_step? => has_step?(item),
        :is_empty? => item.children[:body].empty?,
        :declared_variables => item.declared_variables_names,
        :raw_parameter_names => item.children[:parameters].map {|p| p.children[:name] },
        :self_name => item.children[:name],
      }
    end

    alias :walk_actionword :walk_item

    def walk_folder(folder)
      relative_package = @context.relative_path.split('/')[0...-1].join('.')
      relative_package = ".#{relative_package}" unless relative_package.empty?
      {
        :needs_to_import_actionwords? => @context.relative_path.count('/') > 0,
        :relative_package => relative_package,
        :self_name => folder.children[:name],
      }
    end

    def walk_scenario(scenario)
      base = walk_item(scenario)
      base[:project_name] = scenario.parent.parent.children[:name]

      datatable = scenario.children[:datatable]
      base[:has_datasets?] = datatable ? !datatable.children[:datasets].empty? : false
      return base
    end

    def walk_dataset(dataset)
      datatable = dataset.parent
      {
        :scenario_name => datatable.parent.children[:name]
      }
    end

    def walk_scenarios(scenarios)
      project = scenarios.parent
      {
        :project_name => project.children[:name],
        :self_name => project.children[:name],
      }
    end

    def walk_test(test)
      {
        :has_parameters? => false,
        :has_tags? => !test.children[:tags].empty?,
        :has_step? => has_step?(test),
        :is_empty? => test.children[:body].empty?,
        :has_datasets? => false,
        :project_name => test.parent.parent.children[:name],
        :self_name => test.children[:name],
      }
    end

    def walk_tests(tests)
      project = tests.parent
      {
        :project_name => project.children[:name],
        :self_name => project.children[:name],
      }
    end

    def walk_call(c)
      {
        :has_arguments? => !c.children[:arguments].empty?,
        :has_annotation? => !c.children[:annotation].nil?
      }
    end

    def walk_ifthen(it)
      {
        :has_else? => !it.children[:else].empty?
      }
    end

    def walk_parameter(p)
      {
        :has_default_value? => !p.children[:default].nil?
      }
    end

    def walk_tag(t)
      {
        :has_value? => !t.children[:value].nil?
      }
    end

    def walk_template(t)
      treated = t.children[:chunks].map do |chunk|
        {
          :is_variable? => chunk.is_a?(Hiptest::Nodes::Variable),
          :raw => chunk
        }
      end
      variable_names = treated.map {|item| item[:raw].children[:name] if item[:is_variable?]}.compact

      {
        :treated_chunks => treated,
        :variable_names => variable_names
      }
    end

    private

    def has_step?(item)
      item.each_sub_nodes(deep: true) do |node|
        return true if node.is_a?(Hiptest::Nodes::Step)
      end
      false
    end
  end
end
