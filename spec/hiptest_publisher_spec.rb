require 'spec_helper'
require_relative '../lib/hiptest-publisher'

describe Hiptest::Publisher do
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
