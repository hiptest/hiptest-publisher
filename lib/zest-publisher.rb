require 'colorize'

require 'zest-publisher/string'
require 'zest-publisher/utils'
require 'zest-publisher/options_parser'
require 'zest-publisher/xml_parser'
require 'zest-publisher/parameter_type_adder'

module Zest
  class Publisher
    def initialize(args)
      options = OptionsParser.parse(ARGV)

      begin
        show_status_message "Fetching data from Zest"
        xml = fetch_project_export(options.site, options.token)
        show_status_message "Fetching data from Zest", :success
      rescue
        show_status_message "Fetching data from Zest", :failure
        puts "Unable to open the file, please check that the token is correct".red
        return
      end

      show_status_message "Extracting data"
      parser = Zest::XMLParser.new(xml, options)
      show_status_message "Extracting data", :success
      parser.build_project

      language_config = LanguageConfigParser.new(options)

      Zest::Nodes::ParameterTypeAdder.add(parser.project) if options.language == 'java'

      unless options.actionwords_only
        show_status_message "Exporting scenarios to: #{language_config.tests_output_dir}"
        File.open(language_config.tests_output_dir, 'w') { |file|
          file.write(parser.project.childs[:scenarios].render(
            options.language,
            language_config.tests_render_context)
          )
        }
        show_status_message "Exporting scenarios to: #{language_config.tests_output_dir}", :success
      end

      unless options.tests_only
        show_status_message "Exporting actionwords to: #{language_config.aw_output_dir}"
        File.open(language_config.aw_output_dir, 'w') { |file|
          file.write(parser.project.childs[:actionwords].render(
            options.language,
            language_config.actionword_render_context)
          )
        }
        show_status_message "Exporting actionwords to: #{language_config.aw_output_dir}", :success
      end
    end
  end
end