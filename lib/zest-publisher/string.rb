require 'i18n'

require_relative 'utils'

class String
  def literate
    I18n.enforce_available_locales = false
    I18n.transliterate(self)
  end

  def normalize
    literated = self.literate
    literated.strip.gsub(/\s+/, '_').gsub(/\W/, '')
  end

  def underscore
    # based on:
    # http://stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
    normalized = self.normalize
    normalized.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  def camelize
    normalized = self.normalize
    normalized.split('_').map {|w| w.empty? ? "" : "#{w[0].upcase}#{w[1..-1]}"}.join
  end
end