require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/nodes'
require_relative '../lib/hiptest-publisher/call_arguments_adder'

describe 'Selenium IDE rendering' do
  include HelperFactories

  # Note: we do not want to test everything as we'll only render
  # tests and calls.

  let(:actionwords) {
    ['open', 'type', 'click', 'verifyTextPresent'].map do |name|
      make_actionword(name, [], [
        make_parameter('target', make_literal(:string, '')),
        make_parameter('value', make_literal(:string, ''))
      ])
    end
  }

  let(:login_test) {
    make_test('Login', [], [
      make_call('open', [
        make_argument('target', make_literal(:string, '/login'))
      ]),
      make_call('type', [
        make_argument('target', make_literal(:string, 'id=login')),
        make_argument('value', make_literal(:string, 'user@example.com'))
      ]),
      make_call('type', [
        make_argument('target', make_literal(:string, 'id=password')),
        make_argument('value', make_literal(:string, 's3cret'))
      ]),
      make_call('click', [
        make_argument('target', make_literal(:string, 'css=.login-form input[type=submit]'))
      ]),
      make_call('verifyTextPresent', [
        make_argument('target', make_literal(:string, 'Welcome user !'))
      ])
    ])
  }

  let(:project) {
    make_project('My test project', [], [login_test], actionwords)
  }

  before(:each) do
    Hiptest::DefaultArgumentAdder.add(project)
    @context = {framework: '', forced_templates: {}}
  end

  context 'Test' do
    it 'generates an html file' do
      @context[:forced_templates] = {'test' => 'single_test'}

      expect(login_test.render('seleniumide', @context)).to eq([
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
    it 'generates a summary' do
      expect(project.children[:tests].render('seleniumide', @context)).to eq([
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