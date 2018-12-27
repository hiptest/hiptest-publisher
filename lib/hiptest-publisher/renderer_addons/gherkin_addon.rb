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

    def walk_uidcall(call)
      if call.free_text_arg
        @rendered_children[:free_text_arg] = rendered_freetext_arg(call)
      end

      if call.datatable_arg
        @rendered_children[:datatable_arg] = rendered_datatable_arg(call)
      end

      super(call)
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
  end
end
