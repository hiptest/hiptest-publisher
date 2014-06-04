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

class OptionsParser
  def self.parse(args)
    options = OpenStruct.new
    options.language = 'ruby'
    options.framework = ''
    options.config = 'config'
    options.site = 'https://zest.smartesting.com'
    options.output_directory = '.'
    options.tests_only = false
    options.actionwords_only = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ruby publisher.rb [options]"
      opts.separator ""
      opts.separator "Exports tests from Zest for automation."
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-t", "--token=TOKEN", String,
              "Secret token (available in your project settings)") do |token|
        options.token = token
      end

      opts.on("-l", "--language=LANG", String,
              "Target language (only Ruby available for the moment)") do |language|
        options.language = language
      end

      opts.on("-f", "--framework=FRAMEWORK", String,
              "Test framework to use") do |framework|
        options.framework = framework
      end

      opts.on("-o", "--output-directory=PATH", String,
              "Directory to output the tests") do |output_directory|
        options.output_directory = output_directory
      end

      opts.on("-c", "--config-file=PATH", String,
              "Configuration file (default: config)") do |config|
        options.config = config
      end

      opts.on("--tests-only", "Export only the tests") do |tests_only|
        options.tests_only = tests_only
      end

      opts.on("--actionwords-only", "Export only the actionwords") do |actionwords_only|
        options.actionwords_only = actionwords_only
      end

      opts.on("-s", "--site=SITE", String,
              "Site to fetch from (default: https://zest.smartesting.com)") do |site|
        options.site = site
      end

      opts.on("-v", "--verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    FileConfigParser.update_options options
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
