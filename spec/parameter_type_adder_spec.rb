require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/zest-publisher/nodes'
require_relative '../lib/zest-publisher/parameter_type_adder'

describe Zest::Nodes do
  context 'ParameterTypeAdder' do

    it 'gives string type if calls nothing' do
      parameter = type_adding(Zest::Nodes::Parameter.new('x'))
      expect(parameter.childs[:type]).to eq(:String)
    end

    it 'gives integer type if calls with an integer value' do
      parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::NumericLiteral.new('3'))
      expect(parameter.childs[:type]).to eq(:int)
    end

    it 'gives float type if calls with a float value' do
      parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::NumericLiteral.new('3.14'))
      expect(parameter.childs[:type]).to eq(:float)
    end

    it 'gives boolean type if calls with boolean value' do
      parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::BooleanLiteral.new(true))
      expect(parameter.childs[:type]).to eq(:bool)
    end

    it 'gives string type if calls with null value' do
      parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::NullLiteral.new)
      expect(parameter.childs[:type]).to eq(:null)
    end

    it 'gives string type if calls with a template value' do
      parameter = type_adding(
        Zest::Nodes::Parameter.new('x'),
        Zest::Nodes::Template.new([Zest::Nodes::StringLiteral.new('My value')])
      )
      expect(parameter.childs[:type]).to eq(:String)
    end

    it 'gives string type if calls with a string value' do
      parameter = type_adding(Zest::Nodes::Parameter.new('x'), Zest::Nodes::StringLiteral.new('my string'))
      expect(parameter.childs[:type]).to eq(:String)
    end

    it 'gives float type if calls with integer and float values' do
      parameter = type_adding(
        Zest::Nodes::Parameter.new('x'),
        Zest::Nodes::NumericLiteral.new('3'),
        Zest::Nodes::NumericLiteral.new('4.12'))
      expect(parameter.childs[:type]).to eq(:float)
    end

    it 'gives int type if calls with integer value and null values' do
      parameter = type_adding(
        Zest::Nodes::Parameter.new('x'),
        Zest::Nodes::NullLiteral.new,
        Zest::Nodes::NumericLiteral.new('4'))
      expect(parameter.childs[:type]).to eq(:int)
    end

    it 'gives float type if calls with integer value, float value and null values' do
      parameter = type_adding(
        Zest::Nodes::Parameter.new('x'),
        Zest::Nodes::NumericLiteral.new('3.14'),
        Zest::Nodes::NullLiteral.new,
        Zest::Nodes::NumericLiteral.new('4'))
      expect(parameter.childs[:type]).to eq(:float)
    end

    it 'gives boolean type if calls with boolean values and null value' do
      parameter = type_adding(
        Zest::Nodes::Parameter.new('x'),
        Zest::Nodes::BooleanLiteral.new(true),
        Zest::Nodes::NullLiteral.new,
        Zest::Nodes::BooleanLiteral.new(false))
      expect(parameter.childs[:type]).to eq(:bool)
    end

    it 'gives string type if impossible to deduce type' do
      parameter = type_adding(
        Zest::Nodes::Parameter.new('x'),
        Zest::Nodes::BooleanLiteral.new(true),
        Zest::Nodes::NumericLiteral.new('3'))
      expect(parameter.childs[:type]).to eq(:String)
    end
  end
end

def type_adding(parameter, *called_values)
  aw = Zest::Nodes::Actionword.new('aw', [], [parameter], [])
  calls = called_values.map{|called_value|
    Zest::Nodes::Call.new('aw', [Zest::Nodes::Argument.new('x', called_value)])
  }
  sc = Zest::Nodes::Scenario.new('many calls scenarios', '', [], [], calls)
  actionwords= Zest::Nodes::Actionwords.new([aw])
  scenarios= Zest::Nodes::Scenarios.new([sc])
  project = Zest::Nodes::Project.new('My project', '', scenarios, actionwords)

  Zest::Nodes::ParameterTypeAdder.add(project)
  parameter
end
