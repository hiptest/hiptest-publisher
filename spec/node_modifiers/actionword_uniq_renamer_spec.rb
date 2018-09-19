require_relative '../spec_helper'
require_relative '../../lib/hiptest-publisher/node_modifiers/actionword_uniq_renamer'

describe Hiptest::NodeModifiers::ActionwordUniqRenamer do
  include HelperFactories

  context 'find_uniq_name' do
    let(:subject) { Hiptest::NodeModifiers::ActionwordUniqRenamer.new(nil) }

    it 'returns the original one if it does not belong to the list' do
      expect(subject.find_uniq_name('Plop', [])).to eq('Plop')
      expect(subject.find_uniq_name('Plop', ['Plip', 'Plup'])).to eq('Plop')
    end

    it 'adds a postfix to make the name uniq' do
      expect(subject.find_uniq_name('Plop', ['Plop'])).to eq('Plop 1')
    end

    it 'does not reuse an existing name' do
      expect(subject.find_uniq_name('Plop', ['Plop', 'Plop 1', 'Plop 2'])).to eq('Plop 3')
    end
  end

  context 'make_uniq_names' do
    let(:first_lib) { Hiptest::Nodes::Library.new('First library') }
    let(:second_lib) { Hiptest::Nodes::Library.new('Second library') }

    let(:project) {
      p = Hiptest::Nodes::Project.new('My project')

      p.children[:libraries].children[:libraries] << first_lib
      p.children[:libraries].children[:libraries] << second_lib
      p
    }

    let(:subject) {
      Hiptest::NodeModifiers::ActionwordUniqRenamer.new(project)
    }

    it 'renames action words if needed' do
      first_lib.children[:actionwords] << make_actionword('plop', uid: '1234')
      first_lib.children[:actionwords] << make_actionword('plop', uid: '5678')
      first_lib.children[:actionwords] << make_actionword('plop', uid: '0987')

      subject.make_uniq_names()

      expect(first_lib.children[:actionwords].map(&:uniq_name)).to eq(['plop 1', 'plop 2', 'plop'])
    end

    it 'only limitates to names inside a library' do
      first_lib.children[:actionwords] << make_actionword('plop', uid: '1234')
      second_lib.children[:actionwords] << make_actionword('plop', uid: '5678')

      subject.make_uniq_names()

      expect(first_lib.children[:actionwords].map(&:uniq_name)).to eq(['plop'])
      expect(second_lib.children[:actionwords].map(&:uniq_name)).to eq(['plop'])
    end
  end
end
