require_relative 'spec_helper'

require_relative '../lib/hiptest-publisher/signature_exporter'
require_relative '../lib/hiptest-publisher/signature_differ'

describe Hiptest::SignatureDiffer do
  include HelperFactories

  let(:exporter) { Hiptest::SignatureExporter }
  let(:differ) { Hiptest::SignatureDiffer }

  let(:v1) {
    exporter.export_actionwords(
      make_project('My project', [], [], [
        make_actionword('My actionword', [], [], [], 'id1')
      ])
    )
  }

  let(:v2) {
    exporter.export_actionwords(
      make_project('My project', [], [], [
        make_actionword('My actionword', [], [], [], 'id1'),
        make_actionword('My actionwurst', [], [], [], 'id2')
      ])
    )
  }

  let(:v3) {
    exporter.export_actionwords(
      make_project('My project', [], [], [
        make_actionword('My actionword', [], [], [], 'id1'),
        make_actionword('My actionwürst', [], [], [], 'id2')
      ])
    )
  }

  it 'finds newly created action words' do
    expect(differ.diff(v1, v2)).to eq({created: [{name: 'My actionwurst'}]})
  end

  it 'finds removed action words' do
    expect(differ.diff(v2, v1)).to eq({deleted: [{name: 'My actionwurst'}]})
  end

  it 'finds renamed action words' do
    expect(differ.diff(v2, v3)).to eq({renamed: [{name: 'My actionwurst', new_name: 'My actionwürst'}]})
  end

  it 'finds newly added parameters'
  it 'finds removed parameters'
end