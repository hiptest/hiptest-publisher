require 'i18n'
require 'optparse'
require 'parseconfig'
require 'ostruct'
require 'digest/md5'
require 'pathname'
require 'ruby-handlebars/escapers/dummy_escaper'

require 'hiptest-publisher/formatters/console_formatter'
require 'hiptest-publisher/renderer_addons'
require 'hiptest-publisher/utils'
require 'hiptest-publisher/handlebars_helper'


class FileConfigParser
  FALSY_VALUE_PATTERN = /\A(false|no|0)\Z/i

  def self.update_options(options, reporter)
    config = ParseConfig.new(options.config)
    config.get_params.each do |param|
      next if options.__cli_args && options.__cli_args.include?(param.to_sym)
      if param.start_with?("no_")
        value = falsy?(config[param]) ? "true" : "false"
        param = param.sub("no_", "")
      else
        value = config[param]
      end
      if falsy?(value)
        options[param] = false
      else
        options[param] = value
      end
      if %w(overriden_templates output_directory).include?(param)
        update_path!(param, config, options)
      end
      options.__config_args << param.to_sym if options.__config_args
    end
  rescue => err
    reporter.dump_error(err)
  end

  def self.falsy?(value)
    FALSY_VALUE_PATTERN.match(value)
  end

  def self.update_path!(param, config, options)
    path = Pathname.new(config[param])
    return unless path.relative?
    config_path = Pathname.new(options.config)
    config_absolute_path = config_path.relative? ? Pathname.pwd + config_path : config_path
    resolved_path = config_absolute_path.cleanpath.dirname + path
    options[param] = resolved_path.cleanpath.to_path
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
      "#{@help} (#{I18n.t(:default)}: #{@default})"
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

class CliOptions < OpenStruct
  def initialize(hash = nil)
    hash ||= {}
    hash[:language] ||= ""
    hash[:framework] ||= ""

    super(__cli_args: Set.new, __config_args: Set.new, **hash)
  end

  def actionwords_diff?
    actionwords_diff || actionwords_diff_json || aw_deleted || aw_created || aw_renamed || aw_signature_changed || aw_definition_changed
  end

  def push?
    option_present?(push)
  end

  def test_run_id?
    option_present?(test_run_id)
  end

  def test_run_name?
    option_present?(test_run_name)
  end

  def test_run?
    test_run_id? || test_run_name?
  end

  def language_framework
    if framework.empty?
      language
    else
      "#{language}-#{framework}"
    end
  end

  def groups_to_keep
    only.split(",") if only
  end

  def command_line_used(exclude: [])
    args = self.__cli_args.map do |key|
      next if exclude.include?(key)
      "--#{key.to_s.gsub('_', '-')}=#{self[key]}"
    end.compact

    "hiptest-publisher #{args.join(' ')}".strip
  end

  def uids_not_set_yet?
    !__cli_args.include?(:uids) && !__config_args.include?(:uids)
  end

  def normalize!(reporter = nil)
    self.uids = true if test_run? && uids_not_set_yet?
    self.no_uids = !uids # silent normalization
    modified_options = self.clone
    if actionwords_only
      modified_options.only = 'actionwords'
    elsif tests_only
      modified_options.only = 'tests'
    end

    if language.include?('-')
      modified_options.language, modified_options.framework = language.split("-", 2)
    elsif framework.empty?
      # pick first framework for the language
      _, frameworks = OptionsParser.languages.find do |language, frameworks|
        language.downcase.gsub(' ', '') == self.language.downcase.gsub(' ', '')
      end
      if frameworks
        modified_options.framework = frameworks.first.downcase
      end
    end

    if without
      begin
        available_groups = LanguageConfigParser.new(modified_options).filtered_group_names
        modified_options.only = (available_groups - without.split(',')).join(',')
      rescue ArgumentError
        # Ok, that will be handled by cli_options_checkers later on
      end
    end

    if self != modified_options
      delta = modified_options.table.select do |key, value|
        modified_options[key] != self[key]
      end
      marshal_load(modified_options.marshal_dump)
      if reporter
        reporter.show_options(delta, I18n.t("help.options.nomalized_options"))
      end
      return delta
    end
  end

  private

  def option_present?(value)
    value && !value.empty?
  end
end

class EmptiableString
end

