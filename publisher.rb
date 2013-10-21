require 'open-uri'

require_relative 'options_parser'
require_relative 'xml_parser'


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

parser = Zest::XMLParser.new(xml)
parser.build_project

puts '-----------------------------------------------------'
puts parser.project.render('ruby', {call_prefix: 'actionwords'})
puts '-----------------------------------------------------'
puts parser.project.rendered_childs[:scenarios]
puts '-----------------------------------------------------'
puts parser.project.rendered_childs[:actionwords]
puts '-----------------------------------------------------'