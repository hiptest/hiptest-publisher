require 'colorize'

def fetch_project_export site, token
  open("#{site}/publication/#{token}/project?future=1")
end

def trace_exception exception
  line = "-" * 80
  puts line.yellow
  puts "#{exception.class.name}: #{exception.message}".red
  puts "#{exception.backtrace.map {|l| "  #{l}\n"}.join}".yellow
  puts line.yellow
end

