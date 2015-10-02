require 'optparse'
require 'parseconfig'
require 'ostruct'

require 'hiptest-publisher/formatters/console_formatter'
require 'hiptest-publisher/utils'

class FileConfigParser
  def self.update_options(options, reporter)
    config = ParseConfig.new(options.config)
    config.get_params.each do |param|
      next if options.__cli_args && options.__cli_args.include?(param.to_sym)
      options[param] = config[param]
      options.__config_args << param.to_sym if options.__config_args
    end
  rescue => err
    reporter.dump_error(err)
  end
end

class Option
  attr_reader :short, :long, :default, :type, :help, :attribute

  def initialize(short, long, default, type, help, attribute)
    @short = short
    @long = long
    @default = default
    @type = type
    @help = help
    @attribute = attribute
  end

  def help
    if default == nil || default == ""
      @help
    else
      "#{@help} (default: #{@default})"
    end
  end

  def register(opts, options)
    options[attribute] = @default unless default.nil?
    on_values = [
      @short ? "-#{@short}" : nil,
      "--#{@long}",
      @type,
      help
    ].compact

    opts.on(*on_values) do |value|
      options[attribute] = value
      options.__cli_args << attribute
    end
  end
end

class OptionsParser
  def self.languages
    # First framework is default framework

    {
      'Ruby' => ['Rspec', 'MiniTest'],
      'Cucumber' => ['Ruby'],
      'Java' => ['JUnit', 'Test NG'],
      'Python' => ['Unittest'],
      'Robot Framework' => [''],
      'Selenium IDE' => [''],
      'Javascript' => ['qUnit', 'Jasmine']
    }
  end

  def self.all_options
    [
      Option.new('t', 'token=TOKEN', nil, String, "Secret token (available in your project settings)", :token),
      Option.new('l', 'language=LANG', 'ruby', String, "Target language", :language),
      Option.new('f', 'framework=FRAMEWORK', '', String, "Test framework to use", :framework),
      Option.new('o', 'output-directory=PATH', '.', String, "Output directory", :output_directory),
      Option.new('c', 'config-file=PATH', nil, String, "Configuration file", :config),
      Option.new(nil, 'overriden-templates=PATH', '', String, "Folder for overriden templates", :overriden_templates),
      Option.new(nil, 'test-run-id=ID', '', String, "Export data from a test run", :test_run_id),
      Option.new(nil, 'scenario-ids=IDS', '', String, "Filter scenarios by ids", :filter_ids),
      Option.new(nil, 'scenario-tags=TAGS', '', String, "Filter scenarios by tags", :filter_tags),
      Option.new(nil, 'only=CATEGORIES', nil, String, "Restrict export to given file categories (--only=list to list them)", :only),
      Option.new(nil, 'tests-only', false, nil, "(deprecated) alias for --only=tests", :tests_only),
      Option.new(nil, 'actionwords-only', false, nil, "(deprecated) alias for --only=actionwords", :actionwords_only),
      Option.new(nil, 'actionwords-signature', false, nil, "Export actionwords signature", :actionwords_signature),
      Option.new(nil, 'show-actionwords-diff', false, nil, "Show actionwords diff since last update (summary)", :actionwords_diff),
      Option.new(nil, 'show-actionwords-deleted', false, nil, "Output signature of deleted action words", :aw_deleted),
      Option.new(nil, 'show-actionwords-created', false, nil, "Output code for new action words", :aw_created),
      Option.new(nil, 'show-actionwords-renamed', false, nil, "Output signatures of renamed action words", :aw_renamed),
      Option.new(nil, 'show-actionwords-signature-changed', false, nil, "Output signatures of action words for which signature changed", :aw_signature_changed),
      Option.new(nil, 'split-scenarios', false, nil, "Export each scenario in a single file", :split_scenarios),
      Option.new(nil, 'leafless-export', false, nil, "Use only last level action word", :leafless_export),
      Option.new('s', 'site=SITE', 'https://hiptest.net', String, "Site to fetch from", :site),
      Option.new('p', 'push=FILE.TAP', '', String, "Push a results file to the server", :push),
      Option.new(nil, 'push-format=tap', 'tap', String, "Format of the test results (tap, junit, robot)", :push_format),
      Option.new('v', 'verbose', false, nil, "Run verbosely", :verbose)
    ]
  end

  def self.parse(args, reporter)
    options = OpenStruct.new(__cli_args: Set.new, __config_args: Set.new)
    opt_parser = OptionParser.new do |opts|
      opts.version = hiptest_publisher_version if hiptest_publisher_version
      opts.banner = "Usage: ruby publisher.rb [options]"
      opts.separator ""
      opts.separator "Exports tests from Hiptest for automation."
      opts.separator ""
      opts.separator "Specific options:"

      all_options.each {|o| o.register(opts, options)}

      opts.on("-H", "--languages-help", "Show languages and framework options") do
        self.show_languages
        exit
      end

      opts.on("-F", "--filters-help", "Show help about scenario filtering") do
        [
          "hiptest-publisher allows you to filter the exported scenarios.",
          "You can select the ids of the scenarios:",
          "hiptest-publisher --scenario-ids=12",
          "hiptest-publisher --scenario-ids=12,15,16",
          "",
          "You can also filter by tags:",
          "hiptest-publisher --scenario-tags=mytag",
          "hiptest-publisher --scenario-tags=mytag,myother:tag",
          "",
          "You can not mix ids and tag filtering, only the id filtering will be applied."
        ].each {|line| puts line}
        exit
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    args << "--help" if args.empty?
    opt_parser.parse!(args)
    reporter.add_listener(ConsoleFormatter.new(options.verbose))
    FileConfigParser.update_options(options, reporter)

    reporter.show_options(options.marshal_dump)
    options
  end

  def self.make_language_option(lang, framework = '')
    lang_opt = "--language=#{lang.downcase.gsub(' ', '')}"
    framework_opt = "--framework=#{framework.downcase.gsub(' ', '')}"

    framework.empty? ? lang_opt : "#{lang_opt} #{framework_opt}"
  end

  def self.show_languages
    puts "Supported languages:"
    languages.each do |language, frameworks|
      puts "#{language}:"
      if frameworks.empty?
        puts "  no framework option available #{make_language_option(language, '')}"
      else
        frameworks.each_with_index do |fw, index|
          if index == 0
            puts " - #{fw} [default] #{make_language_option(language, '')}"
          else
            puts " - #{fw} #{make_language_option(language, fw)}"
          end
        end
      end
    end
  end
