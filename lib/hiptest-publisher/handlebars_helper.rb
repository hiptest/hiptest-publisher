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
        :normalize_with_dashes,
        :normalize_with_spaces,
        :underscore,
        :capitalize,
        :camelize,
        :camelize_lower,
        :camelize_upper,
        :clear_extension,
        :downcase,
        :strip
      ]

      string_helpers.each do |helper|
        @handlebars.register_helper(helper) do |context, block|
          if block.is_a? Handlebars::Tree::Block
            value = block.fn(context)
          else
            value = block
          end
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

    def compute_block_value(context, value, block)
      value.is_a?(Handlebars::Tree::Block) ? value.fn(context) : value
    end

    def hh_to_string(context, value, block=nil)
      value = compute_block_value(context, value, block)
      "#{value.to_s}"
    end

    def hh_join(context, items, joiner, block, else_block = nil)
      joiner = joiner.to_s
      joiner.gsub!(/\\t/, "\t")
      joiner.gsub!(/\\n/, "\n")


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

    def hh_join_gherkin_dataset(context, items, block, else_block = nil)
      items.map! {|item| item.gsub(/\|/, "\\|")}

      hh_join(context, items, ' | ', block, else_block)
    end

    def hh_with(context, var, name, block)
      name = name.to_s
      current_value = context.get(name)
      context.add_item(name, var)
      result = block.fn(context)
      context.add_item(name, current_value)
      result
    end

    def hh_unless(context, condition, block, else_block = nil)
      condition = !condition.empty? if condition.respond_to?(:empty?)

      if !condition
        block.fn(context)
      elsif else_block
        else_block.fn(context)
      else
        ""
      end
    end

    def hh_prepend(context, str, block)
      block.fn(context).split("\n").map do |line|
        indented = "#{str}#{line}"
        indented = "" if indented.strip.empty?
        indented
      end.join("\n")
    end

    def hh_indent(context, block)
      indentation = @context[:indentation] || '  '
      indentation = "\t" if indentation == '\t'

      hh_prepend(context, indentation, block)
    end

    def hh_clear_empty_lines(context, block)
      block.fn(context).split("\n").map do |line|
        line unless line.strip.empty?
      end.compact.join("\n")
    end

    def hh_index(context, list, index, block)
      current_this = context.get('this')
      context.add_item(:this, list[index.to_i])
      rendered = block.fn(context)
      context.add_item(:this, current_this)

      return rendered
    end

    def hh_first(context, list, block)
      hh_index(context, list, 0, block)
    end

    def hh_last(context, list, block)
      hh_index(context, list, list.size - 1, block)
    end

    # kept for backward compatibility of customized templates
    def hh_remove_quotes (context, s, block = nil)
      hh_remove_double_quotes(context, s, block)
    end

    def hh_remove_double_quotes (context, s, block = nil)
      s = compute_block_value(context,s, block)
      s ? s.gsub('"', '') : ""
    end

    def hh_remove_single_quotes (context, s, block = nil)
      s = compute_block_value(context,s, block)
      s ? s.gsub('\'', '') : ""
    end

    # kept for backward compatibility of customized templates
    def hh_escape_quotes (context, s, block=nil)
      hh_escape_double_quotes(context, s, block)
    end

    def hh_escape_double_quotes (context, s, block=nil)
      s = compute_block_value(context, s, block)
      s ? s.gsub('"', '\\"') : ""
    end

    def hh_escape_single_quotes (context, s, block=nil)
      # weird \\\\, see http://stackoverflow.com/questions/7074337/why-does-stringgsub-double-content
      s = compute_block_value(context, s, block)
      s ? s.gsub('\'', "\\\\'") : ""
    end

    def hh_unescape_single_quotes (context, s, block=nil)
      # weird \\\\, see http://stackoverflow.com/questions/7074337/why-does-stringgsub-double-content
      s = compute_block_value(context, s, block)
      s ? s.gsub("\\'", "'") : ""
    end

    def hh_escape_backslashes_and_double_quotes (context, s, block=nil)
      s = compute_block_value(context, s, block)

      if s
        s.gsub('\\') { |c| c*2 }.
          gsub('"', '\\"')
      else
        ""
      end
    end

    def hh_escape_new_line(context, s, block = nil)
      s = compute_block_value(context, s, block)
      s ? s.gsub("\n", '\\n') : ""
    end

    def hh_remove_surrounding_quotes(context, s, block = nil)
      s = compute_block_value(context, s, block)

      if s.nil?
        ""
      elsif surrounded_with?(s, "'") || surrounded_with?(s, '"')
        s.slice(1...-1)
      else
        s
      end
    end

    def surrounded_with?(main, sub)
      main.start_with?(sub) && main.end_with?(sub)
    end

    def hh_comment (context, commenter, block)
      block.fn(context).split("\n").map do |line|
        "#{commenter} #{line}"
      end.join("\n")
    end

    def hh_description_with_annotations (context, commenter, block)
      value = compute_block_value(context, commenter, block)
      value = value.split("\n").map do |line|
        line.strip.downcase.start_with?('given', 'when', 'then', 'and', 'but', '*', '#') ? "\"#{line}\"" : line
      end.join("\n")
      value
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

    def hh_relative_path(context, filename, path_prefix = nil, block)
      levels_count = context.get('context.relative_path').count('/')
      name = ""
      name << path_prefix if path_prefix
      if levels_count == 0
        name << filename
      else
        name << "../" * levels_count
        name << filename.to_s.gsub(/\A\.\//, '')
      end
      name
    end

    def hh_strip_regexp_delimiters(context, regexp, block=nil)
      regexp = compute_block_value(context, regexp, block)
      return regexp.gsub(/(^\^)|(\$$)/, '')
    end

    def hh_remove_last_character(context, character = '', block)
      txt = block.fn(context)
      return txt[-1] == character ? txt[0..-2] : txt
    end

    def hh_trim_surrounding_characters(context, character, block)
      return block.fn(context).gsub(/(\A(#{character})*)|((#{character})*\z)/, '')
    end

    def hh_replace(context, str, replacement, block)
      return block.fn(context).gsub(str, replacement)
    end

    def hh_debug(context, block)
      require 'pry'
      binding.pry
      ""
    end

    def hh_if_includes(context, array, element, block_true, block_false = nil)
      if array.kind_of?(Array) && array.include?(element)
        block_true.fn(context)
      elsif block_false
        block_false.fn(context)
      else
        ''
      end
    end
  end
end
