require 'i18n'

require 'hiptest-publisher/handlebars_helper'

class TemplateFinder
  attr_reader :template_dirs, :overriden_templates, :forced_templates, :fallback_template

  def initialize(
    template_dirs: nil,
    overriden_templates: nil,
    indentation: '  ',
    forced_templates: nil,
    fallback_template: nil,
    language_group: nil,
    **extra)
    @template_dirs = template_dirs || []
    @overriden_templates = overriden_templates
    @compiled_handlebars = {}
    @template_path_by_name = {}
    @forced_templates = forced_templates || {}
    @fallback_template = fallback_template
    @language_group = language_group
    @extra_params = extra

    @context = {indentation: indentation}
  end

  def dirs
    @dirs ||= begin
      search_dirs = []
      # search in overriden template base dir first
      search_dirs << overriden_templates if overriden_templates
      template_dirs.each do |template_dir|
        # search template paths in overriden_templates
        search_dirs << "#{overriden_templates}/#{template_dir}" if overriden_templates
        version = required_version(template_dir)

        # Search for templates/languages/<language>/version-<language-version>
        if languages_dirs.has_key?(template_dir)
          language_dir = "#{hiptest_publisher_path}/lib/templates/languages/#{template_dir}/#{find_version(languages_dirs[template_dir], version)}"
          if @language_group && File.directory?(File.join(language_dir, @language_group))
            search_dirs << "#{language_dir}/#{@language_group}"
          end

          search_dirs << language_dir
        # Search for templates/frameworks/<framework>/version-<framework-version>
        elsif framework_dirs.has_key?(template_dir)
          framework_dir = "#{hiptest_publisher_path}/lib/templates/frameworks/#{template_dir}/#{find_version(framework_dirs[template_dir], version)}"
          if @language_group && File.directory?(File.join(framework_dir, @language_group))
            search_dirs << "#{framework_dir}/#{@language_group}"
          end

          search_dirs << framework_dir
        else
          # Support old location for templates and "common" folder
          search_dirs << "#{hiptest_publisher_path}/lib/templates/#{template_dir}/"
        end
      end

      search_dirs
    end
  end

  def required_version(template_dir)
    required = @extra_params["#{template_dir}_version".to_sym]
    required ? "version-#{required}" : nil
  end

  def find_version(versions, version)
    versions.include?(version) ? version : versions.first
  end

  def get_compiled_handlebars(template_name)
    template_path = get_template_path(template_name)
    @compiled_handlebars[template_path] ||= handlebars.compile(File.read(template_path))
  end

  def get_template_path(template_name)
    unless @template_path_by_name.has_key?(template_name)
      @template_path_by_name[template_name] = get_template_by_name(template_name) || get_template_by_name(@fallback_template)
    end
    @template_path_by_name[template_name] or raise ArgumentError.new(I18n.t('errors.template_not_found', template_name: template_name, dirs: dirs))
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

  def languages_dirs
    @languages_dirs ||= two_levels_hierarchy('languages')
  end

  def framework_dirs
    @framework_dirs ||= two_levels_hierarchy('frameworks')
  end

  def two_levels_hierarchy(path)
    hierarchy = {}
    list_directories(path).map do |first_level|
      hierarchy[first_level] = list_directories("#{path}/#{first_level}")
    end
    hierarchy
  end

  def list_directories(path)
    Dir.
    entries("#{hiptest_publisher_path}/lib/templates/#{path}")
    .select {|entry| File.directory? File.join("#{hiptest_publisher_path}/lib/templates/#{path}", entry) and !(entry =='.' || entry == '..') }
    .sort
  end

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
