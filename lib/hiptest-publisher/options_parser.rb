require 'optparse'
require 'parseconfig'
require 'ostruct'

require 'hiptest-publisher/formatters/console_formatter'
require 'hiptest-publisher/utils'

class FileConfigParser
  def self.update_options(options, reporter)
    config = ParseConfig.new(options.config)
    config.get_params.each do |param|
      next if options.__cli_args && options.__cli_args.include?(param.to_sym)
      options[param] = config[param]
      options.__config_args << param.to_sym if options.__config_args
    end
  rescue => err
    reporter.dump_error(err)
  end
end

class Option
  attr_reader :short, :long, :default, :type, :help, :attribute

  def initialize(short, long, default, type, help, attribute)
    @short = short
    @long = long
    @default = default
    @type = type
    @help = help
    @attribute = attribute
  end

  def help
    if default == nil || default == ""
      @help
    else
      "#{@help} (default: #{@default})"
    end
  end

  def register(opts, options)
    options[attribute] = @default unless default.nil?
    on_values = [
      @short ? "-#{@short}" : nil,
      "--#{@long}",
      @type,
      help
    ].compact

    opts.on(*on_values) do |value|
      options[attribute] = value
      options.__cli_args << attribute
    end
  end
end

class OptionsParser
  def self.languages
    # First framework is default framework

    {
      'Ruby' => ['Rspec', 'MiniTest'],
      'Cucumber' => ['Ruby'],
      'Java' => ['JUnit', 'Test NG'],
      'Python' => ['Unittest'],
      'Robot Framework' => [''],
      'Selenium IDE' => [''],
      'Javascript' => ['qUnit', 'Jasmine']
    }
  end

  def self.all_options
    [
      Option.new('t', 'token=TOKEN', nil, String, "Secret token (available in your project settings)", :token),
      Option.new('l', 'language=LANG', 'ruby', String, "Target language", :language),
      Option.new('f', 'framework=FRAMEWORK', '', String, "Test framework to use", :framework),
      Option.new('o', 'output-directory=PATH', '.', String, "Output directory", :output_directory),
      Option.new('c', 'config-file=PATH', nil, String, "Configuration file", :config),
      Option.new(nil, 'overriden-templates=PATH', '', String, "Folder for overriden templates", :overriden_templates),
      Option.new(nil, 'test-run-id=ID', '', String, "Export data from a test run", :test_run_id),
      Option.new(nil, 'scenario-ids=IDS', '', String, "Filter scenarios by ids", :filter_ids),
      Option.new(nil, 'scenario-tags=TAGS', '', String, "Filter scenarios by tags", :filter_tags),
      Option.new(nil, 'tests-only', false, nil, "Export only the tests", :tests_only),
      Option.new(nil, 'actionwords-only', false, nil, "Export only the actionwords", :actionwords_only),
      Option.new(nil, 'actionwords-signature', false, nil, "Export actionword signature", :actionwords_signature),
      Option.new(nil, 'show-actionwords-diff', false, nil, "Show actionwords diff since last update (summary)", :actionwords_diff),
      Option.new(nil, 'show-actionwords-deleted', false, nil, "Output signature of deleted action words", :aw_deleted),
      Option.new(nil, 'show-actionwords-created', false, nil, "Output code for new action words", :aw_created),
      Option.new(nil, 'show-actionwords-renamed', false, nil, "Output signatures of renamed action words", :aw_renamed),
      Option.new(nil, 'show-actionwords-signature-changed', false, nil, "Output signatures of action words for which signature changed", :aw_signature_changed),
      Option.new(nil, 'split-scenarios', false, nil, "Export each scenario in a single file", :split_scenarios),
      Option.new(nil, 'leafless-export', false, nil, "Use only last level action word", :leafless_export),
      Option.new('s', 'site=SITE', 'https://hiptest.net', String, "Site to fetch from", :site),
      Option.new('p', 'push=FILE.TAP', '', String, "Push a results file to the server", :push),
      Option.new(nil, 'push-format=tap', 'tap', String, "Format of the test results (tap, junit, robot)", :push_format),
      Option.new('v', 'verbose', false, nil, "Run verbosely", :verbose)
    ]
  end

  def self.parse(args, reporter)
    options = OpenStruct.new(__cli_args: Set.new, __config_args: Set.new)
    opt_parser = OptionParser.new do |opts|
      opts.version = hiptest_publisher_version if hiptest_publisher_version
      opts.banner = "Usage: ruby publisher.rb [options]"
      opts.separator ""
      opts.separator "Exports tests from Hiptest for automation."
      opts.separator ""
      opts.separator "Specific options:"

      all_options.each {|o| o.register(opts, options)}

      opts.on("-H", "--languages-help", "Show languages and framework options") do
        self.show_languages
        exit
      end

      opts.on("-F", "--filters-help", "Show help about scenario filtering") do
        [
          "hiptest-publisher allows you to filter the exported scenarios.",
          "You can select the ids of the scenarios:",
          "hiptest-publisher --scenario-ids=12",
          "hiptest-publisher --scenario-ids=12,15,16",
          "",
          "You can also filter by tags:",
          "hiptest-publisher --scenario-tags=mytag",
          "hiptest-publisher --scenario-tags=mytag,myother:tag",
          "",
          "You can not mix ids and tag filtering, only the id filtering will be applied."
        ].each {|line| puts line}
        exit
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    args << "--help" if args.empty?
    opt_parser.parse!(args)
    reporter.add_listener(ConsoleFormatter.new(options.verbose))
    FileConfigParser.update_options(options, reporter)

    reporter.show_options(options.marshal_dump)
    options
  end

  def self.make_language_option(lang, framework = '')
    lang_opt = "--language=#{lang.downcase.gsub(' ', '')}"
    framework_opt = "--framework=#{framework.downcase.gsub(' ', '')}"

    framework.empty? ? lang_opt : "#{lang_opt} #{framework_opt}"
  end

  def self.show_languages
    puts "Supported languages:"
    languages.each do |language, frameworks|
      puts "#{language}:"
      if frameworks.empty?
        puts "  no framework option available #{make_language_option(language, '')}"
      else
        frameworks.each_with_index do |fw, index|
          if index == 0
            puts " - #{fw} [default] #{make_language_option(language, '')}"
          else
            puts " - #{fw} #{make_language_option(language, fw)}"
          end
        end
      end
    end
  end
