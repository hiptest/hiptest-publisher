require 'colorize'
require 'json'
require 'yaml'

require 'hiptest-publisher/node_modifiers/add_all'
require 'hiptest-publisher/cli_options_checker'
require 'hiptest-publisher/client'
require 'hiptest-publisher/formatters/diff_displayer'
require 'hiptest-publisher/formatters/reporter'
require 'hiptest-publisher/file_writer'
require 'hiptest-publisher/handlebars_helper'
require 'hiptest-publisher/options_parser'
require 'hiptest-publisher/renderer'
require 'hiptest-publisher/signature_differ'
require 'hiptest-publisher/signature_exporter'
require 'hiptest-publisher/string'
require 'hiptest-publisher/utils'
require 'hiptest-publisher/xml_parser'

module Hiptest
  class Publisher
    attr_reader :reporter

    def initialize(args, listeners: nil, exit_on_bad_arguments: true)
      @reporter = Reporter.new(listeners)
      @cli_options = OptionsParser.parse(args, reporter)
      @client = Hiptest::Client.new(@cli_options, reporter)
      @file_writer = Hiptest::FileWriter.new(@reporter)

      # pass false to prevent hiptest-publisher from exiting, useful when used embedded
      @exit_on_bad_arguments = exit_on_bad_arguments
    end

    def run
      if @cli_options.check_version
        check_version
        return
      end

      begin
        CliOptionsChecker.new(@cli_options, reporter).check!
      rescue CliOptionError => e
        puts e.message
        exit 1 if @exit_on_bad_arguments
        raise
      end

      if @cli_options.only == 'list'
        print_categories
        return
      end

      if @cli_options.push?
        post_results
        return
      end

      xml = get_xml_file
      return if xml.nil?

      @project = get_project(xml)

      if @cli_options.actionwords_signature
        export_actionword_signature
        return
      end

      if @cli_options.actionwords_diff?
        show_actionwords_diff
        return
      end

      export
    end

    def get_xml_file
      if @cli_options.xml_file
        IO.read(@cli_options.xml_file)
      else
        fetch_xml_file
      end
    end

    def fetch_xml_file
      reporter.with_status_message "Fetching data from Hiptest" do
        @client.fetch_project_export
      end
    rescue ClientError => err
      # This should not be an error that needs reporting to an exception monitoring app
      puts err.message.yellow
      if @exit_on_bad_arguments == false # means we are embedded in hiptest-publisher
        raise
      end
    rescue => err
      puts ("An error has occured, sorry for the inconvenience.\n" +
        "Try running the command again with --verbose for detailed output").red
      reporter.dump_error(err)
    end

    def get_project(xml)
      reporter.with_status_message "Extracting data" do
        parser = Hiptest::XMLParser.new(xml, reporter)
        return parser.build_project
      end
    rescue => err
      reporter.dump_error(err)
    end

    def write_to_file(path, message, ask_overwrite: false)
      return if ask_overwrite && !overwrite_file?(path)
      @file_writer.write_to_file(path, message) { yield }
    end

    def overwrite_file?(path)
      return true unless File.file?(path)
      return true if @cli_options.force_overwrite

      if $stdout.isatty
        STDOUT.print "\n"
        STDOUT.print "[#{"?".yellow}] File #{path} exists, do you want to overwrite it? [y/N] "
        answer = $stdin.gets.chomp.downcase.strip
        return ['y', 'yes'].include?(answer)
      else
        reporter.warning_message("File #{path} already exists, skipping. Use --force to overwrite it.")
        return false
      end
    end

    def add_listener(listener)
      reporter.add_listener(listener)
    end

    def write_node_to_file(path, node, context, message, ask_overwrite: false)
      write_to_file(path, message, ask_overwrite: ask_overwrite) do
        Hiptest::Renderer.render(node, context)
      end
    end

    def export_files
      @language_config.language_group_configs.each do |language_group_config|
        next if ['library', 'libraries'].include?(language_group_config[:group_name]) && !@project.has_libraries?
        ask_overwrite = ['actionwords', 'libraries'].include?(language_group_config[:group_name])

        language_group_config.each_node_rendering_context(@project) do |node_rendering_context|
          write_node_to_file(
            node_rendering_context.path,
            node_rendering_context.node,
            node_rendering_context,
            "Exporting #{node_rendering_context.description}",
            ask_overwrite: ask_overwrite
          )
        end
      end
    end

    def export_actionword_signature
      analyze_project_data

      write_to_file(
        "#{@cli_options.output_directory}/actionwords_signature.yaml",
        "Exporting actionword signature",
        ask_overwrite: true
      ) { Hiptest::SignatureExporter.export_actionwords(@project).to_yaml }
    end

    def compute_actionwords_diff
      old = nil
      reporter.with_status_message "Loading previous definition" do
        old = YAML.load_file("#{@cli_options.output_directory}/actionwords_signature.yaml")
      end

      analyze_project_data

      current = Hiptest::SignatureExporter.export_actionwords(@project, true)
      diff =  Hiptest::SignatureDiffer.diff(old, current, library_name: @cli_options.library_name)
    end

    def show_actionwords_diff
      Hiptest::DiffDisplayer.new(compute_actionwords_diff, @cli_options, @language_config, @file_writer).display
    rescue => err
      reporter.dump_error(err)
    end

    def analyze_project_data
      return if @project_data_analyzed
      reporter.with_status_message "Analyzing data" do
        @language_config = LanguageConfigParser.new(@cli_options)
        Hiptest::NodeModifiers.add_all(@project, @cli_options.sort)
      end
      @project_data_analyzed = true
    end

    def export
      return if @project.nil?

      analyze_project_data
      export_files
      export_actionword_signature if @language_config.include_group?("actionwords")
    end

    def print_categories
      language_config = LanguageConfigParser.new(@cli_options)
      group_names = language_config.group_names
      puts "For language #{@cli_options.language}, available file groups are"
      group_names.each do |group_name|
        puts "  - #{group_name}"
      end
      puts [
        "",
        "Usage examples:",
        "",
        "To export only #{group_names.first} files:",
        "    hiptest-publisher --language=#{@cli_options.language} --only=#{group_names.first}",
        "",
        "To export both #{group_names.first} and #{group_names[1]} files:",
        "    hiptest-publisher --language=#{@cli_options.language} --only=#{group_names.take(2).join(",")}"
      ].join("\n")
    end

    def check_version
      latest = nil
      reporter.with_status_message "Checking latest version on Rubygem" do
        latest_gem = Gem.latest_version_for('hiptest-publisher')

        raise RuntimeError, "Unable to connect to Rubygem" if latest_gem.nil?

        latest = latest_gem.version
      end

      return if latest.nil?

      current = hiptest_publisher_version

      if latest == current
        puts "Your current install of hiptest-publisher (#{current}) is up-to-date."
      else
        puts [
          "Your current install of hiptest-publisher (#{current}) is outdated, version #{latest} is available",
          "run 'gem install hiptest-publisher' to get the latest version."
          ].join("\n")
      end
    end

    def post_results
      response = nil
      reporter.with_status_message "Posting #{@cli_options.push} to #{@cli_options.site}" do
        response = @client.push_results
      end
      if valid_hiptest_api_response?(response)
        report_imported_results(response)
      else
        report_hiptest_api_error(response)
      end
    rescue => err
      reporter.dump_error(err)
    end

    def valid_hiptest_api_response?(response)
      response.is_a?(Net::HTTPSuccess)
    end

    def report_imported_results(response)
      json = JSON.parse(response.body)

      reported_tests = json.has_key?('test_import') ? json['test_import'] : []
      passed_count = reported_tests.size

      reporter.with_status_message "#{pluralize(passed_count, "test")} imported" do
        if @cli_options.verbose
          reported_tests.each do |imported_test|
            puts "  Test '#{imported_test['name']}' imported"
          end
        end
      end

      display_empty_push_help if passed_count == 0
    end

    def report_hiptest_api_error(response)
      reporter.failure_message("Hiptest API returned error #{response.code}")
      if response.code == "422" && response.body.start_with?("Unknown format")
        STDERR.print response.body.chomp + "\n"
      elsif response.code == "404"
        STDERR.print "Did you specify the project token of an existing Hiptest project?\n"
      end
    end

    def display_empty_push_help
      command = @cli_options.command_line_used(exclude: [:push, :push_format])
      enhanced_command = "#{command} --without=actionwords"
      if @cli_options.test_run_id.nil? || @cli_options.test_run_id.empty?
        enhanced_command += " --test-run-id=<the ID of the test run you want to push the results to>"
      end

      puts [
        "Possible causes for the lack of imported tests:",
        "",
        "  * Did you run the following command before executing your tests?",
        "    #{enhanced_command}",
        "",
        "  * Did you specify the correct push format?",
        "    Use push_format=<format> in your config file or option --push-format=<format> in the command line",
        "    Available formats are: cucumber-json, junit, nunit, robot, tap",
        ""
      ].join("\n")
    end
  end
end
