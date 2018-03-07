require_relative '../spec_helper'
require_relative '../../lib/hiptest-publisher/nodes'
require_relative '../../lib/hiptest-publisher/node_modifiers/add_all'

describe 'Selenium IDE rendering' do
  include HelperFactories

  # Note: we do not want to test everything as we'll only render
  # tests and calls.

  let(:actionwords) {
    ['open', 'type', 'click', 'verifyTextPresent'].map do |name|
      make_actionword(name, parameters: [
        make_parameter('target', default: literal('')),
        make_parameter('value', default: literal(''))
      ])
    end
  }

  let(:login_test) {
    make_test('Login', body: [
      make_call('open', arguments: [
        make_argument('target', literal('/login'))
      ]),
      make_call('type', arguments: [
        make_argument('target', literal('id=login')),
        make_argument('value', literal('user@example.com'))
      ]),
      make_call('type', arguments: [
        make_argument('target', literal('id=password')),
        make_argument('value', literal('s3cret'))
      ]),
      make_call('click', arguments: [
        make_argument('target', literal('css=.login-form input[type=submit]'))
      ]),
      make_call('verifyTextPresent', arguments: [
        make_argument('target', literal('Welcome user !'))
      ])
    ])
  }

  let(:project) {
    make_project('My test project', tests: [login_test], actionwords: actionwords)
  }

  before(:each) do
    Hiptest::NodeModifiers.add_all(project)
  end

  def rendering(node)
    @context = context_for(
      node: node,
      language: 'seleniumide',
      split_scenarios: split_scenarios)
    node.render(@context)
  end

  context 'Test' do
    let(:split_scenarios) { true }

    it 'generates an html file' do
      expect(rendering(login_test)).to eq([
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
        '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">',
        '  <head profile="http://selenium-ide.openqa.org/profiles/test-case">',
        '    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />',
        '    <link rel="selenium.base" href="http://selenium.googlecode.com/" />',
        '    <title>Login</title>',
        '  </head>',
        '  <body>',
        '    <table>',
        '      <thead>',
        '        <tr>',
        '          <td colspan="3">Login</td>',
        '        </tr>',
        '      </thead>',
        '      <tbody>',
        '        <tr>',
        '          <td>open</td>',
        '          <td>/login</td>',
        '          <td></td>',
        '        </tr>',
        '        <tr>',
        '          <td>type</td>',
        '          <td>id=login</td>',
        '          <td>user@example.com</td>',
        '        </tr>',
        '        <tr>',
        '          <td>type</td>',
        '          <td>id=password</td>',
        '          <td>s3cret</td>',
        '        </tr>',
        '        <tr>',
        '          <td>click</td>',
        '          <td>css=.login-form input[type=submit]</td>',
        '          <td></td>',
        '        </tr>',
        '        <tr>',
        '          <td>verifyTextPresent</td>',
        '          <td>Welcome user !</td>',
        '          <td></td>',
        '        </tr>',
        '      </tbody>',
        '    </table>',
        '  </body>',
        '</html>'
      ].join("\n"))
    end
  end

  context 'Tests' do
    let(:split_scenarios) { false }

    it 'generates a summary' do
      expect(rendering(project.children[:tests])).to eq([
        '<html>',
        '  <head>',
        '    <title>My test project</title>',
        '  </head>',
        '  <body>',
        '    <table>',
        '      <tbody>',
        '        <tr><td><b>Suite Of Tests</b></td></tr>',
        '        <tr>',
        '          <td><a href="./Login.html">Login</a></td>',
        '        </tr>',
        '      </tbody>',
        '    </table>',
        '  </body>',
        '</html>'
      ].join("\n"))
    end
  end
end
