require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/nodes'
require_relative '../lib/hiptest-publisher/render_context_maker'

describe Hiptest::RenderContextMaker do
  let(:node_rendering_context) { double('NodeRenderingContext') }
  subject {
    obj = Object.new.extend(Hiptest::RenderContextMaker)
    obj.instance_variable_set(:@context, node_rendering_context)
    obj
  }

  context 'walk_item' do
    let(:node) {Hiptest::Nodes::Scenario.new('My scenario')}

    it 'provides information about the item content' do
      expect(subject.walk_item(node).keys).to eq([
        :has_description?,
        :has_parameters?,
        :has_tags?,
        :has_step?,
        :is_empty?,
        :declared_variables,
        :raw_parameter_names,
        :self_name,
      ])
    end

    it 'has_description? is true when a description is set' do
      expect(subject.walk_item(node)[:has_description?]).to be false

      node.children[:description] << 'A description for, well, describing ...'
      expect(subject.walk_item(node)[:has_description?]).to be true
    end

    it 'has_parameters? is true when there is parameters' do
      expect(subject.walk_item(node)[:has_parameters?]).to be false

      node.children[:parameters] << Hiptest::Nodes::Parameter.new('x')
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

        node.children[:body] << Hiptest::Nodes::Step.new('action', 'Do something')
        expect(subject.walk_item(node)[:has_step?]).to be true
      end

      it 'works even if the step is inside another statement' do
        node.children[:body] << Hiptest::Nodes::While.new('true', [])
        expect(subject.walk_item(node)[:has_step?]).to be false

        node.children[:body].first.children[:body] << Hiptest::Nodes::Step.new('action', 'Do something')
        expect(subject.walk_item(node)[:has_step?]).to be true
      end
    end

    it 'is_empty? is true when there is no content in the item' do
      expect(subject.walk_item(node)[:is_empty?]).to be true

      node.children[:body] << 'x'
      expect(subject.walk_item(node)[:is_empty?]).to be false
    end

    it ':raw_parameter_names gives the raw names of the parameters' do
      expect(subject.walk_item(node)[:raw_parameter_names]).to eq([])

      node.children[:parameters] << Hiptest::Nodes::Parameter.new('bli')
      node.children[:parameters] << Hiptest::Nodes::Parameter.new('bla')
      node.children[:parameters] << Hiptest::Nodes::Parameter.new('blu blu')

      expect(subject.walk_item(node)[:raw_parameter_names]).to eq(['bli', 'bla', 'blu blu'])
    end
  end

  context 'walk_scenario' do
    let(:node) {
      sc = Hiptest::Nodes::Scenario.new('My scenario')
      sc.parent = Hiptest::Nodes::Scenarios.new([])
      sc.parent.parent = Hiptest::Nodes::Project.new('A project')
      sc
    }

    it 'adds the project name and has_datasets? to walk_item result' do
      allow(node_rendering_context).to receive(:relative_path).and_return("")

      expect(subject.walk_scenario(node).keys).to eq([
        :has_description?,
        :has_parameters?,
        :has_tags?,
        :has_step?,
        :is_empty?,
        :declared_variables,
        :raw_parameter_names,
        :self_name,
        :needs_to_import_actionwords?,
        :relative_package,
        :project_name,
        :has_datasets?,
        :has_annotations?,
        :uniq_name
      ])

      expect(subject.walk_scenario(node)[:project_name]).to eq('A project')
      expect(subject.walk_scenario(node)[:has_datasets?]).to be false

      node.children[:datatable] = Hiptest::Nodes::Datatable.new()
      expect(subject.walk_scenario(node)[:has_datasets?]).to be false

      node.children[:datatable].children[:datasets] << 'Anything'
      expect(subject.walk_scenario(node)[:has_datasets?]).to be true
    end

    it 'adds the relative_package and needs_to_import_actionwords? to walk_scenario result' do
      allow(node_rendering_context).to receive(:relative_path).and_return("my/deep/path")

      expect(subject.walk_scenario(node).keys).to include(
        :needs_to_import_actionwords?,
        :relative_package,
      )

      expect(subject.walk_scenario(node)[:needs_to_import_actionwords?]).to be true
      expect(subject.walk_scenario(node)[:relative_package]).to eq(".my.deep")

      allow(node_rendering_context).to receive(:relative_path).and_return("my")
      expect(subject.walk_scenario(node)[:needs_to_import_actionwords?]).to be false
      expect(subject.walk_scenario(node)[:relative_package]).to eq("")

      allow(node_rendering_context).to receive(:relative_path).and_return("")
      expect(subject.walk_scenario(node)[:needs_to_import_actionwords?]).to be false
      expect(subject.walk_scenario(node)[:relative_package]).to eq("")
    end

    it 'sets has_annotations? to true if at least one call has a Gherkin annotation' do
      allow(node_rendering_context).to receive(:relative_path).and_return("")

      expect(subject.walk_scenario(node)[:has_annotations?]).to be false

      node.children[:body] << Hiptest::Nodes::Call.new('my action word')
      expect(subject.walk_scenario(node)[:has_annotations?]).to be false

      node.children[:body] << Hiptest::Nodes::Call.new('my action word', [], 'given')
      expect(subject.walk_scenario(node)[:has_annotations?]).to be true
    end
  end

  context 'walk_scenarios' do
    let(:node) {
      scs = Hiptest::Nodes::Scenarios.new([])
      scs.parent = Hiptest::Nodes::Project.new('Another project')
      scs
    }

    it 'gives the project name' do
      expect(subject.walk_scenarios(node)).to eq({
        datatables_present?: false,
        project_name: 'Another project',
        self_name: 'Another project',
      })
    end
  end

  context 'walk_actionwords' do
    let(:node) {
      Hiptest::Nodes::Actionwords.new
    }

    let(:project) {Hiptest::Nodes::Project.new('My project')}

    context 'uses_library?' do
      it 'returns false if there is no project for the node' do
        expect(subject.walk_actionwords(node)[:uses_library?]).to be false
      end

      it 'returns false when the project does not have any library' do
        node.parent = project
        expect(subject.walk_actionwords(node)[:uses_library?]).to be false
      end

      it 'returns true otherwise' do
        project.children[:libraries].children[:libraries] << Hiptest::Nodes::Library.new('default')
        node.parent = project
        expect(subject.walk_actionwords(node)[:uses_library?]).to be true
      end
    end
  end

  context 'walk_call' do
    let(:node) {node = Hiptest::Nodes::Call.new('my_action_word')}

    it 'tells if there is arguments' do
      expect(subject.walk_call(node)).to eq({
        has_arguments?: false,
        has_annotation?: false,
        in_actionword?: false,
        in_datatabled_scenario?: false,
        chunks: [],
        extra_inlined_arguments: []
      })

      node.children[:arguments] << 'x'
      expect(subject.walk_call(node)).to eq({
        has_arguments?: true,
        has_annotation?: false,
        in_actionword?: false,
        in_datatabled_scenario?: false,
        chunks: [],
        extra_inlined_arguments: []
      })

      node.children[:annotation] = 'Given'
      expect(subject.walk_call(node)).to eq({
        has_arguments?: true,
        has_annotation?: true,
        in_actionword?: false,
        in_datatabled_scenario?: false,
        chunks: [],
        extra_inlined_arguments: []
      })
    end

    it ':in_actionword? tells if the parent is an action word' do
      expect(subject.walk_call(node)[:in_actionword?]).to be false

      node.parent = Hiptest::Nodes::Actionword.new('Another action word')
      expect(subject.walk_call(node)[:in_actionword?]).to be true
    end

    it ':in_datatabled_scenario? tells if the parent is a scenario with a datatable' do
      expect(subject.walk_call(node)[:in_datatabled_scenario?]).to be false

      node.parent = Hiptest::Nodes::Scenario.new('My scenario')
      expect(subject.walk_call(node)[:in_datatabled_scenario?]).to be false

      node.parent.children[:datatable] = Hiptest::Nodes::Datatable.new()
      node.parent.children[:datatable].children[:datasets] << 'Anything'

      expect(subject.walk_call(node)[:in_datatabled_scenario?]).to be true
    end
  end

  context 'walk_uidcall' do
    let(:node) { Hiptest::Nodes::UIDCall.new('ff85fe99-55c0-48f5-9de3-b4ffd6ea9636') }

    it 'tells if there is an annotation' do
      expect(subject.walk_uidcall(node)[:has_annotation?]).to be false

      node.children[:annotation] = 'Given'
      expect(subject.walk_uidcall(node)[:has_annotation?]).to be true
    end

    it 'tells if there is a library' do
      expect(subject.walk_uidcall(node)[:has_library?]).to be false

      node.children[:library_name] = 'default library'
      expect(subject.walk_uidcall(node)[:has_library?]).to be true
    end
  end

  context 'walk_ifthen' do
    it 'tells if there is stements in the else part' do
      node = Hiptest::Nodes::IfThen.new(nil, nil)

      expect(subject.walk_ifthen(node)).to eq({
        has_else?: false
      })

      node.children[:else] << 'Something'
      expect(subject.walk_ifthen(node)).to eq({
        has_else?: true
      })
    end
  end

  context 'walk_parameter' do
    it 'tells if the parameter has a default value' do
      node = Hiptest::Nodes::Parameter.new('My parameter')

      expect(subject.walk_parameter(node)).to match(a_hash_including({
        has_default_value?: false
      }))

      node.children[:default] = 'Tralala'
      expect(subject.walk_parameter(node)).to match(a_hash_including({
        has_default_value?: true
      }))
    end

    it 'tells if the parameter is a free text parameter' do
      expect(subject.walk_parameter(Hiptest::Nodes::Parameter.new('param'))).to match(a_hash_including({
        is_free_text?: false
      }))
      expect(subject.walk_parameter(Hiptest::Nodes::Parameter.new('__free_text'))).to match(a_hash_including({
        is_free_text?: true
      }))
    end
  end

  context 'walk_tag' do
    it 'tells if the tag has a value' do
      node = Hiptest::Nodes::Tag.new('mytag')

      expect(subject.walk_tag(node)).to eq({
        has_value?: false
      })

      node.children[:value] = '123'
      expect(subject.walk_tag(node)).to eq({
        has_value?: true
      })
    end
  end

  context 'walk_template' do
    let (:node) {Hiptest::Nodes::Template.new([])}
    let (:node_with_variables) {
      Hiptest::Nodes::Template.new([
        Hiptest::Nodes::StringLiteral.new('The value of '),
        Hiptest::Nodes::Variable.new('x'),
        Hiptest::Nodes::StringLiteral.new('should equal the one of '),
        Hiptest::Nodes::Variable.new('y')
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
