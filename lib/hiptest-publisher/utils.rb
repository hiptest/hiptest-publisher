require 'colorize'
require 'io/console'
require 'open-uri'
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

def make_url(options)
  if push?(options)
    "#{options.site}/import_test_results/#{options.token}/#{options.push_format}"
  else
    base_url = "#{options.site}/publication/#{options.token}"
    if options.test_run_id.nil? || options.test_run_id.empty?
      "#{base_url}/#{options.leafless_export ? 'leafless_tests' : 'project'}"
    else
      "#{base_url}/test_run/#{options.test_run_id}"
    end
  end
end

def fetch_project_export(options)
  url = make_url(options)

  open(url, "User-Agent" => 'Ruby/hiptest-publisher', :ssl_verify_mode => OpenSSL::SSL::VERIFY_PEER)
end

def show_status_message(message, status=nil)
  status_icon = " "
  output = STDOUT

  if status == :success
    status_icon = "v".green
  elsif status == :failure
    status_icon = "x".red
    output = STDERR
  end
  if status
    cursor_offset = ""
  else
    return unless $stdout.tty?
    rows, columns = IO.console.winsize
    return if columns == 0
    vertical_offset = (4 + message.length) / columns
    cursor_offset = "\r\e[#{vertical_offset + 1}A"
  end

  output.print "[#{status_icon}] #{message}#{cursor_offset}\n"
end

def with_status_message(message, &blk)
  show_status_message message
  status = :success
  yield
rescue
  status = :failure
  raise
ensure
  show_status_message message, status
end

def push?(options)
  options.push && !options.push.empty?
end

def push_results(options)
  # Code from: https://github.com/nicksieger/multipart-post
  url = URI.parse(make_url(options))
  use_ssl = (url.scheme == 'https')
  uploaded = {}

  Dir.glob(options.push.gsub('\\', '/')).each_with_index do |filename, index|
    uploaded["file-#{filename.normalize}"] = UploadIO.new(File.new(filename), "text", filename)
  end

  req = Net::HTTP::Post::Multipart.new(url.path, uploaded)
  response = Net::HTTP.start(url.host, url.port, :use_ssl => use_ssl, :verify_mode => OpenSSL::SSL::VERIFY_PEER) do |http|
    http.request(req)
  end
end

def clean_path(path)
  Pathname.new(path).cleanpath.to_s
end
