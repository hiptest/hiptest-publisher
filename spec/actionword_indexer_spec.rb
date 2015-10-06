require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/actionword_indexer'

describe Hiptest::ActionwordIndexer do
  include HelperFactories

  let(:first_aw) {
    make_actionword('Simple actionword')
  }

  let(:second_aw) {
    make_actionword('Actionword with parameters', parameters: [
      make_parameter('x'),
      make_parameter('y', default: literal('Hi, I am a valued parameter'))
    ])
  }

  let(:project) {
    make_project('My project', actionwords: [first_aw, second_aw])
  }

  let(:indexer) {
    Hiptest::ActionwordIndexer.new(project)
  }

  context 'get_index' do
    it 'gives nil if the seeked actionword does not exist' do
      expect(indexer.get_index('Ho, I do not thing this exists')).to be nil
    end

    it 'otherwise, it provides a hash with a link to the action word and its parameters' do
      index = indexer.get_index('Simple actionword')

      expect(index.keys).to eq([:actionword, :parameters])
      expect(index[:parameters]).to eq({})
      expect(index[:actionword]).to eq(first_aw)
    end

    it 'if no default value is specified, the value associated to the parameter is nil' do
      index = indexer.get_index('Actionword with parameters')
      expect(index[:parameters].keys).to eq(['x', 'y'])
      expect(index[:parameters]['x']).to be nil
    end

    it 'otherwise it is the parameter default value' do
      index = indexer.get_index('Actionword with parameters')
      expect(index[:parameters]['y']).to be_a Hiptest::Nodes::StringLiteral
      expect(index[:parameters]['y'].children[:value]).to eq('Hi, I am a valued parameter')
    end
  end
end
