require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/handlebars_helper'

class MockHbBlock
  def initialize(content)
    @content = content
  end

  def fn(context)
    return @content
  end
end

class MockHandlebars
  attr_reader :helpers

  def initialize
    @helpers = []
  end

  def register_helper(name)
    @helpers << name
  end
end

describe Hiptest::HandlebarsHelper do
  let(:handlebars) {MockHandlebars.new}
  let(:instance) {Hiptest::HandlebarsHelper.new(handlebars, {})}

  let(:block) {
    block = MockHbBlock.new([
      "A single line",
      "Two\nLines",
      "Three\n  indented\n    lines"
    ].join("\n"))
  }

  context 'self.register_helpers' do
    it 'register the helpers needed for the application' do
      Hiptest::HandlebarsHelper.register_helpers(handlebars, {})
      expect(handlebars.helpers.length).to eq(19)
    end
  end

  context 'register_string_helpers' do
    it 'register helpers based on our custom string methods' do
      instance.register_string_helpers
      expect(handlebars.helpers).to eq([
        :literate,
        :normalize,
        :normalize_lower,
        :underscore,
        :camelize,
        :camelize_lower,
        :clear_extension
      ])
    end
  end

  context 'register_custom_helpers' do
    it 'registers the helpers' do
      instance.register_custom_helpers
      expect(handlebars.helpers).to eq([
        "to_string",
        "join",
        "block_join",
        "indent",
        "clear_empty_lines",
        "remove_quotes",
        "escape_quotes",
        "comment",
        "curly",
        "open_curly",
        "close_curly",
        "tab"
      ])
    end

    it 'any method named hh_* is register as a helper (hh stands for handlebars helper)' do
      class CustomHelper < Hiptest::HandlebarsHelper
        def hh_do_something(context, block)
        end
      end

      CustomHelper.new(handlebars, {}).register_custom_helpers
      expect(handlebars.helpers).to eq([
        "do_something",
        "to_string",
        "join",
        "block_join",
        "indent",
        "clear_empty_lines",
        "remove_quotes",
        "escape_quotes",
        "comment",
        "curly",
        "open_curly",
        "close_curly",
        "tab"
      ])
    end
  end

  context 'hh_to_string' do
    it 'transforms the value to a string' do
      expect(instance.hh_to_string(nil, true, nil)).to eq('true')
      expect(instance.hh_to_string(nil, 3.14, nil)).to eq('3.14')
      expect(instance.hh_to_string(nil, 'A string', nil)).to eq('A string')
    end
  end

  context 'hh_join' do
    it 'joins a list with the given joiner' do
      expect(instance.hh_join(nil, [1, 2, 3], '-', nil)).to eq('1-2-3')
    end

    it 'uses a real tabulation character when needed' do
      expect(instance.hh_join(nil, [1, 2, 3], '\t', nil)).to eq("1\t2\t3")
    end
  end

  context 'hh_indent' do
    it 'indent a block' do
      expect(instance.hh_indent(nil, block)).to eq([
        "  A single line",
        "  Two",
        "  Lines",
        "  Three",
        "    indented",
        "      lines"
        ].join("\n"))
    end

    it 'if no indentation is specified, it uses the one from the context' do
      instance = Hiptest::HandlebarsHelper.new(nil, {indentation: '---'})
      expect(instance.hh_indent(nil, MockHbBlock.new("La"))).to eq("---La")
    end

    it 'default indentation is wo spaces' do
      expect(instance.hh_indent(nil, MockHbBlock.new("La"))).to eq("  La")
    end

    it 'keeps empty line but do not indent them' do
      block = MockHbBlock.new([
        "First line",
        "",
        "Third line"
      ].join("\n"))

      expect(instance.hh_indent(nil, block)).to eq([
        "  First line",
        "",
        "  Third line"
      ].join("\n"))
    end
  end

  context 'hh_clear_empty_lines' do
    it 'removes empty lines' do
      block = MockHbBlock.new([
        "First line",
        "",
        "Third line"
      ].join("\n"))

      expect(instance.hh_clear_empty_lines(nil, block)).to eq([
        "First line",
        "Third line"
      ].join("\n"))
    end

    it 'also removes lines containing only white spaces' do
      block = MockHbBlock.new([
        "First line",
        "\t         ",
        "Third line"
      ].join("\n"))

      expect(instance.hh_clear_empty_lines(nil, block)).to eq([
        "First line",
        "Third line"
      ].join("\n"))
    end
  end

  context 'hh_remove_quotes' do
    it 'removes double quotes from a string' do
      expect(instance.hh_remove_quotes(nil, 'My "string"', nil)).to eq('My string')
    end

    it 'leaves single quotes' do
      expect(instance.hh_remove_quotes(nil, "My 'string'", nil)).to eq("My 'string'")
    end
  end

  context 'hh_escape_quotes' do
    it 'escapes double quotes' do
      expect(instance.hh_escape_quotes(nil, 'My "string"', nil)).to eq('My \"string\"')
    end

    it 'leaves single quotes' do
      expect(instance.hh_escape_quotes(nil, "My 'string'", nil)).to eq("My 'string'")
    end
  end

  context 'hh_comment' do
    it 'Adds the given commenter before each line' do
      expect(instance.hh_comment(nil, '/+', block)).to eq([
        "/+ A single line",
        "/+ Two",
        "/+ Lines",
        "/+ Three",
        "/+   indented",
        "/+     lines"
        ].join("\n"))
    end
  end

  context 'hh_curly' do
    it 'adds curly braces around a block' do
      expect(instance.hh_curly(nil, block)).to eq([
        "{A single line",
        "Two",
        "Lines",
        "Three",
        "  indented",
        "    lines}"
        ].join("\n"))
    end
  end

  context 'hh_open_curly' do
    it 'returns an opening curly brace' do
      expect(instance.hh_open_curly(nil, nil)).to eq('{')
    end
  end

  context 'hh_close_curly  ' do
    it 'returns an closing curly brace' do
      expect(instance.hh_close_curly(nil, nil)).to eq('}')
    end
  end
end