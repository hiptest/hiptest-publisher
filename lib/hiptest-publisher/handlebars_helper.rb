module Hiptest
  class HandlebarsHelper
    def self.register_helpers(handlebars, context)
      instance = Hiptest::HandlebarsHelper.new(handlebars, context)
      instance.register_string_helpers
      instance.register_custom_helpers
    end

    def initialize(handlebars, context)
      @handlebars = handlebars
      @context = context
    end

    def register_string_helpers
      string_helpers = [
        :literate,
        :normalize,
        :normalize_lower,
        :underscore,
        :camelize,
        :camelize_lower,
        :camelize_upper,
        :clear_extension,
        :downcase
      ]

      string_helpers.each do |helper|
        @handlebars.register_helper(helper) do |context, value|
          "#{value.to_s.send(helper)}"
        end
      end
    end

    def register_custom_helpers
      self.class.instance_methods.each do |method_name|
        next unless method_name.to_s.start_with? 'hh_'
        @handlebars.register_helper(method_name.to_s.gsub(/hh_/, '')) do |*args|
          send(method_name, *args)
        end
      end
    end

    def hh_to_string(context, value, block)
      "#{value.to_s}"
    end

    def hh_join(context, items, joiner, block, else_block = nil)
      joiner = "\t" if joiner == '\t'

      if block.nil? || block.items.empty?
        "#{items.join(joiner)}"
      else
        if items.empty? && else_block
          return else_block.fn(context)
        end

        current_this = context.get('this')
        result = items.map do |item|
          context.add_item(:this, item)
          block.fn(context)
        end.join(joiner)

        context.add_item(:this, current_this)
        result
      end
    end

    def hh_indent(context, block)
      indentation = @context[:indentation] || '  '
      indentation = "\t" if indentation == '\t'

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

    # kept for backward compatibility of customized templates
    def hh_remove_quotes (context, s, block)
      hh_remove_double_quotes(context, s, block)
    end

    def hh_remove_double_quotes (context, s, block)
      s ? s.gsub('"', '') : ""
    end

    def hh_remove_single_quotes (context, s, block)
      s ? s.gsub('\'', '') : ""
    end

    # kept for backward compatibility of customized templates
    def hh_escape_quotes (context, s, block)
      hh_escape_double_quotes(context, s, block)
    end

    def hh_escape_double_quotes (context, s, block)
      s ? s.gsub('"', '\\"') : ""
    end

    def hh_escape_single_quotes (context, s, block)
      # weird \\\\, see http://stackoverflow.com/questions/7074337/why-does-stringgsub-double-content
      s ? s.gsub('\'', "\\\\'") : ""
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

    def hh_tab (context, block)
      "\t"
    end

    def hh_relative_path(context, filename, block)
      levels_count = context.get('context.relative_path').count('/')
      if levels_count == 0
        filename
      else
        base_name = filename.to_s.gsub(/\A\.\//, '')
        "../" * levels_count + base_name
      end
    end

    def hh_debug(context, block)
      require 'pry'
      binding.pry
      ""
    end
  end
end