class OptionsParser
  def self.languages
    # First framework is default framework

    {
      'Ruby' => ['Rspec', 'MiniTest'],
      'Cucumber' => ['Ruby', 'Java', 'Javascript', 'Groovy', 'TypeScript'],
      'Cucumber_Legacy' => ['Java', 'Groovy', 'TypeScript'],
      'Java' => ['JUnit', 'Test NG', 'Espresso'],
      'Python' => ['Unittest'],
      'Robot Framework' => [''],
      'Selenium IDE' => [''],
      'Javascript' => ['qUnit', 'Jasmine', 'Mocha', 'Protractor', 'CodeceptJS'],
      'CSharp' => ['NUnit'],
      'PHP' => ['PHPUnit'],
      'SpecFlow' => [''],
      'Behave' => [''],
      'Behat' => [''],
      'Groovy' => ['Spock'],
      'JBehave' => [''],
      'Swift' => ['XCTest']
    }
  end

  def self.all_options
    [
      Option.new('t', 'token=TOKEN', nil, String, I18n.t('options.token'), :token),
      Option.new('l', 'language=LANG', 'ruby', String, I18n.t('options.language'), :language),
      Option.new('f', 'framework=FRAMEWORK', '', String, I18n.t('options.framework'), :framework),
      Option.new('o', 'output-directory=PATH', '.', String, I18n.t('options.output_directory'), :output_directory),
      Option.new(nil, 'filename-pattern=PATTERN', nil, String, I18n.t('options.filename_pattern'), :filename_pattern),
      Option.new('c', 'config-file=PATH', nil, String, I18n.t('options.config'), :config),
      Option.new(nil, 'overriden-templates=PATH', '', String, I18n.t('options.overriden_templates'), :overriden_templates),
      Option.new(nil, 'overriden-language-configs=PATH', '', String, I18n.t('options.overriden_language_configs'), :overriden_language_configs),
      Option.new(nil, 'test-run-id=ID', '', String, I18n.t('options.test_run_id'), :test_run_id),
      Option.new(nil, 'test-run-name=NAME', '', String, I18n.t('options.test_run_name'), :test_run_name),
      Option.new(nil, 'only=CATEGORIES', nil, String, I18n.t('options.only'), :only),
      Option.new(nil, 'without=CATEGORIES', nil, String, I18n.t('options.without'), :without),
      Option.new('x', 'xml-file=PROJECT_XML', nil, String, I18n.t('options.xml_file'), :xml_file),
      Option.new(nil, 'cache-dir=PATH', self.default_cache_directory, String, I18n.t('options.cache_dir'), :cache_dir),
      Option.new(nil, 'cache-duration=DURATION', 60, Integer, I18n.t('options.cache_duration'), :cache_duration),
      Option.new(nil, 'tests-only', false, nil, I18n.t('options.tests_only'), :tests_only),
      Option.new(nil, 'actionwords-only', false, nil, I18n.t('options.actionwords_only'), :actionwords_only),
      Option.new(nil, 'actionwords-signature', false, nil, I18n.t('options.actionwords_signature'), :actionwords_signature),
      Option.new(nil, 'show-actionwords-diff', false, nil, I18n.t('options.actionwords_diff'), :actionwords_diff),
      Option.new(nil, 'show-actionwords-diff-as-json', false, nil, I18n.t('options.actionwords_diff_json'), :actionwords_diff_json),
      Option.new(nil, 'show-actionwords-deleted', false, nil, I18n.t('options.aw_deleted'), :aw_deleted),
      Option.new(nil, 'show-actionwords-created', false, nil, I18n.t('options.aw_created'), :aw_created),
      Option.new(nil, 'show-actionwords-renamed', false, nil, I18n.t('options.aw_renamed'), :aw_renamed),
      Option.new(nil, 'show-actionwords-signature-changed', false, nil, I18n.t('options.aw_signature_changed'), :aw_signature_changed),
      Option.new(nil, 'show-actionwords-definition-changed', false, nil, I18n.t('options.aw_definition_changed'), :aw_definition_changed),
      Option.new(nil, 'library-name=LIBRARY_NAME', nil, String, I18n.t('options.library_name'), :library_name),
      Option.new(nil, 'with-folders', false, nil, I18n.t('options.with_folders'), :with_folders),
      Option.new(nil, 'empty-folders', false, nil, I18n.t('options.empty_folders'), :empty_folders),
      Option.new(nil, 'split-scenarios', false, nil, I18n.t('options.split_scenarios'), :split_scenarios),
      Option.new(nil, 'leafless-export', false, nil, I18n.t('options.leafless_export'), :leafless_export),
      Option.new('s', 'site=SITE', 'https://studio.cucumberstudio.com', String, I18n.t('options.site'), :site),
      Option.new(nil, 'http-proxy=PROXY_URL', nil, String, I18n.t('options.http_proxy'), :http_proxy),
      Option.new('p', 'push=FILE.TAP', '', String, I18n.t('options.push'), :push),
      Option.new(nil, 'global-failure-on-missing-reports', false, nil, I18n.t('options.global_failure_on_missing_reports'), :global_failure_on_missing_reports),
      Option.new(nil, 'push-format=tap', 'tap', String, I18n.t('options.push_format'), :push_format),
      Option.new(nil, 'execution-environment=NAME', '', String, I18n.t('options.execution_environment'), :execution_environment),
      Option.new(nil, 'build-id=ID', '', String, I18n.t('options.build_id'), :build_id),
      Option.new(nil, 'build-name=NAME', '', String, I18n.t('options.build_name'), :build_name),
      Option.new(nil, 'sort=[id,order,alpha]', 'order', String, I18n.t('options.sort'), :sort),
      Option.new(nil, '[no-]uids', false, nil, I18n.t('options.uids'), :uids),
      Option.new(nil, '[no-]parent-folder-tags', true, nil, I18n.t('options.parent_folder_tags'), :parent_folder_tags),
      Option.new(nil, 'parameter-delimiter=DELIMITER', '"', EmptiableString, I18n.t('options.parameter_delimiter'), :parameter_delimiter),
      Option.new(nil, 'with-dataset-names', false, nil, I18n.t('options.with_dataset_names'), :with_dataset_names),
      Option.new(nil, 'keep-filenames', false, nil, I18n.t('options.keep_filenames'), :keep_filenames),
      Option.new(nil, 'keep-foldernames', false, nil, I18n.t('options.keep_foldernames'), :keep_foldernames),
      Option.new(nil, 'filter-on-scenario-ids=IDS', '', String, I18n.t('options.filter_on_scenario_ids'), :filter_on_scenario_ids),
      Option.new(nil, 'filter-on-folder-ids=IDS', '', String, I18n.t('options.filter_on_folder_ids'), :filter_on_folder_ids),
      Option.new(nil, 'filter-on-scenario-name=NAME', '', String, I18n.t('options.filter_on_scenario_name'), :filter_on_scenario_name),
      Option.new(nil, 'filter-on-folder-name=NAME', '', String, I18n.t('options.filter_on_folder_name'), :filter_on_folder_name),
      Option.new(nil, 'filter-on-tags=TAGS', '', String, I18n.t('options.filter_on_tags'), :filter_on_tags),
      Option.new(nil, 'filter-on-status=STATUS', '', String, I18n.t('options.filter_on_status'), :filter_on_status),
      Option.new(nil, 'not-recursive', false, nil, I18n.t('options.not_recursive'), :not_recursive),
      Option.new(nil, 'meta=META', '', String, I18n.t('options.meta'), :meta),
      Option.new(nil, 'check-version', false, nil, I18n.t('options.check_version'), :check_version),
      Option.new(nil, 'force', false, nil, I18n.t('options.force_overwrite'), :force_overwrite),
      Option.new(nil, '[no-]color', nil, nil, I18n.t('options.color'), :color),
      Option.new('v', 'verbose', false, nil, I18n.t('options.verbose'), :verbose),
      Option.new(nil, 'indentation=INDENTATION', nil, EmptiableString, I18n.t('options.indentation'), :indent)
    ]
  end

  def self.default_cache_directory
    home_dir =  begin
                  Dir.home
                rescue
                  '.'
                end

    File.join(home_dir, '.hiptest-publisher', 'cache')
  end

  def self.parse(args, reporter)
    options = CliOptions.new
    opt_parser = OptionParser.new do |opts|
      opts.version = hiptest_publisher_version if hiptest_publisher_version
      opts.banner = I18n.t('help.header')
      opts.separator I18n.t("help.description")
      opts.accept(EmptiableString, /.*/m) { |s,*| s }

      all_options.each {|o| o.register(opts, options)}

      opts.on("-H", "--languages-help", I18n.t('options.languages_help')) do
        self.show_languages
        exit
      end

      opts.on_tail("-h", "--help", I18n.t('options.help')) do
        puts opts
        exit
      end
    end

    args << "--help" if args.empty?
    opt_parser.parse!(args)
    reporter.add_listener(ConsoleFormatter.new(options.verbose, color: options.color))
    FileConfigParser.update_options(options, reporter)

    reporter.show_options(options.marshal_dump)
    options.normalize!(reporter)
    options
  end

  def self.make_language_option(lang, framework = '')
    lang_opt = "--language=#{lang.downcase.gsub(' ', '')}"
    framework_opt = "--framework=#{framework.downcase.gsub(' ', '')}"

    framework.empty? ? lang_opt : "#{lang_opt} #{framework_opt}"
  end

  def self.show_languages
    puts I18n.t('help.languages.supported_languages')
    languages.each do |language, frameworks|
      puts "#{language}:"
      if frameworks.empty?
        puts I18n.t('help.languages.no_framework_available', language: make_language_option(language, ''))
      else
        frameworks.each_with_index do |fw, index|
          if index == 0
            puts " - #{fw} [#{I18n.t(:default)}] #{make_language_option(language, '')}"
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
    # should contain  :node, :path, :description, :indentation
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

  def folder
    File.dirname(@properties.path)
  end

  def relative_folder
    File.dirname(@properties.relative_path)
  end

  def renderer_addons
    addons = @properties.renderer_addons || ""

    addons.split.map do |addon_name|
      Hiptest.const_get(addon_name)
    end
  end
