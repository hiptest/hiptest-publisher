require "codeclimate-test-reporter"
require 'pry'
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

  def make_template(*chunks)
    Hiptest::Nodes::Template.new(chunks)
  end

  def literal(arg)
    case arg
    when String                      then Hiptest::Nodes::StringLiteral.new(arg)
    when Numeric                     then Hiptest::Nodes::NumericLiteral.new(arg.to_s)
    when true, false                 then Hiptest::Nodes::BooleanLiteral.new(arg.to_s)
    when nil                         then Hiptest::Nodes::NullLiteral.new
    when Hiptest::Nodes::Literal     then arg
    when Hiptest::Nodes::NullLiteral then arg
    else raise ArgumentError.new("bad argument #{arg}")
    end
  end

  def template_of_literals(*args)
    Hiptest::Nodes::Template.new(args.map { |arg| literal(arg) })
  end

  def make_annotated_call(annotation, actionword, arguments = [])
    Hiptest::Nodes::Call.new(actionword, arguments, annotation)
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
