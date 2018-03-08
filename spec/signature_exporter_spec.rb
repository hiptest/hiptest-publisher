require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/signature_exporter'

describe Hiptest::SignatureExporter do
  include HelperFactories
  let(:exporter) { Hiptest::SignatureExporter.new }

  let(:aw) {
    make_actionword('my action word',
      uid: '1234-5678',
      parameters: [
        make_parameter('x'),
        make_parameter('y', default: literal('Hi, I am a valued parameter'))
      ]
    )
  }
  let(:aw2) { make_actionword('plic') }

  let(:aws) {
    Hiptest::Nodes::Actionwords.new([aw, aw2])
  }

  let(:first_library) {
    make_library('default library', [
      make_actionword('My first lib actionword', uid: 'aw-lib-uid'),
      make_actionword('My second lib actionword', uid: 'aw1-lib-uid')]
  )}

  let(:second_library) {
    make_library('second library', [
      make_actionword('Another lib actionword', uid: 'aw2-lib-uid'),
    ])
  }

  let(:project) {
    make_project('My project', actionwords: [aw, aw2])
  }

  describe 'self.export_actionwords' do
    it 'exports all actionwords of a project as a hash' do
      expect(Hiptest::SignatureExporter.export_actionwords(project)).to eq([
        {
          "name" => "my action word",
          "uid" => "1234-5678",
          "parameters" => [
            {"name" => "x"},
            {"name" => "y"}
          ],
          "body_hash" => "d41d8cd98f00b204e9800998ecf8427e"
        },
        {
          "name" => "plic",
          "uid" => nil,
          "parameters" => [],
          "body_hash" => "d41d8cd98f00b204e9800998ecf8427e"
        }
      ])
    end

    it 'if asked, it also export the AW node' do
      expect(Hiptest::SignatureExporter.export_actionwords(project, true)).to eq([
        {
          "name" => "my action word",
          "uid" => "1234-5678",
          "parameters" => [
            {"name" => "x"},
            {"name" => "y"}
          ],
          "body_hash" => "d41d8cd98f00b204e9800998ecf8427e",
          "node" => aw},
        {
          "name" => "plic",
          "uid" => nil,
          "parameters" => [],
          "body_hash" => "d41d8cd98f00b204e9800998ecf8427e",
          "node" => aw2
        }
      ])
    end

    it 'also exports libraries when available' do
      project.children[:libraries].children[:libraries] << first_library
      project.children[:libraries].children[:libraries] << second_library

      expect(Hiptest::SignatureExporter.export_actionwords(project)).to eq([
        {
          "name" => "my action word",
          "uid" => "1234-5678",
          "parameters" => [
            {"name" => "x"},
            {"name" => "y"}
          ],
          "body_hash" => "d41d8cd98f00b204e9800998ecf8427e"
        },
        {
          "name" => "plic",
          "uid" => nil,
          "parameters" => [],
          "body_hash" => "d41d8cd98f00b204e9800998ecf8427e"
        },
        {
          "name" => "default library",
          "type" => "library",
          "actionwords" => [
            {
              "name" => "My first lib actionword",
              "uid" => 'aw-lib-uid',
              "parameters" => [],
              "body_hash"=>"d41d8cd98f00b204e9800998ecf8427e"
            },
            {
              "name" => "My second lib actionword",
              "uid" => 'aw1-lib-uid',
              "parameters" => [],
              "body_hash"=>"d41d8cd98f00b204e9800998ecf8427e"
            }
          ]
        },
        {
          "name" => "second library",
          "type" => "library",
          "actionwords" => [
            {
              "name" => "Another lib actionword",
              "uid" => 'aw2-lib-uid',
              "parameters" => [],
              "body_hash"=>"d41d8cd98f00b204e9800998ecf8427e"
            }
          ]
        }
      ])
    end
  end

  describe 'export_actionwords' do
    it 'exports all actionwords of a project as a hash' do
      expect(exporter.export_actionwords(aws)).to eq([
        {
          "name" => "my action word",
          "uid" => "1234-5678",
          "parameters" => [
            {"name" => "x"},
            {"name" => "y"}
          ],
          "body_hash" => "d41d8cd98f00b204e9800998ecf8427e"
        },
        {
          "name" => "plic",
          "uid" => nil,
          "parameters" => [],
          "body_hash"=>"d41d8cd98f00b204e9800998ecf8427e"
        }
      ])
    end
  end

  context 'export_libraries' do
    it 'export actionwords in a list inside hash for each library' do
      project.children[:libraries].children[:libraries] << first_library
      project.children[:libraries].children[:libraries] << second_library

      expect(exporter.export_libraries(project.children[:libraries])).to eq([
        {
          "name" => "default library",
          "type" => "library",
          "actionwords" => [
            {
              "name" => "My first lib actionword",
              "uid" => 'aw-lib-uid',
              "parameters" => [],
              "body_hash"=>"d41d8cd98f00b204e9800998ecf8427e"
            },
            {
              "name" => "My second lib actionword",
              "uid" => 'aw1-lib-uid',
              "parameters" => [],
              "body_hash"=>"d41d8cd98f00b204e9800998ecf8427e"
            }
          ]
        },
        {
          "name" => "second library",
          "type" => "library",
          "actionwords" => [
            {
              "name" => "Another lib actionword",
              "uid" => 'aw2-lib-uid',
              "parameters" => [],
              "body_hash"=>"d41d8cd98f00b204e9800998ecf8427e"
            }
          ]
        },
      ])
    end
  end

  describe 'export_actionword' do
    it 'exports usefull data an item (scenario, actionword)' do
      expect(exporter.export_actionword(aw)).to eq({
        "name" => "my action word",
        "parameters" => [{"name"=>"x"}, {"name"=>"y"}],
        "body_hash" => "d41d8cd98f00b204e9800998ecf8427e",
        "uid" => "1234-5678"
      })
    end
  end

  describe 'export_parameters' do
    it 'exports all parameters of an item as a list' do
      expect(exporter.export_parameters(aw)).to eq([{'name' => 'x'}, {'name' => 'y'}])
    end

    it 'exports an empty list if there is no parameters' do
      expect(exporter.export_parameters(make_actionword('plop'))).to eq([])
    end
  end

  describe 'export_parameter' do
    let(:param) { make_parameter('x', default: literal('Hi, I am a valued parameter')) }

    it 'exports the name of a parameter' do
      expect(exporter.export_parameter(param)).to eq({'name' => 'x'})
    end
  end
end
