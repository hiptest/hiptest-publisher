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
      renamed: [{name: "My actionword", new_name: "My actionzord", node: aw1v4}],
      signature_changed: [{name: "My actionzord", node: aw1v4}],
      definition_changed: [{name: 'My actionzord', node: aw1v4}]
    })
  end
end
