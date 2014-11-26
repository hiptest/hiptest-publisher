require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/nodes'

describe Hiptest::Nodes do
  context 'Node' do
    context 'find_sub_nodes' do
      before(:all) do
        @literal = Hiptest::Nodes::Literal.new(1)
        @var = Hiptest::Nodes::Variable.new('x')
        @assign = Hiptest::Nodes::Assign.new(@var, @literal)
      end

      it 'finds all sub-nodes (including self)' do
        expect(@literal.find_sub_nodes).to eq([@literal])
        expect(@assign.find_sub_nodes).to eq([@assign, @var, @literal])
      end

      it 'can be filter by type' do
        expect(@assign.find_sub_nodes(Hiptest::Nodes::Variable)).to eq([@var])
      end
    end
  end
end