require_relative '../spec_helper'
require_relative '../../lib/hiptest-publisher/indexers/actionword_uid_indexer'

describe Hiptest::ActionwordUidIndexer do
  include HelperFactories

  let(:first_actionword_uid) {'12345678-1234-1234-1234-123456789012'}
  let(:first_actionword) { make_actionword('My first action word', uid: first_actionword_uid)}
  let(:first_lib) { make_library('My first library', [first_actionword])}

  let(:second_actionword_uid) {'87654321-4321-4321-4321-098765432121'}
  let(:second_actionword) { make_actionword('My second action word', uid: second_actionword_uid)}
  let(:second_lib) { make_library('My second library', [second_actionword])}

  let(:project_actionword_uid) {'ABCDABCDABCD-ABCD-ABCD-ABCD-ABCDABCDABCDABCD'}
  let(:project_actionword) { make_actionword('My project action word', uid: project_actionword_uid) }

  let(:project) {
    p = make_project('My project', actionwords: [project_actionword])
    p.children[:libraries] = Hiptest::Nodes::Libraries.new([first_lib, second_lib])
    p
  }

  let(:subject) { Hiptest::ActionwordUidIndexer.new(project) }

  it 'finds an actionword and its library based on an UID' do
    expect(subject.get_index(first_actionword_uid)).to eq({
      actionword: first_actionword,
      library: first_lib
    })

    expect(subject.get_index(second_actionword_uid)).to eq({
      actionword: second_actionword,
      library: second_lib
    })
  end

  it 'can also index actionwords that do not belong to a library' do
    expect(subject.get_index(project_actionword_uid)).to eq({
      actionword: project_actionword,
      library: nil
    })
  end

  it 'returns nil when the action word UID does not exist' do
    expect(subject.get_index('azerty')).to be_nil
  end
end
