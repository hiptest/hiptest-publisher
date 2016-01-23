require_relative 'spec_helper'
require_relative "../lib/hiptest-publisher/formatters/reporter"
require_relative '../lib/hiptest-publisher/utils'

describe 'Hiptest publisher utils' do
  describe 'show_status_message' do
    before do
      allow(STDOUT).to receive(:print)
      allow(STDERR).to receive(:print)
    end

    it 'sends a message on STDOUT with brackets before' do
      show_status_message('My message')
      expect(STDOUT).to have_received(:print).with("[ ] My message\r\e[1A\n").once
    end

    it 'if status is :success, it also adds a green checkbox and goes to the next line' do
      show_status_message('My message', :success)
      expect(STDOUT).to have_received(:print).with("[#{"v".green}] My message\n").once
    end

    it 'if status is :failure, it adds a red checkbox and sends to STDERR with a new line character' do
      show_status_message('My message', :failure)
      expect(STDERR).to have_received(:print).with("[#{"x".red}] My message\n").once
    end

    context "not a tty" do
      before do
        allow($stdout).to receive(:tty?).and_return(false)
      end

      it 'does not output anything if no status' do
        show_status_message('My message')
        expect(STDOUT).not_to have_received(:print)
      end

      it 'outputs normally if status' do
        show_status_message('My message', :success)
        expect(STDOUT).to have_received(:print).with("[#{"v".green}] My message\n").once
      end
    end

    context "unable to guess terminal size" do
      before do
        allow(IO.console).to receive(:winsize).and_return([0, 0])
      end

      it 'does not output anything if no status' do
        show_status_message('My message')
        expect(STDOUT).not_to have_received(:print)
      end

      it 'outputs normally if status' do
        show_status_message('My message', :success)
        expect(STDOUT).to have_received(:print).with("[#{"v".green}] My message\n").once
      end
    end
  end

  describe "singularize" do
    it "singularizes a plural form" do
      expect(singularize("names")).to eq("name")
      expect(singularize("actionwords")).to eq("actionword")
      expect(singularize(:actionwords)).to eq("actionword")
    end

    it "does not modify a singular form" do
      expect(singularize("name")).to eq("name")
      expect(singularize("actionword")).to eq("actionword")
      expect(singularize(:actionword)).to eq("actionword")
    end
  end

  describe 'make_url' do
    it 'creates url for tests generation' do
      args = ["--token", "1234"]
      options = OptionsParser.parse(args, NullReporter.new)
      expect(make_url(options)).to eq("https://hiptest.net/publication/1234/project")
    end

    it 'creates url for tests generation with tags and scenario ids filter' do
      args = ["--token", "1234", "--scenario-ids", "5,7,6", "--scenario-tags", "titi,toto"]
      options = OptionsParser.parse(args, NullReporter.new)
      expect(make_url(options)).to eq("https://hiptest.net/publication/1234/project?filter[]=id:5&filter[]=id:7&filter[]=id:6&filter[]=tag:titi&filter[]=tag:toto")
    end

    it 'creates url for tests generation from a test run' do
      args = ["--token", "1234", "--test-run-id", "98"]
      options = OptionsParser.parse(args, NullReporter.new)
      expect(make_url(options)).to eq("https://hiptest.net/publication/1234/test_run/98")
    end

    it 'creates url to push results' do
      args = ["--token", "1234", "--push", "myfile.tap"]
      options = OptionsParser.parse(args, NullReporter.new)
      expect(make_url(options)).to eq("https://hiptest.net/import_test_results/1234/tap")
    end
  end
end
