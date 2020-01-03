require 'hiptest-publisher/nodes'

module Hiptest
  module GherkinAddon
    def walk_call(call)
      if call.free_text_arg
        @rendered_children[:free_text_arg] = rendered_freetext_arg(call)
      end

      if call.datatable_arg
        @rendered_children[:datatable_arg] = rendered_datatable_arg(call)
      end

      super(call)
    end

    def walk_actionword(aw)
      parameters = aw.children[:parameters]
      aw.chunks = replace_parameter_value_with_type(aw.chunks, parameters)
      aw.extra_inlined_parameters = replace_parameter_value_with_type(aw.extra_inlined_parameters, parameters)

      super(aw)
    end

    def walk_folder(folder)
      @rendered_children[:ancestor_tags] = ancestor_tags(folder)

      super(folder)
    end

    private

    def rendered_datatable_arg(call)
      @rendered[call.datatable_arg.children[:value]]
    end

    def rendered_freetext_arg(call)
      @rendered[call.free_text_arg.children[:value]]
    end

    def ancestor_tags(folder)
      ancestor_tags = folder.ancestors.map { |f| f.children[:tags] }.flatten.uniq
      ancestor_tags.map { |t| Hiptest::Renderer.render(t, @context) }
    end

    def replace_parameter_value_with_type(collection, parameters)
      collection.map do |obj|
        if obj[:is_parameter]
          parameter = parameters.find { |parameter| parameter.children[:name] == obj[:name] }
          obj[:typed_value] = parameter ? "{#{parameter.type.downcase}}" : "{}"
        else
          obj[:typed_value] = obj[:value]
        end

        obj
      end
    end
  end
end
