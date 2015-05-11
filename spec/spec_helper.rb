require "codeclimate-test-reporter"
require_relative '../lib/hiptest-publisher/nodes'

CodeClimate::TestReporter.start

module HelperFactories
  def make_var(name)
    Hiptest::Nodes::Variable(name)
  end

  def make_literal(type, value)
    if type == :nil
      return Hiptest::Nodes::NullLiteral.new
    end

    mapping = {
      :numeric => Hiptest::Nodes::NumericLiteral,
      :string =>  Hiptest::Nodes::StringLiteral,
      :boolean => Hiptest::Nodes::BooleanLiteral
    }
    mapping[type].new(value)
  end

  def make_argument(name, value)
    Hiptest::Nodes::Argument.new(name, value)
  end

  def make_call(actionword, arguments= [])
    Hiptest::Nodes::Call.new(actionword, arguments)
  end

  def make_parameter(name, default=nil)
    Hiptest::Nodes::Parameter.new(name, default)
  end

  def make_actionword(name, tags = [], parameters = [], body = [], uid = nil)
    Hiptest::Nodes::Actionword.new(name, tags, parameters, body, uid)
  end

  def make_scenario(name, tags, parameters, body)
    Hiptest::Nodes::Scenario.new(name, '', tags, parameters, body)
  end

  def make_test(name, tags, body)
    Hiptest::Nodes::Test.new(name, '', tags, body)
  end

  def make_project(name, scenarios, tests, actionwords)
    Hiptest::Nodes::Project.new(name, '',
      Hiptest::Nodes::TestPlan.new,
      Hiptest::Nodes::Scenarios.new(scenarios),
      Hiptest::Nodes::Actionwords.new(actionwords),
      Hiptest::Nodes::Tests.new(tests)
    )
  end
end