module Hiptest
  class Client
    attr_reader :cli_options

    def initialize(cli_options)
      @cli_options = cli_options
    end

    def url
      if cli_options.push?
        "#{cli_options.site}/import_test_results/#{cli_options.token}/#{cli_options.push_format}"
      else
        base_url = "#{cli_options.site}/publication/#{cli_options.token}"
        if cli_options.test_run_id.nil? || cli_options.test_run_id.empty?
          "#{base_url}/#{cli_options.leafless_export ? 'leafless_tests' : 'project'}"
        else
          "#{base_url}/test_run/#{cli_options.test_run_id}"
        end
      end
    end

    def fetch_project_export
      open(url, "User-Agent" => 'Ruby/hiptest-publisher', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
    end

    def push_results
      # Code from: https://github.com/nicksieger/multipart-post
      uri = URI.parse(url)
      use_ssl = (uri.scheme == 'https')
      uploaded = {}

      Dir.glob(cli_options.push.gsub('\\', '/')).each_with_index do |filename, index|
        uploaded["file-#{filename.normalize}"] = UploadIO.new(File.new(filename), "text", filename)
      end

      req = Net::HTTP::Post::Multipart.new(uri.path, uploaded)
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => use_ssl, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request(req)
      end
    end
  end
end
