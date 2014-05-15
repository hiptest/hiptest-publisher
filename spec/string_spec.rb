# encoding: UTF-8
require_relative 'spec_helper'
require_relative '../lib/zest-publisher/string'

describe String do
  context 'literate' do
    it 'returns the same string with only ascii characters' do
      'Skøl ofenstrü'.literate.should eq('Skol ofenstru')
    end
  end

  context 'normalize' do
    it 'trims the string' do
      '     lala     '.normalize.should eq('lala')
    end

    it 'replaces multiple white characters by a single underscore' do
      "flip  flap\tdie\n\nGiraffe".normalize.should eq('flip_flap_die_Giraffe')
    end

    it 'removes quotes' do
      %|it's a "string"|.normalize.should eq('its_a_string')
    end

    it 'literates the string' do
      'Skøl ofenstrü'.normalize.should eq('Skol_ofenstru')
    end

    it 'does all at once, hurray <o/' do
      %|  it's  the Støry of\n\n"Pouin Pouin le Marsouin"\n  |.normalize.should eq(
        'its_the_Story_of_Pouin_Pouin_le_Marsouin')
    end
  end

  context 'underscore' do
    it 'returns the string in snake_case' do
      'SnakeCase'.underscore.should eq('snake_case')
      'almostSnake_case_string'.underscore.should eq('almost_snake_case_string')
    end

    it 'leaves intact a string already in snake case' do
      'my_snake_case_string'.underscore.should eq('my_snake_case_string')
    end

    it 'normalize the string before' do
      'Skøl ofenstrü'.underscore.should eq('skol_ofenstru')
    end
  end

  context 'camelize' do
    it 'returns the string in CamelCase' do
      'camel_case'.camelize.should eq('CamelCase')
      'almostCamelCaseString'.camelize.should eq('AlmostCamelCaseString')
    end

    it 'leaves intact a string already camelized' do
      'ACamelCaseString'.camelize.should eq('ACamelCaseString')
    end

    it 'normalize the string before' do
      'Skøl ofenstrü'.camelize.should eq('SkolOfenstru')
    end

    it "does not fail with multiple spaces" do
      'Tra la  la'.camelize.should eq('TraLaLa')
    end
  end
end
