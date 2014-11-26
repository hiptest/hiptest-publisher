require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/utils'

describe 'Hiptest publisher utils' do
  describe 'show_status_message' do
    it 'sends a message on STDOUT with brackets before' do
      allow(STDOUT).to receive(:print)

      show_status_message('My message')
      expect(STDOUT).to have_received(:print).with("[ ] My message\r").once
    end

    it 'if status is :success, it also adds a green checkbox and goes to the next line' do
      allow(STDOUT).to receive(:print)

      show_status_message('My message', :success)
      expect(STDOUT).to have_received(:print).with("[#{"v".green}] My message\r\n").once
    end

    it 'if status is :failure, it adds a red checkbox and sends to STDERR with a new line character' do
      allow(STDERR).to receive(:print)

      show_status_message('My message', :failure)
      expect(STDERR).to have_received(:print).with("[#{"x".red}] My message\r\n").once
    end
  end
end