end


class NodeRenderingContext

  def initialize(properties)
    # should contain  :node, :path, :template_dirs, :description, :indentation
    @properties = OpenStruct.new(properties)
  end

  def method_missing(name, *)
    @properties[name]
  end

  def node
    @properties.node
  end

  def [](key)
    @properties[key]
  end

  def has_key?(key)
    @properties.respond_to?(key)
  end

  def filename
    File.basename(@properties.path)
  end
end


class TemplateFinder
  attr_reader :language, :framework, :overriden_templates, :forced_templates, :fallback_template

  def initialize(
      language: "ruby",
      framework: nil,
      overriden_templates: nil,
      indentation: '  ',
      forced_templates: nil,
      fallback_template: nil,
      **)
    @language = language
    @framework = framework
    @overriden_templates = overriden_templates
    @compiled_handlebars = {}
    @forced_templates = forced_templates || {}
    @fallback_template = fallback_template
    @context = {indentation: indentation}
  end

  def dirs
    dirs = []
    dirs << "#{language}/#{framework}" if framework
    dirs << language
    dirs << "common"
    dirs.map! { |path| "#{hiptest_publisher_path}/lib/templates/#{path}" }

    dirs.unshift(overriden_templates) if overriden_templates
    dirs
  end

  def get_compiled_handlebars(template)
    @compiled_handlebars[template] ||= handlebars.compile(File.read(template))
  end

  def get_template_by_name(name, extension)
    return if name.nil?
    dirs.map do |path|
      template_path = File.join(path, "#{name}.#{extension}")
      template_path if File.file?(template_path)
    end.compact.first
  end

  def get_template_path(template_name, extension = 'hbs')
    get_template_by_name(template_name, extension) || get_template_by_name(@fallback_template, extension)
  end

  def get_template(template_name, extension = 'hbs')
    template_file = get_template_path(template_name, extension = 'hbs')
    if template_file
      get_compiled_handlebars(template).call(render_context)
    else
      raise ArgumentError.new("no template with name #{template_name}")
    end
  end

  def register_partials
    dirs.reverse.each do |path|
      next unless File.directory?(path)
      Dir.entries(path).select do |file_name|
        file_path = File.join(path, file_name)
        next unless File.file?(file_path) && file_name.start_with?('_')
        @handlebars.register_partial(file_name[1..-5], File.read(file_path))
      end
    end
  end

  private

  def handlebars
    if !@handlebars
      @handlebars = Handlebars::Handlebars.new
      register_partials
      Hiptest::HandlebarsHelper.register_helpers(@handlebars, @context)
    end
    @handlebars
  end
end

