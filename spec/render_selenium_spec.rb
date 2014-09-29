require_relative 'spec_helper'
require_relative '../lib/zest-publisher/nodes'
require_relative '../lib/zest-publisher/call_arguments_adder'

describe 'Selenium IDE rendering' do
  # Note: we do not want to test everything as we'll only render
  # tests and calls.

  before(:each) do
    project = Zest::Nodes::Project.new('My test project')
    ['open', 'type', 'click', 'verifyTextPresent'].each do |name|
      project.children[:actionwords].children[:actionwords] << Zest::Nodes::Actionword.new(name, [], [
        Zest::Nodes::Parameter.new('target', Zest::Nodes::StringLiteral.new('')),
        Zest::Nodes::Parameter.new('value', Zest::Nodes::StringLiteral.new(''))
      ])
    end

    @first_test = Zest::Nodes::Test.new(
      'Login',
      '',
      [],
      [
        Zest::Nodes::Call.new('open', [
          Zest::Nodes::Argument.new('target', Zest::Nodes::StringLiteral.new('/login'))
        ]),
        Zest::Nodes::Call.new('type', [
          Zest::Nodes::Argument.new('target', Zest::Nodes::StringLiteral.new('id=login')),
          Zest::Nodes::Argument.new('value', Zest::Nodes::StringLiteral.new('user@example.com'))
        ]),
        Zest::Nodes::Call.new('type', [
          Zest::Nodes::Argument.new('target', Zest::Nodes::StringLiteral.new('id=password')),
          Zest::Nodes::Argument.new('value', Zest::Nodes::StringLiteral.new('s3cret'))
        ]),
        Zest::Nodes::Call.new('click', [
          Zest::Nodes::Argument.new('target', Zest::Nodes::StringLiteral.new('css=.login-form input[type=submit]'))
        ]),
        Zest::Nodes::Call.new('verifyTextPresent', [
          Zest::Nodes::Argument.new('target', Zest::Nodes::StringLiteral.new('Welcome user !'))
        ])
      ])


    @tests = project.children[:tests]
    @tests.children[:tests] << @first_test
    @first_test.parent = @tests
    @tests.parent = project

    Zest::DefaultArgumentAdder.add(project)

    @context = {framework: '', forced_templates: {}}
  end

  context 'Test' do
    it 'generates an html file' do
      @context[:forced_templates] = {'test' => 'single_test'}

      expect(@first_test.render('selenium', @context)).to eq([
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
      expect(@tests.render('selenium', @context)).to eq([
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