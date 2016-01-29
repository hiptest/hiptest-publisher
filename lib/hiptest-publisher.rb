require 'colorize'
require 'yaml'

require 'hiptest-publisher/formatters/reporter'
require 'hiptest-publisher/cli_options_checker'
require 'hiptest-publisher/string'
require 'hiptest-publisher/utils'
require 'hiptest-publisher/options_parser'
require 'hiptest-publisher/pruner'
require 'hiptest-publisher/xml_parser'
require 'hiptest-publisher/parent_adder'
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
      # pass false to prevent hiptest-publisher from exiting, useful when used embedded
      @exit_on_bad_arguments = exit_on_bad_arguments
    end

    def run
      puts "URL: #{make_url(@cli_options)}".white if @cli_options.verbose
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

      if push?(@cli_options)
        post_results
        return
      end

      if @cli_options.xml_file
        xml = IO.read(@cli_options.xml_file)
      else
        xml = fetch_xml_file
      end
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

    def fetch_xml_file
      with_status_message "Fetching data from Hiptest" do
        fetch_project_export(@cli_options)
      end
    rescue Exception => err
      puts "Unable to open the file, please check that the token is correct".red
      reporter.dump_error(err)
    end

    def prune_xml(xml)
      pruner = Hiptest::Pruner.new(xml, @cli_options)
      return pruner.prune()
    end

    def get_project(xml)
      with_status_message "Extracting data" do
        parser = Hiptest::XMLParser.new(xml, reporter)
        prune_xml(parser.xml)
        return parser.build_project
      end
    rescue Exception => err
      reporter.dump_error(err)
    end

    def write_to_file(path, message)
      with_status_message "#{message}: #{path}" do
        mkdirs_for(path)
        File.open(path, 'w') do |file|
          file.write(yield)
        end
      end
    rescue Exception => err
      reporter.dump_error(err)
    end

    def mkdirs_for(path)
      unless Dir.exists?(File.dirname(path))
        FileUtils.mkpath(File.dirname(path))
      end
    end

    def add_listener(listener)
      reporter.add_listener(listener)
    end

    def write_node_to_file(path, node, context, message)
      write_to_file(path, message) do
        Hiptest::Renderer.render(node, context)
      end
    end

    def export_files
      @language_config.language_group_configs.each do |language_group_config|
        language_group_config.each_node_rendering_context(@project) do |node_rendering_context|
          write_node_to_file(
            node_rendering_context.path,
            node_rendering_context.node,
            node_rendering_context,
            "Exporting #{node_rendering_context.description}",
          )
        end
      end
    end

    def export_actionword_signature
      write_to_file(
        "#{@cli_options.output_directory}/actionwords_signature.yaml",
        "Exporting actionword signature"
      ) { Hiptest::SignatureExporter.export_actionwords(@project).to_yaml }
    end

    def show_actionwords_diff
      old = nil
      with_status_message "Loading previous definition" do
        old = YAML.load_file("#{@cli_options.output_directory}/actionwords_signature.yaml")
      end

      @language_config = LanguageConfigParser.new(@cli_options)
      Hiptest::Nodes::ParentAdder.add(@project)
      Hiptest::Nodes::ParameterTypeAdder.add(@project)
      Hiptest::DefaultArgumentAdder.add(@project)
      Hiptest::GherkinAdder.add(@project)

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
        return if diff[:created].nil?

        @language_config.language_group_configs.select { |language_group_config|
          language_group_config[:group_name] == "actionwords"
        }.each do |language_group_config|
          diff[:created].each do |created|
            node_rendering_context = language_group_config.build_node_rendering_context(created[:node])
            puts node_rendering_context[:node].render(node_rendering_context)
            puts ""
          end
        end
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
        return if diff[:signature_changed].nil?

        @language_config.language_group_configs.select { |language_group_config|
          language_group_config[:group_name] == "actionwords"
        }.each do |language_group_config|
          diff[:signature_changed].each do |signature_changed|
            node_rendering_context = language_group_config.build_node_rendering_context(signature_changed[:node])
            puts signature_changed[:node].render(node_rendering_context)
            puts ""
          end
        end
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
    rescue Exception => err
      reporter.dump_error(err)
    end

    def export
      return if @project.nil?

      with_status_message "Analyzing data" do
        @language_config = LanguageConfigParser.new(@cli_options)
        Hiptest::Nodes::ParentAdder.add(@project)
        Hiptest::Nodes::ParameterTypeAdder.add(@project)
        Hiptest::DefaultArgumentAdder.add(@project)
        Hiptest::GherkinAdder.add(@project)
        Hiptest::ItemsOrderer.add(@project, @cli_options.sort)
      end

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

    def post_results
      with_status_message "Posting #{@cli_options.push} to #{@cli_options.site}" do
        push_results(@cli_options)
      end
    rescue Exception => err
      reporter.dump_error(err)
    end
  end
end