class LanguageGroupConfig
  def initialize(user_params, language_group_params = nil)
    @output_directory = user_params.output_directory
    @split_scenarios = user_params.split_scenarios
    @leafless_export = user_params.leafless_export
    @user_language = user_params.language
    @user_framework = user_params.framework
    @language_group_params = language_group_params || {}
  end

  def [](key)
    @language_group_params[key]
  end

  def splitted_files?
    if self[:scenario_filename].nil?
      false
    elsif self[:filename].nil?
      true
    else
      @split_scenarios
    end
  end

  def each_node(project)
    if splitted_files?
      project.children[node_name].children[node_name].each do |node|
        yield node
      end
    else
      yield project.children[node_name]
    end
  end

  def forced_templates
    forced = {}
    if splitted_files?
      forced.merge!(
        "scenario" => "single_scenario",
        "test" => "single_test",
      )
    end
    if @language_group_params[:forced_templates]
      forced.merge!(@language_group_params[:forced_templates])
    end
    forced
  end

  def template_finder
    @template_finder ||= TemplateFinder.new(
      language: @language_group_params[:language] || @user_language,
      framework: @language_group_params[:framework] || @user_framework,
      overriden_templates: @language_group_params[:overriden_templates],
      indentation: indentation,
      forced_templates: forced_templates,
      fallback_template: @language_group_params[:fallback_template],
    )
  end

  def template_dirs
    template_finder.dirs
  end

  def each_node_rendering_context(project)
    each_node(project) do |node|
      yield build_node_rendering_context(node)
    end
  end

  def indentation
    @language_group_params[:indentation] || '  '
  end

  def build_node_rendering_context(node)
    path = "#{@output_directory}/#{output_file(node)}"

    if splitted_files?
      description = "#{singularize(node_name)} \"#{node.children[:name]}\""
    else
      description = node_name.to_s
    end

    NodeRenderingContext.new(
      path: path,
      indentation: indentation,
      template_dirs: template_dirs,
      template_finder: template_finder,
      forced_templates: forced_templates,
      description: description,
      node: node,
      fallback_template: @language_group_params[:fallback_template],
      call_prefix: @language_group_params[:call_prefix],
      package: @language_group_params[:package],
    )
  end

  def output_file(node)
    if splitted_files?
      class_name_convention = @language_group_params[:class_name_convention] || :normalize
      name = node.children[:name].send(class_name_convention)

      self[:scenario_filename].gsub('%s', name)
    else
      self[:filename]
    end
  end

  private

  def node_name
    if self[:node_name] == "tests" || self[:node_name] == "scenarios" || self[:group_name] == "tests"
      @leafless_export ? :tests : :scenarios
    else
      :actionwords
    end
  end
end


class LanguageConfigParser
  def initialize(cli_options, language_config_path = nil)
    @cli_options = cli_options
    language_config_path ||= LanguageConfigParser.config_path_for(cli_options)
    @config = ParseConfig.new(language_config_path)
  end

  def self.config_path_for(cli_options)
    config_path = [
      "#{hiptest_publisher_path}/lib/config/#{cli_options.language}-#{cli_options.framework}.conf",
      "#{hiptest_publisher_path}/lib/config/#{cli_options.language}.conf",
    ].map do |path|
      File.expand_path(path) if File.file?(path)
    end.compact.first
    if config_path.nil?
      message = "cannot find configuration file in \"#{hiptest_publisher_path}/config\" for language #{cli_options.language.inspect}"
      message << " and framework #{cli_options.framework.inspect}" if cli_options.framework
      raise ArgumentError.new(message)
    end
    config_path
  end

  def group_names
    @config.groups.reject {|group_name|
      group_name.start_with?('_')
    }
  end

  def filtered_group_names
    if @cli_options.only
      groups_to_keep = @cli_options.only.split(",")
      group_names.select {|group_name| groups_to_keep.include?(group_name)}
    else
      group_names
    end
  end

  def include_group?(group_name)
    filtered_group_names.include?(group_name)
  end

  def language_group_configs
    filtered_group_names.map { |group_name| make_language_group_config(group_name) }
  end

  def name_action_word(name)
    name.send(@config['actionwords']['naming_convention'])
  end

  private

  def group_config(group_name)
    if @config[group_name]
      @config[group_name].map { |key, value| [key.to_sym, value] }.to_h
    else
      {}
    end
  end

  def make_language_group_config group_name
    language_group_params = group_config('_common')
    language_group_params.merge!(group_config(group_name))
    language_group_params[:group_name] = group_name
    language_group_params[:package] = @cli_options.package if @cli_options.package
    language_group_params[:framework] = @cli_options.framework if @cli_options.framework

    unless @cli_options.overriden_templates.nil? || @cli_options.overriden_templates.empty?
      language_group_params[:overriden_templates] = @cli_options.overriden_templates
    end

    LanguageGroupConfig.new(@cli_options, language_group_params)
  end
end
