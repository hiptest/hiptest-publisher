require "spec_helper"
require_relative "../lib/hiptest-publisher/options_parser"
require_relative "../lib/hiptest-publisher/formatters/reporter"

describe OptionParser do

  context "with config file" do
    it "merges options from config file" do
      f = Tempfile.new('config')
      File.write(f, "language = java")
      options = OptionsParser.parse([
        "--config-file", f.path], NullReporter.new)
      expect(options.language).to eq("java")
    end

    it "does not overwrite an option already defined on cli" do
      f = Tempfile.new('config')
      File.write(f, "language = java\nframework = tartanpion")
      options = OptionsParser.parse([
        "--language", "ruby",
        "--config-file", f.path], NullReporter.new)
      expect(options.language).to eq("ruby")
      expect(options.framework).to eq("tartanpion")
    end

    it "works if config file is nil" do
      options = OpenStruct.new
      options.config = nil
      expect { FileConfigParser.update_options(options, NullReporter.new) }.not_to raise_error
    end
  end
end


describe LanguageConfigParser do

  let(:options) { OpenStruct.new(language: "ruby") }

  describe "#filtered_group_names" do
    it "rejects groups not specified in --only clip option" do
      options = OpenStruct.new(language: "ruby", only: "actionwords")
      expect(LanguageConfigParser.new(options).filtered_group_names).to match_array(["actionwords"])

      options = OpenStruct.new(language: "ruby", only: "actionwords,tests")
      expect(LanguageConfigParser.new(options).filtered_group_names).to match_array(["actionwords", "tests"])
    end

    it "keeps all groups if --only option is not specified" do
      options = OpenStruct.new(language: "ruby")
      expect(LanguageConfigParser.new(options).filtered_group_names).to match_array(["actionwords", "tests"])
    end
  end

  describe ".config_path_for" do
    context "given a language" do
      it "searches an language configuration file in config/<language>.conf" do
        expect(LanguageConfigParser.config_path_for(options)).to end_with("config/ruby.conf")
      end
    end

    context "given a language and a framework" do
      it "searches an language configuration file in lib/templates/config<language>/<framework>" do
        options.framework = "minitest"
        expect(LanguageConfigParser.config_path_for(options)).to end_with("config/ruby-minitest.conf")
      end

      it "fallbacks to lib/templates/<language> if framework does not no match anything" do
        options.framework = "youplala"
        expect(LanguageConfigParser.config_path_for(options)).to end_with("config/ruby.conf")
      end
    end

    it "raises an error if language config file could not be found" do
      options.language = "carakoko"
      options.framework = "lalakoko"
      expect{LanguageConfigParser.config_path_for(options)}.
        to raise_error('cannot find configuration file in "./config" for language "carakoko" and framework "lalakoko"')
    end
  end

  describe "#new" do
    it "returns the LanguageConfigParser for given options" do
      expect(LanguageConfigParser.new(options)).to be_a LanguageConfigParser
    end

    it "raises an error if language config file cannot be found" do
      options.language = "carakoko"
      expect{LanguageConfigParser.new(options)}.
        to raise_error('cannot find configuration file in "./config" for language "carakoko"')
    end
  end
end
