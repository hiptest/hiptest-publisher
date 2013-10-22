require 'open-uri'
require 'parseconfig'

require_relative 'string'
require_relative 'utils'
require_relative 'options_parser'
require_relative 'xml_parser'

options = OptionsParser.parse(ARGV)

begin
  xml = fetch_project_export(options.site, options.token)
rescue
  puts "Unable to open the file, please check that the token is correct"
  exit
end

parser = Zest::XMLParser.new(xml)
parser.build_project

language_config = LanguageConfigParser.new(options)

unless options.actionwords_only
  File.open(language_config.aw_output_dir, 'w') { |file|
    file.write(parser.project.childs[:scenarios].render(
      options.language,
      language_config.tests_render_context)
    )
  }
end

unless options.tests_only
  File.open(language_config.tests_output_dir, 'w') { |file|
    file.write(parser.project.childs[:actionwords].render(
      options.language,
      language_config.actionword_render_context)
    )
  }
end
