require 'colorize'
require 'yaml'

require 'hiptest-publisher/string'
require 'hiptest-publisher/utils'
require 'hiptest-publisher/options_parser'
require 'hiptest-publisher/xml_parser'
require 'hiptest-publisher/parent_adder'
require 'hiptest-publisher/parameter_type_adder'
require 'hiptest-publisher/call_arguments_adder'
require 'hiptest-publisher/signature_exporter'
require 'hiptest-publisher/signature_differ'

module Hiptest
  class Publisher
    def initialize(args)
      @options = OptionsParser.parse(args)
    end

    def run
      unless @options.push.nil? || @options.push.empty?
        post_results
        return
      end

      xml = fetch_xml_file
      return if xml.nil?

      @project = get_project(xml)

      if @options.actionwords_signature
        export_actionword_signature
        return
      end

      if @options.actionwords_diff || @options.aw_deleted|| @options.aw_created|| @options.aw_renamed|| @options.aw_signature_changed
        show_actionwords_diff
        return
      end

      export
    end

    def fetch_xml_file
      show_status_message "Fetching data from Hiptest"
      xml = fetch_project_export(@options)
      show_status_message "Fetching data from Hiptest", :success

      return xml
    rescue Exception => err
      show_status_message "Fetching data from Hiptest", :failure
      puts "Unable to open the file, please check that the token is correct".red
      trace_exception(err) if @options.verbose
    end

    def get_project(xml)
      show_status_message "Extracting data"
      parser = Hiptest::XMLParser.new(xml, @options)
      show_status_message "Extracting data", :success

      return parser.build_project
    end

    def write_to_file(path, message)
      status_message = "#{message}: #{path}"
      begin
        show_status_message status_message
        File.open(path, 'w') do |file|
          file.write(yield)
        end

        show_status_message status_message, :success
      rescue Exception => err
        show_status_message status_message, :failure
        trace_exception(err) if @options.verbose
      end
    end

    def write_node_to_file(path, node, context, message)
      write_to_file(path, message) do
        Hiptest::Renderer.render(node, @options.language, context)
      end
    end

    def export_tests
      if @options.split_scenarios
        @project.children[:tests].children[:tests].each do |test|
          context = @language_config.tests_render_context
          context[:test_file_name] = @language_config.scenario_output_file(test.children[:name])

          write_node_to_file(
            @language_config.scenario_output_dir(test.children[:name]),
            test,
            context,
            "Exporting test \"#{test.children[:name]}\"")
        end
      else
        write_node_to_file(
          @language_config.tests_output_dir,
          @project.children[:tests],
          @language_config.tests_render_context,
          "Exporting tests")
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
      export_actionword_signature
    end

    def export_actionword_signature
      write_to_file(
        "#{@options.output_directory}/actionwords_signature.yaml",
        "Exporting actionword signature"
      ) { Hiptest::SignatureExporter.export_actionwords(@project).to_yaml }
    end

    def show_actionwords_diff
      begin
        show_status_message("Loading previous definition")
        old = YAML.load_file("#{@options.output_directory}/actionwords_signature.yaml")
        show_status_message("Loading previous definition", :success)
      rescue Exception => err
        show_status_message("Loading previous definition", :failure)
        trace_exception(err) if @options.verbose
      end

      @language_config = LanguageConfigParser.new(@options)
      Hiptest::Nodes::ParentAdder.add(@project)
      Hiptest::Nodes::ParameterTypeAdder.add(@project)
      Hiptest::DefaultArgumentAdder.add(@project)

      current = Hiptest::SignatureExporter.export_actionwords(@project, true)
      diff =  Hiptest::SignatureDiffer.diff( old, current)

      if @options.aw_deleted
        return if diff[:deleted].nil?

        diff[:deleted].map {|deleted|
          puts @language_config.name_action_word(deleted[:name])
        }
        return
      end

      if @options.aw_created
        return if diff[:created].nil?
        diff[:created].map {|created|
          puts Hiptest::Renderer.render(created[:node], @options.language, @language_config.actionword_render_context)
          puts ""
        }
        return
      end

      if @options.aw_renamed
        return if diff[:renamed].nil?

        diff[:renamed].map {|renamed|
          puts "#{@language_config.name_action_word(renamed[:name])}\t#{@language_config.name_action_word(renamed[:new_name])}"
        }
        return
      end

      if @options.aw_signature_changed
        return if diff[:signature_changed].nil?

        diff[:signature_changed].map {|signature_changed|
          puts Hiptest::Renderer.render(signature_changed[:node], @options.language, @language_config.actionword_render_context)
          puts ""
        }
        return
      end

      unless diff[:deleted].nil?
        puts "#{pluralize(diff[:deleted].length, "action word")} deleted:"
        puts diff[:deleted].map {|d| "- #{d[:name]}"}.join("\n")
        puts ""
      end

      unless diff[:created].nil?
        puts "#{pluralize(diff[:created].length, "action word")} created:"
        puts diff[:created].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      unless diff[:renamed].nil?
        puts "#{pluralize(diff[:renamed].length, "action word")} renamed:"
        puts diff[:renamed].map {|r| "- #{r[:name]} => #{r[:new_name]}"}.join("\n")
        puts ""
      end

      unless diff[:signature_changed].nil?
        puts "#{pluralize(diff[:signature_changed].length, "action word")} which signature changed:"
        puts diff[:signature_changed].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      if diff.empty?
        puts "No action words changed"
        puts ""
      end
    end

    def export
      return if @project.nil?

      @language_config = LanguageConfigParser.new(@options)
      Hiptest::Nodes::ParentAdder.add(@project)
      Hiptest::Nodes::ParameterTypeAdder.add(@project)
      Hiptest::DefaultArgumentAdder.add(@project)
      Hiptest::GherkinAdder.add(@project)

      unless @options.actionwords_only
        @options.leafless_export ? export_tests : export_scenarios
      end

      export_actionwords unless @options.tests_only
    end

    def post_results
      status_message = "Posting #{@options.push} to #{@options.site}"
      show_status_message(status_message)

      begin
        push_results(@options)
        show_status_message(status_message, :success)
      rescue Exception => err
        show_status_message(status_message, :failure)
        trace_exception(err) if @options.verbose
      end
    end
  end
end