end

class TemplateFinder
  attr_reader :template_dirs, :overriden_templates, :overriden_language_configs, :forced_templates, :fallback_template

  def initialize(
    template_dirs: nil,
    overriden_templates: nil,
    overriden_language_configs: nil,
    indentation: '  ',
    forced_templates: nil,
    fallback_template: nil,
    **)
    @template_dirs = template_dirs || []
    @overriden_templates = overriden_templates
    @compiled_handlebars = {}
    @template_path_by_name = {}
    @forced_templates = forced_templates || {}
    @fallback_template = fallback_template
    @context = {indentation: indentation}
  end

  def dirs
    @dirs ||= begin
      search_dirs = []
      # search in overriden template base dir first
      search_dirs << overriden_templates if overriden_templates
      template_dirs.each {|template_dir|
        # search template paths in overriden_templates
        search_dirs << "#{overriden_templates}/#{template_dir}" if overriden_templates
        # search template paths in hiptest_publisher
        search_dirs << "#{hiptest_publisher_path}/lib/templates/#{template_dir}"
      }
      search_dirs
    end
  end

  def get_compiled_handlebars(template_name)
    template_path = get_template_path(template_name)
    @compiled_handlebars[template_path] ||= handlebars.compile(File.read(template_path))
  end

  def get_template_by_name(name)
    return if name.nil?
    name = forced_templates.fetch(name, name)
    dirs.each do |path|
      template_path = File.join(path, "#{name}.hbs")
      return template_path if File.file?(template_path)
    end
    nil
  end

  def get_template_path(template_name)
    unless @template_path_by_name.has_key?(template_name)
      @template_path_by_name[template_name] = get_template_by_name(template_name) || get_template_by_name(@fallback_template)
    end
    @template_path_by_name[template_name] or raise ArgumentError.new(I18n.t('errors.template_not_found', template_name: template_name, dirs: dirs))
  end

  def register_partials
    dirs.reverse_each do |path|
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
      @handlebars.set_escaper(Handlebars::Escapers::DummyEscaper)

      register_partials
      Hiptest::HandlebarsHelper.register_helpers(@handlebars, @context)
    end
    @handlebars
  end
