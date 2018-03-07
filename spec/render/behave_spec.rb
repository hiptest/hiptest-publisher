require_relative '../spec_helper'
require_relative '../render_shared'

describe 'Behave rendering' do
  include HelperFactories

  it_behaves_like 'a BDD renderer', uid_should_be_in_outline: true do
    let(:language) {'behave'}
    let(:rendered_actionwords) {
      [
        'from behave import *',
        '',
        '# This should be added to environment.py',
        '# from steps.actionwords import Actionwords',
        '#',
        '# def before_scenario(context, scenario):',
        '#     context.actionwords = Actionwords()',
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
        '@then(r\'you cannot play croquet\')',
        'def impl(context):',
        '    context.actionwords.you_cannot_play_croquet()',
        '',
        '',
        '@given(r\'I am on the "(.*)" home page\')',
        '@when(r\'I am on the "(.*)" home page\')',
        'def impl(context, site, free_text = \'\'):',
        '    context.actionwords.i_am_on_the_site_home_page(site, context.text)',
        '',
        '',
        '@when(r\'the following users are available on "(.*)"\')',
        'def impl(context, site, datatable = \'||\'):',
        '    context.actionwords.the_following_users_are_available_on_site(site, context.table)',
        '',
        '',
        '@given(r\'an untrimed action word\')',
        'def impl(context):',
        '    context.actionwords.an_untrimed_action_word()',
        '',
        '',
        '@given(r\'the "(.*)" of "(.*)" is weird "(.*)" "(.*)"\')',
        'def impl(context, order, parameters, p0, p1):',
        '    context.actionwords.the_order_of_parameters_is_weird(p0, p1, parameters, order)',
        '',
        '',
        '@given(r\'I login on "(.*)" "(.*)"\')',
        'def impl(context, site, username):',
        '    context.actionwords.i_login_on(site, username)',
        ''
      ].join("\n")
    }

    let(:rendered_free_texted_actionword) {[
      'def the_following_users_are_available(self, free_text = \'\'):',
      '    pass',
      ''].join("\n")}

    let(:rendered_datatabled_actionword) {[
      'def the_following_users_are_available(self, datatable = \'\'):',
      '    pass',
      ''].join("\n")}

    let(:rendered_empty_scenario) { "\nScenario: Empty Scenario\n" }
  end

  it 'strips last colon of an actionword name' do
    # If your action word is called "Do something:", Behave will try to match "Do something"
    aw = make_actionword('I do something:')
    project = make_project("Colors",
      scenarios: [
        make_scenario('My scenario',
          body: [
            make_call("I do something:",  annotation: "when")
          ])
      ],
      actionwords: [aw]
    )
    Hiptest::NodeModifiers.add_all(project)

    options =  context_for(only: "step_definitions", language: 'behave')
    expect(aw.render(options)).to eq([
      "",
      "@when(r'I do something')",
      "def impl(context):",
      "    context.actionwords.i_do_something()"
    ].join("\n"))
  end
end
