module Zest
  module RenderContextMaker
    def walk_actionword(aw)
      {
        :has_parameters? => aw.has_parameters?,
        :has_tags? => !aw.children[:tags].empty?,
        :has_step? => aw.has_step?,
        :is_empty? => aw.children[:body].empty?
      }
    end

    def walk_scenario(sc)
      {
        :has_parameters? => sc.has_parameters?,
        :has_tags? => !sc.children[:tags].empty?,
        :is_empty? => sc.children[:body].empty?
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