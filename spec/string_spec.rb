# encoding: UTF-8
require_relative 'spec_helper'
require_relative '../lib/zest-publisher/string'

describe String do
  context 'literate' do
    it 'returns the same string with only ascii characters' do
      expect('Skøl ofenstrü'.literate).to eq('Skol ofenstru')
    end
  end

  context 'normalize' do
    it 'trims the string' do
      expect('     lala     '.normalize).to eq('lala')
    end

    it 'replaces multiple white characters by a single underscore' do
      expect("flip  flap\tdie\n\nGiraffe".normalize).to eq('flip_flap_die_Giraffe')
    end

    it 'removes quotes' do
      expect(%|it's a "string"|.normalize).to eq('its_a_string')
    end

    it 'literates the string' do
      expect('Skøl ofenstrü'.normalize).to eq('Skol_ofenstru')
    end

    it 'does all at once, hurray <o/' do
      expect(%|  it's  the Støry of\n\n"Pouin Pouin le Marsouin"\n  |.normalize).to eq(
        'its_the_Story_of_Pouin_Pouin_le_Marsouin')
    end
  end

  context 'underscore' do
    it 'returns the string in snake_case' do
      expect('SnakeCase'.underscore).to eq('snake_case')
      expect('almostSnake_case_string'.underscore).to eq('almost_snake_case_string')
    end

    it 'leaves intact a string already in snake case' do
      expect('my_snake_case_string'.underscore).to eq('my_snake_case_string')
    end

    it 'normalize the string before' do
      expect('Skøl ofenstrü'.underscore).to eq('skol_ofenstru')
    end
  end

  context 'camelize' do
    it 'returns the string in CamelCase' do
      expect('camel_case'.camelize).to eq('CamelCase')
      expect('almostCamelCaseString'.camelize).to eq('AlmostCamelCaseString')
    end

    it 'leaves intact a string already camelized' do
      expect('ACamelCaseString'.camelize).to eq('ACamelCaseString')
    end

    it 'normalize the string before' do
      expect('Skøl ofenstrü'.camelize).to eq('SkolOfenstru')
    end

    it "does not fail with multiple spaces" do
      expect('Tra la  la'.camelize).to eq('TraLaLa')
    end
  end

  context 'camelize_lower' do
    it 'returns the string in lower camelCase' do
      expect('camel_case'.camelize_lower).to eq('camelCase')
      expect('almostCamelCaseString'.camelize_lower).to eq('almostCamelCaseString')
    end

    it 'leaves intact a string already camelized' do
      expect('aCamelCaseString'.camelize_lower).to eq('aCamelCaseString')
    end

    it 'normalize the string before' do
      expect('Skøl ofenstrü'.camelize_lower).to eq('skolOfenstru')
    end

    it "does not fail with multiple spaces" do
      expect('Tra la  la'.camelize_lower).to eq('traLaLa')
    end
  end

  context 'clear_extension' do
    it 'removes the extension' do
      expect('MyProject.java'.clear_extension).to eq('MyProject')
    end
  end
end
