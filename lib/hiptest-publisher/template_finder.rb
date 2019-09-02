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
    language_version: nil,
    framework_version: nil,
    **)
    @template_dirs = template_dirs || []
    @overriden_templates = overriden_templates
    @compiled_handlebars = {}
    @template_path_by_name = {}
    @forced_templates = forced_templates || {}
    @fallback_template = fallback_template
    @language_version = language_version
    @framework_version = framework_version
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
