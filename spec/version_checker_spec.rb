require_relative 'spec_helper'

require_relative '../lib/hiptest-publisher/version_checker'

describe Hiptest::VersionChecker do
  let(:subject) { Hiptest::VersionChecker }

  context '.check_version' do
    context 'when fetching latest version fails' do
      before { allow(Gem).to receive(:latest_version_for).and_return(nil) }

      it 'raises a RunTime exception' do
        expect { subject.check_version }.to raise_error(RuntimeError, 'Unable to connect to Rubygem') 
      end
    end

    context 'when current version is outdated' do
      before do
        version = double('Gem version', version: '100.1000.10000')
        allow(Gem).to receive(:latest_version_for).and_return(version)
      end

      it 'notifies the user' do
        expect { subject.check_version }.to output(a_string_including("Your current install of hiptest-publisher (#{ hiptest_publisher_version }) is outdated, version 100.1000.10000 is available")).to_stdout
      end
    end

    context 'when current version is the latest' do
      before do
        version = double('Gem version', version: hiptest_publisher_version)
        allow(Gem).to receive(:latest_version_for).and_return(version)
      end

      it 'notifies the user' do
        expect { subject.check_version }.to output(a_string_including("Your current install of hiptest-publisher (#{ hiptest_publisher_version }) is up-to-date")).to_stdout

      end
    end
  end
end
