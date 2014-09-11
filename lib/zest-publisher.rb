require 'colorize'

require 'zest-publisher/string'
require 'zest-publisher/utils'
require 'zest-publisher/options_parser'
require 'zest-publisher/xml_parser'
require 'zest-publisher/parameter_type_adder'

module Zest
  class Publisher
    def get_project(xml)
      show_status_message "Extracting data"
      parser = Zest::XMLParser.new(xml, @options)
      show_status_message "Extracting data", :success
      parser.build_project
    end

    def write_node_to_file(path, node, message)
      status_message = "#{message}: #{path}"
      begin
        show_status_message status_message
        File.open(path, 'w') do |file|
          file.write(node.render(
            @options.language,
            @language_config.tests_render_context)
          )
        end
        show_status_message status_message, :success
      rescue
        show_status_message status_message, :failure
      end
    end

    def export_scenarios
      if @options.split_scenarios
        @project.children[:scenarios].children[:scenarios].each do |scenario|
          write_node_to_file(
            @language_config.scenario_output_dir(scenario.children[:name]),
            scenario,
            "Exporting scenario \"#{scenario.children[:name]}\"")
        end
      else
        write_node_to_file(
          @language_config.tests_output_dir,
          @project.children[:scenarios],
          "Exporting scenarios")
      end
    end

    def export_actionwords
      write_node_to_file(
        @language_config.aw_output_dir,
        @project.children[:actionwords],
        "Exporting actionwords"
      )
    end

    def initialize(args)
      @options = OptionsParser.parse(ARGV)

      begin
        show_status_message "Fetching data from Zest"
        xml = fetch_project_export(@options.site, @options.token, @options.verbose)
        show_status_message "Fetching data from Zest", :success
      rescue Exception => err
        show_status_message "Fetching data from Zest", :failure
        puts "Unable to open the file, please check that the token is correct".red
        trace_exception err
        return
      end

      @project = get_project(xml)
      @language_config = LanguageConfigParser.new(@options)

      Zest::Nodes::ParameterTypeAdder.add(@project) if @options.language == 'java'

      export_scenarios unless @options.actionwords_only
      export_actionwords unless @options.tests_only
    end
  end
end