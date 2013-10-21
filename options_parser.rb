require 'optparse'
require 'ostruct'

class OptionsParser

  def self.parse(args)
    options = OpenStruct.new
    options.language = 'ruby'
    options.site = 'https://zest.smartesting.com'
    options.tests_only = false
    options.actionwords_only = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ruby publisher.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-t", "--token TOKEN", String,
              "Secret token (available in your project settings)") do |token|
        options.token = token
      end

      opts.on("-l", "--language LANG", String,
              "Target language (only Ruby available for the moment)") do |token|
        options.token = token
      end

      opts.on("--test-only", "Export only the tests") do |tests_only|
        options.tests_only = tests_only
      end

      opts.on("--action-words-only", "Export only the action words") do |actionwords_only|
        options.actionwords_only = actionwords_only
      end

      opts.on("-s", "--site SITE", String,
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
    options
  end
end