require_relative '../spec_helper'

require_relative '../../lib/hiptest-publisher/node_modifiers/uid_call_reference_adder'

describe Hiptest::NodeModifiers::UidCallReferencerAdder do
  include HelperFactories

  let(:library_actionword_uid) { '12345678-1234-1234-123456789012'}
  let(:library_actionword) { make_actionword('My library actionword', uid: library_actionword_uid)}
  let(:library) { make_library('default', [library_actionword]) }

  let(:project_actionword_uid) { '87654321-4321-432-0987654321321'}
  let(:project_actioword) { make_actionword('My project actionword', uid: project_actionword_uid)}

  let(:library_uid_call) { make_uidcall(library_actionword_uid)}
  let(:project_uid_call) { make_uidcall(project_actionword_uid)}

  let(:scenario) {
    make_scenario('My scenario', body: [
      library_uid_call,
      project_uid_call
    ])
  }

  let(:incorrect_scenario) {
    make_scenario('My scenario', body: [
       make_uidcall("an-unknown-uid")
    ])
  }


  let(:project) {
    make_project(
      'My project',
      scenarios: [scenario, incorrect_scenario],
      actionwords: [project_actioword],
      libraries: Hiptest::Nodes::Libraries.new([library])
    )
  }

  context 'add' do
    before do
      Hiptest::NodeModifiers::UidCallReferencerAdder.add(project)
    end

    it 'adds the names of the actionword and libraries to UID calls' do
      expect(library_uid_call.children[:actionword_name]).to eq('My library actionword')
      expect(library_uid_call.children[:library_name]).to eq('default')
    end

    it 'does not set the library_name if the action word belongs to the project' do
      expect(project_uid_call.children[:actionword_name]).to eq('My project actionword')
      expect(project_uid_call.children).not_to have_key(:library_name)
    end

    it 'adds a message when the referenced actionword do not exist' do
      # Far from perfect, but at least code will be generated
      expect(incorrect_scenario.children[:body].first.children[:actionword_name]).to eq("Unknown actionword with UID: an-unknown-uid")
    end
  end
end
