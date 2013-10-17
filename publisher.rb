require 'nokogiri'
require 'open-uri'

require_relative 'options_parser'

def fetch_project_export token
  open("https://zest.smartesting.com/publication/#{token}/project")
end

options = OptionsParser.parse(ARGV)
begin
  xml = fetch_project_export(options.token)
rescue
  puts "Unable to open the file, please check that the token is correct"
  exit
end
