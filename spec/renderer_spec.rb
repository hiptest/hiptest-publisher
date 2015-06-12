require 'tmpdir'
require 'tempfile'
require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/renderer'
require_relative '../lib/hiptest-publisher/nodes'

describe Hiptest::Renderer do
  context '#get_template_path' do
    it 'checks if the file exists in the common templates' do
      node = Hiptest::Nodes::StringLiteral.new('coucou')
      renderer = Hiptest::Renderer.new({language: 'python', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/common/stringliteral.hbs')
    end

    it 'checks in the language template folder' do
      node = Hiptest::Nodes::Assign.new('x', 1)
      renderer = Hiptest::Renderer.new({language: 'ruby', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/assign.hbs')
    end

    it 'checks in the framework specific folder if existing' do
      node = Hiptest::Nodes::Scenarios.new([])
      renderer = Hiptest::Renderer.new({language: 'ruby', framework: 'minitest', forced_templates: {}})

      expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/ruby/minitest/scenarios.hbs')
    end

    context 'searches first in overriden templates' do
      let(:node) { Hiptest::Nodes::Scenarios.new([])}

      it 'uses the default one if there is none overriden' do
        Dir.mktmpdir("overriden_templates") do |dir|
          renderer = Hiptest::Renderer.new({language: 'python', overriden_templates: "#{dir}", forced_templates: {}})
          expect(renderer.get_template_path(node, 'hbs')).to eq('./lib/templates/python/scenarios.hbs')
        end
      end

      it 'uses the overriden template is it exists' do
        Dir.mktmpdir("overriden_templates") do |dir|
          renderer = Hiptest::Renderer.new({language: 'python', overriden_templates: "#{dir}", forced_templates: {}})
          open("#{dir}/scenarios.hbs", 'w') { |f| f.puts ""}
          expect(renderer.get_template_path(node, 'hbs')).to eq("#{dir}/scenarios.hbs")
        end
      end
    end
  end

  describe "#render_node" do
    context "when no template is found" do
      subject(:rendered_node) do
        renderer = Hiptest::Renderer.new({ignore_unknown_templates: ignore_unknown_templates, language: 'baraccuda', forced_templates: {}})
        node = Hiptest::Nodes::Call.new('Is anybody here?')
        renderer.render_node(node, nil)
      end

      context "when option[:ignore_unknown_templates] is set" do
        let(:ignore_unknown_templates) { true }

        it "returns empty string" do
          expect(rendered_node).to eq('')
        end
      end

      context "when option[:ignore_unknown_templates] is not set" do
        let(:ignore_unknown_templates) { false }

        it "raises a ArgumentError" do
          expect{rendered_node}.to raise_error(ArgumentError)
        end
      end
    end
  end
end
