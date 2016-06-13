require 'colorize'
require 'io/console'
require 'openssl'
require 'net/http/post/multipart'
require 'pathname'


def hiptest_publisher_path
  Gem.loaded_specs['hiptest-publisher'].full_gem_path
rescue
  '.'
end

def hiptest_publisher_version
  Gem.loaded_specs['hiptest-publisher'].version.to_s
rescue
  File.read("#{hiptest_publisher_path}/VERSION").strip if File.exists?("#{hiptest_publisher_path}/VERSION")
end

def pluralize_word(count, singular, plural=nil)
  if count == 1
    singular
  else
    "#{singular}s"
  end
end

def pluralize(count, singular, plural=nil)
  word = pluralize_word(count, singular, plural)
  "#{count} #{word}"
end

def singularize(name)
  name.to_s.chomp("s")
end

def clean_path(path)
  Pathname.new(path).cleanpath.to_s
end
