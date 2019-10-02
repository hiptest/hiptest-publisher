require 'i18n'
require 'pathname'

require 'hiptest-publisher/utils'

module Hiptest
  class CliOptionError < StandardError
  end

  class CliOptionsChecker
    attr_reader :reporter, :cli_options
    def initialize(cli_options, reporter)
      @cli_options = cli_options
      @reporter = reporter
    end

    def check!
      check_config_file

      if cli_options.only == 'list'
        return
      end

      check_secret_token
      check_filters
      check_status_filter
      check_meta

      if cli_options.push?
        check_execution_environment
        check_push_file
      else
        check_output_directory
        check_actionwords_signature_file
        check_xml_file
        check_test_run_id
        check_language_and_only
      end
    end

    def check_config_file
      begin
        ParseConfig.new(cli_options.config) if present?(cli_options.config)
      rescue Errno::EACCES => err
        raise CliOptionError, I18n.t('errors.cli_options.missing_config_file', config_file: cli_options.config)
      end
    end

    def check_filters
      filters = [
        cli_options.filter_on_scenario_ids,
        cli_options.filter_on_folder_ids,
        cli_options.filter_on_scenario_name,
        cli_options.filter_on_folder_name,
        cli_options.filter_on_tags
      ].reject {|opt| absent?(opt) }

      return if filters.empty?

      if filters.size > 1
        raise CliOptionError, I18n.t('errors.cli_options.multiple_filters')
      end

      if present?(cli_options.test_run_id) || present?(cli_options.test_run_name)
        raise CliOptionError, I18n.t('errors.cli_options.filter_with_test_run')
      end

      check_numeric_list(:filter_on_scenario_ids)
      check_numeric_list(:filter_on_folder_ids)
      check_tag_list(:filter_on_tags)
    end

    def check_status_filter
      return if absent?(cli_options.filter_on_status)

      if absent?(cli_options.test_run_id) && absent?(cli_options.test_run_name)
          raise CliOptionError, I18n.t('errors.cli_options.filter_status_without_test_run')
      end
    end

    def check_secret_token
      if absent?(cli_options.xml_file)
        if absent?(cli_options.token)
          raise CliOptionError, I18n.t('errors.cli_options.missing_token')
        end

        unless numeric?(cli_options.token)
          raise CliOptionError, I18n.t('errors.cli_options.invalid_token', token: cli_options.token)
        end
      end
    end

    def check_push_file
      if cli_options.push && !cli_options.global_failure_on_missing_reports
        agnostic_path = clean_path(cli_options.push)
        globbed_files = Dir.glob(agnostic_path)

        if globbed_files.length == 0
          raise CliOptionError, I18n.t('errors.cli_options.unreadable_report_file', path: cli_options.push)
        elsif globbed_files.length == 1 && globbed_files == [cli_options.push]
          if !File.readable?(agnostic_path)
            raise CliOptionError, I18n.t('errors.cli_options.unreadable_report_file', path: cli_options.push)
          elsif !File.file?(agnostic_path)
            raise CliOptionError, I18n.t('errors.cli_options.irregular_report_file', path: cli_options.push)
          end
        end
      end
    end

    def check_execution_environment
      if cli_options.execution_environment
        if cli_options.execution_environment.length > 255
          raise CliOptionError, I18n.t('errors.cli_options.invalid_execution_environment')
        end
      end
    end

    def check_output_directory
      output_directory = clean_path(cli_options.output_directory)

      parent = first_existing_parent(output_directory)
      if !parent.writable?
        if parent.realpath === Pathname.new(cli_options.output_directory).cleanpath
          raise CliOptionError, I18n.t('errors.cli_options.output_directory_not_writable', output_dir: cli_options.output_directory)
        else
          raise CliOptionError, I18n.t('errors.cli_options.output_directory_parent_not_writable', realpath: parent.realpath, output_dir: cli_options.output_directory)
        end
      elsif !parent.directory?
        raise CliOptionError, I18n.t('errors.cli_options.output_directory_not_directory', output_dir: cli_options.output_directory)
      end
    end


    def check_actionwords_signature_file
      if cli_options.actionwords_diff?
        actionwords_signature_file = Pathname.new(cli_options.output_directory).join("actionwords_signature.yaml")
        if actionwords_signature_file.directory?
          raise CliOptionError, I18n.t('errors.cli_options.actionwords_signature_directory', path: actionwords_signature_file.realpath)
        elsif !actionwords_signature_file.exist?
          raise CliOptionError, I18n.t('errors.cli_options.missing_actionwords_signature_file', directory_path: File.expand_path(cli_options.output_directory))
        end
      end
    end

    def check_xml_file
      if cli_options.xml_file
        xml_path = clean_path(cli_options.xml_file)

        if !File.readable?(xml_path)
          raise CliOptionError, I18n.t('errors.cli_options.unreadable_xml_file', path: cli_options.xml_file)
        elsif !File.file?(xml_path)
          raise CliOptionError, I18n.t('errors.cli_options.irregular_xml_file', path: cli_options.xml_file)
        end
      end
    end

    def check_test_run_id
      if present?(cli_options.test_run_id) && !numeric?(cli_options.test_run_id)
        raise CliOptionError, I18n.t('errors.cli_options.invalid_test_run_id', test_run_id: cli_options.test_run_id)
      end
    end

    def check_numeric_list(option_name)
      value = cli_options.send(option_name)
      return if absent?(value)

       value.split(',').each do |val|
        next if numeric?(val.strip)
        raise CliOptionError, I18n.t('errors.cli_options.invalid_numeric_value_list', option: option_name, incorrect_value: val.strip.inspect)
       end
    end

    def check_tag_list(option_name)
      value = cli_options.send(option_name)
      return if absent?(value)

      value.split(',').each do |val|
        next if tag_compatible?(val.strip)
        raise CliOptionError, I18n.t('errors.cli_options.invalid_tag_value_list', option: option_name, incorrect_value: val.strip.inspect)
      end
    end

    def check_meta
      value = cli_options.meta
      return if absent?(value)

      value.split(',').each do |val|
        next if meta_compatible?(val.strip)
        raise CliOptionError, I18n.t('errors.cli_options.invalid_meta', incorrect_value: val.strip.inspect)
      end
    end

    def check_language_and_only
      if present?(cli_options.language)
        begin
          language_config_parser = LanguageConfigParser.new(cli_options)
        rescue ArgumentError => err
          raise CliOptionError, err.message
        end

        if present?(cli_options.only)
          if language_config_parser.filtered_group_names != cli_options.groups_to_keep
            unknown_categories = cli_options.groups_to_keep - language_config_parser.group_names
            raise CliOptionError, I18n.t(
              'errors.cli_options.invalid_category',
              count: unknown_categories.length,
              invalid_categories: formatted_categories(unknown_categories),
              available_categories: formatted_categories(language_config_parser.group_names),
              language: cli_options.language_framework
            )
          end
        end
      end
    end

    private

    def numeric?(arg)
      arg =~ /\A\d*\z/
    end

    def missing?(arg)
      arg.nil?
    end

    def empty?(arg)
      arg.strip.empty?
    end

    def absent?(arg)
      missing?(arg) || empty?(arg)
    end

    def present?(arg)
      !absent?(arg)
    end

    def tag_compatible?(value)
      value =~ /\A[a-zA-Z0-9_-]*(: ?[a-zA-Z0-9_-]*)?\z/
    end

    def meta_compatible?(value)
      value =~ /\A[a-zA-Z0-9_-]*: ?.*\z/
    end

    def formatted_categories(categories)
      formatted_categories = categories.map(&:inspect)
      if formatted_categories.length == 1
        formatted_categories.first
      else
        I18n.t(:readable_list, first_items: formatted_categories[0...-1].join(", "), last_item: formatted_categories.last)
      end
    end

    def first_existing_parent(path)
      pathname = Pathname.new(path)
      while !pathname.exist?
        pathname = pathname.parent
      end
      pathname.realpath
    end
  end
end
