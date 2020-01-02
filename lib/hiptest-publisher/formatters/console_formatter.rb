require 'i18n'

require 'hiptest-publisher/utils'

class ConsoleFormatter
  attr_reader :verbose

  def initialize(verbose, color: nil)
    @verbose = verbose
    @color = color.nil? ? tty? : color
    @immediate_verbose = true
    @verbose_messages = []
  end

  def dump_error(error, message = nil)
    return unless verbose
    puts colorize(message, :blue) if message
    line = "-" * 80
    puts colorize(line, :yellow)
    puts colorize("#{error.class.name}: #{error.message}", :red)
    puts colorize("#{error.backtrace.map {|l| "  #{l}\n"}.join}", :yellow)
    puts colorize(line, :yellow)
  end

  def show_error(message)
    STDOUT.print colorize(message, :yellow)
  end

  def show_failure(message)
    STDOUT.print(colorize(message, :red))
  end

  def show_options(options, message = nil)
    return unless verbose
    message ||= I18n.t(:verbose_header, version: hiptest_publisher_version)
    puts colorize(message, :yellow)
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
      status_icon = colorize("v", :green)
    elsif status == :warning
      status_icon = colorize("?", :yellow)
    elsif status == :failure
      status_icon = colorize("x", :red)
      output = STDERR
    end
    if status
      @immediate_verbose = true
      cursor_offset = ""
    else
      return unless tty?
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

  def ask(question)
    return unless tty?
    STDOUT.print "[#{colorize('?', :yellow)}] #{question}"
    return $stdin.gets.chomp.downcase.strip
  end

  def colored?
    @color
  end

  private

  def tty?
    $stdout.tty?
  end

  def colorize(txt, color)
    colored? ? txt.send(color) : txt
  end
end
