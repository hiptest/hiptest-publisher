require 'spec_helper'
require_relative '../../lib/hiptest-publisher/formatters/console_formatter'

describe ConsoleFormatter do

  let(:verbose) { false }
  let(:color) { nil }
  let(:is_a_tty) { true }
  subject(:console_formatter) { ConsoleFormatter.new(verbose, color: color) }

  before do
    allow($stdout).to receive(:tty?).and_return(is_a_tty)
  end

  describe 'show_status_message' do
    before do
      allow(STDOUT).to receive(:print)
      allow(STDERR).to receive(:print)
    end

    context "when is a tty" do
      let(:is_a_tty) { true }

      before do
        allow(IO.console).to receive(:winsize).and_return([80, 25])
      end

      it 'is colored by default' do
        expect(console_formatter.colored?).to be true
      end

      it 'sends a message on STDOUT with brackets before' do
        console_formatter.show_status_message('My message')
        expect(STDOUT).to have_received(:print).with("[ ] My message\r\e[1A\n").once
      end

      it 'if status is :success, it also adds a green checkbox and goes to the next line' do
        console_formatter.show_status_message('My message', :success)
        expect(STDOUT).to have_received(:print).with("[#{"v".green}] My message\n").once
      end

      it 'if status is :failure, it adds a red checkbox and sends to STDERR with a new line character' do
        console_formatter.show_status_message('My message', :failure)
        expect(STDERR).to have_received(:print).with("[#{"x".red}] My message\n").once
      end
    end

    context "when not a tty" do
      let(:is_a_tty) { false }

      it 'is not colored by default' do
        expect(console_formatter.colored?).to be false
      end

      it 'does not output anything if no status' do
        console_formatter.show_status_message('My message')
        expect(STDOUT).not_to have_received(:print)
      end

      it 'outputs normally if status' do
        console_formatter.show_status_message('My message', :success)
        expect(STDOUT).to have_received(:print).with("[v] My message\n").once
      end
    end

    context "unable to guess terminal size" do
      before do
        allow(IO.console).to receive(:winsize).and_return([0, 0])
      end

      it 'does not output anything if no status' do
        console_formatter.show_status_message('My message')
        expect(STDOUT).not_to have_received(:print)
      end

      it 'outputs normally if status' do
        console_formatter.show_status_message('My message', :success)
        expect(STDOUT).to have_received(:print).with("[#{"v".green}] My message\n").once
      end
    end

    context 'without colors' do
      let(:color) { false }

      it 'if status is :success, it adds "v" checkbox and goes to the next line' do
        console_formatter.show_status_message('My message', :success)
        expect(STDOUT).to have_received(:print).with("[v] My message\n").once
      end

      it 'if status is :failure, it adds an "x" checkbox and sends to STDERR with a new line character' do
        console_formatter.show_status_message('My message', :failure)
        expect(STDERR).to have_received(:print).with("[x] My message\n").once
      end
    end

    context 'with colors forced while not a tty' do
      let(:is_a_tty) { false }
      let(:color) { true }

      before do
        allow($stdout).to receive(:tty?).and_return(false)
      end

      it 'is colored' do
        expect(console_formatter.colored?).to be true
      end
    end
  end

  describe 'show_verbose_message' do
    before do
      allow(STDOUT).to receive(:print)
      allow(STDERR).to receive(:print)
    end

    context 'when verbose' do
      let(:verbose) { true }

      it 'outputs the message' do
        console_formatter.show_verbose_message('My message')
        expect(STDOUT).to have_received(:print).with("My message\n")
      end

      context 'when inside a #show_status_message' do
        before do
          allow($stdout).to receive(:tty?).and_return(true)
          allow(IO.console).to receive(:winsize).and_return([80, 25])
        end

        it 'delays outputs until the #show_status_message is called with :success or :failed' do
          console_formatter.show_status_message('My status message')
          expect(STDOUT).to have_received(:print).with("[ ] My status message\r\e[1A\n").once

          console_formatter.show_verbose_message("My intermediate message")
          expect(STDOUT).not_to have_received(:print).with("My intermediate message\n")

          console_formatter.show_status_message('My status message', :success)
          expect(STDOUT).to have_received(:print).with("[#{"v".green}] My status message\n").once
          expect(STDOUT).to have_received(:print).with("My intermediate message\n")
        end

        it 'outputs delayed verbose messages only once' do
          console_formatter.show_status_message('My status message')
          console_formatter.show_verbose_message('My intermediate message')
          console_formatter.show_status_message('My status message', :success)
          console_formatter.show_status_message('My status message', :success)
          expect(STDOUT).to have_received(:print).with("[#{"v".green}] My status message\n").twice
          expect(STDOUT).to have_received(:print).with("My intermediate message\n").once
        end
      end
    end

    context 'when not verbose' do
      let(:verbose) { false }

      it 'does not output anything' do
        console_formatter.show_verbose_message('My message')
        expect(STDOUT).not_to have_received(:print)
      end
    end
  end

  describe '#show_failure' do
    before do
      allow(STDOUT).to receive(:print)
    end

    it 'outputs the message in red on STDOUT' do
      console_formatter.show_failure('Some failure')
      expect(STDOUT).to have_received(:print).with("Some failure".red)
    end

    context 'when colors are disabled' do
      let(:color) { false }
      it 'outputs the message on STDOUT' do
        console_formatter.show_failure('Some failure')
        expect(STDOUT).to have_received(:print).with('Some failure')
      end
    end
  end

  describe '#show_error' do
    before do
      allow(STDOUT).to receive(:print)
    end

    it 'outputs the message in yellow on STDOUT' do
      console_formatter.show_error('Some error')
      expect(STDOUT).to have_received(:print).with("Some error".yellow)
    end

    context 'when colors are disabled' do
      let(:color) { false }
      it 'outputs the message on STDOUT' do
        console_formatter.show_error('Some error')
        expect(STDOUT).to have_received(:print).with('Some error')
      end
    end
  end

  describe '#ask' do
    before do
      allow(STDOUT).to receive(:print)
    end

    context "is a tty" do
      before do
        allow($stdout).to receive(:tty?).and_return(true)
        allow($stdin).to receive(:gets).and_return('')
      end

      it 'display the question with a yellow question mark' do
        console_formatter.ask('What is your quest ?')
        expect(STDOUT).to have_received(:print).with("[#{'?'.yellow}] What is your quest ?").once
      end

      it 'returns the user input (downcased and cleaned of spaces or line returns)' do
        allow($stdin).to receive(:gets).and_return("  To seek for the Holy grail !\r\n")
        expect(console_formatter.ask('What is your quest ?')).to eq("to seek for the holy grail !")
      end

      context 'with color disabled' do
        let(:color) { false }

        it 'display the question with a question mark' do
          console_formatter.ask('What is your quest ?')
          expect(STDOUT).to have_received(:print).with("[?] What is your quest ?").once
        end
      end
    end

    context "not a tty" do
      let(:is_a_tty) { false }

      it 'returns nil' do
        expect(console_formatter.ask("Is this nil?")).to be_nil
      end
    end
  end
end
