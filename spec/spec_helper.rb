require "codeclimate-test-reporter"
require 'pry'
require 'securerandom'
require_relative '../lib/hiptest-publisher/nodes'
require_relative '../lib/hiptest-publisher/options_parser'

CodeClimate::TestReporter.start


class ErrorListener
  def dump_error(error, message)
    fail("failing the test because the app has dumped an unexpected error: #{error.message}\n" \
      "#{error.backtrace.map {|l| "  #{l}\n"}.join}")
    Rails.logger.error ""

  end

  def method_missing(*args)
  end
end


module HelperFactories
  def make_argument(name, value)
    Hiptest::Nodes::Argument.new(name, value)
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

  def variable(name)
    Hiptest::Nodes::Variable.new(name)
  end

  def template_of_literals(*args)
    Hiptest::Nodes::Template.new(args.map { |arg| literal(arg) })
  end

  def make_call(actionword, arguments: [], annotation: nil)
    Hiptest::Nodes::Call.new(actionword, arguments, annotation)
  end

  def make_parameter(name, default: nil)
    Hiptest::Nodes::Parameter.new(name, default)
  end

  def make_actionword(name, tags: [], parameters: [], body: [], uid: nil)
    Hiptest::Nodes::Actionword.new(name, tags, parameters, body, uid)
  end

  def make_scenario(name, tags: [], parameters: [], body: [], folder: nil, datatable: Hiptest::Nodes::Datatable.new)
    folder_uid = folder ? folder.uid : nil
    Hiptest::Nodes::Scenario.new(name, '', tags, parameters, body, folder_uid, datatable).tap do |scenario|
      folder.children[:scenarios] << scenario if folder
    end
  end

  def make_test(name, tags: [], body: [])
    Hiptest::Nodes::Test.new(name, '', tags, body)
  end

  def make_folder(name, parent: nil)
    uid = SecureRandom.uuid
    parent_uid = parent.uid if parent
    Hiptest::Nodes::Folder.new(uid, parent_uid, name).tap do |folder|
      if parent
        folder.parent = parent
        parent.children[:subfolders] << folder
      end
    end
  end

  def make_project(name, scenarios: [], tests: [], actionwords: [], folders: [])
    Hiptest::Nodes::Project.new(name, '',
      Hiptest::Nodes::TestPlan.new(folders).tap { |tp| tp.organize_folders },
      Hiptest::Nodes::Scenarios.new(scenarios),
      Hiptest::Nodes::Actionwords.new(actionwords),
      Hiptest::Nodes::Tests.new(tests)
    )
  end
end

def context_for(properties)
  test_name = properties.delete(:test_name) || 'dummy'
  cli_options = OpenStruct.new(properties)
  language_config = LanguageConfigParser.new(cli_options)
  language_group_config = language_config.language_group_configs.first or fail("no language group defined for --only=#{cli_options.only}")
  dummy_node = OpenStruct.new(children: {name: test_name})
  language_group_config.build_node_rendering_context(dummy_node)
end
