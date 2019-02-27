require 'erb'
require 'json'
require 'net/http'
require 'uri'

require_relative 'formatters/reporter'

module Hiptest

  class ClientError < StandardError
  end

  class Client
    attr_reader :cli_options

    def initialize(cli_options, reporter = nil)
      @cli_options = cli_options
      @reporter = reporter || NullReporter.new
    end

    def url
      if cli_options.push?
        "#{cli_options.site}/import_test_results/#{cli_options.token}/#{cli_options.push_format}#{execution_environment_query_parameter}"
      elsif test_run_id
        "#{base_publication_path}/test_run/#{test_run_id}#{test_run_export_filter}"
      else
        "#{base_publication_path}/#{cli_options.leafless_export ? 'leafless_tests' : 'project'}#{project_export_filters}"
      end
    end

    def global_failure_url
      "#{cli_options.site}/report_global_failure/#{cli_options.token}/#{cli_options.test_run_id}/"
    end

    def project_export_filters
      mapping = {
        filter_on_scenario_ids: 'filter_scenario_ids',
        filter_on_folder_ids: 'filter_folder_ids',
        filter_on_scenario_name: 'filter_scenario_name',
        filter_on_folder_name: 'filter_folder_name',
        filter_on_tags: 'filter_tags'
      }

      options = []

      mapping.each do |key, filter_name|
        value = @cli_options[key]
        next if value.nil? || value.empty?

        if [:filter_on_scenario_ids, :filter_on_folder_ids, :filter_on_tags].include?(key)
          value = value.split(',').map(&:strip).map{ |s| ERB::Util.url_encode(s) }.join(',')
        else
          value = ERB::Util.url_encode(value)
        end

        options << "#{filter_name}=#{value}"
        if [:filter_on_folder_ids, :filter_on_folder_name].include?(key) && @cli_options[:not_recursive]
          options << "not_recursive=true"
        end
      end


      return options.empty? ? '' : "?#{options.join('&')}"
    end

    def test_run_export_filter
      value = @cli_options.filter_on_status
      return '' if value.nil? || value.empty?

      return "?filter_status=#{value}"
    end

    def fetch_project_export
      response = send_get_request(url)
      if response.code_type == Net::HTTPNotFound
        raise ClientError, "No project found with this secret token."
      end
      response.body
    end

    def available_test_runs
      @available_test_runs ||= begin
        response = send_get_request("#{base_publication_path}/test_runs")
        if response.code_type == Net::HTTPNotFound
          :api_not_available
        else
          json_response = JSON.parse(response.body)
          json_response["test_runs"]
        end
      end
    end

    def push_results
      # Code from: https://github.com/nicksieger/multipart-post
      uploaded = {}
      Dir.glob(cli_options.push.gsub('\\', '/')).each_with_index do |filename, index|
        uploaded["file-#{filename.normalize}"] = UploadIO.new(File.new(filename), "text", filename)
      end

      if cli_options.global_failure_on_missing_reports && uploaded.empty?
        return send_post_request(global_failure_url)
      end

      uri = URI.parse(url)
      send_request(Net::HTTP::Post::Multipart.new(uri, uploaded))
    end

    private

    def test_run_id
      return unless cli_options.test_run_id? || cli_options.test_run_name?

      if cli_options.test_run_id?
        key = "id"
        searched_value = cli_options.test_run_id
      elsif cli_options.test_run_name?
        key = "name"
        searched_value = cli_options.test_run_name
      end

      if available_test_runs == :api_not_available
        if cli_options.test_run_id?
          cli_options.test_run_id
        else
          raise ClientError, "Cannot get the list of available test runs from HipTest. Try using --test-run-id instead of --test-run-name"
        end
      else
        matching_test_run = available_test_runs.find { |test_run| test_run[key] == searched_value }
        if matching_test_run.nil?
          raise ClientError, no_matching_test_runs_error_message
        end
        matching_test_run["id"]
      end
    end

    def no_matching_test_runs_error_message
      if available_test_runs.empty?
        "No matching test run found: this project does not have any test runs."
      else
        "No matching test run found. Available test runs for this project are:\n" +
            columnize_test_runs(available_test_runs)
      end
    end

    def columnize_test_runs(test_runs)
      lines = []
      lines << ["ID", "Name"]
      lines << ["--", "----"]
      lines += test_runs.map { |tr| [tr["id"], tr["name"]] }
      first_column_width = lines.map { |line| line[0].length }.max
      lines.map! { |line| "  #{line[0].ljust(first_column_width)}  #{line[1]}" }
      lines.join("\n")
    end

    def base_publication_path
      "#{cli_options.site}/publication/#{cli_options.token}"
    end

    def send_get_request(url)
      uri = URI.parse(url)
      response = send_request(Net::HTTP::Get.new(uri))
      response
    end

    def send_post_request(url)
      uri = URI.parse(url)
      response = send_request(Net::HTTP::Post.new(uri))
      response
    end

    def send_request(request)
      request["User-Agent"] = "Ruby/hiptest-publisher"
      use_ssl = request.uri.scheme == "https"
      proxy_uri = find_proxy_uri(request.uri.hostname, request.uri.port)
      if proxy_uri
        proxy_address = proxy_uri.hostname
        proxy_port = proxy_uri.port
        proxy_user, proxy_pass = proxy_uri.userinfo.split(':', 2) if proxy_uri.userinfo
      end
      Net::HTTP.start(
          request.uri.hostname, request.uri.port,
          proxy_address, proxy_port, proxy_user, proxy_pass,
          use_ssl: use_ssl,
          verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        @reporter.show_verbose_message("Request sent to: #{request.uri}")
        http.request(request)
      end
    end

    def find_proxy_uri(address, port)
      URI::HTTP.new(
        "http", nil, address, port, nil, nil, nil, nil, nil
      ).find_proxy
    end

    def execution_environment_query_parameter
      return "?execution_environment=#{cli_options.execution_environment}" unless cli_options.execution_environment.strip.empty?

      ""
    end
  end
end
