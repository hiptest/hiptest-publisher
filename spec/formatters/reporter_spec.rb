require 'spec_helper'
require_relative '../../lib/hiptest-publisher/formatters/reporter'

describe Reporter do
  let(:subject) { Reporter.new(listeners) }
  let(:listeners) { [] }

  context 'ask' do
    context 'when no listener implements "ask"' do
      it 'returns nil' do
        expect(subject.ask("What is your quest ?")).to be_nil
      end
    end

    context 'when on listener implements "ask"' do
      let(:ask_listener) { double }
      let(:listeners) { [ask_listener] }

      before do
        allow(ask_listener).to receive(:ask).and_return("To seek for the Holy grail")
      end

      it 'returns the result from the listener' do
        expect(subject.ask("What is your quest ?")).to eq("To seek for the Holy grail")
      end
    end

    context 'when multiple listeners implement "ask"' do
      let(:first_ask_listener) { double }
      let(:second_ask_listener) { double }

      let(:listeners) { [first_ask_listener, second_ask_listener] }

      before do
        allow(first_ask_listener).to receive(:ask).and_return("Red")
        allow(second_ask_listener).to receive(:ask).and_return("No blue !!")
      end

      it 'returns the result from the first listener' do
        expect(subject.ask("What is favorite color ?")).to eq("Red")
      end
    end

    context 'when the listener implements method_missing' do
      let(:first_listener) { double }
      let(:ask_listener) { double }

      let(:listeners) { [first_listener, ask_listener] }

      before do
        allow(first_listener).to receive(:method_missing).and_return("Red")
        allow(ask_listener).to receive(:ask).and_return("No blue !!")
      end

      it 'is not taken into account' do
        expect(subject.ask("What is favorite color ?")).to eq("No blue !!")
      end
    end
  end
end
