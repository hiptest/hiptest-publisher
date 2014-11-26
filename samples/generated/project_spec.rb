# encoding: UTF-8
require 'spec_helper'
require_relative 'actionwords'

describe 'HiptestPublisher' do
  include Actionwords

  it 'show_help' do
    start_publisher(options = {help: true})
    # TODO: Implement result: "help is displayed"
  end
end