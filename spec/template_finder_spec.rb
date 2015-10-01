require 'spec_helper'
require_relative '../lib/hiptest-publisher/options_parser'

describe TemplateFinder do
  context '#get_template_path' do
    it 'checks if the file exists in the common templates' do
      template_finder = context_for(language: 'python').template_finder
      expect(template_finder.get_template_path('stringliteral', 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')
    end

    it 'looks in the language template folder' do
      template_finder = context_for(language: 'ruby').template_finder
      expect(template_finder.get_template_path('stringliteral', 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')
      expect(template_finder.get_template_path('assign', 'hbs')).to eq('./lib/templates/ruby/assign.hbs')
    end

    it 'looks in the framework specific folder if existing' do
      template_finder = context_for(language: 'ruby', framework: 'minitest').template_finder
      expect(template_finder.get_template_path('scenarios', 'hbs')).to eq('./lib/templates/ruby/minitest/scenarios.hbs')
    end

    context 'when option[:overriden_templates] is set' do
      it 'if no matching template file found in overriden templates dir, it uses the default template file' do
        Dir.mktmpdir("overriden_templates") do |dir|
          template_finder = context_for(language: 'python', overriden_templates: "#{dir}").template_finder
          expect(template_finder.get_template_path('scenarios', 'hbs')).to eq('./lib/templates/python/scenarios.hbs')
        end
      end

      it 'if matching template file found in overriden templates dir, it uses the overriden template file' do
        Dir.mktmpdir("overriden_templates") do |dir|
          template_finder = context_for(language: 'python', overriden_templates: "#{dir}").template_finder
          File.write("#{dir}/scenarios.hbs", "")
          expect(template_finder.get_template_path('scenarios', 'hbs')).to eq("#{dir}/scenarios.hbs")
        end
      end
    end

    context 'when option[:fallback_template] is set' do
      it 'uses the given fallback template if no template is found' do
        template_finder = context_for(group_name: 'features', language: 'cucumber', fallback_template: "empty").template_finder
        expect(template_finder.get_template_path('assign', 'hbs')).to eq('./lib/templates/cucumber/empty.hbs')
      end

      it 'still uses the template if found' do
        template_finder = context_for(group_name: 'features', language: 'cucumber', fallback_template: "empty").template_finder
        expect(template_finder.get_template_path('stringliteral', 'hbs')).to eq('./lib/templates/cucumber/stringliteral.hbs')
      end
    end
  end
end
