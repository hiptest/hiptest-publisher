require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/hiptest-publisher'

describe Hiptest::Publisher do

  it 'works in the golden case' do
    stub_request(:get, "https://hiptest.net/publication/123456789/project?future=1").
      to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
    Dir.mktmpdir do |output_dir|
      args = [
        "--language", "ruby",
        "--output-directory", output_dir,
        "--token", "123456789",
      ]
      publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
      publisher.run
      expect_same_files("samples/expected_output/Hiptest publisher", output_dir)
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

  it 'displays help and exists when called with --help' do
    expect {
      begin
        Hiptest::Publisher.new(["--help"])
        fail("it should have exited")
      rescue SystemExit
      end
    }.to output(a_string_including("Usage: ruby publisher.rb [options]")).to_stdout
  end

  it 'displays help and exists when called without arguments' do
    expect {
      begin
        Hiptest::Publisher.new([])
        fail("it should have exited")
      rescue SystemExit
      end
    }.to output(a_string_including("Usage: ruby publisher.rb [options]")).to_stdout
  end
end
