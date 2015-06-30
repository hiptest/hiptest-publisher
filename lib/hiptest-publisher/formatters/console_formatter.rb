require 'hiptest-publisher/utils'

class ConsoleFormatter
  attr_reader :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  def dump_error(error, message = nil)
    return unless verbose
    puts message.blue if message
    line = "-" * 80
    puts line.yellow
    puts "#{error.class.name}: #{error.message}".red
    puts "#{error.backtrace.map {|l| "  #{l}\n"}.join}".yellow
    puts line.yellow
  end

  def show_options(options)
    return unless verbose
    puts "Running Hiptest-publisher #{hiptest_publisher_version} with:".yellow
    options.each { |k, v| puts " - #{k}: #{v}".white }
  end
end
