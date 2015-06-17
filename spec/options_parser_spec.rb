require "spec_helper"
require_relative "../lib/hiptest-publisher/options_parser"

describe LanguageConfigParser do

  let(:options) { OpenStruct.new(language: "ruby") }

  describe ".config_path_for" do
    context "given a language" do
      it "searches an output_config file in lib/templates/<language>" do
        expect(LanguageConfigParser.config_path_for(options)).to end_with("lib/templates/ruby/output_config")
      end
    end

    context "given a language and a framework" do
      it "searches an output_config file in lib/templates/<language>/<framework>" do
        options.framework = "minitest"
        expect(LanguageConfigParser.config_path_for(options)).to end_with("lib/templates/ruby/minitest/output_config")
      end

      it "fallbacks to lib/templates/<language> if framework does not no match anything" do
        options.framework = "youplala"
        expect(LanguageConfigParser.config_path_for(options)).to end_with("lib/templates/ruby/output_config")
      end
    end

    it "raises an error if language config file could not be found" do
      options.language = "carakoko"
      options.framework = "lalakoko"
      expect{LanguageConfigParser.config_path_for(options)}.
        to raise_error('cannot find output_config file in "./lib/templates" for language "carakoko" and framework "lalakoko"')
    end
  end

  describe "#new" do
    it "returns the LanguageConfigParser for given options" do
      expect(LanguageConfigParser.new(options)).to be_a LanguageConfigParser
    end

    it "raises an error if language config file cannot be found" do
      options.language = "carakoko"
      expect{LanguageConfigParser.new(options)}.
        to raise_error('cannot find output_config file in "./lib/templates" for language "carakoko"')
    end
  end
end
