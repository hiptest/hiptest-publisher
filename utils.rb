require 'iconv'

def normalize_string name
  literated = Iconv.conv('ascii//translit//ignore', 'utf-8', name)
  literated.strip.gsub(/\s+/, '_').gsub(/\W/, '')
end