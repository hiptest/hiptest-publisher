require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/zest-publisher/renderer'
require_relative '../lib/zest-publisher/nodes'

describe Zest::Renderer do
  context 'get_template_path' do
    it 'checks if the file exists in the common templates' do
      node = Zest::Nodes::StringLiteral.new('coucou')
      renderer = Zest::Renderer.new({language: 'python'})

      expect(renderer.get_template_path(node)).to eq('./lib/templates/common/stringliteral.erb')
    end

    it 'checks in the language template folder' do
      node = Zest::Nodes::Assign.new('x', 1)
      renderer = Zest::Renderer.new({language: 'ruby'})

      expect(renderer.get_template_path(node)).to eq('./lib/templates/ruby/assign.erb')
    end

    it 'checks in the framework specific folder if existing' do
      node = Zest::Nodes::Scenarios.new([])
      renderer = Zest::Renderer.new({language: 'ruby', framework: 'minitest'})

      expect(renderer.get_template_path(node)).to eq('./lib/templates/ruby/minitest/scenarios.erb')
    end
  end

  context 'indent_block' do
    it 'indent a block' do
      renderer = Zest::Renderer.new({})
      block = ["A single line", "Two\nLines", "Three\n  indented\n    lines"]
      expect(renderer.indent_block(block)).to eq([
        "  A single line",
        "  Two",
        "  Lines",
        "  Three",
        "    indented",
        "      lines",
        ""
        ].join("\n"))
    end

    it 'can have a specified indentation' do
      renderer = Zest::Renderer.new({})
      expect(renderer.indent_block(["La"], "---")).to eq("---La\n")
    end

    it 'if no indentation is specified, it uses the one from the context' do
      renderer = Zest::Renderer.new({:indentation => '~'})

      expect(renderer.indent_block(["La"])).to eq("~La\n")
    end

    it 'default indentation is wo spaces' do
      renderer = Zest::Renderer.new({})
      expect(renderer.indent_block(["La"])).to eq("  La\n")
    end

    it 'also accepts a separator to join the result (aded to te line return)' do
      renderer = Zest::Renderer.new({})
      expect(renderer.indent_block(["A", "B\nC", "D\nE"], '  ', '#')).to eq("  A\n#  B\n  C\n#  D\n  E\n")
    end
  end
end