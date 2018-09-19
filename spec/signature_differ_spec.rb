require_relative 'spec_helper'

require_relative '../lib/hiptest-publisher/signature_exporter'
require_relative '../lib/hiptest-publisher/signature_differ'

describe Hiptest::SignatureDiffer do
  include HelperFactories

  let(:exporter) { Hiptest::SignatureExporter }
  let(:differ) { Hiptest::SignatureDiffer }

  let(:aw1v1) { make_actionword('My actionword', uid: 'id1', body: [
      Hiptest::Nodes::Step.new('action', Hiptest::Nodes::StringLiteral.new('Do something'))
    ])
  }

  let(:aw1v2) {
    make_actionword('My actionzord', uid: 'id1', parameters: [
      make_parameter('x'),
      make_parameter('y', default: literal('Hi, I am a valued parameters'))
    ], body: [
      Hiptest::Nodes::Step.new('action', Hiptest::Nodes::StringLiteral.new('Do something'))
    ])
  }

  let(:aw1v3) {
    make_actionword('My actionzord', uid: 'id1', parameters: [
      make_parameter('y', default: literal('Hi, I am a valued parameter')),
      make_parameter('z'),
    ], body: [
      Hiptest::Nodes::Step.new('action', Hiptest::Nodes::StringLiteral.new('Do something'))
    ])
  }

  let(:aw1v4) {
    make_actionword('My actionzord', uid: 'id1', parameters: [
      make_parameter('y', default: literal('Hi, I am a valued parameter')),
      make_parameter('z'),
    ], body: [
      Hiptest::Nodes::Step.new('action', Hiptest::Nodes::StringLiteral.new('Do something better'))
    ])
  }

  let(:aw2v1) {
    make_actionword('My actionwurst', uid: 'id2')
  }

  let(:aw2v2) {
    make_actionword('My actionwürst', uid: 'id2')
  }

  let(:v1) {
    exporter.export_actionwords(
      make_project('My project', actionwords: [aw1v1]), true
    )
  }

  let(:v2) {
    exporter.export_actionwords(
      make_project('My project', actionwords: [aw1v1, aw2v1]), true
    )
  }

  let(:v3) {
    exporter.export_actionwords(
      make_project('My project', actionwords: [aw1v1, aw2v2]), true
    )
  }

  let(:v4) {
    exporter.export_actionwords(
      make_project('My project', actionwords: [aw1v2]), true
    )
  }

  let(:v5) {
    exporter.export_actionwords(
      make_project('My project', actionwords: [aw1v3]), true
    )
  }

  let(:v6) {
    exporter.export_actionwords(
      make_project('My project', actionwords: [aw1v4]), true
    )
  }

  it 'finds newly created action words' do
    expect(differ.diff(v1, v2)).to eq({created: [{name: 'My actionwurst', node: aw2v1}]})
  end

  it 'finds removed action words' do
    expect(differ.diff(v2, v1)).to eq({deleted: [{name: 'My actionwurst'}]})
  end

  it 'finds renamed action words' do
    expect(differ.diff(v2, v3)).to eq({renamed: [{name: 'My actionwurst', new_name: 'My actionwürst', node: aw2v2}]})
  end

  it 'finds updated signature (not really fine diff for now)' do
    expect(differ.diff(v4, v5)).to eq({signature_changed: [{name: 'My actionzord', node: aw1v3}]})
  end

  it 'finds definition changes' do
    expect(differ.diff(v5, v6)).to eq({definition_changed: [{name: 'My actionzord', node: aw1v4}]})
  end

  it 'can find lots of things at once' do
    expect(differ.diff(v2, v6)).to eq({
      deleted: [{name: "My actionwurst"}],
      definition_changed: [{name: 'My actionzord', node: aw1v4}]
    })
  end

  context 'it does not display the same action words in multiple categories' do
    let(:aw3v1) {
      make_actionword('I do "p1"', uid: 'id1', parameters: [
        make_parameter('p1'),
      ], body: [
      ])
    }

    let(:aw3v2) {
      make_actionword('I do "things"', uid: 'id1', parameters: [
        make_parameter('things'),
      ], body: [
      ])
    }

    let(:aw3v3) {
      make_actionword('I do "things"', uid: 'id1', parameters: [
        make_parameter('things', default: literal('')),
      ], body: [
        Hiptest::Nodes::Step.new('action', Hiptest::Nodes::StringLiteral.new('Do things'))
      ])
    }

    let(:v1) {
      exporter.export_actionwords(
        make_project('My project', actionwords: [aw3v1]), true
      )
    }

    let(:v2) {
      exporter.export_actionwords(
        make_project('My project', actionwords: [aw3v2]), true
      )
    }

    let(:v3) {
      exporter.export_actionwords(
        make_project('My project', actionwords: [aw3v3]), true
      )
    }

    it 'when the name and signature changed' do
      expect(differ.diff(v1, v2)).to eq({
        signature_changed: [{name: 'I do "things"', node: aw3v2}]
      })
    end

    it 'when the definition and signature changed' do
      expect(differ.diff(v2, v3)).to eq({
        definition_changed: [{name: 'I do "things"', node: aw3v3}]
      })
    end

    it 'when the definition, signature and definition changed' do
      expect(differ.diff(v1, v3)).to eq({
        definition_changed: [{name: 'I do "things"', node: aw3v3}]
      })
    end
  end

  it 'does not mind libraries being exported at the same level than actionwords' do
    current = exporter.export_actionwords(
      make_project('My project',
        actionwords: [aw1v1],
        libraries: Hiptest::Nodes::Libraries.new([
          make_library('my library', [make_actionword('My new action word')])
        ])), true
    )

    expect(differ.diff(v1, current)).to be_empty
  end

  it 'uses the actionwords from the library to compute the diff when argument library_name is provided' do
    old = exporter.export_actionwords(
      make_project('My project',
        actionwords: [make_actionword('My old action word')],
        libraries: Hiptest::Nodes::Libraries.new([
          make_library('my library', [aw1v1])
        ])), true
    )

    current = exporter.export_actionwords(
      make_project('My project',
        actionwords: [make_actionword('My new action word'), aw2v1],
        libraries: Hiptest::Nodes::Libraries.new([
          make_library('my library', [aw1v2])
        ])), true
    )

    expect(differ.diff(old, current, library_name: 'my library')).to eq({
      :signature_changed => [
        {
          name: aw1v2.children[:name],
          node: aw1v2
        }
      ]
    })
  end
end
