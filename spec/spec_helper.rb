require 'webmock'
require 'codeclimate-test-reporter'
require 'pry'
require 'securerandom'
require_relative '../lib/hiptest-publisher/formatters/reporter'
require_relative '../lib/hiptest-publisher/nodes'
require_relative '../lib/hiptest-publisher/options_parser'

CodeClimate::TestReporter.start
WebMock.disable_net_connect!(allow: "codeclimate.com")

class ErrorListener
  def dump_error(error, message)
    fail("failing the test because the app has dumped an unexpected error: #{error.message}\n" \
      "#{error.backtrace.map {|l| "  #{l}\n"}.join}")
    Rails.logger.error ""

  end

  def method_missing(*args)
  end
end

def error_reporter
  Reporter.new([ErrorListener.new])
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

  def make_uidcall(uid, arguments: [], annotation: nil)
    Hiptest::Nodes::UIDCall.new(uid, arguments, annotation)
  end

  def make_parameter(name, default: nil)
    Hiptest::Nodes::Parameter.new(name, default)
  end

  def make_actionword(name, tags: [], parameters: [], body: [], uid: nil)
    Hiptest::Nodes::Actionword.new(name, tags, parameters, body, uid)
  end

  def make_scenario(name, tags: [], description: '', parameters: [], body: [], folder: nil, datatable: Hiptest::Nodes::Datatable.new)
    folder_uid = folder ? folder.uid : nil
    Hiptest::Nodes::Scenario.new(name, description, tags, parameters, body, folder_uid, datatable).tap do |scenario|
      if folder
        folder.children[:scenarios] << scenario
        project = folder.project
        if project
          project.children[:scenarios].children[:scenarios] << scenario
          scenario.parent = project.children[:scenarios]
        end
      end
    end
  end

  def make_tag(key, value = nil)
    Hiptest::Nodes::Tag.new(key, value)
  end

  def make_test(name, tags: [], body: [], description: [])
    Hiptest::Nodes::Test.new(name, description, tags, body)
  end

  def make_folder(name, description: nil, parent: nil, body: [], tags: [])
    uid = SecureRandom.uuid
    if parent.respond_to?(:uid)
      parent_uid = parent.uid
    end
    folder = Hiptest::Nodes::Folder.new(uid, parent_uid, name, description, tags, 0, body)
    if parent
      folder.parent = parent
      if parent.is_a?(Hiptest::Nodes::TestPlan)
        parent.children[:folders] << folder
      else
        parent.children[:subfolders] << folder
        parent.project && parent.project.children[:test_plan].children[:folders] << folder
      end
    end
    folder
  end

  def make_project(name, scenarios: [], tests: [], actionwords: [], folders: [], libraries: nil)
    Hiptest::Nodes::Project.new(name, '',
      Hiptest::Nodes::TestPlan.new(folders).tap { |tp| tp.organize_folders },
      Hiptest::Nodes::Scenarios.new(scenarios),
      Hiptest::Nodes::Actionwords.new(actionwords),
      Hiptest::Nodes::Tests.new(tests),
      libraries || Hiptest::Nodes::Libraries.new()
    )
  end

  def make_library(name, actionwords)
    Hiptest::Nodes::Library.new(name, actionwords)
  end
end

def language_group_config_for(properties)
  if properties.is_a?(Array)
    args = properties
    cli_options = OptionsParser.parse(args, error_reporter)
  else
    cli_options = OptionsParser.parse(["--language", "ruby"], error_reporter)
    properties[:framework] ||= "" if properties[:language]
    properties.each { |key, value| cli_options[key] = value }
  end
  cli_options.normalize!
  language_config = LanguageConfigParser.new(cli_options)
  language_config.language_group_configs.first or fail("no language group defined for --only=#{cli_options.only}")
end

def context_for(properties)
  node = properties.delete(:node) || OpenStruct.new(children: {name: 'dummy'})
  language_group_config = language_group_config_for(properties)
  language_group_config.build_node_rendering_context(node)
end
