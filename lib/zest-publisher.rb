require 'colorize'

require 'zest-publisher/string'
require 'zest-publisher/utils'
require 'zest-publisher/options_parser'
require 'zest-publisher/xml_parser'
require 'zest-publisher/parent_adder'
require 'zest-publisher/parameter_type_adder'

module Zest
  class Publisher
    def initialize(args)
      @options = OptionsParser.parse(args)

      xml = fetch_xml_file
      return if xml.nil?

      @project = get_project(xml)
    end

    def fetch_xml_file
      show_status_message "Fetching data from Zest"
      xml = fetch_project_export(@options.site, @options.token, @options.verbose)
      show_status_message "Fetching data from Zest", :success

      return xml
    rescue Exception => err
      show_status_message "Fetching data from Zest", :failure
      puts "Unable to open the file, please check that the token is correct".red
      trace_exception(err) if @options.verbose
    end

    def get_project(xml)
      show_status_message "Extracting data"
      parser = Zest::XMLParser.new(xml, @options)
      show_status_message "Extracting data", :success

      return parser.build_project
    end

    def write_node_to_file(path, node, context, message)
      status_message = "#{message}: #{path}"
      begin
        show_status_message status_message
        File.open(path, 'w') do |file|
          file.write(Zest::Renderer.render(node, @options.language, context))
        end

        show_status_message status_message, :success
      rescue Exception => err
        show_status_message status_message, :failure
        trace_exception(err) if @options.verbose
      end
    end

    def export_scenarios
      if @options.split_scenarios
        @project.children[:scenarios].children[:scenarios].each do |scenario|
          context = @language_config.tests_render_context
          context[:test_file_name] = @language_config.scenario_output_file(scenario.children[:name])

          write_node_to_file(
            @language_config.scenario_output_dir(scenario.children[:name]),
            scenario,
            context,
            "Exporting scenario \"#{scenario.children[:name]}\"")
        end
      else
        write_node_to_file(
          @language_config.tests_output_dir,
          @project.children[:scenarios],
          @language_config.tests_render_context,
          "Exporting scenarios")
      end
    end

    def export_actionwords
      write_node_to_file(
        @language_config.aw_output_dir,
        @project.children[:actionwords],
        @language_config.actionword_render_context,
        "Exporting actionwords"
      )
    end

    def export
      @language_config = LanguageConfigParser.new(@options)
      Zest::Nodes::ParentAdder.add(@project)
      Zest::Nodes::ParameterTypeAdder.add(@project) if @options.language == 'java'

      export_scenarios unless @options.actionwords_only
      export_actionwords unless @options.tests_only
    end
  end
end