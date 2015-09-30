require 'spec_helper'
require_relative '../lib/hiptest-publisher/options_parser'


describe TemplateFinder do
  context '#get_template_path' do
    it 'checks if the file exists in the common templates' do
      template_finder = context_for(language: 'python').template_finder
      expect(template_finder.get_template_path('stringliteral', 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')
    end

    it 'checks in the language template folder' do
      node = Hiptest::Nodes::Assign.new('x', 1)

      template_finder = context_for(language: 'ruby').template_finder
      expect(template_finder.get_template_path('stringliteral', 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')

      rendering_context = context_for(language: 'ruby')
      renderer = TemplateFinder.new(rendering_context)

      expect(template_finder.get_template_path('assign', 'hbs')).to eq('./lib/templates/ruby/assign.hbs')
    end

    it 'checks in the framework specific folder if existing' do
      node = Hiptest::Nodes::Scenarios.new([])
      rendering_context = context_for(language: 'ruby', framework: 'minitest')
      renderer = TemplateFinder.new(rendering_context)

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/minitest/scenarios.hbs')
    end

    context 'searches first in overriden templates' do
      let(:node) { Hiptest::Nodes::Scenarios.new([])}

      it 'uses the default one if there is none overriden' do
        Dir.mktmpdir("overriden_templates") do |dir|
          rendering_context = context_for(language: 'python', overriden_templates: "#{dir}")
          renderer = TemplateFinder.new(rendering_context)
          expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/python/scenarios.hbs')
        end
      end

      it 'uses the overriden template is it exists' do
        Dir.mktmpdir("overriden_templates") do |dir|
          rendering_context = context_for(language: 'python', overriden_templates: "#{dir}")
          renderer = TemplateFinder.new(rendering_context)
          open("#{dir}/scenarios.hbs", 'w') { |f| f.puts ""}
          expect(renderer.get_template_path(node, 'hbs')).to eq("#{dir}/scenarios.hbs")
        end
      end
    end

    context 'when option[:fallback_template] is set' do
      it 'uses the given fallback template if no template is found' do
        node = Hiptest::Nodes::Assign.new("name", "value")

        rendering_context = context_for({language: 'cucumber', fallback_template: "empty"})
        renderer = TemplateFinder.new(rendering_context)
        expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/cucumber/empty.hbs')
      end

      it 'still uses the template if found' do
        node = Hiptest::Nodes::StringLiteral.new("polop")

        rendering_context = context_for({language: 'cucumber', fallback_template: "empty"})
        renderer = TemplateFinder.new(rendering_context)
        expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/cucumber/stringliteral.hbs')
      end
    end
  end
end
