require 'spec_helper'
require_relative '../lib/hiptest-publisher/options_parser'

describe LanguageConfigParser do
  context '#config_path_for' do
    it 'checks if the file exists in the normal config directory' do
      cli_options = cli_opts_for(language: 'python', framework: 'unittest')
      expect(LanguageConfigParser.config_path_for(cli_options)).to eq("#{Dir.pwd}/lib/config/python-unittest.conf")
    end

    context 'when option[:overriden_language_configs] is set' do
      let(:overriden_language_configs_dir) {
        @overriden_language_configs_dir_created = true
        d = Dir.mktmpdir
        FileUtils.mkdir_p(d)
        d
      }

      after(:each) {
        if @overriden_language_configs_dir_created
          FileUtils.rm_rf(overriden_language_configs_dir)
        end
      }

      it 'if no matching language config file found in overriden language config dir, it uses the default template file' do
        cli_options = cli_opts_for(language: 'python', framework: 'unittest', overriden_language_configs: overriden_language_configs_dir)
        expect(LanguageConfigParser.config_path_for(cli_options)).to eq("#{Dir.pwd}/lib/config/python-unittest.conf")
      end

      it 'if matching language config file found in overriden language config dir, it uses the overriden template file' do
        FileUtils.touch("#{overriden_language_configs_dir}/python-unittest.conf")
        cli_options = cli_opts_for(language: 'python', framework: 'unittest', overriden_language_configs: overriden_language_configs_dir)
        expect(LanguageConfigParser.config_path_for(cli_options)).to eq("#{overriden_language_configs_dir}/python-unittest.conf")
      end

      it 'if no matching language config file found in overriden language config dir or the default dir, it raises an ArgumentError' do
        cli_options = cli_opts_for(language: 'foo', framework: 'bar', overriden_language_configs: overriden_language_configs_dir)
        expect { LanguageConfigParser.config_path_for(cli_options) }.to raise_error(ArgumentError)
      end
    end
  end
end
