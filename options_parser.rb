require 'optparse'
require 'ostruct'

class OptionsParser

  def self.parse(args)
    options = OpenStruct.new
    options.language = 'ruby'

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