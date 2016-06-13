require 'colorize'
require 'io/console'
require 'openssl'
require 'net/http/post/multipart'
require 'pathname'


def hiptest_publisher_path
  Gem.loaded_specs['hiptest-publisher'].full_gem_path
rescue
  '.'
end

def hiptest_publisher_version
  Gem.loaded_specs['hiptest-publisher'].version.to_s
rescue
  File.read("#{hiptest_publisher_path}/VERSION").strip if File.exists?("#{hiptest_publisher_path}/VERSION")
end

def pluralize_word(count, singular, plural=nil)
  if count == 1
    singular
  else
    "#{singular}s"
  end
end

def pluralize(count, singular, plural=nil)
  word = pluralize_word(count, singular, plural)
  "#{count} #{word}"
end

def singularize(name)
  name.to_s.chomp("s")
end

def show_status_message(message, status=nil)
  status_icon = " "
  output = STDOUT

  if status == :success
    status_icon = "v".green
  elsif status == :failure
    status_icon = "x".red
    output = STDERR
  end
  if status
    cursor_offset = ""
  else
    return unless $stdout.tty?
    rows, columns = IO.console.winsize
    return if columns == 0
    vertical_offset = (4 + message.length) / columns
    cursor_offset = "\r\e[#{vertical_offset + 1}A"
  end

  output.print "[#{status_icon}] #{message}#{cursor_offset}\n"
end

def with_status_message(message, &blk)
  show_status_message message
  status = :success
  yield
rescue
  status = :failure
  raise
ensure
  show_status_message message, status
end

def clean_path(path)
  Pathname.new(path).cleanpath.to_s
end
