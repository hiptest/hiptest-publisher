require_relative 'spec_helper'
require_relative '../lib/zest-publisher/nodes'
require_relative '../lib/zest-publisher/render_context_maker'

describe Zest::RenderContextMaker do
  subject { Object.new.extend(Zest::RenderContextMaker) }

  context 'walk_item' do
    let(:node) {Zest::Nodes::Scenario.new('My scenario')}

    it 'provides information about the item content' do
      expect(subject.walk_item(node).keys).to eq([
        :has_parameters?,
        :has_tags?,
        :has_step?,
        :is_empty?
      ])
    end

    it 'has_parameters? is true when there is parameters' do
      expect(subject.walk_item(node)[:has_parameters?]).to be false

      node.children[:parameters] << 'x'
      expect(subject.walk_item(node)[:has_parameters?]).to be true
    end

    it 'has_tags? is true when there is tags' do
      expect(subject.walk_item(node)[:has_tags?]).to be false

      node.children[:tags] << 'x'
      expect(subject.walk_item(node)[:has_tags?]).to be true
    end

    context 'has_step?' do
      it 'is true when there is steps in the body' do
        expect(subject.walk_item(node)[:has_step?]).to be false

        node.children[:body] << Zest::Nodes::Step.new('action', 'Do something')
        expect(subject.walk_item(node)[:has_step?]).to be true
      end

      it 'works even if the step is inside another statement' do
        node.children[:body] << Zest::Nodes::While.new('true', [])
        expect(subject.walk_item(node)[:has_step?]).to be false

        node.children[:body].first.children[:body] << Zest::Nodes::Step.new('action', 'Do something')
        expect(subject.walk_item(node)[:has_step?]).to be true
      end
    end

    it 'is_empty? is true when there is no content in the item' do
      expect(subject.walk_item(node)[:is_empty?]).to be true

      node.children[:body] << 'x'
      expect(subject.walk_item(node)[:is_empty?]).to be false
    end
  end

  context 'walk_scenario' do
    let(:node) {
      sc = Zest::Nodes::Scenario.new('My scenario')
      sc.parent = Zest::Nodes::Scenarios.new([])
      sc.parent.parent = Zest::Nodes::Project.new('A project')
      sc
    }

    it 'adds the project name to walk_item result' do
      expect(subject.walk_scenario(node).keys).to eq([
        :has_parameters?,
        :has_tags?,
        :has_step?,
        :is_empty?,
        :project_name
      ])

      expect(subject.walk_scenario(node)[:project_name]).to eq('A project')
    end
  end

  context 'walk_scenarios' do
    let(:node) {
      scs = Zest::Nodes::Scenarios.new([])
      scs.parent = Zest::Nodes::Project.new('Another project')
      scs
    }

    it 'gives the project name' do
      expect(subject.walk_scenarios(node)).to eq({:project_name => 'Another project'})
    end
  end

  context 'walk_call' do
    it 'tells if there is arguments' do
      node = Zest::Nodes::Call.new('my_action_word')

      expect(subject.walk_call(node)).to eq({
        :has_arguments? => false
      })

      node.children[:arguments] << 'x'
      expect(subject.walk_call(node)).to eq({
        :has_arguments? => true
      })
    end
  end

  context 'walk_ifthen' do
    it 'tells if there is stements in the else part' do
      node = Zest::Nodes::IfThen.new(nil, nil)

      expect(subject.walk_ifthen(node)).to eq({
        :has_else? => false
      })

      node.children[:else] << 'Something'
      expect(subject.walk_ifthen(node)).to eq({
        :has_else? => true
      })
    end
  end

  context 'walk_parameter' do
    it 'tells if the parameter has a default value' do
      node = Zest::Nodes::Parameter.new('My parameter')

      expect(subject.walk_parameter(node)).to eq({
        :has_default_value? => false
      })

      node.children[:default] = 'Tralala'
      expect(subject.walk_parameter(node)).to eq({
        :has_default_value? => true
      })
    end
  end

  context 'walk_tag' do
    it 'tells if the tag has a value' do
      node = Zest::Nodes::Tag.new('mytag')

      expect(subject.walk_tag(node)).to eq({
        :has_value? => false
      })

      node.children[:value] = '123'
      expect(subject.walk_tag(node)).to eq({
        :has_value? => true
      })
    end
  end

  context 'walk_template' do
    let (:node) {Zest::Nodes::Template.new([])}
    let (:node_with_variables) {
      Zest::Nodes::Template.new([
        Zest::Nodes::StringLiteral.new('The value of '),
        Zest::Nodes::Variable.new('x'),
        Zest::Nodes::StringLiteral.new('should equal the one of '),
        Zest::Nodes::Variable.new('y')
      ])
    }

    it 'generates two flag: one with data treated for output, one with variable names' do
      expect(subject.walk_template(node).keys).to eq([:treated_chunks, :variable_names])
    end

    it 'treated_chunks gives for each chunk if it is a variable and the raw node' do
      treated = subject.walk_template(node_with_variables)[:treated_chunks]

      expect(treated.length).to eq(4)
      expect(treated.map {|item| item[:is_variable?]}).to eq([false, true, false, true])
      expect(treated.map {|item| item[:raw]}).to eq(node_with_variables.children[:chunks])
    end

    it 'variable_names gives the list of variable names, in order' do
      expect(subject.walk_template(node_with_variables)[:variable_names]).to eq(['x', 'y'])
    end
  end
end