require 'colorize'
require 'fileutils'
require 'json'
require 'yaml'

require 'hiptest-publisher/formatters/reporter'
require 'hiptest-publisher/cli_options_checker'
require 'hiptest-publisher/client'
require 'hiptest-publisher/string'
require 'hiptest-publisher/utils'
require 'hiptest-publisher/options_parser'
require 'hiptest-publisher/xml_parser'
require 'hiptest-publisher/parent_adder'
require 'hiptest-publisher/datatable_fixer'
require 'hiptest-publisher/parameter_type_adder'
require 'hiptest-publisher/call_arguments_adder'
require 'hiptest-publisher/signature_exporter'
require 'hiptest-publisher/signature_differ'
require 'hiptest-publisher/items_orderer'

module Hiptest
  class Publisher
    attr_reader :reporter

    def initialize(args, listeners: nil, exit_on_bad_arguments: true)
      @reporter = Reporter.new(listeners)
      @cli_options = OptionsParser.parse(args, reporter)
      @client = Hiptest::Client.new(@cli_options, reporter)
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
    rescue Exception => err
      puts ("An error has occured, sorry for the inconvenience.\n" +
        "Try running the command again with --verbose for detailed output").red
      reporter.dump_error(err)
    end

    def get_project(xml)
      reporter.with_status_message "Extracting data" do
        parser = Hiptest::XMLParser.new(xml, reporter)
        return parser.build_project
      end
    rescue Exception => err
      reporter.dump_error(err)
    end

    def write_to_file(path, message, ask_overwrite: false)
      return if ask_overwrite && !overwrite_file?(path)

      reporter.with_status_message "#{message}: #{path}" do
        mkdirs_for(path)
        File.open(path, 'w') do |file|
          file.write(yield)
        end
      end
    rescue Exception => err
      reporter.dump_error(err)
    end

    def overwrite_file?(path)
      return true unless File.file?(path)
      return true if @cli_options.force_overwrite

      if $stdout.isatty
        puts ""
        STDOUT.print "[#{"?".yellow}] File #{path} exists, do you want to overwrite it? [y/N] "
        answer = $stdin.gets.chomp.downcase.strip
        return ['y', 'yes'].include?(answer)
      else
        reporter.notify(:show_status_message, "File #{path} already exists, skipping. Use --force to overwrite it.", :warning)
        return false
      end
    end

    def mkdirs_for(path)
      unless Dir.exists?(File.dirname(path))
        FileUtils.mkpath(File.dirname(path))
      end
    end

    def add_listener(listener)
      reporter.add_listener(listener)
    end

    def write_node_to_file(path, node, context, message, ask_overwrite: false)
      write_to_file(path, message, ask_overwrite: ask_overwrite) do
        context.get_renderer.render(node, context)
      end
    end

    def export_files
      @language_config.language_group_configs.each do |language_group_config|
        ask_overwrite = language_group_config[:group_name] == 'actionwords'

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

    def show_actionwords_diff
      old = nil
      reporter.with_status_message "Loading previous definition" do
        old = YAML.load_file("#{@cli_options.output_directory}/actionwords_signature.yaml")
      end

      analyze_project_data

      current = Hiptest::SignatureExporter.export_actionwords(@project, true)
      diff =  Hiptest::SignatureDiffer.diff( old, current)

      if @cli_options.aw_deleted
        return if diff[:deleted].nil?

        diff[:deleted].map {|deleted|
          puts @language_config.name_action_word(deleted[:name])
        }
        return
      end

      if @cli_options.aw_created
        print_updated_aws(diff[:created])
        return
      end

      if @cli_options.aw_renamed
        return if diff[:renamed].nil?

        diff[:renamed].map {|renamed|
          puts "#{@language_config.name_action_word(renamed[:name])}\t#{@language_config.name_action_word(renamed[:new_name])}"
        }
        return
      end

      if @cli_options.aw_signature_changed
        print_updated_aws(diff[:signature_changed])
        return
      end

      if @cli_options.aw_definition_changed
        print_updated_aws(diff[:definition_changed])
        return
      end

      command_line = @cli_options.command_line_used(exclude: [:actionwords_diff])

      unless diff[:deleted].nil?
        puts "#{pluralize(diff[:deleted].length, "action word")} deleted,"
        puts "run '#{command_line} --show-actionwords-deleted' to list the #{pluralize_word(diff[:deleted].length, "name")} in the code"
        puts diff[:deleted].map {|d| "- #{d[:name]}"}.join("\n")
        puts ""
      end

      unless diff[:created].nil?
        puts "#{pluralize(diff[:created].length, "action word")} created,"
        puts "run '#{command_line} --show-actionwords-created' to get the #{pluralize_word(diff[:created].length, "definition")}"

        puts diff[:created].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      unless diff[:renamed].nil?
        puts "#{pluralize(diff[:renamed].length, "action word")} renamed,"
        puts "run '#{command_line} --show-actionwords-renamed' to get the new #{pluralize_word(diff[:renamed].length, "name")}"
        puts diff[:renamed].map {|r| "- #{r[:name]} => #{r[:new_name]}"}.join("\n")
        puts ""
      end

      unless diff[:signature_changed].nil?
        puts "#{pluralize(diff[:signature_changed].length, "action word")} which signature changed,"
        puts "run '#{command_line} --show-actionwords-signature-changed' to get the new #{pluralize_word(diff[:signature_changed].length, "signature")}"
        puts diff[:signature_changed].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      unless diff[:definition_changed].nil?
        puts "#{pluralize(diff[:definition_changed].length, "action word")} which definition changed:"
        puts "run '#{command_line} --show-actionwords-definition-changed' to get the new #{pluralize_word(diff[:definition_changed].length, "definition")}"
        puts diff[:definition_changed].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      if diff.empty?
        puts "No action words changed"
        puts ""
      end
    rescue Exception => err
      reporter.dump_error(err)
    end

    def print_updated_aws(actionwords)
        return if actionwords.nil?

        @language_config.language_group_configs.select { |language_group_config|
          language_group_config[:group_name] == "actionwords"
        }.each do |language_group_config|
          actionwords.each do |actionword|
            node_rendering_context = language_group_config.build_node_rendering_context(actionword[:node])
            puts actionword[:node].render(node_rendering_context)
            puts ""
          end
        end
        return
    end

    def analyze_project_data
      return if @project_data_analyzed
      reporter.with_status_message "Analyzing data" do
        @language_config = LanguageConfigParser.new(@cli_options)
        Hiptest::Nodes::DatatableFixer.add(@project)
        Hiptest::Nodes::ParentAdder.add(@project)
        Hiptest::Nodes::ParameterTypeAdder.add(@project)
        Hiptest::DefaultArgumentAdder.add(@project)
        Hiptest::GherkinAdder.add(@project)
        Hiptest::ItemsOrderer.add(@project, @cli_options.sort)
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
    rescue Exception => err
      reporter.dump_error(err)
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
        "  * Did you run the following command before executing your tests ?",
        "    #{enhanced_command}",
        "",
        "  * Did you specify the correct push format ?",
        "    Use push_format=<format> in your config file or option --push-format=<format> in the command line",
        "    Available formats are: tap, junit, robot, nunit",
        ""
      ].join("\n")
    end
  end
end
