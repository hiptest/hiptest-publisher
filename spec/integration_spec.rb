require 'spec_helper'
require 'fileutils'
require 'webmock/rspec'
require_relative '../lib/hiptest-publisher'

describe Hiptest::Publisher do

  let(:output_dir) {
    @output_dir_created = true
    Dir.mktmpdir
  }

  before(:each) {
    # partially prevent printing on stdout during rspec run (hacky! comment to use pry correctly)
    allow(STDOUT).to receive(:print)
  }

  after(:each) {
    if @output_dir_created
      FileUtils.rm_rf(output_dir)
    end
  }

  context "calling all languages/framework should not produce any errors" do
    [
      [],
      ["--test-run-id=987"],
      ["--split-scenarios"],
      ["--with-folders"],
      ["--leafless-export"],
      ["--test-run-id=987", "--split-scenarios"],
      ["--test-run-id=987", "--leafless-export"], # leafless-export is ignored for test-run, TODO? print an error and exit?
      ["--split-scenarios", "--leafless-export"],
      ["--split-scenarios", "--with-folders"],
      ["--test-run-id=987", "--split-scenarios", "--leafless-export"],
      ["--test-run-id=987", "--split-scenarios", "--with-folders"],
      ["--split-scenarios", "--leafless-export", "--with-folders"],
      ["--test-run-id=987", "--split-scenarios", "--leafless-export", "--with-folders"],
    ].each do |extra_args|
      context extra_args.join(" ") do
        [
          %w"cucumber ruby",
          %w"cucumber java",
          %w"cucumber javascript",
          %w"java junit",
          %w"java testng",
          %w"javascript qunit",
          %w"javascript jasmine",
          %w"javascript mocha",
          %w"python unittest",
          %w"csharp nunit",
          %w"robotframework",
          %w"ruby minitest",
          %w"ruby rspec",
          %w"seleniumide",
          %w"specflow",
          %w"php phpunit",
          %w"behave",
          %w"jbehave",
          %w"behat"
        ].each do |language, framework|
          assertion_text = "--language=#{language}"
          assertion_text <<  " --framework=#{framework}" if framework
          it assertion_text do
            test_runs_json = { test_runs: [{id: "987",name: "Sprint 1"}] }.to_json
            stub_request(:get, "https://app.hiptest.com/publication/123456789/test_runs").
              to_return(body: test_runs_json, headers: {'Content-Type' => 'application/json'})
            stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
              to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
            stub_request(:get, "https://app.hiptest.com/publication/123456789/test_run/987").
              to_return(body: File.read('samples/xml_input/Hiptest test run.xml'))
            stub_request(:get, "https://app.hiptest.com/publication/123456789/leafless_tests").
              to_return(body: File.read('samples/xml_input/Hiptest automation.xml'))
            args = [
              "--language", language,
              "--output-directory", output_dir,
              "--token", "123456789",
            ]
            args.concat(["--framework", framework]) if framework
            args.concat(extra_args)
            expect {
              publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
              publisher.run
            }.not_to raise_error
          end
        end
      end
    end
  end

  context 'using --meta option in templates' do
    let(:templates_dir) {
      @templates_dir_created = true
      Dir.mktmpdir
    }

    before(:each) {
      File.write("#{templates_dir}/scenarios.hbs", "This is a custom template referencing meta:custom {{ context.meta.custom }}")
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
    }

    after(:each) {
      if @templates_dir_created
        FileUtils.rm_rf(templates_dir)
      end
    }

    let(:arguments) {
      [
        "--language", 'ruby',
        "--output-directory", output_dir,
        "--token", "123456789",
        "--overriden-templates", templates_dir
      ]
    }

    it 'does not fail when the meta is not set' do
      expect {
        publisher = Hiptest::Publisher.new(arguments, listeners: [ErrorListener.new])
        publisher.run
      }.not_to raise_error

      expect(File.read("#{output_dir}/project_spec.rb")).to eq("This is a custom template referencing meta:custom ")
    end

    it 'uses the value when set' do
      arguments.concat(["--meta", "custom:My_meta_value_in_use"])
      expect {
        publisher = Hiptest::Publisher.new(arguments, listeners: [ErrorListener.new])
        publisher.run
      }.not_to raise_error

      expect(File.read("#{output_dir}/project_spec.rb")).to eq("This is a custom template referencing meta:custom My_meta_value_in_use")
    end

    it 'can correctly use boolean values' do
      File.write("#{templates_dir}/scenarios.hbs", [
        "{{#unless context.meta.boolean}}This will be displayed as 'false' is interpreted as a boolean{{/unless}}",
        "{{#unless context.meta.nonBoolean}}This will not, even 0 is considered as a String{{/unless}}"
      ].join("\n"))

      arguments.concat(["--meta", "boolean:false,nonBoolean:0"])
      expect {
        publisher = Hiptest::Publisher.new(arguments, listeners: [ErrorListener.new])
        publisher.run
      }.not_to raise_error

      expect(File.read("#{output_dir}/project_spec.rb")).to eq("This will be displayed as 'false' is interpreted as a boolean\n")
    end
  end
end
