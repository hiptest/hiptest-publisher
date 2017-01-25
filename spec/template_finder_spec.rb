require 'spec_helper'
require_relative '../lib/hiptest-publisher/options_parser'

describe TemplateFinder do
  context '#get_template_path' do
    it 'checks if the file exists in the common templates' do
      template_finder = context_for(language: 'python').template_finder
      expect(template_finder.get_template_path('stringliteral')).to eq('./lib/templates/common/stringliteral.hbs')
    end

    it 'looks in the language template folder' do
      template_finder = context_for(language: 'ruby').template_finder
      expect(template_finder.get_template_path('stringliteral')).to eq('./lib/templates/common/stringliteral.hbs')
      expect(template_finder.get_template_path('assign')).to eq('./lib/templates/ruby/assign.hbs')
    end

    it 'looks in the framework specific folder if existing' do
      template_finder = context_for(language: 'ruby', framework: 'minitest').template_finder
      expect(template_finder.get_template_path('scenarios')).to eq('./lib/templates/ruby/minitest/scenarios.hbs')
    end

    context 'when option[:overriden_templates] is set' do
      let(:overriden_templates_dir) {
        @overriden_templates_dir_created = true
        d = Dir.mktmpdir
        FileUtils.mkdir_p("#{d}/python/unittest")
        d
      }

      after(:each) {
        if @overriden_templates_dir_created
          FileUtils.rm_rf(overriden_templates_dir)
        end
      }

      # create a new one each time because it is stateful
      def template_finder
        context_for(language: 'python', overriden_templates: overriden_templates_dir).template_finder
      end

      it 'if no matching template file found in overriden templates dir, it uses the default template file' do
        expect(template_finder.get_template_path('scenarios')).to eq('./lib/templates/python/scenarios.hbs')
      end

      it 'if matching template file found in overriden templates dir, it uses the overriden template file' do
        FileUtils.touch("#{overriden_templates_dir}/scenarios.hbs")
        expect(template_finder.get_template_path('scenarios')).to eq("#{overriden_templates_dir}/scenarios.hbs")
      end

      it 'looks for template in overriden templates base dir first' do
        FileUtils.touch("#{overriden_templates_dir}/actionwords.hbs")
        FileUtils.touch("#{overriden_templates_dir}/python/unittest/actionwords.hbs")
        FileUtils.touch("#{overriden_templates_dir}/python/actionwords.hbs")
        expect(template_finder.get_template_path('actionwords')).to eq("#{overriden_templates_dir}/actionwords.hbs")
      end

      it 'looks for template in each template subdirectory, both in overriden templates and hiptest-publisher template' do
        FileUtils.touch("#{overriden_templates_dir}/python/unittest/actionwords.hbs")
        FileUtils.touch("#{overriden_templates_dir}/python/actionwords.hbs")
        expect(template_finder.get_template_path('actionwords')).to eq("#{overriden_templates_dir}/python/unittest/actionwords.hbs")

        # if removing the overriden_template/python/unittest/actionwords.hbs file,
        # it should pick the hiptest publisher one
        # it should not pick the overriden_template/python/unittestactionwords.hbs one
        FileUtils.rm("#{overriden_templates_dir}/python/unittest/actionwords.hbs")
        expect(template_finder.get_template_path('actionwords')).to eq("./lib/templates/python/unittest/actionwords.hbs")
      end
    end

    context 'when option[:fallback_template] is set' do
      it 'uses the given fallback template if no template is found' do
        template_finder = context_for(only: 'features', language: 'cucumber', fallback_template: "empty").template_finder
        expect(template_finder.get_template_path('assign')).to eq('./lib/templates/common/empty.hbs')
      end

      it 'still uses the template if found' do
        template_finder = context_for(only: 'features', language: 'cucumber', fallback_template: "empty").template_finder
        expect(template_finder.get_template_path('stringliteral')).to eq('./lib/templates/gherkin/stringliteral.hbs')
      end
    end
  end
end
