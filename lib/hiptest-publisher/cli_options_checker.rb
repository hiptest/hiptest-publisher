require 'pathname'

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
      # ensure config file was readable if specified
      begin
        ParseConfig.new(cli_options.config) if present?(cli_options.config)
      rescue Errno::EACCES => err
        raise CliOptionError, "Error with --config: the file \"#{cli_options.config}\" does not exist or is not readable"
      end

      if cli_options.only == 'list'
        return
      end

      if push?(cli_options)
        return
      end

      # secret token
      if missing?(cli_options.token) || empty?(cli_options.token)
        raise CliOptionError, [
          "Missing argument --token: you must specify project secret token with --token=<project-token>",
          "",
          "The project secret token can be found on Hiptest in the settings section, under",
          "'Publication settings'. It is a sequence of numbers uniquely identifying your",
          "project.",
          "",
          "Note that settings section is available only to administrators of the project.",
        ].join("\n")
      end

      unless numeric?(cli_options.token)
        raise CliOptionError, "Invalid format --token=\"#{@cli_options.token}\": the project secret token must be numeric"
      end

      # output directory
      parent = first_existing_parent(cli_options.output_directory)
      if !parent.writable?
        if parent.realpath === Pathname.new(cli_options.output_directory).cleanpath
          raise CliOptionError, "Error with --output-directory: the directory \"#{@cli_options.output_directory}\" is not writable"
        else
          raise CliOptionError, "Error with --output-directory: the directory \"#{@cli_options.output_directory}\" can not be created because \"#{parent.realpath}\" is not writable"
        end
      elsif !parent.directory?
        raise CliOptionError, "Error with --output-directory: the file \"#{@cli_options.output_directory}\" is not a directory"
      end

      # actionwords signature file
      if cli_options.actionwords_diff || cli_options.aw_deleted || cli_options.aw_created || cli_options.aw_renamed || cli_options.aw_signature_changed
        actionwords_signature_file = Pathname.new(cli_options.output_directory).join("actionwords_signature.yaml")
        if actionwords_signature_file.directory?
          raise CliOptionError, "Bad Action Words signature file: the file \"#{actionwords_signature_file.realpath}\" is a directory"
        elsif !actionwords_signature_file.exist?
          full_path = File.expand_path(cli_options.output_directory)
          raise CliOptionError, [
            "Missing Action Words signature file: the file \"actionwords_signature.yaml\" could not be found in directory \"#{full_path}\"",
            "Use --actionwords-signature to generate the file \"#{full_path}/actionwords_signature.yaml\"",
          ].join("\n")
        end
      end

      # test run id
      if present?(cli_options.test_run_id) && !numeric?(cli_options.test_run_id)
        raise CliOptionError, "Invalid format --test-run-id=\"#{@cli_options.test_run_id}\": the test run id must be numeric"
      end
    end

    private

    def numeric?(arg)
      arg =~ /^\d*$/
    end

    def missing?(arg)
      arg.nil?
    end

    def empty?(arg)
      arg.strip.empty?
    end

    def present?(arg)
      arg && !arg.strip.empty?
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
