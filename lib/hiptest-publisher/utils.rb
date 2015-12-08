require 'colorize'
require 'io/console'
require 'open-uri'
require 'openssl'
require 'net/http/post/multipart'

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

def make_filter(options)
  ids = options.filter_ids.split(',').map {|id| "filter[]=id:#{id}"}
  tags = options.filter_tags.split(',').map {|tag| "filter[]=tag:#{tag}"}

  filter = (ids + tags).join("&")
  filter.empty? ? '' : "?#{filter}"
end

def make_url(options)
  if push?(options)
    "#{options.site}/import_test_results/#{options.token}/#{options.push_format}"
  else
    base_url = "#{options.site}/publication/#{options.token}"
    if options.test_run_id.nil? || options.test_run_id.empty?
      "#{base_url}/#{options.leafless_export ? 'leafless_tests' : 'project'}#{make_filter(options)}"
    else
      "#{base_url}/test_run/#{options.test_run_id}"
    end
  end
end

def fetch_project_export(options)
  url = make_url(options)

  open(url, "User-Agent" => 'Ruby/hiptest-publisher', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
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

  File.open(options.push) do |results|
    req = Net::HTTP::Post::Multipart.new(url.path, "file" => UploadIO.new(results, "text", "results.tap"))

    response = Net::HTTP.start(url.host, url.port, :use_ssl => use_ssl, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(req)
    end
  end
end
