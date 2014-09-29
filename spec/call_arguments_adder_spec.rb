require_relative 'spec_helper'
require_relative '../lib/zest-publisher/call_arguments_adder'

describe Zest::DefaultArgumentAdder do
  include HelperFactories

  let(:aw) {
    make_actionword('first actionword', [], [
      make_parameter('x', make_literal(:string, 'Hi, I am a valued parameter')),
      make_parameter('y', make_literal(:string, 'Hi, I am another valued parameter'))
    ])
  }

  let(:aw1) {
    make_actionword('second actionword', [], [make_parameter('x')])
  }

  let(:call_to_unknown_actionword) {
    make_call('Humm, nope')
  }

  let(:call_with_all_parameters_set) {
    make_call('first actionword', [
      make_argument('y', make_literal(:string, 'And another value here')),
      make_argument('x', make_literal(:numeric, '3.14'))
    ])
  }

  let(:call_with_no_parameter_set) {
    make_call('first actionword')
  }

  let(:call_with_no_parameters_even_if_needed) {
    # Yep, that' a long name
    make_call('second actionword')
  }

  let(:scenario) {
    make_scenario('My scenario', [], [], [
      call_to_unknown_actionword,
      call_with_all_parameters_set,
      call_with_no_parameter_set,
      call_with_no_parameters_even_if_needed
    ])
  }

  let(:project) {
    make_project('My project', [scenario], [], [aw, aw1])
  }

  before(:each) do
    Zest::DefaultArgumentAdder.add(project)
  end

  def get_all_arguments_for_call(call)
    call.children[:all_arguments].map {|arg|
      [arg.class, arg.children[:name], arg.children[:value].children[:value]]
    }
  end

  it 'adds a "all_arguments" children to Call nodes where missing arguments are set with the default value' do
    expect(call_with_no_parameter_set.children.has_key?(:all_arguments)).to be true

    expect(get_all_arguments_for_call(call_with_no_parameter_set)).to eq([
      [Zest::Nodes::Argument, 'x', 'Hi, I am a valued parameter'],
      [Zest::Nodes::Argument, 'y', 'Hi, I am another valued parameter']
    ])
  end

  it 'when all value are set in a call, then all_arguments contains the set values' do
    # Note that the arguments are in the same order than in the definition
    expect(get_all_arguments_for_call(call_with_all_parameters_set)).to eq([
      [Zest::Nodes::Argument, 'x', '3.14'],
      [Zest::Nodes::Argument, 'y', 'And another value here']
    ])
  end

  it 'if the value is not set nor the default one, then we get nil as value' do
    # Note, it may fail during code generation but Zest should tell the suer there's a problem in the scenario definition.
    arg = call_with_no_parameters_even_if_needed.children[:all_arguments].first
    expect(arg.children[:name]).to eq('x')
    expect(arg.children[:value]).to eq(nil)
  end

  it 'if the action word is unknown, then the :all_arguments key is not even set' do
    expect(call_to_unknown_actionword.children.has_key?(:all_arguments)).to be false
  end
end

describe Zest::ActionwordIndexer do
  include HelperFactories

  let(:first_aw) {
    make_actionword('Simple actionword')
  }

  let(:second_aw) {
    make_actionword('Actionword with parameters', [], [
      make_parameter('x'),
      make_parameter('y', make_literal(:string, 'Hi, I am a valued parameter'))
    ])
  }

  let(:project) {
    make_project('My project', [], [], [first_aw, second_aw])
  }

  let(:indexer) {
    Zest::ActionwordIndexer.new(project)
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
      expect(index[:parameters]['y']).to be_a Zest::Nodes::StringLiteral
      expect(index[:parameters]['y'].children[:value]).to eq('Hi, I am a valued parameter')
    end
  end
end