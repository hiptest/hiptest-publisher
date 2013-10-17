# encoding: UTF-8

require_relative '../utils'

describe 'normalize_string' do
  it 'trims' do
    normalize_string('     lala     ').should eq('lala')
  end

  it 'transliterate' do
    normalize_string('Skøl ofenstrü').should eq('Skl_ofenstru')
  end

  it 'replaces multiple white characters by a single underscore' do
    normalize_string("flip  flap\tdas\n\nGirafe").should eq('flip_flap_das_Girafe')
  end

  it 'removes quotes' do
    normalize_string(%|it's a "string"|).should eq('its_a_string')
  end

  it 'does all at once, hurray <o/' do
    normalize_string(%|  it's  the Støry of\n\n"Pouin Pouin le Marsouin"\n  |).should eq('its_the_Stry_of_Pouin_Pouin_le_Marsouin')
  end
end