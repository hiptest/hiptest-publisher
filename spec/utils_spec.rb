require_relative 'spec_helper'
require_relative '../lib/zest-publisher/utils'

describe 'Zest publisher utils' do
  describe 'show_status_message' do
    it 'sends a message on STDOUT with brackets before' do
      STDOUT.stub(:print)

      show_status_message('My message')
      STDOUT.should have_received(:print).with("[ ] My message\r").once
    end

    it 'is status is :success, it also adds a green checkbox and goes to the next line' do
      STDOUT.stub(:print)

      show_status_message('My message', :success)
      STDOUT.should have_received(:print).with("[#{"v".green}] My message\r\n").once
    end

    it 'is status is :failure, it adds a red checkbox and sends to STDERR with a new line character' do
      STDERR.stub(:print)

      show_status_message('My message', :failure)
      STDERR.should have_received(:print).with("[#{"x".red}] My message\r\n").once
    end
  end
end