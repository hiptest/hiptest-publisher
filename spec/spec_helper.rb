require "codeclimate-test-reporter"
require_relative '../lib/zest-publisher/nodes'

CodeClimate::TestReporter.start

module HelperFactories
  def make_var(name)
    Zest::Nodes::Variable(name)
  end

  def make_literal(type, value)
    if type == :nil
      return Zest::Nodes::NullLiteral.new
    end

    mapping = {
      :numeric => Zest::Nodes::NumericLiteral,
      :string =>  Zest::Nodes::StringLiteral,
      :boolean => Zest::Nodes::BooleanLiteral
    }
    mapping[type].new(value)
  end

  def make_argument(name, value)
    Zest::Nodes::Argument.new(name, value)
  end

  def make_call(actionword, arguments)
    Zest::Nodes::Call.new(actionword, arguments)
  end

  def make_parameter(name, default=nil)
    Zest::Nodes::Parameter.new(name, default)
  end

  def make_actionword(name, tags = [], parameters = [], body = [])
    Zest::Nodes::Actionword.new(name, tags, parameters, body)
  end

  def make_scenario(name, tags, parameters, body)
    Zest::Nodes::Scenario.new(name, '', tags, parameters, body)
  end

  def make_test(name, tags, body)
    Zest::Nodes::Test.new(name, tags, body)
  end

  def make_project(name, scenarios, tests, actionwords)
    Zest::Nodes::Project.new(name, '',
      Zest::Nodes::TestPlan.new,
      Zest::Nodes::Scenarios.new(scenarios),
      Zest::Nodes::Actionwords.new(actionwords),
      Zest::Nodes::Tests.new(tests)
    )
  end
end