end

class LanguageGroupConfig
  @@MAX_FILE_SIZE = 255

  def initialize(user_params, language_group_params = nil)
    @output_directory = user_params.output_directory || ""
    @filename_pattern = user_params.filename_pattern
    @split_scenarios = user_params.split_scenarios
    @with_folders = user_params.with_folders
    @leafless_export = user_params.leafless_export
    @language_group_params = language_group_params || {}

    @user_params = user_params
  end

  def [](key)
    @language_group_params[key]
  end

  def filename_pattern
    @filename_pattern || self[:named_filename]
  end

  def with_folders?
    @with_folders && (node_name == :scenarios || node_name == :folders)
  end

  def splitted_files?
    if filename_pattern.nil?
      # if we can't give a different name for each file, we can't split them
      false
    elsif self[:filename].nil?
      # if we can't give a name to a single file, we must split them
      true
    else
      # both options are possible, do as user specified
      @split_scenarios
    end
  end

  def can_name_files?
    if filename_pattern.nil?
      false
    else
      splitted_files? || with_folders?
    end
  end

  def nodes(project)
    case node_name
    when :tests, :scenarios, :actionwords, :libraries
      if splitted_files?
        project.children[node_name].children[node_name]
      elsif with_folders?
        get_folder_nodes(project)
      else
        [project.children[node_name]]
      end
    when :library
      [project.children[:libraries]]
    when :folders
      get_folder_nodes(project)
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

  def template_dirs
    if @language_group_params[:template_dirs]
      @language_group_params[:template_dirs].split(',').map(&:strip)
    else
      []
    end
  end

  def template_finder
    @template_finder ||= TemplateFinder.new(
      template_dirs: template_dirs,
      overriden_templates: @language_group_params[:overriden_templates],
      indentation: indentation,
      forced_templates: forced_templates,
      fallback_template: @language_group_params[:fallback_template],
    )
  end

  def each_node_rendering_context(project)
    return to_enum(:each_node_rendering_context, project) unless block_given?
    nodes(project).each do |node|
      yield build_node_rendering_context(node)
    end
  end

  def indentation
    return @user_params[:indent] unless @user_params[:indent].nil?
    @language_group_params[:indentation] || '  '
  end

  def build_node_rendering_context(node)
    relative_path = File.join(output_dirname(node), output_filename(node))
    relative_path = relative_path[1..-1] if relative_path[0] == '/'
    path = File.join(language_group_output_directory, relative_path)

    if splitted_files?
      description = "#{singularize(node_name)} \"#{node.children[:name]}\""
    else
      description = node_name.to_s
    end

    NodeRenderingContext.new(
      path: path,
      relative_path: relative_path,
      indentation: indentation,
      template_finder: template_finder,
      description: description,
      node: node,
      call_prefix: @language_group_params[:call_prefix],
      package: @language_group_params[:package],
      meta: @language_group_params[:meta],
      parameter_delimiter: @user_params[:parameter_delimiter],
      namespace: @language_group_params[:namespace],
      uids: @user_params[:uids],
      parent_folder_tags: @user_params[:parent_folder_tags],
      with_dataset_names: @user_params[:with_dataset_names],
      renderer_addons: @language_group_params[:renderer_addons]
    )
  end

  def language_group_output_directory
    @user_params["#{@language_group_params[:group_name]}_output_directory"] || @output_directory
  end

  def output_dirname(node)
    return "" unless with_folders?
    folder = node.folder
    hierarchy = []
    while folder && !folder.root?
      hierarchy << normalized_dirname(folder.children[:name])
      folder = folder.parent
    end
    File.join(*hierarchy.reverse)
  end

  def output_filename(node)
    if can_name_files?
      name = shorten_filename(normalized_filename(node.children[:name] || ''))
      filename = filename_pattern.gsub('%s', name)
    else
      self[:filename]
    end
  end

  def shorten_filename(name)
    mandatory_characters = filename_pattern.gsub('%s', '').length
    if name.length + mandatory_characters > @@MAX_FILE_SIZE
      "#{name[0, (@@MAX_FILE_SIZE - 32 - mandatory_characters)]}#{Digest::MD5.hexdigest(name)}"
    else
      name
    end
  end

  private

  def node_name
    if self[:node_name] == "tests" || self[:node_name] == "scenarios" || self[:group_name] == "tests"
      @leafless_export ? :tests : :scenarios
    elsif self[:node_name] == "actionwords" || self[:group_name] == "actionwords"
      :actionwords
    elsif self[:node_name] == "libraries" || self[:group_name] == "libraries"
      :libraries
    elsif self[:node_name] == "library" || self[:group_name] == "library"
      :library
    elsif self[:node_name] == "folders"
      :folders
    else
      raise I18n.t('errors.invalid_node', name: self[:node_name], group_name: self[:group_name])
    end
  end

  def get_folder_nodes(project)
    folders = project.children[:test_plan].children[:folders]
    unless @user_params.empty_folders
      folders.select {|folder| folder.children[:scenarios].length > 0}
    else
      folders
    end
  end

  def normalized_dirname(name)
    return name if @user_params.keep_foldernames

    dirname_convention = @language_group_params[:dirname_convention] || @language_group_params[:filename_convention] || :normalize
    name.send(dirname_convention)
  end

  def normalized_filename(name)
    return name if @user_params.keep_filenames

    filename_convention = @language_group_params[:filename_convention] || :normalize
    name.send(filename_convention)
  end
