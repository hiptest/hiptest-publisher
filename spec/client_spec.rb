require 'webmock/rspec'
require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/client'

describe Hiptest::Client do
  let(:args) { ["--token", "123456789"] }
  let(:options) {
    full_args = args + ["--cache-duration", cache_duration]
    OptionsParser.parse(full_args, NullReporter.new)
  }
  let(:cache_duration) { "0" }

  subject(:client) { Hiptest::Client.new(options) }

  let(:tr_89__Sprint_12) { {
    "id" => "89",
    "name" => "Sprint 12",
    "created_at" => "2016-06-06T09:31:33.138Z",
  } }

  let(:tr_98__Sprint_13) { {
    "id" => "98",
    "name" => "Sprint 13",
    "created_at" => "2016-06-20T09:35:17.981Z",
  } }

  let(:tr_18__Continuous_integration) { {
    "id" => "18",
    "name" => "Continuous integration",
    "created_at" => "2016-03-03T16:02:38.574Z",
  } }

  let(:tr_54__Unit_tests) { {
    "id" => "541",
    "name" => "Unit tests",
    "created_at" => "2015-02-12T20:17:44.600Z",
  } }

  def stub_available_test_runs(test_runs:, token: "123456789")
    test_runs_json = { test_runs: test_runs }.to_json
    stub_request(:get, "https://app.hiptest.com/publication/#{token}/test_runs").
      to_return(body: test_runs_json,
                headers: {'Content-Type' => 'application/json'})
  end

  describe '#url' do
    context "with --token" do
      let(:args) { ["--token", "1234"] }

      it 'creates url for tests generation' do
        expect(client.url).to eq("https://app.hiptest.com/publication/1234/project")
      end

      context "and with --test-run-id" do
        let(:args) { ["--token", "1234", "--test-run-id", "98"] }

        it 'creates url for tests generation from a test run id' do
          stub_available_test_runs(test_runs: [tr_98__Sprint_13], token: "1234")
          expect(client.url).to eq("https://app.hiptest.com/publication/1234/test_run/98")
        end

        context 'and with --filter-on-status' do
          let(:args) { ["--token", "1234", "--test-run-id", "98", '--filter-on-status', 'passed']}

          it 'creates a url to download only tests matching the status' do
            stub_available_test_runs(test_runs: [tr_98__Sprint_13], token: "1234")
            expect(client.url).to eq("https://app.hiptest.com/publication/1234/test_run/98?filter_status=passed")
          end
        end
      end

      context "and with --push" do
        let(:args) { ["--token", "1234", "--push", "myfile.tap"] }

        it 'creates url to push results' do
          expect(client.url).to eq("https://app.hiptest.com/import_test_results/1234/tap")
        end

        context "and with --execution-environment" do
          let(:args) { ["--token", "1234", "--push", "myfile.tap", "--execution-environment", "Default"] }

          it 'creates url to import results for a specific execution environment' do
            expect(client.url).to eq("https://app.hiptest.com/import_test_results/1234/tap?execution_environment=Default")
          end
        end
      end

      context "and with --filter-on-scenario-ids" do
        let(:args) {['--token', '123', '--filter-on-scenario-ids', '1, 3, 4']}

        it 'creates a url specifying the filter' do
          expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_scenario_ids=1,3,4")
        end
      end

      context "and with --filter-on-scenario-name" do
        let(:args) {['--token', '123', '--filter-on-scenario-name', 'My scenario']}

        it 'creates a url specifying the filter' do
          expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_scenario_name=My%20scenario")
        end

        it 'escapes the name for the URL' do
          # args = ['--token', '123', '--filter-on-scenario-name', 'My pouet scenario']
          args[-1] = %q{It's "escaped"_%42_😎_<>}
          expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_scenario_name=It%27s%20%22escaped%22_%2542_%F0%9F%98%8E_%3C%3E")
        end

        it 'escapes accentuated letters for the URL' do
          # args = ['--token', '123', '--filter-on-scenario-name', 'My pouet scenario']
          args[-1] = "La qualité est clé"
          expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_scenario_name=La%20qualit%C3%A9%20est%20cl%C3%A9")
        end
      end

      context "and with --filter-on-folder-ids" do
        let(:args) {['--token', '123', '--filter-on-folder-ids', '7, 8, 10']}

        it 'creates a url specifying the filter' do
          expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_folder_ids=7,8,10")
        end

        context '--not-recursive' do
          let(:args) {['--token', '123', '--filter-on-folder-ids', '7, 8, 10', '--not-recursive']}

          it 'allows enabling the not_recursive option' do
            expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_folder_ids=7,8,10&not_recursive=true")
          end
        end
      end

      context "and with --filter-on-folder-name" do
        let(:args) {['--token', '123', '--filter-on-folder-name', 'My super folder']}

        it 'creates a url specifying the filter' do
          expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_folder_name=My%20super%20folder")
        end

        context '--not-recursive' do
          let(:args) {['--token', '123', '--filter-on-folder-name', 'My super folder', '--not-recursive']}

          it 'allows enabling the not_recursive option' do
            expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_folder_name=My%20super%20folder&not_recursive=true")
          end
        end
      end

      context "and with --filter-on-tags" do
        let(:args) {['--token', '123', '--filter-on-tags', 'tag, another:tag']}

        it 'creates a url specifying the filter' do
          expect(client.url).to eq("https://app.hiptest.com/publication/123/project?filter_tags=tag,another%3Atag")
        end
      end

      context 'with filters' do
        context 'on project' do
          context 'and scenario ids'
          context 'and scenario name'
          context 'and folder ids'
          context 'and folder names'
          context 'and tags'
        end
      end
    end
  end

  describe '#fetch_project_export' do
    let(:args) { ["--token", "123456789"] }

    it 'fetches the project xml from HipTest server' do
      sent_xml = "<xml_everywhere/>"
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_return(body: sent_xml)
      got_xml = client.fetch_project_export
      expect(got_xml).to eq(sent_xml)
    end

    context "when a redirection response is given" do
      let(:original_location) { "https://app.hiptest.com/publication/123456789/project" }
      let(:new_location) { "https://hop.hiptest.org/publication/123456789/project" }

      before do
        stub_request(:get, original_location).
          to_return(:status => 301, :headers => { 'Location' => new_location })
      end

      it 'is followed' do
        sent_xml = "<xml_everywhere/>"

        stub_request(:get, new_location).
          to_return(body: sent_xml)

        got_xml = client.fetch_project_export
        expect(got_xml).to eq(sent_xml)
      end

      it 'fails when maximum redirection is reached' do
        stub_request(:get, new_location).
          to_return(:status => 301, :headers => { 'Location' => original_location })

        expect {
          client.fetch_project_export
        }.to raise_exception(Hiptest::MaximumRedirectionReachedError)

        expect(a_request(:get, original_location)).to have_been_made.at_most_times(6)
        expect(a_request(:get, new_location)).to have_been_made.at_most_times(6)
      end
    end

    context 'when xml cache is enabled' do
      let(:args) { ["--token", "123456789", "--cache-dir", cache_dir] }
      let(:cache_dir) { Dir.mktmpdir }
      let(:cache_duration) { "60" }

      after do
        FileUtils.rm_rf(cache_dir)
      end

      it 'only fetches the XML file from Hiptest the first time' do
        stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
          to_return(body: "<xml_everywhere/>")

        client.fetch_project_export
        client.fetch_project_export
        client.fetch_project_export

        expect(a_request(:get, "https://app.hiptest.com/publication/123456789/project"))
          .to have_been_made.at_most_once
      end
    end

    context "with unexisting secret token" do
      let(:args) { ["--token", "987654321"] }

      it "raises a ClientError exception with a message" do
        stub_request(:get, "https://app.hiptest.com/publication/987654321/project").
          to_return(status: 404)
        expect {
          client.fetch_project_export
        }.to raise_error(Hiptest::ClientError, "No project found with this secret token.")
      end

      context "with --test-run-id" do
        let(:args) { ["--token", "987654321", "--test-run-id", "98"] }

        it "raises a ClientError exception with a message" do
          stub_available_test_runs(test_runs: [tr_98__Sprint_13], token: "987654321")
          stub_request(:get, "https://app.hiptest.com/publication/987654321/test_run/98").
            to_return(status: 404)
          expect {
            client.fetch_project_export
          }.to raise_error(Hiptest::ClientError, "No project found with this secret token.")
        end

        it "raises a ClientError exception with a message (return 404 at another level)" do
          stub_request(:get, "https://app.hiptest.com/publication/987654321/test_runs").
            to_return(status: 404)
          stub_request(:get, "https://app.hiptest.com/publication/987654321/test_run/98").
            to_return(status: 404)
          expect {
            client.fetch_project_export
          }.to raise_error(Hiptest::ClientError, "No project found with this secret token.")
        end
      end

      context "with --test-run-name" do
        let(:args) { ["--token", "987654321", "--test-run-name", "plop"] }

        it "raises a ClientError exception with a message" do
          stub_request(:get, "https://app.hiptest.com/publication/987654321/test_runs").
            to_return(status: 404)
          expect {
            client.fetch_project_export
          }.to raise_error(Hiptest::ClientError, "Cannot get the list of available test runs from HipTest. Try using --test-run-id instead of --test-run-name")
        end
      end
    end

    context "with --test-run-id" do
      let(:args) { ["--token", "123456789", "--test-run-id", "98"] }

      it "fetches the test run xml from HipTest server" do
        stub_available_test_runs(test_runs: [tr_98__Sprint_13])
        sent_xml = "<xml_everywhere/>"
        stub_request(:get, "https://app.hiptest.com/publication/123456789/test_run/98").
          to_return(body: sent_xml)
        got_xml = client.fetch_project_export
        expect(got_xml).to eq(sent_xml)
      end

      context "with unexisting test run id" do
        before do
          stub_available_test_runs(test_runs: [tr_18__Continuous_integration, tr_54__Unit_tests])
        end

        it "raises a ClientError exception with a message stating available test runs in project" do
          expected_message = [
            "No matching test run found. Available test runs for this project are:",
            "  ID   Name",
            "  --   ----",
            "  18   Continuous integration",
            "  541  Unit tests",
            ""
          ].join("\n")
          expect{client.fetch_project_export}.to raise_error(Hiptest::ClientError, expected_message)
        end

        it "has a different message when there are no test runs" do
          stub_available_test_runs(test_runs: [])
          expected_message = "No matching test run found: this project does not have any test runs."
          expect{client.fetch_project_export}.to raise_error(Hiptest::ClientError, expected_message)
        end
      end

      context "on old HipTest version (no /publication/<token>/test_runs API)" do
        it "uses the given test run id and ignores that the API does not exist" do
          stub_request(:get, "https://app.hiptest.com/publication/123456789/test_runs").
            to_return(status: 404)
          sent_xml = "<xml_everywhere/>"
          stub_request(:get, "https://app.hiptest.com/publication/123456789/test_run/98").
            to_return(body: sent_xml)
          got_xml = client.fetch_project_export
          expect(got_xml).to eq(sent_xml)
        end
      end
    end

    context "with --test-run-name" do
      let(:args) { ["--token", "123456789", "--test-run-name", "Sprint 12"] }

      it "first fetches the test runs list to get the id, then the test run xml" do
        stub_available_test_runs(test_runs: [tr_89__Sprint_12])
        sent_xml = "<xml_everywhere/>"
        stub_request(:get, "https://app.hiptest.com/publication/123456789/test_run/89").
          to_return(body: sent_xml)
        got_xml = client.fetch_project_export
        expect(got_xml).to eq(sent_xml)
      end

      context "with unexisting test run name" do
        let(:args) { ["--token", "123456789", "--test-run-name", "The spoon"] }

        it "raises a ClientError exception with a message stating available test runs in project" do
          stub_available_test_runs(test_runs: [tr_89__Sprint_12, tr_18__Continuous_integration, tr_54__Unit_tests])
          expected_message = [
            "No matching test run found. Available test runs for this project are:",
            "  ID   Name",
            "  --   ----",
            "  89   Sprint 12",
            "  18   Continuous integration",
            "  541  Unit tests",
            ""
          ].join("\n")
          expect{client.fetch_project_export}.to raise_error(Hiptest::ClientError, expected_message)
        end

        it "has a different message when there are no test runs" do
          stub_available_test_runs(test_runs: [])
          expected_message = "No matching test run found: this project does not have any test runs."
          expect{client.fetch_project_export}.to raise_error(Hiptest::ClientError, expected_message)
        end
      end
    end
  end

  describe '#push_results' do
    let(:results_dir) { Dir.mktmpdir }
    let(:pushed_file) { "#{results_dir}/result.json" }
    let(:args) { ["--token", "123456789", "--test-run-id", "123", "--push", pushed_file, "--push-format", "json", "--global-failure-on-missing-reports"] }

    let(:report_content) { "Some JSON here" }
    let(:second_report_content) { "Some more JSON" }


    before do
      File.write("#{results_dir}/result.json", report_content)
      File.write("#{results_dir}/result1.json", second_report_content)
    end

    after do
      FileUtils.rm_rf(results_dir)
    end

    it 'sends a post request with the file specified in the --push option embedded' do
      stub_request(:post, "https://app.hiptest.com/import_test_results/123456789/json")
      client.push_results

      expect(a_request(:post, "https://app.hiptest.com/import_test_results/123456789/json").
        with { |req|
          expect(req.body).to match(/Content-Disposition: form-data;.+ filename="result.json"(.|\n)*#{report_content}.*/)
          expect(req.headers['Content-Type']).to include('multipart/form-data;')
        }
      ).to have_been_made.once
    end

    context 'when using globs for pushed file' do
      let(:pushed_file) { "#{results_dir}/*.json" }

      it 'sends multiple files' do
        stub_request(:post, "https://app.hiptest.com/import_test_results/123456789/json")
        client.push_results

        expect(a_request(:post, "https://app.hiptest.com/import_test_results/123456789/json").
          with { |req|
            expect(req.body).to match(/Content-Disposition: form-data;.+ filename="result.json"(.|\n)*#{report_content}.*/)
            expect(req.body).to match(/Content-Disposition: form-data;.+ filename="result1.json"(.|\n)*#{second_report_content}*/)
            expect(req.headers['Content-Type']).to include('multipart/form-data;')
          }
        ).to have_been_made.once
      end
    end

    context "when a redirect response is given" do
      let(:original_location) { "https://app.hiptest.com/import_test_results/123456789/json"}
      let(:new_location) { "https://hop.hiptest.org/import_test_results/123456789/json" }

      before do
        stub_request(:post, original_location).
          to_return(:status => 301, :headers => { 'Location' => new_location })
      end

      it 'is followed' do
        stub_request(:post, new_location).
          to_return(body: "Ola")

        client.push_results
        expect(a_request(:post, new_location).
          with { |req|
            expect(req.body).to match(/Content-Disposition: form-data;.+ filename="result.json"(.|\n)*#{report_content}.*/)
            expect(req.headers['Content-Type']).to include('multipart/form-data;')
          }
        ).to have_been_made.once
      end

      it 'fails when maximum redirection is reached' do
        stub_request(:post, new_location).
          to_return(:status => 301, :headers => { 'Location' => original_location })

        expect {
          client.push_results
        }.to raise_exception(Hiptest::MaximumRedirectionReachedError)

        expect(a_request(:post, original_location)).to have_been_made.at_most_times(6)
        expect(a_request(:post, new_location)).to have_been_made.at_most_times(6)
      end
    end

    context "when there is no file to push" do
      let(:failure_url) { "https://app.hiptest.com/report_global_failure/123456789/123/" }
      let(:pushed_file) { "#{results_dir}/nothing_there.json" }

      it "sends a request to notify hiptest" do
        stub_request(:post, failure_url).
          to_return(body: "Ok")

        client.push_results
        expect(a_request(:post, failure_url)).to have_been_made
      end

      context "when a redirect response is given " do
        let(:original_location) { failure_url }
        let(:new_location)  {"https://hop.hiptest.org/report_global_failure/123456789/123/" }

        before do
          stub_request(:post, failure_url).
            to_return(:status => 301, :headers => { 'Location' => new_location })
        end

        it "is followed" do
          stub_request(:post, new_location).
            to_return(body: "Ola")

          client.push_results
          expect(a_request(:post, new_location)).to have_been_made
        end

        it 'fails when maximum redirection is reached' do
          stub_request(:post, new_location).
            to_return(:status => 301, :headers => { 'Location' => original_location })

          expect {
            client.push_results
          }.to raise_exception(Hiptest::MaximumRedirectionReachedError)

          expect(a_request(:post, original_location)).to have_been_made.at_most_times(6)
          expect(a_request(:post, new_location)).to have_been_made.at_most_times(6)
        end
      end
    end
  end

  describe "#columnize_test_runs" do

    it "formats given test runs in aligned columns" do
      test_runs = [
        tr_89__Sprint_12,
        {
          "id" => "12345",
          "name" => "Another one",
          "created_at" => "2014-02-11T20:17:44.600Z",
        },
        tr_18__Continuous_integration,
        tr_54__Unit_tests,
      ]

      got_output = client.send(:columnize_test_runs, test_runs)
      expect(got_output).to eq([
        "  ID     Name",
        "  --     ----",
        "  89     Sprint 12",
        "  12345  Another one",
        "  18     Continuous integration",
        "  541    Unit tests",
      ].join("\n"))
    end
  end
end
