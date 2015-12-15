# encoding: UTF-8
require 'spec_helper'
require_relative 'actionwords'

describe 'Hiptest publisher' do
  include Actionwords

  it "A scenario in a subfolder" do
    # TODO: Implement action: "Some actions to do"
    raise NotImplementedError
  end

  it "show help" do
    start_publisher({help: true})
    # TODO: Implement result: "help is displayed"
    raise NotImplementedError
  end
end