end

class LanguageConfigParser
  def initialize(cli_options, language_config_path = nil)
    @cli_options = cli_options
    language_config_path ||= LanguageConfigParser.config_path_for(cli_options)
    @config = ParseConfig.new(language_config_path)
  end

  def self.config_path_for(cli_options)
    config_name = if cli_options.framework.empty?
                    "#{cli_options.language}.conf"
                  else
                    "#{cli_options.language}-#{cli_options.framework}.conf"
                  end
    config_path = "/lib/config/#{config_name.downcase}"
    config_prefix = if !cli_options.overriden_language_configs.to_s.empty?
                      # If the user has specified a overiden language config path, check it first. If the config
                      # exists there, return that, otherwise fall back to the default setup and look for a config there.
                      expanded = File.expand_path("#{cli_options.overriden_language_configs}/#{config_name.downcase}")

                      # If the file exists in the path the user specified, set the config path to blank so we will be
                      # looking in the exact path that the user requested.
                      if File.file?(expanded)
                        config_path = ''
                        expanded
                      end
                    end

    config_path = File.expand_path("#{config_prefix || hiptest_publisher_path}#{config_path}")

    if !File.file?(config_path)
      if cli_options.framework.to_s.empty?
        message = I18n.t('errors.invalid_config_file_no_framework', hiptest_publisher_path: hiptest_publisher_path, language: cli_options.language.inspect)
      else
        message = I18n.t('errors.invalid_config_file', hiptest_publisher_path: hiptest_publisher_path, language: cli_options.language.inspect, framework: cli_options.framework.inspect)
      end
      raise ArgumentError.new(message)
    end
    File.expand_path(config_path)
  end

  def group_names
    @config.groups.reject {|group_name|
      group_name.start_with?('_')
    }
  end

  def filtered_group_names
    if @cli_options.groups_to_keep
      group_names.select {|group_name| @cli_options.groups_to_keep.include?(group_name)}
    else
      group_names
    end
  end

  def include_group?(group_name)
    filtered_group_names.include?(group_name)
  end

  def language_group_configs
    filtered_group_names.map {|group_name| make_language_group_config(group_name)}
  end

  def name_action_word(name)
    name.send(get_key_from_group('actionwords', 'naming_convention'))
  end

  def meta
    treated = {}
    meta_opt = @cli_options.meta || ""

    meta_opt.split(',').each do |m|
      key, value = m.split(':')
      value = true if value == 'true'
      value = false if value == 'false'

      treated[key.strip] = value
    end

    treated
  end

  private

  def get_key_from_group(group, key)
    @config[group][key] || @config['_common'][key]
  end

  def group_config(group_name)
    if @config[group_name]
      key_values = @config[group_name].map {|key, value| [key.to_sym, value]}
      Hash[key_values]
    else
      {}
    end
  end

  def make_language_group_config group_name
    # List of options that can be set in the config file but not in command line
    non_visible_options = {
      package: @cli_options.package,
      meta: meta,
      namespace: @cli_options.namespace,
      test_export_dir: @cli_options.test_export_dir,
      tests_ouput_dir: @cli_options.tests_ouput_dir,
      features_output_directory: @cli_options.features_output_directory,
      step_definitions_output_directory: @cli_options.step_definitions_output_directory,
      step_definitions_library_output_directory: @cli_options.step_definitions_output_directory,
      libraries_output_directory: @cli_options.actionwords_output_directory,
      library_output_directory: @cli_options.actionwords_output_directory,
      actionwords_output_directory: @cli_options.actionwords_output_directory
    }

    language_group_params = group_config('_common')
    language_group_params.merge!(group_config(group_name))
    language_group_params[:group_name] = group_name

    non_visible_options.each do |key, value|
      language_group_params[key] = value if value
    end

    unless @cli_options.overriden_templates.nil? || @cli_options.overriden_templates.empty?
      language_group_params[:overriden_templates] = @cli_options.overriden_templates
    end

    if @cli_options.step_definitions_output_directory
      @cli_options.step_definitions_library_output_directory = @cli_options.step_definitions_output_directory
    end

    if @cli_options.actionwords_output_directory
      @cli_options.libraries_output_directory = @cli_options.actionwords_output_directory
      @cli_options.library_output_directory = @cli_options.actionwords_output_directory
    end

    LanguageGroupConfig.new(@cli_options, language_group_params)
  end
end
