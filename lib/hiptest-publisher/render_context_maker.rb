module Hiptest
  module RenderContextMaker
    def walk_item(item)
      {
        has_description?: !item.children[:description].nil? && !item.children[:description].empty?,
        has_parameters?: !item.children[:parameters].empty?,
        has_tags?: !item.children[:tags].empty?,
        has_step?: has_step?(item),
        is_empty?: item.children[:body].empty?,
        declared_variables: item.declared_variables_names,
        raw_parameter_names: item.children[:parameters].map {|p| p.children[:name] },
        self_name: item.children[:name]
      }
    end

    def walk_relative_item(item)
      relative_package = @context.relative_path.split('/')[0...-1].join('.')
      relative_package = ".#{relative_package}" unless relative_package.empty?
      {
        needs_to_import_actionwords?: @context.relative_path.count('/') > 0,
        relative_package: relative_package,
      }
    end

    def walk_actionword(aw)
      walk_item(aw).merge(
        chunks: aw.chunks || [],
        extra_inlined_parameters: aw.extra_inlined_parameters || [],
        has_free_text_parameter?: aw.children[:parameters].select(&:free_text?).count > 0,
        has_datatable_parameter?: aw.children[:parameters].select(&:datatable?).count > 0,
        uniq_name: aw.uniq_name,
        has_library?: (aw.parent.is_a? Hiptest::Nodes::Library) ? true : false,
        library_name: aw.parent.nil? ? '' : aw.parent.children[:name]
      )
    end

    def walk_actionwords(aws)
      project = aws.parent
      {
        uses_library?: project.nil? ? false : project.has_libraries?
      }
    end

    def walk_folder(folder)
      walk_relative_item(folder).merge(
        self_name: folder.children[:name],
        has_tags?: !folder.children[:tags].empty?,
        has_step?: has_step?(folder),
        is_empty?: folder.children[:body].empty?,
        datatables_present?: datatable_present?(folder)
      )
    end

    def walk_scenario(scenario)
      walk_item(scenario).merge(walk_relative_item(scenario)).merge(
        project_name: scenario.parent.parent.children[:name],
        has_datasets?: has_datasets?(scenario),
        has_annotations?: has_annotations?(scenario),
        uniq_name: scenario.children[:name]
      )
    end

    def walk_dataset(dataset)
      datatable = dataset.parent
      {
        scenario_name: datatable.parent.children[:name]
      }
    end

    def walk_scenarios(scenarios)
      project = scenarios.parent
      {
        project_name: project.children[:name],
        self_name: project.children[:name],
        datatables_present?: datatable_present?(scenarios)
      }
    end

    def walk_test(test)
      {
        has_description?: !test.children[:description].nil? && !test.children[:description].empty?,
        has_parameters?: false,
        has_tags?: !test.children[:tags].empty?,
        has_step?: has_step?(test),
        is_empty?: test.children[:body].empty?,
        has_datasets?: false,
        project_name: test.parent.parent.children[:name],
        self_name: test.children[:name]
      }
    end

    def walk_tests(tests)
      project = tests.parent
      {
        project_name: project.children[:name],
        self_name: project.children[:name]
      }
    end

    def walk_call(c)
      {
        has_arguments?: !c.children[:arguments].empty?,
        has_annotation?: !c.children[:annotation].nil?,
        in_actionword?: c.parent.is_a?(Hiptest::Nodes::Actionword),
        in_datatabled_scenario?: c.parent.is_a?(Hiptest::Nodes::Scenario) && has_datasets?(c.parent),
        chunks: c.chunks || [],
        extra_inlined_arguments: c.extra_inlined_arguments || []
      }
    end

    def walk_uidcall(uidcall)
      {
        has_library?: !uidcall.children[:library_name].nil?,
        has_annotation?: !uidcall.children[:annotation].nil?,
        in_actionword?: uidcall.parent.is_a?(Hiptest::Nodes::Actionword),
        chunks: uidcall.chunks || []
      }
    end

    def walk_ifthen(it)
      {
        has_else?: !it.children[:else].empty?
      }
    end

    def walk_parameter(p)
      {
        is_free_text?: p.free_text?,
        is_datatable?: p.datatable?,
        is_bool?: p.children[:type] == :bool,
        has_default_value?: !p.children[:default].nil?
      }
    end

    def walk_tag(t)
      {
        has_value?: !t.children[:value].nil?
      }
    end

    def walk_template(t)
      treated = t.children[:chunks].map do |chunk|
        {
          is_variable?: chunk.is_a?(Hiptest::Nodes::Variable),
          raw: chunk
        }
      end
      variable_names = treated.map {|item| item[:raw].children[:name] if item[:is_variable?]}.compact

      {
        treated_chunks: treated,
        variable_names: variable_names
      }
    end

    def walk_libraries(libraries)
      {
        library_names: libraries.children[:libraries].map {|lib| lib.children[:name]}
      }
    end

    private

    def has_step?(item)
      item.each_sub_nodes(deep: true) do |node|
        return true if node.is_a?(Hiptest::Nodes::Step)
      end
      false
    end

    def has_annotations?(scenario)
      scenario.each_sub_nodes(deep: true) do |node|
        return true if node.is_a?(Hiptest::Nodes::Call) && !node.children[:annotation].nil?
      end
      false
    end

    def has_datasets?(scenario)
      datatable = scenario.children[:datatable]
      datatable ? !datatable.children[:datasets].empty? : false
    end

    def datatable_present?(container)
      datatables_present = false

      container.children[:scenarios].each do |scenario|
        if has_datasets?(scenario)
          datatables_present = true
          break
        end
      end

      return datatables_present
    end
  end
end
