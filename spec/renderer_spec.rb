require 'tmpdir'
require 'tempfile'
require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/renderer'
require_relative '../lib/hiptest-publisher/nodes'

describe Hiptest::Renderer do
  context '#normalized_name' do
    it 'normalizes the node name to a template name' do
      node = Hiptest::Nodes::StringLiteral.new('coucou')
      rendering_context = context_for(language: 'python')
      renderer = Hiptest::Renderer.new(rendering_context)

      expect(renderer.normalized_name(node)).to eq('stringliteral')
    end
  end

  describe "#render_node" do
    it "raises a ArgumentError when no templates is found" do
      class UnknownNode < Hiptest::Nodes::Node
      end
      node = UnknownNode.new # no template file lib/template/ruby/unknownnode.hbs for ruby

      rendering_context = context_for(language: 'ruby')
      renderer = Hiptest::Renderer.new(rendering_context)

      expect{
        renderer.render_node(node, nil)
      }.to raise_error(ArgumentError)
    end
  end
end