end


class FileOutputContext

  def initialize(properties)
    # should contain  :node, :path, :language, :template_dirs, :description, :indentation
    @properties = OpenStruct.new(properties)
  end

  def method_missing(name, *)
    @properties[name]
  end

  def node
    @properties.node
  end

  def [](key)
    @properties[key]
  end

  def update(properties)
    properties.each_pair { |key, value| @properties[key] = value }
  end

  def []=(key, value)
  end

  def has_key?(key)
    @properties.respond_to?(key)
  end

  def test_file_name
    File.basename(@properties.path)
  end
end

def template_dirs_for(language: "ruby", framework: nil, overriden_templates: nil, **)
  dirs = []
  if framework
    dirs << "#{language}/#{framework}"
  end
  dirs << language
  dirs << "common"
  dirs.map! { |path| "#{hiptest_publisher_path}/lib/templates/#{path}" }

  dirs.unshift(overriden_templates) if overriden_templates

  return dirs
end

class NodeOutputConfig
  def initialize(user_params, node_params = nil)
    @output_directory = user_params.output_directory
    @split_scenarios = user_params.split_scenarios
    @leafless_export = user_params.leafless_export
    @user_language = user_params.language
    @user_framework = user_params.framework
    @node_params = node_params || {}
  end

  def [](key)
    # puts "=> [#{key}]"
    @node_params[key]
  end

  def splitted_files?
    if self[:scenario_filename].nil?
      false
    elsif self[:filename].nil?
      true
    else
      @split_scenarios
    end
  end

  def language
    @node_params[:language] || @user_language
  end

  def framework
    @node_params[:framework] || @user_framework
  end

  def each_node(project)
    if splitted_files?
      project.children[node_name].children[node_name].each do |node|
        yield node
      end
    else
      yield project.children[node_name]
    end
  end

  def template_dirs
    template_dirs_for(
      language:language,
      framework: framework,
      overriden_templates: @node_params[:overriden_templates]
    )
  end

  def each_file_output_context(project)
    each_node(project) do |node|
      filename = output_file(node.children[:name])
      path = "#{@output_directory}/#{filename}"
      indentation = @node_params[:indentation]

      if splitted_files?
        description = "scenario \"#{node.children[:name]}\""
        forced_templates = {
          "scenario" => "single_scenario",
          "test" => "single_test",
        }
      else
        description = node_name.to_s
        forced_templates = {}
      end
      yield FileOutputContext.new(
        path: path,
        language: language,
        indentation: indentation,
        template_dirs: template_dirs,
        forced_templates: forced_templates,
        description: description,
        node: node,
      )
    end
  end

  def output_file(name)
    if splitted_files?
      class_name_convention = @node_params[:class_name_convention] || :normalize
      name = name.send(class_name_convention)

      self[:scenario_filename].gsub('%s', name)
    else
      self[:filename]
    end
  end

  def scenario_output_dir(scenario_name)
    "#{@output_directory}/#{output_file(scenario_name)}"
  end

  private

  def node_name
    if self[:category] == "tests" || self[:name] == "tests"
      @leafless_export ? :tests : :scenarios
    else
      :actionwords
    end
  end
