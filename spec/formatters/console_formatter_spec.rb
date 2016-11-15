require 'spec_helper'
require_relative '../../lib/hiptest-publisher/formatters/console_formatter'

describe ConsoleFormatter do

  let(:verbose) { false }
  subject(:console_formatter) { ConsoleFormatter.new(verbose) }

  describe 'show_status_message' do
    before do
      allow(STDOUT).to receive(:print)
      allow(STDERR).to receive(:print)
    end

    context "is a tty" do
      before do
        allow($stdout).to receive(:tty?).and_return(true)
        allow(IO.console).to receive(:winsize).and_return([80, 25])
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

    context "not a tty" do
      before do
        allow($stdout).to receive(:tty?).and_return(false)
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
end
