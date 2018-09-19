require_relative '../spec_helper'
require_relative '../../lib/hiptest-publisher/indexers/actionword_indexer'

describe Hiptest::ActionwordIndexer do
  shared_examples "an index query" do
    include HelperFactories

    let(:first_actionword_uid) {'12345678-1234-1234-1234-123456789012'}
    let(:first_aw) {
      make_actionword('Simple actionword', uid: first_actionword_uid)
    }

    let(:second_actionword_uid) {'87654321-4321-4321-4321-09876543212'}
    let(:second_aw) {
      make_actionword('Actionword with parameters', uid: second_actionword_uid, parameters: [
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

    it 'gives nil if the seeked actionword does not exist' do
      expect(indexer.send(getter_method, unknown_query)).to be nil
    end

    it 'otherwise, it provides a hash with a link to the action word and its parameters' do
      index = indexer.send(getter_method, first_aw_query)

      expect(index.keys).to eq([:actionword, :parameters])
      expect(index[:parameters]).to eq({})
      expect(index[:actionword]).to eq(first_aw)
    end

    it 'if no default value is specified, the value associated to the parameter is nil' do
      index = indexer.send(getter_method, second_aw_query)
      expect(index[:parameters].keys).to eq(['x', 'y'])
      expect(index[:parameters]['x']).to be nil
    end

    it 'otherwise it is the parameter default value' do
      index = indexer.send(getter_method, second_aw_query)
      expect(index[:parameters]['y']).to be_a Hiptest::Nodes::StringLiteral
      expect(index[:parameters]['y'].children[:value]).to eq('Hi, I am a valued parameter')
    end
  end

  context 'get_index' do
    it_behaves_like "an index query" do
      let(:getter_method) { :get_index }
      let(:unknown_query) { 'Ho, I do not thing this exists' }
      let(:first_aw_query) { 'Simple actionword' }
      let(:second_aw_query) { 'Actionword with parameters' }
    end
  end

  context 'get_uid_index' do
    it_behaves_like "an index query" do
      let(:getter_method) { :get_uid_index }
      let(:unknown_query) { 'abcdabcdabcd-bcda-bcda-bcda-abcdabcdabcdabcd' }
      let(:first_aw_query) { first_actionword_uid }
      let(:second_aw_query) { second_actionword_uid }
    end
  end
end