end


class LanguageConfigParser
  def initialize(options, language_config_path = nil)
    @options = options
    language_config_path ||= LanguageConfigParser.config_path_for(options)
    @config = ParseConfig.new(language_config_path)
  end

  def self.config_path_for(options)
    config_path = [
      "#{hiptest_publisher_path}/lib/config/#{options.language}-#{options.framework}.conf",
      "#{hiptest_publisher_path}/lib/config/#{options.language}.conf",
      "#{hiptest_publisher_path}/lib/templates/#{options.language}/#{options.framework}/output_config",
      "#{hiptest_publisher_path}/lib/templates/#{options.language}/output_config",
    ].map do |path|
      File.expand_path(path) if File.file?(path)
    end.compact.first
    if config_path.nil?
      message = "cannot find output_config file in \"#{hiptest_publisher_path}/lib/templates\" for language #{options.language.inspect}"
      message << " and framework #{options.framework.inspect}" if options.framework
      raise ArgumentError.new(message)
    end
    config_path
  end

  def scenario_output_file(scenario_name)
    if make_context('tests').has_key? :class_name_convention
      scenario_name = scenario_name.send(make_context('tests')[:class_name_convention])
    else
      scenario_name = scenario_name.normalize
    end

    @config['tests']['scenario_filename'].gsub('%s', scenario_name)
  end

  def scenario_output_dir(scenario_name)
    "#{@options.output_directory}/#{scenario_output_file(scenario_name)}"
  end

  def tests_output_dir
    "#{@options.output_directory}/#{@config['tests']['filename']}"
  end

  def aw_output_dir
    "#{@options.output_directory}/#{@config['actionwords']['filename']}"
  end

  def node_output_configs
    @config.groups.map { |group_name|
      make_node_output_config(group_name)
    }
  end

  def tests_render_context
    make_node_output_config('tests')
  end

  def actionword_render_context
    make_node_output_config('actionwords')
  end

  def name_action_word(name)
    name.send(@config['actionwords']['naming_convention'])
  end

  private
  def make_context group
    context = {
      :forced_templates => {}
    }

    if @options.split_scenarios
      context[:forced_templates]['scenario'] = 'single_scenario'
      context[:forced_templates]['test'] = 'single_test'
    end

    context[:package] = @options.package unless @options.package.nil?
    context[:framework] = @options.framework unless @options.framework.nil?

    unless @options.overriden_templates.nil? || @options.overriden_templates.empty?
      context[:overriden_templates] = @options.overriden_templates
    end

    @config[group].each {|param, value| context[param.to_sym] = value }
    context
  end

  def make_node_output_config group_name
    node_params = @config[group_name].map { |key, value| [key.to_sym, value] }.to_h
    if group_name == "tests" || group_name == "actionwords"
      node_params[:category] = group_name
    end
    node_params[:name] = group_name
    node_params[:package] = @options.package if @options.package
    node_params[:framework] = @options.framework if @options.framework

    unless @options.overriden_templates.nil? || @options.overriden_templates.empty?
      node_params[:overriden_templates] = @options.overriden_templates
    end

    NodeOutputConfig.new(@options, node_params)
  end
end
