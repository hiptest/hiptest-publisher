require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/zest-publisher/nodes'

describe Zest::Nodes do
  context 'Node' do
    context 'find_sub_nodes' do
      before(:all) do
        @literal = Zest::Nodes::Literal.new(1)
        @var = Zest::Nodes::Variable.new('x')
        @assign = Zest::Nodes::Assign.new(@var, @literal)
      end

      it 'finds all sub-nodes (including self)' do
        expect(@literal.find_sub_nodes).to eq([@literal])
        expect(@assign.find_sub_nodes).to eq([@assign, @var, @literal])
      end

      it 'can be filter by type' do
        expect(@assign.find_sub_nodes(Zest::Nodes::Variable)).to eq([@var])
      end
    end
  end

  context 'Item' do
    context 'has_parameters?' do
      it 'returns false if has not parameter' do
        item = Zest::Nodes::Item.new('my item', [], [])
        expect(item.has_parameters?).to be_falsey
      end

      it 'returns true if has at least one parameter' do
        item = Zest::Nodes::Item.new('my item', [], [Zest::Nodes::Parameter.new('piou')])
        expect(item.has_parameters?).to be_truthy
      end
    end
  end

  context 'Actionword' do
    context 'has_step?' do
      it 'returns true if body has at least one step' do
        step = Zest::Nodes::Step.new('action', 'value')
        myNode = Zest::Nodes::Actionword.new('name', tags = [], parameters = [], body = [step])
        expect(myNode.has_step?).to be_truthy
      end

      it 'returns false if there is no step in body' do
        myNode = Zest::Nodes::Actionword.new('name', tags = [], parameters = [], body = [])
        expect(myNode.has_step?).to be_falsey
      end
    end
  end

  context 'Call' do
    context 'has_arguments?' do
      it 'returns false if has no argument' do
        call = Zest::Nodes::Call.new('', [])
        expect(call.has_arguments?).to be_falsey
      end

      it 'returns true if has at least one argument' do
        call = Zest::Nodes::Call.new('', [Zest::Nodes::Argument.new('name', 'value')])
        expect(call.has_arguments?).to be_truthy
      end
    end
  end
end