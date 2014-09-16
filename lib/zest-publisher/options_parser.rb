require 'optparse'
require 'parseconfig'
require 'ostruct'

require 'zest-publisher/utils'

class FileConfigParser
  def self.update_options(options)
    config = ParseConfig.new(options.config)

    config.get_params.each do |param|
      options.send("#{param}=", config[param])
    end
    options

  rescue
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
      'Robot Framework' => ['']
    }
  end

  def self.all_options
    [
      Option.new('t', 'token=TOKEN', nil, String, "Secret token (available in your project settings)", :token),
      Option.new('l', 'language=LANG', 'ruby', String, "Target language", :language),
      Option.new('f', 'framework=FRAMEWORK', '', String, "Test framework to use", :framework),
      Option.new('o', 'output-directory=PATH', '.', String, "Output directory", :output_directory),
      Option.new('c', 'config-file=PATH', 'config', String, "Configuration file", :config),
      Option.new(nil, 'tests-only', false, nil, "Export only the tests", :tests_only),
      Option.new(nil, 'actionwords-only', false, nil, "Export only the actionwords", :actionwords_only),
      Option.new(nil, 'split-scenarios', false, nil, "Export each scenario in a single file", :split_scenarios),
      Option.new('s', 'site=SITE', 'https://www.zest-testing.com', String, "Site to fetch from", :site),
      Option.new('v', 'verbose', false, nil, "Run verbosely", :verbose)
    ]
  end

  def self.parse(args)
    options = OpenStruct.new
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ruby publisher.rb [options]"
      opts.separator ""
      opts.separator "Exports tests from Zest for automation."
      opts.separator ""
      opts.separator "Specific options:"

      all_options.each {|o| o.register(opts, options)}

      opts.on("-H", "--languages-help", "Show languages and framework options") do
        self.show_languages
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
    puts "Running Zest-publisher with:".yellow
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
    @config = ParseConfig.new("#{zest_publisher_path}/lib/templates/#{options.language}/output_config")
  end

  def scenario_output_dir(scenario_name)
    "#{@options.output_directory}/#{@config['tests']['scenario_filename']}".gsub('%s', scenario_name.normalize)
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

    context[:forced_templates]['scenario'] = 'single_scenario' if @options.split_scenarios
    context[:package] = @options.package unless @options.package.nil?
    context[:framework] = @options.framework unless @options.framework.nil?

    @config[group].each {|param, value|
      context[param.to_sym] = value
    }
    context
  end
end
