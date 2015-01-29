require 'optparse'
require 'parseconfig'
require 'ostruct'

require 'hiptest-publisher/utils'

class FileConfigParser
  def self.update_options(options)
    config = ParseConfig.new(options.config)
    config.get_params.each do |param|
      options.send("#{param}=", config[param])
    end
    options

  rescue Exception => err
    trace_exception(err) if options.verbose
    options
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
    return @help if default.nil?

    if @default.is_a? String
      @default.empty? ? @help : "#{@help} (default: #{@default})"
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
    end
  end
end

class OptionsParser
  def self.languages
    # First framework is default framework

    {
      'Ruby' => ['Rspec', 'MiniTest'],
      'Java' => ['JUnit', 'Test NG'],
      'Python' => ['Unittest'],
      'Robot Framework' => [''],
      'Selenium IDE' => ['']
    }
  end

  def self.all_options
    [
      Option.new('t', 'token=TOKEN', nil, String, "Secret token (available in your project settings)", :token),
      Option.new('l', 'language=LANG', 'ruby', String, "Target language", :language),
      Option.new('f', 'framework=FRAMEWORK', '', String, "Test framework to use", :framework),
      Option.new('o', 'output-directory=PATH', '.', String, "Output directory", :output_directory),
      Option.new('c', 'config-file=PATH', 'config', String, "Configuration file", :config),
      Option.new(nil, 'test-run-id=ID', '', String, "Export data from a test run", :test_run_id),
      Option.new(nil, 'scenario-ids=IDS', '', String, "Filter scenarios by ids", :filter_ids),
      Option.new(nil, 'scenario-tags=TAGS', '', String, "Filter scenarios by tags", :filter_tags),
      Option.new(nil, 'tests-only', false, nil, "Export only the tests", :tests_only),
      Option.new(nil, 'actionwords-only', false, nil, "Export only the actionwords", :actionwords_only),
      Option.new(nil, 'split-scenarios', false, nil, "Export each scenario in a single file", :split_scenarios),
      Option.new(nil, 'leafless-export', false, nil, "Use only last level action word", :leafless_export),
      Option.new('s', 'site=SITE', 'https://hiptest.net', String, "Site to fetch from", :site),
      Option.new('p', 'push=FILE.TAP', '', String, "Push a results file to the server", :push),
      Option.new(nil, 'push-format=tap', 'tap', String, "Format of the test results (tap, junit, robot)", :push_format),
      Option.new('v', 'verbose', false, nil, "Run verbosely", :verbose)
    ]
  end

  def self.parse(args)
    options = OpenStruct.new
    opt_parser = OptionParser.new do |opts|
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

    opt_parser.parse!(args)
    FileConfigParser.update_options options

    show_options(options) if options.verbose
    options
  end

  def self.show_options(options)
    puts "Running Hiptest-publisher with:".yellow
    options.marshal_dump.each { |k, v| puts " - #{k}: #{v}".white }
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

class LanguageConfigParser
  def initialize(options)
    @options = options
    @config = ParseConfig.new(find_config_file(options))
  end

  def find_config_file(options)
    ["#{options.language}/#{options.framework}", "#{options.language}"].map do |p|
      path = "#{hiptest_publisher_path}/lib/templates/#{p}/output_config"
      path if File.file?(path)
    end.compact.first
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

  def tests_render_context
    make_context('tests')
  end

  def actionword_render_context
    make_context('actionwords')
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

    @config[group].each {|param, value| context[param.to_sym] = value }
    context
  end
end
