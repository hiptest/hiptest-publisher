module Zest
  class HandlebarsHelper
    def self.register_helpers(handlebars, context)
      instance = Zest::HandlebarsHelper.new(handlebars, context)
      instance.register_string_helpers
      instance.register_all_helpers
    end

    def initialize(handlebars, context)
      @handlebars = handlebars
      @context = context
    end

    def register_string_helpers
      string_helpers = [
        :literate,
        :normalize,
        :underscore,
        :camelize,
        :camelize_lower,
        :clear_extension
      ]

      string_helpers.each do |helper|
        @handlebars.register_helper(helper) do |context, value|
          "#{value.send(helper)}"
        end
      end
    end

    def register_all_helpers
      HandlebarsHelper.instance_methods(false).each do |method_name|
        next unless method_name.to_s.start_with? 'hh_'
        @handlebars.register_helper(method_name.to_s.gsub(/hh_/, '')) do |*args|
          send(method_name, *args)
        end
      end
    end

    def hh_to_string(context, value, block)
      "#{value.to_s}"
    end

    def hh_join(context, items, joiner, block)
      "#{items.join(joiner)}"
    end

    def hh_indent(context, block)
      indentation = @context[:indentation] || '  '
      block.fn(context).split("\n").map do |line|
        indented = "#{indentation}#{line}"
        indented = "" if indented.strip.empty?
        indented
      end.join("\n")
    end

    def hh_clear_empty_lines(context, block)
      block.fn(context).split("\n").map do |line|
        line unless line.strip.empty?
      end.compact.join("\n")
    end

    def hh_remove_quotes (context, s, block)
      "#{s.gsub('"', '')}"
    end

    def hh_escape_quotes (context, s, block)
      "#{s.gsub(/"/) {|_| '\\"' }}"
    end

    def hh_comment (context, commenter, block)
      block.fn(context).split("\n").map do |line|
        "#{commenter} #{line}"
      end.join("\n")
    end

    def hh_curly (context, block)
      "{#{block.fn(context)}}"
    end

    def hh_open_curly (context, block)
      "{"
    end

    def hh_close_curly (context, block)
      "}"
    end
  end
end