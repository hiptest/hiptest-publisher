require 'tmpdir'
require 'tempfile'
require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/renderer'
require_relative '../lib/hiptest-publisher/nodes'

describe Hiptest::Renderer do
  context '#get_template_path' do
    it 'checks if the file exists in the common templates' do
      node = Hiptest::Nodes::StringLiteral.new('coucou')
      output_context = context_for(language: 'python')
      renderer = Hiptest::Renderer.new(output_context)

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')
    end

    it 'checks in the language template folder' do
      node = Hiptest::Nodes::Assign.new('x', 1)
      output_context = context_for(language: 'ruby')
      renderer = Hiptest::Renderer.new(output_context)

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/assign.hbs')
    end

    it 'checks in the framework specific folder if existing' do
      node = Hiptest::Nodes::Scenarios.new([])
      output_context = context_for(language: 'ruby', framework: 'minitest')
      renderer = Hiptest::Renderer.new(output_context)

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/minitest/scenarios.hbs')
    end

    context 'searches first in overriden templates' do
      let(:node) { Hiptest::Nodes::Scenarios.new([])}

      it 'uses the default one if there is none overriden' do
        Dir.mktmpdir("overriden_templates") do |dir|
          output_context = context_for(language: 'python', overriden_templates: "#{dir}")
          renderer = Hiptest::Renderer.new(output_context)
          expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/python/scenarios.hbs')
        end
      end

      it 'uses the overriden template is it exists' do
        Dir.mktmpdir("overriden_templates") do |dir|
          output_context = context_for(language: 'python', overriden_templates: "#{dir}")
          renderer = Hiptest::Renderer.new(output_context)
          open("#{dir}/scenarios.hbs", 'w') { |f| f.puts ""}
          expect(renderer.get_template_path(node, 'hbs')).to eq("#{dir}/scenarios.hbs")
        end
      end
    end

    context 'when option[:fallback_template] is set' do
      it 'uses the given fallback template if no template is found' do
        node = Hiptest::Nodes::Assign.new("name", "value")

        output_context = context_for({language: 'cucumber', fallback_template: "empty"})
        renderer = Hiptest::Renderer.new(output_context)
        expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/cucumber/empty.hbs')
      end

      it 'still uses the template if found' do
        node = Hiptest::Nodes::StringLiteral.new("polop")

        output_context = context_for({language: 'cucumber', fallback_template: "empty"})
        renderer = Hiptest::Renderer.new(output_context)
        expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/cucumber/stringliteral.hbs')
      end
    end
  end

  describe "#render_node" do
    it "raises a ArgumentError when no templates is found" do
      node = Hiptest::Nodes::Call.new('Is anybody here?')
      output_context = context_for(language: 'baraccuda')
      renderer = Hiptest::Renderer.new(output_context)

      expect{
        renderer.render_node(node, nil)
      }.to raise_error(ArgumentError)
    end
  end
end
