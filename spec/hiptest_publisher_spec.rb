require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/hiptest-publisher'

describe Hiptest::Publisher do

  class ErrorListener
    def dump_error(error, message)
      fail
    end

    def method_missing(*args)
    end
  end

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

  describe "--language=ruby" do
    it "exports correctly in the golden case" do
      stub_request(:get, "https://hiptest.net/publication/123456789/project?future=1").
        to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
      args = [
        "--language", "ruby",
        "--output-directory", output_dir,
        "--token", "123456789",
      ]
      publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
      publisher.run
      expect_same_files("samples/expected_output/Hiptest publisher", output_dir)
    end

    describe "actionwords modifications" do
      before(:each) do
        aw_signatures = YAML.load_file("samples/expected_output/Hiptest publisher/actionwords_signature.yaml")

        # simulate "Do something" has been deleted
        aw_signatures << {
          "name" => "Do something",
          "uid" => "a9bd8101-96bc-43d4-bd47-c429a60c6bdc",
          "parameters" => [{"name"=>"x"}]}

        # simulate "start publisher" has been created
        aw_signatures.reject! { |aw| aw["name"] == "start publisher" }

        # simulate "Parameters and assignements" has been renamed
        aw = aw_signatures.find {|e| e["name"] == "Parameters and assignements"}
        aw["name"] = "Parameters and assinements"

        # simulate "Control blocks" signature has changed
        aw = aw_signatures.find {|e| e["name"] == "Control blocks"}
        aw["parameters"] = []

        File.write("#{output_dir}/actionwords_signature.yaml", YAML.dump(aw_signatures))
      end

      def run_publisher_command(command)
        stub_request(:get, "https://hiptest.net/publication/123456789/project?future=1").
          to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
        args = [
          command,
          "--language", "ruby",
          "--output-directory", output_dir,
          "--token", "123456789",
        ]
        publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
        publisher.run
      end

      describe "--show-actionwords-diff" do
        it "displays differences in actionwords" do
          expect {
            run_publisher_command("--show-actionwords-diff")
          }.to output(a_string_including([
            "1 action word deleted:",
            "- Do something",
            "",
            "1 action word created:",
            "- start publisher",
            "",
            "1 action word renamed:",
            "- Parameters and assinements => Parameters and assignements",
            "",
            "1 action word which signature changed:",
            "- Control blocks",
          ].join("\n"))).to_stdout
        end
      end

      describe "--show-actionwords-deleted" do
        it "displays the method names of deleted actionwords" do
          expect {
            run_publisher_command("--show-actionwords-deleted")
          }.to output(a_string_including('do_something')).to_stdout
        end
      end

      describe "--show-actionwords-created" do
        it "displays the method stubs of created actionwords" do
          expect {
            run_publisher_command("--show-actionwords-created")
          }.to output(a_string_including([
            'def start_publisher(options = {})',
            '  # TODO: Implement action: "start publisher with options #{options}"',
            '  raise NotImplementedError',
            'end',
          ].join("\n"))).to_stdout
        end
      end

      describe "--show-actionwords-renamed" do
        it "displays a tabular list of renamed actionwords with old and new method names" do
          expect {
            run_publisher_command("--show-actionwords-renamed")
          }.to output(a_string_including(
            "parameters_and_assinements\tparameters_and_assignements",
          )).to_stdout
        end
      end

      describe "--show-actionwords-signature-changed" do
        it "displays the method stubs of the modified actionwords with its new signature" do
          expect {
            run_publisher_command("--show-actionwords-signature-changed")
          }.to output(a_string_including([
            'def control_blocks(x)',
            '  # Tags: parameters dsltests',
            '  while ((x < 0))',
            '    x = x + 1',
            '  end',
            '  if ((x == 0))',
            '    # TODO: Implement result: "#{x} is now equal to zero"',
            '  else',
            '    control_blocks(x - 1)',
            '  end',
            '  raise NotImplementedError',
            'end',
          ].join("\n"))).to_stdout
        end
      end
    end
  end

  def expect_same_files(expected_directory, actual_directory)
    aggregate_failures "output files" do
      actual_files = Dir.entries(actual_directory).reject { |f| [".", ".."].include?(f) }
      expected_files = Dir.entries(expected_directory).reject { |f| [".", ".."].include?(f) }
      expect(actual_files).to match_array(expected_files)

      common_files = (actual_files & expected_files)
      common_files.each do |file|
        actual_content = File.read("#{actual_directory}/#{file}")
        expected_content = File.read("#{expected_directory}/#{file}")
        expect(actual_content).to eq(expected_content), "File #{file} output is different from its expected output"
      end
    end
  end

  describe "--help" do
    it 'displays help and exists' do
      expect {
        begin
          Hiptest::Publisher.new(["--help"])
          fail("it should have exited")
        rescue SystemExit
        end
      }.to output(a_string_including("Usage: ruby publisher.rb [options]")).to_stdout
    end
  end

  describe "without arguments" do
    it 'displays help and exists' do
      expect {
        begin
          Hiptest::Publisher.new([])
          fail("it should have exited")
        rescue SystemExit
        end
      }.to output(a_string_including("Usage: ruby publisher.rb [options]")).to_stdout
    end
  end
end
