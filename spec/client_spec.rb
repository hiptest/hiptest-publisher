require 'webmock/rspec'
require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/client'

describe Hiptest::Client do
  let(:args) { ["--token", "123456789"] }
  let(:options) { OptionsParser.parse(args, NullReporter.new) }
  subject(:client) { Hiptest::Client.new(options) }

  describe '#url' do
    context "with --token" do
      let(:args) { ["--token", "1234"] }

      it 'creates url for tests generation' do
        expect(client.url).to eq("https://hiptest.net/publication/1234/project")
      end

      context "and with --test-run-id" do
        let(:args) { ["--token", "1234", "--test-run-id", "98"] }

        it 'creates url for tests generation from a test run id' do
          expect(client.url).to eq("https://hiptest.net/publication/1234/test_run/98")
        end
      end

      context "and with --push" do
        let(:args) { ["--token", "1234", "--push", "myfile.tap"] }

        it 'creates url to push results' do
          expect(client.url).to eq("https://hiptest.net/import_test_results/1234/tap")
        end
      end
    end
  end

  describe '#fetch_project_export' do
    let(:args) { ["--token", "123456789"] }

    it 'fetches the project xml from Hiptest server' do
      sent_xml = "<xml_everywhere/>"
      stub_request(:get, "https://hiptest.net/publication/123456789/project").
        to_return(body: sent_xml)
      got_xml = client.fetch_project_export
      expect(got_xml.read).to eq(sent_xml)
    end
  end
end
