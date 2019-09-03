require 'spec_helper'
require_relative '../lib/hiptest-publisher/template_finder'

describe TemplateFinder do
  before do
    allow_any_instance_of(TemplateFinder).to receive(:hiptest_publisher_path).and_return("./spec/fixtures")
  end

  context '#get_template_path' do
    it 'checks if the file exists in the common templates' do
      template_finder = TemplateFinder.new(template_dirs: ['python-unittest', 'python', 'common'])
      expect(template_finder.get_template_path('stringliteral')).to eq('./spec/fixtures/lib/templates/common/stringliteral.hbs')
    end

    it 'looks in the language template folder' do
      template_finder = TemplateFinder.new(template_dirs: ['rspec', 'ruby', 'common'])
      expect(template_finder.get_template_path('stringliteral')).to eq('./spec/fixtures/lib/templates/common/stringliteral.hbs')
      expect(template_finder.get_template_path('assign')).to eq('./spec/fixtures/lib/templates/languages/ruby/version-2.3/assign.hbs')
    end

    it 'looks in the framework specific folder if existing' do
      template_finder = TemplateFinder.new(template_dirs: ['minitest', 'ruby', 'common'])
      expect(template_finder.get_template_path('scenarios')).to eq('./spec/fixtures/lib/templates/frameworks/minitest/version-5.0/scenarios.hbs')
    end

    context 'when multiple versions of the language are available' do
      it 'picks the first one in the list by default' do
        template_finder = TemplateFinder.new(template_dirs: ['rspec', 'ruby', 'common'])
        expect(template_finder.get_template_path('assign')).to eq('./spec/fixtures/lib/templates/languages/ruby/version-2.3/assign.hbs')
      end

      it 'selects the one specified if available' do
        template_finder = TemplateFinder.new(template_dirs: ['rspec', 'ruby', 'common'], ruby_version: '2.7')
        expect(template_finder.get_template_path('assign')).to eq('./spec/fixtures/lib/templates/languages/ruby/version-2.7/assign.hbs')
      end

      it 'picks the first one if the selected one does not exist' do
        template_finder = TemplateFinder.new(template_dirs: ['rspec', 'ruby', 'common'], ruby_version: '4.7')
        expect(template_finder.get_template_path('assign')).to eq('./spec/fixtures/lib/templates/languages/ruby/version-2.3/assign.hbs')
      end
    end

    context 'when multiple versions of the framework are available' do
      it 'picks the first one in the list by default' do
        template_finder = TemplateFinder.new(template_dirs: ['minitest', 'ruby', 'common'])
        expect(template_finder.get_template_path('scenarios')).to eq('./spec/fixtures/lib/templates/frameworks/minitest/version-5.0/scenarios.hbs')
      end

      it 'selects the one specified if available' do
        template_finder = TemplateFinder.new(template_dirs: ['minitest', 'ruby', 'common'], minitest_version: '7.0')
        expect(template_finder.get_template_path('scenarios')).to eq('./spec/fixtures/lib/templates/frameworks/minitest/version-7.0/scenarios.hbs')
      end

      it 'picks the first one if the selected one does not exist' do
        template_finder = TemplateFinder.new(template_dirs: ['minitest', 'ruby', 'common'], minitest_version: '17.0')
        expect(template_finder.get_template_path('scenarios')).to eq('./spec/fixtures/lib/templates/frameworks/minitest/version-5.0/scenarios.hbs')
      end
    end

    context 'when specific sub folders exists for group' do
      it 'picks the template in that sub-folder if the language group is the correct one' do
        template_finder = TemplateFinder.new(template_dirs: ['cucumber-java', 'java', 'common'], language_group: 'actionwords')

        expect(template_finder.get_template_path('assign')).to eq('./spec/fixtures/lib/templates/frameworks/cucumber-java/version-1.2/actionwords/assign.hbs')
      end

      it 'picks the root one if there is none for the group' do
        template_finder = TemplateFinder.new(template_dirs: ['cucumber-java', 'java', 'common'], language_group: 'step_definitions')

        expect(template_finder.get_template_path('assign')).to eq('./spec/fixtures/lib/templates/frameworks/cucumber-java/version-1.2/assign.hbs')
      end
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
        template_finder = TemplateFinder.new(template_dirs: ['python-unittest', 'python', 'common'], overriden_templates: overriden_templates_dir)
      end

      it 'if no matching template file found in overriden templates dir, it uses the default template file' do
        expect(template_finder.get_template_path('scenarios')).to eq('./spec/fixtures/lib/templates/languages/python/version-2.7/scenarios.hbs')
      end

      it 'if matching template file found in overriden templates dir, it uses the overriden template file' do
        FileUtils.touch("#{overriden_templates_dir}/scenarios.hbs")
        expect(template_finder.get_template_path('scenarios')).to eq("#{overriden_templates_dir}/scenarios.hbs")
      end

      it 'looks for template in overriden templates base dir first' do
        FileUtils.touch("#{overriden_templates_dir}/actionwords.hbs")
        FileUtils.mkdir_p("#{overriden_templates_dir}/frameworks/python-unittest/version-2.7")
        FileUtils.touch("#{overriden_templates_dir}/frameworks/python-unittest/version-2.7/actionwords.hbs")
        expect(template_finder.get_template_path('actionwords')).to eq("#{overriden_templates_dir}/actionwords.hbs")
      end
    end

    context 'when option[:fallback_template] is set' do
      it 'uses the given fallback template if no template is found' do
        template_finder = TemplateFinder.new(template_dirs: ['python-unittest', 'python', 'common'], fallback_template: 'empty')
        expect(template_finder.get_template_path('assign')).to eq('./spec/fixtures/lib/templates/common/empty.hbs')
      end

      it 'still uses the template if found' do
        template_finder = TemplateFinder.new(template_dirs: ['python-unittest', 'python', 'common'], fallback_template: 'empty')
        expect(template_finder.get_template_path('scenarios')).to eq('./spec/fixtures/lib/templates/languages/python/version-2.7/scenarios.hbs')
      end
    end
  end
end
