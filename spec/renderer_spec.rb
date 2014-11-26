require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/renderer'
require_relative '../lib/hiptest-publisher/nodes'

describe Hiptest::Renderer do
  context 'get_template_path' do
    it 'checks if the file exists in the common templates' do
      node = Hiptest::Nodes::StringLiteral.new('coucou')
      renderer = Hiptest::Renderer.new({language: 'python', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')
    end

    it 'checks in the language template folder' do
      node = Hiptest::Nodes::Assign.new('x', 1)
      renderer = Hiptest::Renderer.new({language: 'ruby', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/assign.hbs')
    end

    it 'checks in the framework specific folder if existing' do
      node = Hiptest::Nodes::Scenarios.new([])
      renderer = Hiptest::Renderer.new({language: 'ruby', framework: 'minitest', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/minitest/scenarios.hbs')
    end
  end
end