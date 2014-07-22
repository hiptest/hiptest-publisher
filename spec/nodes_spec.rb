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
    context 'post_render_children' do
      it 'finds all variable declared in the steps' do
        item = Zest::Nodes::Item.new('my item', [], [], [
          Zest::Nodes::Step.new(
            'result',
            Zest::Nodes::Template.new([
              Zest::Nodes::Variable.new('x'),
              Zest::Nodes::StringLiteral.new('should equals 0')
            ])),
          Zest::Nodes::Assign.new(
            Zest::Nodes::Variable.new('y'),
            Zest::Nodes::Variable.new('x')
          )
        ])
        item.post_render_children

        expect(item.variables.map {|v| v.children[:name]}).to eq(['x', 'y'])
      end

      it 'saves two lists of parameters: with and without default value' do
        simple = Zest::Nodes::Parameter.new('simple')
        valued = Zest::Nodes::Parameter.new('non_valued', '0')
        item = Zest::Nodes::Item.new('my item', [], [simple, valued])
        item.post_render_children

        expect(item.non_valued_parameters).to eq([simple])
        expect(item.valued_parameters).to eq([valued])
      end
    end
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