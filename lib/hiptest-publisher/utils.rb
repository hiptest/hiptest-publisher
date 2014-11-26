require 'open-uri'
require 'openssl'
require 'colorize'

def hiptest_publisher_path
  Gem.loaded_specs['hiptest-publisher'].full_gem_path
rescue
  '.'
end

def make_filter(options)
  ids = options.filter_ids.split(',').map {|id| "filter[]=id:#{id}"}
  tags = options.filter_tags.split(',').map {|tag| "filter[]=tag:#{tag}"}

  filter = (ids + tags).join("&")
  filter.empty? ? '' : "&#{filter}"
end

def fetch_project_export(options)
  url = "#{options.site}/publication/#{options.token}/#{options.leafless_export ? 'leafless_tests' : 'project'}?future=1#{make_filter(options)}"

  puts "URL: #{url}".white if options.verbose
  open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
end

def trace_exception(exception)
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