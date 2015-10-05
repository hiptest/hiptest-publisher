


class CliOptionsChecker
  attr_reader :reporter, :cli_options
  def initialize(cli_options, reporter)
    @cli_options = cli_options
    @reporter = reporter
  end

  def bad_arguments?
    # ensure config file was readable if specified
    begin
      ParseConfig.new(cli_options.config) if present?(cli_options.config)
    rescue Errno::EACCES => err
      puts "Error with --config: the file \"#{cli_options.config}\" does not exist or is not readable"
      return true
    end

    if cli_options.only == 'list'
      return
    end

    unless cli_options.push.nil? || cli_options.push.empty?
      return
    end

    # secret token
    if missing?(cli_options.token) || empty?(cli_options.token)
      puts "Missing argument --token: you must specify project secret token with --token=<project-token>"
      puts ""
      puts "The project secret token can be found on Hiptest in the settings section, under"
      puts "'Publication settings'. It is a sequence of numbers uniquely identifying your"
      puts "project."
      puts ""
      puts "Note that settings section is available only to administrators of the project."
      return true
    end

    unless numeric?(cli_options.token)
      puts "Invalid format --token=\"#{@cli_options.token}\": the project secret token must be numeric"
      return true
    end

    # output directory
    parent = first_existing_parent(cli_options.output_directory)
    if !parent.writable?
      if parent.realpath === Pathname.new(cli_options.output_directory).cleanpath
        puts "Error with --output-directory: the directory \"#{@cli_options.output_directory}\" is not writable"
      else
        puts "Error with --output-directory: the directory \"#{@cli_options.output_directory}\" can not be created because \"#{parent.realpath}\" is not writable"
      end
      return true
    elsif !parent.directory?
      puts "Error with --output-directory: the file \"#{@cli_options.output_directory}\" is not a directory"
      return true
    end

    # test run id
    if present?(cli_options.test_run_id) && !numeric?(cli_options.test_run_id)
      puts "Invalid format --test-run-id=\"#{@cli_options.test_run_id}\": the test run id must be numeric"
      return true
    end

    return false
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
