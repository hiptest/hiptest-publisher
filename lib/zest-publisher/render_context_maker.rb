module Zest
  module RenderContextMaker
    def walk_item(item)
      {
        :has_parameters? => !item.children[:parameters].empty?,
        :has_tags? => !item.children[:tags].empty?,
        :has_step? => !item.find_sub_nodes(Zest::Nodes::Step).empty?,
        :is_empty? => item.children[:body].empty?
      }
    end

    alias :walk_actionword :walk_item

    def walk_scenario(scenario)
      base = walk_item(scenario)
      base[:project_name] = scenario.parent.parent.children[:name]

      return base
    end

    def walk_scenarios(scenarios)
      {
        :project_name => scenarios.parent.children[:name]
      }
    end

    def walk_call(c)
      {
        :has_arguments? => !c.children[:arguments].empty?
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
          :is_variable? => chunk.is_a?(Zest::Nodes::Variable),
          :raw => chunk
        }
      end
      variable_names = treated.map {|item| item[:raw].children[:name] if item[:is_variable?]}.compact

      {
        :treated_chunks => treated,
        :variable_names => variable_names
      }
    end
  end
end