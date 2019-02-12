require_relative 'spec_helper'
require_relative "../lib/hiptest-publisher/formatters/reporter"
require_relative '../lib/hiptest-publisher/utils'

describe 'hiptest-publisher utils' do
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
end
