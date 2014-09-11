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
  def self.all_options
    [
      Option.new('t', 'token=TOKEN', nil, String, "Secret token (available in your project settings)", :token),
      Option.new('l', 'language=LANG', 'ruby', String, "Target language", :language),
      Option.new('f', 'framework=FRAMEWORK', '', String, "Test framework to use", :framework),
      Option.new('o', 'output-directory=PATH', '.', String, "Output directory", :output_directory),
      Option.new('c', 'config-file=PATH', 'config', String, "Configuration file", :config),
      Option.new(nil, 'tests-only', false, nil, "Export only the tests", :tests_only),
      Option.new(nil, 'actionwords-only', false, nil, "Export only the actionwords", :actionwords_only),
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
end

class LanguageConfigParser
  def initialize(options)
    @options = options
    @config = ParseConfig.new("#{zest_publisher_path}/lib/templates/#{options.language}/output_config")
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
    context = {}

    unless @options.package.nil?
      context[:package] = @options.package
    end
    unless @options.framework.nil?
      context[:framework] = @options.framework
    end

    @config[group].each {|param, value|
      context[param.to_sym] = value
    }
    context
  end
end
