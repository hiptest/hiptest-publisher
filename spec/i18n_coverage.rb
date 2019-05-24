require 'yaml'

module I18nCoverage
  class KeyLogger
    def self.store_key(key)
        KeyLogger.new.store_key(key)
    end

    def store_key(key)
        used_keys.add(key)
    end

    def used_keys
        @@used_keys ||= Set[]
    end
  end

  class KeyLister
    def self.list_keys(locale: 'en')
      KeyLister.new(locale).list_keys
    end

    def initialize(locale)
      @locale = locale
      @source = YAML.load(File.open(File.expand_path("config/locales/#{locale}.yml")))
      @keys = Set[]
    end

    def list_keys
      visit_childs(path: [])
      @keys
    end

    private

    def visit_childs(path: )
      node = @source.dig(*[@locale, path].flatten.compact)
      if node.is_a? String
        @keys.add(path.join('.'))
      else
        node.keys.map {|key| visit_childs(path: [path, key].flatten.compact)}
      end
    end
  end

  class Reporter
    def self.report
      existing_keys = I18nCoverage::KeyLister.list_keys
      used_keys = I18nCoverage::KeyLogger.new.used_keys
      percentage_used = (used_keys.count.to_f / existing_keys.count.to_f) * 100 

      puts ""
      puts "I18n Coverage: #{percentage_used.round(2)}% of the keys used".white
      puts "#{existing_keys.count} keys found in yml file, #{used_keys.count} keys used during the tests"
      puts "Unused keys:"

      (existing_keys - used_keys).map {|k| puts "  #{k}"}
    end
  end
end

module I18n::Backend::KeyLogger
  def translate(*args)
    I18nCoverage::KeyLogger.store_key(args[1])
    super
  end
end

I18n::Backend::Simple.send(:include, I18n::Backend::KeyLogger)
