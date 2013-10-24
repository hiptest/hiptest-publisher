# encoding: UTF-8
require_relative 'actionwords'

describe 'ZestPublisher' do
  before(:each) do
    @actionwords = Actionwords.new
  end

  it 'show_help' do
    @actionwords.start_publisher(options = {help: true})
    # TODO: Implement result: "help is displayed"
  end
end