require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/zest-publisher/renderer'
require_relative '../lib/zest-publisher/nodes'

describe Zest::Renderer do
  context 'get_template_path' do
    it 'checks if the file exists in the common templates' do
      node = Zest::Nodes::StringLiteral.new('coucou')
      renderer = Zest::Renderer.new({language: 'python', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')
    end

    it 'checks in the language template folder' do
      node = Zest::Nodes::Assign.new('x', 1)
      renderer = Zest::Renderer.new({language: 'ruby', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/assign.hbs')
    end

    it 'checks in the framework specific folder if existing' do
      node = Zest::Nodes::Scenarios.new([])
      renderer = Zest::Renderer.new({language: 'ruby', framework: 'minitest', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/minitest/scenarios.hbs')
    end
  end
end