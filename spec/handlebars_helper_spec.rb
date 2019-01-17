require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/handlebars_helper'

class MockHbBlock
  attr_reader :items

  def initialize(content, items = [])
    @content = content
    @items = items
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
  def evaluate(template, context)
    hbs = Handlebars::Handlebars.new
    Hiptest::HandlebarsHelper.register_helpers(hbs, {})

    hbs.compile(template).call(context)
  end

  let(:handlebars) {MockHandlebars.new}
  let(:instance) {Hiptest::HandlebarsHelper.new(handlebars, {})}

  let(:txt_block) {
    [
      "A single line",
      "Two\nLines",
      "Three\n  indented\n    lines"
    ].join("\n")
  }

  let(:block) {
    MockHbBlock.new(txt_block)
  }

  context 'self.register_helpers' do
    it 'register the helpers needed for the application' do
      expect {
        Hiptest::HandlebarsHelper.register_helpers(handlebars, {})
      }.to change { handlebars.helpers }
    end
  end

  context 'register_string_helpers' do
    before(:each) {instance.register_string_helpers}

    it 'register helpers based on our custom string methods' do
      expect(handlebars.helpers).to include(
        :literate,
        :normalize,
        :normalize_lower,
        :underscore,
        :camelize,
        :camelize_lower,
        :clear_extension,
        :strip
      )
    end

    it 'defines helpers working with strings' do
      expect(evaluate('{{strip value}}', {value: "   Something.   "})).to eq('Something.')
    end

    it 'defines helpers working with blocks' do
      expect(evaluate('{{#strip}}  This is my {{value}}.    {{/strip}}', {value: "Value"})).to eq('This is my Value.')
    end
  end

  context 'register_custom_helpers' do
    it 'registers the helpers' do
      instance.register_custom_helpers
      expect(handlebars.helpers).to include(
        "to_string",
        "join",
        "indent",
        "clear_empty_lines",
        "remove_double_quotes",
        "remove_single_quotes",
        "escape_double_quotes",
        "escape_single_quotes",
        "comment",
        "curly",
        "open_curly",
        "close_curly",
        "tab",
        "debug"
      )
    end

    it 'any method named hh_* is register as a helper (hh stands for handlebars helper)' do
      class CustomHelper < Hiptest::HandlebarsHelper
        def hh_do_something(context, block)
        end
      end

      CustomHelper.new(handlebars, {}).register_custom_helpers
      expect(handlebars.helpers).to include(
        "do_something",
      )
    end
  end

  context 'hh_to_string' do
    it 'transforms the value to a string' do
      expect(instance.hh_to_string(nil, true, nil)).to eq('true')
      expect(instance.hh_to_string(nil, 3.14, nil)).to eq('3.14')
      expect(instance.hh_to_string(nil, 'A string', nil)).to eq('A string')
    end

    it 'real use-case' do
      expect(evaluate('{{to_string x}}', {x: 123})).to eq('123')
    end

    it 'also works with blocks' do
      expect(evaluate('{{#to_string}}{{x}}{{/to_string}}', {x: 123})).to eq('123')
    end
  end

  context 'hh_join' do
    it 'joins a list with the given joiner' do
      expect(instance.hh_join(nil, [1, 2, 3], '-', nil)).to eq('1-2-3')
    end

    it 'uses a real tabulation character when needed' do
      expect(instance.hh_join(nil, [1, 2, 3], '\t', nil)).to eq("1\t2\t3")
    end

    it 'also supports blocks' do
      context = Handlebars::Handlebars.new
      context.set_context({})

      expect(instance.hh_join(context, [1, 2, 3], '||', MockHbBlock.new('-', [1]))).to eq("-||-||-")
    end

    it 'real use-case' do
      expect(evaluate('{{join items "-"}}', {items: [1, 2, 3]})).to eq('1-2-3')
      expect(evaluate('{{#join items "-"}}[{{this}}]{{else}}no items{{/join}}', {items: [1, 2, 3]})).to eq('[1]-[2]-[3]')
      expect(evaluate('{{#join items "-"}}[{{this}}]{{else}}No items{{/join}}', {items: []})).to eq('No items')
    end
  end

  context 'hh_join_gherkin_dataset' do
    it 'datatable use case' do
      expect(evaluate('{{join_gherkin_dataset items}}', {items: ['John Connor', 'Sarah Connor', 'T-|000']})).to eq('John Connor | Sarah Connor | T-\|000')
    end
  end

  context 'hh_with' do
    it 'allows to keep name in the current context' do
      data = {
        items: [
          {
            name: 'Plic',
            subItems: [
              {name: 1},
              {name: 2}
            ]
          },
          {
            name: 'Ploc',
            subItems: [
              {name: 3},
              {name: 4}
            ]
          }
        ]
      }

      template = [
        '{{#clear_empty_lines}}{{#each items}}',
        '  {{#with this.name "name"}}',
        '    {{#each this.subItems}}',
        ' - {{name}} {{this.name}}',
        '    {{/each}}',
        '  {{/with}}',
        '{{/each}}{{/clear_empty_lines}}'
      ].join("\n")

      expect(evaluate(template, data)).to eq([
        " - Plic 1",
        " - Plic 2",
        " - Ploc 3",
        " - Ploc 4"
      ].join("\n"))
    end
  end

  context 'hh_unless' do
    it 'runs the block if the condition is not met' do
      expect(evaluate('{{#unless condition}}Show something{{/unless}}', {condition: false})).to eq('Show something')
      expect(evaluate('{{#unless condition}}Show something{{/unless}}', {condition: true})).to eq('')
    end

    it 'supports an else block (well, #if might be beteer for that)' do
      expect(evaluate('{{#unless condition}}Show something{{else}}Show nothing{{/unless}}', {condition: false})).to eq('Show something')
      expect(evaluate('{{#unless condition}}Show something{{else}}Show nothing{{/unless}}', {condition: true})).to eq('Show nothing')

    end
  end

  context 'hh_prepend' do
    it 'prepends each line with the given character' do
      expect(instance.hh_prepend(nil, '# ', block)).to eq([
        '# A single line',
        '# Two',
        '# Lines',
        '# Three',
        '#   indented',
        '#     lines'
      ].join("\n"))
    end

    it 'real use-case' do
      expect(evaluate("{{#prepend ' - '}}{{#each items}}{{this}}\n{{/each}}{{/prepend}}", {items: [1, 2, 3]})).to eq([
        " - 1",
        " - 2",
        " - 3"
      ].join("\n"))
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

  context 'hh_index' do
    it 'calls the block with the correct element of the list' do
      template = '{{#index list index}}- {{this}}{{/index}}'

      expect(evaluate(template, {list: ['a', 'b', 'c'], index: 0})).to eq('- a')
      expect(evaluate(template, {list: ['a', 'b', 'c'], index: 2})).to eq('- c')
    end

    it 'also work when the index is written in the template' do
      template = '{{#index list "1"}}- {{this}}{{/index}}'

      expect(evaluate(template, {list: ['a', 'b', 'c']})).to eq('- b')
    end
  end

  context 'hh_first' do
    it 'works like hh_index, with a index set to zero' do
      template = '{{#first list}}- {{this}}{{/first}}'

      expect(evaluate(template, {list: ['a', 'b', 'c'], index: 0})).to eq('- a')
    end
  end

  context 'hh_last' do
    it 'works like hh_index, but always points to the last element of the list' do
      template = '{{#last list}}- {{this}}{{/last}}'

      expect(evaluate(template, {list: ['a', 'b', 'c'], index: 0})).to eq('- c')
    end
  end

  context 'hh_remove_quotes' do
    it 'removes double quotes from a string' do
      expect(evaluate('{{remove_quotes value}}', {value: 'My "string"'})).to eq('My string')
      expect(evaluate('{{#remove_quotes}}My "string"{{/remove_quotes}}', {})).to eq('My string')
    end

    it 'leaves single quotes' do
      expect(evaluate('{{remove_quotes value}}', {value: "My 'string'"})).to eq("My 'string'")
      expect(evaluate("{{#remove_quotes}}My 'string'{{/remove_quotes}}", {})).to eq("My 'string'")
    end

    it 'returns empty string when nil' do
      expect(evaluate('{{remove_quotes value}}', {value: nil})).to eq("")
      expect(evaluate("{{#remove_quotes}}{{value}}{{/remove_quotes}}", {value: nil})).to eq("")
    end
  end

  context 'hh_remove_double_quotes' do
    it 'removes double quotes from a string' do
      expect(evaluate('{{remove_double_quotes value}}', {value: 'My "string"'})).to eq('My string')
      expect(evaluate('{{#remove_double_quotes}}My "string"{{/remove_double_quotes}}', {})).to eq('My string')
    end

    it 'leaves single quotes' do
      expect(evaluate('{{remove_double_quotes value}}', {value: "My 'string'"})).to eq("My 'string'")
      expect(evaluate("{{#remove_double_quotes}}My 'string'{{/remove_double_quotes}}", {})).to eq("My 'string'")
    end

    it 'returns empty string when nil' do
      expect(evaluate('{{remove_double_quotes value}}', {value: nil})).to eq("")
      expect(evaluate("{{#remove_double_quotes}}{{value}}{{/remove_double_quotes}}", {value: nil})).to eq("")
    end
  end

  context 'hh_remove_single_quotes' do
    it 'removes single quotes from a string' do
      expect(evaluate('{{remove_single_quotes value}}', {value: "My 'string'"})).to eq("My string")
      expect(evaluate("{{#remove_single_quotes}}My 'string'{{/remove_single_quotes}}", {})).to eq("My string")
    end

    it 'leaves double quotes' do
      expect(evaluate('{{remove_single_quotes value}}', {value: 'My "string"'})).to eq('My "string"')
      expect(evaluate('{{#remove_single_quotes}}My "string"{{/remove_single_quotes}}', {})).to eq('My "string"')
    end

    it 'returns empty string when nil' do
      expect(evaluate('{{remove_single_quotes value}}', {value: nil})).to eq("")
      expect(evaluate("{{#remove_single_quotes}}{{value}}{{/remove_single_quotes}}", {value: nil})).to eq("")
    end
  end

  context 'hh_escape_quotes' do
    it 'escapes double quotes' do
      expect(evaluate('{{escape_quotes value}}', {value: 'My "string"'})).to eq('My \"string\"')
      expect(evaluate('{{#escape_quotes}}My "string"{{/escape_quotes}}', {})).to eq('My \"string\"')
    end

    it 'leaves single quotes' do
      expect(evaluate('{{escape_quotes value}}', {value: "My 'string'"})).to eq("My 'string'")
      expect(evaluate("{{#escape_quotes}}My 'string'{{/escape_quotes}}", {})).to eq("My 'string'")
    end

    it 'returns empty string when nil' do
      expect(evaluate('{{escape_quotes value}}', {value: nil})).to eq("")
      expect(evaluate("{{#escape_quotes}}{{value}}{{/escape_quotes}}", {value: nil})).to eq("")
    end
  end

  context 'hh_escape_double_quotes' do
    it 'escapes double quotes' do
      expect(evaluate('{{escape_double_quotes value}}', {value: 'My "string"'})).to eq('My \"string\"')
      expect(evaluate('{{#escape_double_quotes}}My "string"{{/escape_double_quotes}}', {})).to eq('My \"string\"')
    end

    it 'leaves single quotes' do
      expect(evaluate('{{escape_double_quotes value}}', {value: "My 'string'"})).to eq("My 'string'")
      expect(evaluate("{{#escape_double_quotes}}My 'string'{{/escape_double_quotes}}", {})).to eq("My 'string'")
    end

    it 'returns empty string when nil' do
      expect(evaluate('{{escape_double_quotes value}}', {value: nil})).to eq("")
      expect(evaluate("{{#escape_double_quotes}}{{value}}{{/escape_double_quotes}}", {value: nil})).to eq("")
    end
  end

  context 'hh_escape_single_quotes' do
    it 'escapes single quotes' do
      expect(evaluate('{{escape_single_quotes value}}', {value: "My 'string'"})).to eq("My \\'string\\'")
      expect(evaluate("{{#escape_single_quotes}}My 'string'{{/escape_single_quotes}}", {})).to eq("My \\'string\\'")
    end

    it 'leaves double quotes' do
      expect(evaluate('{{escape_single_quotes value}}', {value: 'My "string"'})).to eq('My "string"')
      expect(evaluate('{{#escape_single_quotes}}My "string"{{/escape_single_quotes}}', {})).to eq('My "string"')
    end

    it 'returns empty string when nil' do
      expect(evaluate('{{escape_single_quotes value}}', {value: nil})).to eq("")
      expect(evaluate("{{#escape_single_quotes}}{{value}}{{/escape_single_quotes}}", {value: nil})).to eq("")
    end
  end

  context 'hh_unescape_single_quotes' do
    it 'removes backslashe before single quotes' do
      expect(evaluate('{{unescape_single_quotes value}}', {value: "My \\'string\\'"})).to eq("My 'string'")
      expect(evaluate("{{#unescape_single_quotes}}My \\'string\\'{{/unescape_single_quotes}}", {})).to eq("My 'string'")
    end
  end

  context 'hh_escape_backslashes_and_double_quotes' do
    it 'escapes double quotes' do
      simple_template = '{{escape_backslashes_and_double_quotes value}}'
      block_template = '{{#escape_backslashes_and_double_quotes}}{{value}}{{/escape_backslashes_and_double_quotes}}'

      expect(evaluate(simple_template, {value: 'My "string"'})).to eq('My \"string\"')
      expect(evaluate(simple_template, {value: 'My \string\\'})).to eq('My \\\\string\\\\')
      expect(evaluate(simple_template, {value: 'My \"string\"'})).to eq('My \\\\\"string\\\\\"')

      expect(evaluate(block_template, {value: 'My "string"'})).to eq('My \"string\"')
      expect(evaluate(block_template, {value: 'My \string\\'})).to eq('My \\\\string\\\\')
      expect(evaluate(block_template, {value: 'My \"string\"'})).to eq('My \\\\\"string\\\\\"')

    end

    it 'returns empty string when nil' do
      expect(evaluate('{{escape_backslashes_and_double_quotes value}}', {value: nil})).to eq("")
      expect(evaluate("{{#escape_backslashes_and_double_quotes}}{{value}}{{/escape_backslashes_and_double_quotes}}", {value: nil})).to eq("")
    end
  end

  context 'hh_escape_new_line' do
    it 'escapes new lines' do
      template = "{{escape_new_line txt}}"
      expect(evaluate(template, {txt: "my\ntext\non\nmultiple lines"})).to eq("my\\ntext\\non\\nmultiple lines")
    end

    it 'also works with blocks' do
      template = "{{#escape_new_line}} I have some \n lines {{/escape_new_line}}"
      expect(evaluate(template, {})).to eq(" I have some \\n lines ")
    end

    it 'works with nil' do
      template = "A{{escape_new_line txt}}Z"
      expect(evaluate(template, {txt: nil})).to eq("AZ")
    end
  end

  context 'hh_remove_surrounding_quotes' do
    it 'removes simple or double quotes at the beginning or the end of the text' do
      template = "{{remove_surrounding_quotes txt}}"

      expect(evaluate(template, {txt: '"some text"'})).to eq("some text")
      expect(evaluate(template, {txt: '""'})).to eq("")
      expect(evaluate(template, {txt: "'some text'"})).to eq("some text")
      expect(evaluate(template, {txt: "''"})).to eq("")
    end

    it 'only removes one quote' do
      template = "{{remove_surrounding_quotes txt}}"

      expect(evaluate(template, {txt: '"""some text"""'})).to eq('""some text""')
    end

    it 'removes quotes only if they are present on both sides' do
      template = "{{remove_surrounding_quotes txt}}"

      expect(evaluate(template, {txt: '\"some text\"'})).to eq('\"some text\"')
      expect(evaluate(template, {txt: "'hello': 742"})).to eq("'hello': 742")
    end

    it 'leaves intact quotes inside the text' do
      template = "{{remove_surrounding_quotes txt}}"

      expect(evaluate(template, {txt: '"some "awesome" text"'})).to eq('some "awesome" text')
    end

    it 'also works with blocks' do
      template = '{{#remove_surrounding_quotes}}"This is "my" text"{{/remove_surrounding_quotes}}'
      expect(evaluate(template, {})).to eq('This is "my" text')
    end

    it 'works with nil' do
      template = "A{{remove_surrounding_quotes txt}}Z"
      expect(evaluate(template, {txt: nil})).to eq("AZ")
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

  context 'hh_description_with_annotations' do
    it 'Surround a line with double quotes if it starts with an annotation steps' do
      commenter = [
        "First line",
        "Given line",
        "When line",
        "    Then line",
        "And line",
        "But line",
        "* line",
        "    * line",
        "Last line"
      ].join("\n")
      expect(instance.hh_description_with_annotations(nil, commenter, nil)).to eq([
        "First line",
        "\"Given line\"",
        "\"When line\"",
        "\"    Then line\"",
        "\"And line\"",
        "\"But line\"",
        "\"* line\"",
        "\"    * line\"",
        "Last line"
      ].join("\n"))
    end

    it 'Surround a line with double quotes if it starts with an #' do
      commenter = [
        "First line",
        "# an other line",
        "",
        "# last line"
      ].join("\n")
      expect(instance.hh_description_with_annotations(nil, commenter, nil)).to eq([
        "First line",
        "\"# an other line\"",
        "",
        "\"# last line\""
      ].join("\n"))
    end

    it 'Surround a line with double quotes if it starts with an annotation steps (case insensitive)' do
      commenter = [
        "given line",
        "when line",
        "    THEN line",
        "aND line",
        "but line"
      ].join("\n")
      expect(instance.hh_description_with_annotations(nil, commenter, nil)).to eq([
        "\"given line\"",
        "\"when line\"",
        "\"    THEN line\"",
        "\"aND line\"",
        "\"but line\""
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

  context 'hh_close_curly' do
    it 'returns an closing curly brace' do
      expect(instance.hh_close_curly(nil, nil)).to eq('}')
    end
  end

  context 'hh_strip_regexp_delimiters' do
    it 'removes ^ at the beginning and $ at the end when present' do
      expect(instance.hh_strip_regexp_delimiters(nil, 'Plic', nil)).to eq('Plic')
      expect(instance.hh_strip_regexp_delimiters(nil, '^Plic', nil)).to eq('Plic')
      expect(instance.hh_strip_regexp_delimiters(nil, 'Plic$', nil)).to eq('Plic')
      expect(instance.hh_strip_regexp_delimiters(nil, '^Plic$', nil)).to eq('Plic')
    end

    it 'let them intact if they are not at the beginning of end' do
      expect(instance.hh_strip_regexp_delimiters(nil, 'This cost 10$ more than expected', nil)).to eq('This cost 10$ more than expected')
      expect(instance.hh_strip_regexp_delimiters(nil, 'Hey ^^', nil)).to eq('Hey ^^')
    end
  end

  context "hh_trim_surrounding_characters" do
    it 'removes the given character around the text' do
      template = '{{#trim_surrounding_characters "#"}}{{txt}}{{/trim_surrounding_characters}}'

      expect(evaluate(template, {txt: '##some text##'})).to eq("some text")
      expect(evaluate(template, {txt: '##some#text##'})).to eq("some#text")
      expect(evaluate(template, {txt: 'some text##'})).to eq("some text")
    end

    it 'can use multiple characters' do
      template = '{{#trim_surrounding_characters "__"}}{{txt}}{{/trim_surrounding_characters}}'

      expect(evaluate(template, {txt: '__my_very_private_function__'})).to eq("my_very_private_function")
      expect(evaluate(template, {txt: '_my_a_bit_private_function'})).to eq("_my_a_bit_private_function")
    end
  end

  context "hh_remove_last_character" do
    it 'removes the last character of the string if it is the correct one' do
      template = '{{#remove_last_character ":"}}{{txt}}{{/remove_last_character}}'

      expect(evaluate(template, {txt: 'Something ending with a colon:'})).to eq("Something ending with a colon")
      expect(evaluate(template, {txt: 'Something not ending with a colon :)'})).to eq("Something not ending with a colon :)")
      expect(evaluate(template, {txt: ''})).to eq("")
    end
  end

  context "hh_replace" do
    it 'replaces a string by another one' do
      template = '{{#replace "plic" "ploc"}}{{txt}}{{/replace}}'

      expect(evaluate(template, {txt: 'When I plic'})).to eq("When I ploc")
    end
  end

  context 'hh_if_includes' do
    it 'returns the true block if array contains the element' do
      template = '{{#if_includes array element}}true block{{else}}false block{{/if_includes}}'

      expect(evaluate(template, array: %w[a b c], element: 'a')).to eq('true block')
    end

    it 'returns the false block if array does not contain the element' do
      template = '{{#if_includes array element}}true block{{else}}false block{{/if_includes}}'

      expect(evaluate(template, array: %w[a b c], element: 'd')).to eq('false block')
    end

    it 'returns the false block if array is empty' do
      template = '{{#if_includes array element}}true block{{else}}false block{{/if_includes}}'

      expect(evaluate(template, array: %w[], element: 'a')).to eq('false block')
    end

    it 'returns the false block if array is nil' do
      template = '{{#if_includes array element}}true block{{else}}false block{{/if_includes}}'

      expect(evaluate(template, array: nil, element: 'a')).to eq('false block')
    end

    it 'does nothing if there is no false block and element not in array' do
      template = '{{#if_includes array element}}true block{{/if_includes}}'
      expect(evaluate(template, array: %w[b c], element: 'a')).to eq('')
    end
  end
end
