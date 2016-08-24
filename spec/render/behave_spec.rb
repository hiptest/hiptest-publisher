require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Behave rendering' do
  it_behaves_like 'a BDD renderer' do
    let(:language) {'behave'}

    let(:rendered_actionwords) {
      [
        'from behave import *',
        '',
        '# This should be added to environments.py',
        '# from steps.actionwords import Actionwords',
        '#',
        '# def before_scenario(context, scenario):',
        '#     context.actionwords = Actionwords.new(nil)',
        '',
        'use_step_matcher(\'re\')',
        '',
        '',
        '@given(r\'the color "(.*)"\')',
        'def impl(context, color):',
        '    context.actionwords.the_color_color(color)',
        '',
        '',
        '@when(r\'you mix colors\')',
        'def impl(context):',
        '    context.actionwords.you_mix_colors()',
        '',
        '',
        '@then(r\'you obtain "(.*)"\')',
        'def impl(context, color):',
        '    context.actionwords.you_obtain_color(color)',
        '',
        '',
        '',
        '',
        '@but(r\'you cannot play croquet\')',
        'def impl(context):',
        '    context.actionwords.you_cannot_play_croquet()',
        '',
        '',
        '@given(r\'I am on the "(.*)" home page\')',
        '@when(r\'I am on the "(.*)" home page\')',
        'def impl(context, site, __free_text = \'\'):',
        '    context.actionwords.i_am_on_the_site_home_page(site, __free_text)',
        ''
      ].join("\n")
    }
  end
end
