


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
end
