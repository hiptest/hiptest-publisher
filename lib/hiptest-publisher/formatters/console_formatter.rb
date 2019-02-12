require 'hiptest-publisher/utils'

class ConsoleFormatter
  attr_reader :verbose

  def initialize(verbose)
    @verbose = verbose
    @immediate_verbose = true
    @verbose_messages = []
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

  def show_options(options, message = nil)
    return unless verbose
    message ||= "Running hiptest-publisher #{hiptest_publisher_version} with:"
    puts message.yellow
    options.each { |k, v| puts " - #{k}: #{v.inspect}" }
  end

  def show_verbose_message(message)
    return unless verbose
    if @immediate_verbose
      STDOUT.print "#{message}\n"
    else
      @verbose_messages << message
    end
  end

  def show_status_message(message, status=nil)
    status_icon = " "
    output = STDOUT

    if status == :success
      status_icon = "v".green
    elsif status == :warning
      status_icon = "?".yellow
    elsif status == :failure
      status_icon = "x".red
      output = STDERR
    end
    if status
      @immediate_verbose = true
      cursor_offset = ""
    else
      return unless $stdout.tty?
      rows, columns = IO.console.winsize
      return if columns == 0
      @immediate_verbose = false
      vertical_offset = (4 + message.length) / columns
      cursor_offset = "\r\e[#{vertical_offset + 1}A"
    end

    output.print "[#{status_icon}] #{message}#{cursor_offset}\n"

    if @immediate_verbose && !@verbose_messages.empty?
      @verbose_messages.each { |message| show_verbose_message(message) }
      @verbose_messages.clear
    end
  end
end
