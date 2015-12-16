require 'i18n'

require_relative 'utils'

class String
  def literate
    I18n.enforce_available_locales = false
    I18n.transliterate(self)
  end

  def normalize
    literated = self.literate
    literated.strip!
    literated.gsub!(/\s+/, '_')
    literated.gsub!(/\W/, '')
    literated
  end

  def normalize_lower
    normalized = self.normalize
    normalized.downcase!
    normalized
  end

  def underscore
    # based on:
    # http://stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
    normalized = self.normalize
    normalized.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    normalized.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    normalized.tr!("-", "_")
    normalized.downcase!
    normalized
  end

  def camelize
    normalized = self.normalize.split('_')
    normalized.map! {|w| w.empty? ? "" : "#{w[0].upcase}#{w[1..-1]}"}
    normalized.join
  end

  def camelize_lower
    camelized = self.camelize
    if camelized.empty?
      ""
    else
      "#{camelized[0].downcase}#{camelized[1..-1]}"
    end
  end

  def camelize_upper
    self.camelize
  end

  def clear_extension
    self.split('.')[0]
  end
end
