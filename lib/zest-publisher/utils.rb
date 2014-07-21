require 'open-uri'
require 'openssl'
require 'colorize'

def zest_publisher_path
  Gem.loaded_specs['zest-publisher'].full_gem_path
rescue
  '.'
end

def fetch_project_export site, token
  open("#{site}/publication/#{token}/project?future=1", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
end

def trace_exception exception
  line = "-" * 80
  puts line.yellow
  puts "#{exception.class.name}: #{exception.message}".red
  puts "#{exception.backtrace.map {|l| "  #{l}\n"}.join}".yellow
  puts line.yellow
end

def show_status_message(message, status=nil)
  status_icon = " "
  line_end = status.nil? ? "" : "\n"
  output = STDOUT

  if status == :success
    status_icon = "v".green
  elsif status == :failure
    status_icon = "x".red
    output = STDERR
  end

  output.print "[#{status_icon}] #{message}\r#{line_end}"
end