require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/nodes'

describe Hiptest::Nodes do
  context 'Node' do
    context 'find_sub_nodes' do

      let(:literal) { Hiptest::Nodes::Literal.new(1) }
      let(:var) { Hiptest::Nodes::Variable.new('x') }
      let(:assign) { Hiptest::Nodes::Assign.new(var, literal) }

      it 'finds all sub-nodes (including self)' do
        expect(literal.find_sub_nodes.to_a).to eq([literal])
        expect(assign.find_sub_nodes.to_a).to eq([assign, var, literal])
      end

      it 'can be filter by type' do
        expect(assign.find_sub_nodes(Hiptest::Nodes::Variable).to_a).to eq([var])
      end

      it 'finds two equal but distinct subnodes' do
        yolo1 = Hiptest::Nodes::StringLiteral.new("YOLO!")
        yolo2 = Hiptest::Nodes::StringLiteral.new("YOLO!")
        template = Hiptest::Nodes::Template.new([yolo1, yolo2])
        expect(template.find_sub_nodes.to_a).to eq([template, yolo1, yolo2])
      end

      it 'finds same subnodes only once' do
        yolo1 = Hiptest::Nodes::StringLiteral.new("YOLO!")
        yolo2 = yolo1
        template = Hiptest::Nodes::Template.new([yolo1, yolo2])
        expect(template.find_sub_nodes.to_a).to eq([template, yolo1])
     end
    end
  end

  context 'Item' do
    context 'declared_variables_names' do
      let(:body) {
        [
          Hiptest::Nodes::Assign.new(
            Hiptest::Nodes::Variable.new('x'),
            Hiptest::Nodes::Literal.new(1)
          ),
          Hiptest::Nodes::Assign.new(
            Hiptest::Nodes::Variable.new('y'),
            Hiptest::Nodes::Literal.new(1)
          ),
          Hiptest::Nodes::Assign.new(
            Hiptest::Nodes::Variable.new('z'),
            Hiptest::Nodes::Literal.new(1)
          ),
        ]
      }

      it 'provide a list of variable name based on the item body' do
        node = Hiptest::Nodes::Item.new('my node', [], [], body)
        expect(node.declared_variables_names).to eq(['x', 'y', 'z'])
      end

      it 'does not provide duplicated name' do
        body << Hiptest::Nodes::Assign.new(
            Hiptest::Nodes::Variable.new('z'),
            Hiptest::Nodes::Literal.new(1)
          )

        node = Hiptest::Nodes::Item.new('my node', [], [], body)
        expect(node.declared_variables_names).to eq(['x', 'y', 'z'])
      end

      it 'does not return parameters' do
        node = Hiptest::Nodes::Item.new('my node', [Hiptest::Nodes::Parameter.new('x')], [], body)
        expect(node.declared_variables_names).to eq(['x', 'y', 'z'])
      end
    end
  end

  context 'Actionword' do
    context 'must_be_implemented?' do
      let(:aw) {Hiptest::Nodes::Actionword.new('my action word')}

      it 'returns true if the body is empty' do
        expect(aw.must_be_implemented?).to be true
      end

      it 'returns true if it contains a step' do
        aw.children[:body] << Hiptest::Nodes::Step.new('action', 'Do something')
        expect(aw.must_be_implemented?).to be true
      end

      it 'returns false if it contains call' do
        aw.children[:body] << Hiptest::Nodes::Call.new('another actionword')
        expect(aw.must_be_implemented?).to be false
      end
    end
  end

  context 'Actionwords' do
    let(:empty) {
      Hiptest::Nodes::Actionword.new('empty action word')
    }

    let(:step) {
      Hiptest::Nodes::Actionword.new('action word with a step', [], [], [Hiptest::Nodes::Step.new('action', 'Do something')])
    }

    let(:call) {
      Hiptest::Nodes::Actionword.new('action word with a step', [], [], [Hiptest::Nodes::Call.new('another actionword')])
    }

    let(:aws) {Hiptest::Nodes::Actionwords.new([empty, step, call])}

    it '@to_implement contains the list of actionwords that need to be implemented' do
      expect(aws.to_implement).to eq([empty, step])
    end

    it '@no_implement contains the list of actionwords that do not need to be implemented' do
      expect(aws.no_implement).to eq([call])
    end
  end
end
