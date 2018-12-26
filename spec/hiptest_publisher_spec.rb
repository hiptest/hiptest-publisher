require 'spec_helper'
require 'fileutils'
require 'webmock/rspec'
require_relative '../lib/hiptest-publisher'

describe Hiptest::Publisher do

  let(:output_dir) {
    @output_dir_created = true
    Dir.mktmpdir
  }
  let(:listeners) { [ErrorListener.new] }

  before(:each) {
    # partially prevent printing on stdout during rspec run (hacky! comment to use pry correctly)
    allow(STDOUT).to receive(:print)
    allow(STDERR).to receive(:print)
  }

  def have_printed(message)
    have_received(:print).at_least(1).with(a_string_including(message))
  end

  def have_not_printed(message)
    have_received(:print).with(a_string_including(message)).at_most(0)
  end

  after(:each) {
    if @output_dir_created
      FileUtils.rm_rf(output_dir)
    end
  }

  context "with http_proxy env var set" do
    before { ENV['http_proxy'] = "http://www.example.org:12345" }
    after  { ENV['http_proxy'] = nil }

    def run_publisher_command(*extra_args)
      args = [
        "--language", "ruby",
        "--output-directory", output_dir,
        "--token", "123456789",
      ] + extra_args
      publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
      publisher.run
    end

    it "connects through the proxy" do
      WebMock.allow_net_connect!

      expect(TCPSocket).to receive(:open).with("www.example.org", 12345, anything, anything).and_throw(:connected_to_proxy)

      catch :connected_to_proxy do
        run_publisher_command
        # TCPSocket was mocked to throw :connected_to_proxy when called with
        # proxy setting. If we did not exit the catch block, that means it
        # did not connect to the proxy we set.
        fail('It did not connect through the http proxy set with "http_proxy" env var')
      end
    end

    context "with proxy user and password specified in http_proxy like http://user:proxy@host:port" do
      before { ENV['http_proxy'] = "http://john.doe:S3cr3tP4zzw0rd@www.example.org:12345" }

      it "retrieves proxy credentials correctly" do
        WebMock.allow_net_connect!

        expect(Net::HTTP).to receive(:start).with(anything, anything, "www.example.org", 12345, "john.doe", "S3cr3tP4zzw0rd", anything).
            and_throw(:proxy_credentials_parsed_correctly)

        catch :proxy_credentials_parsed_correctly do
          run_publisher_command
          fail('It did not parse proxy username and password from "http_proxy" env var')
        end
      end

      it "handles ':' in proxy password" do
        ENV['http_proxy'] = "http://user:S3cr3t:P4zzw0rd@www.example.org:12345"

        expect(Net::HTTP).to receive(:start).with(anything, anything, anything, anything, anything, "S3cr3t:P4zzw0rd", anything).
            and_throw(:proxy_password_parsed_correctly)

        catch :proxy_password_parsed_correctly do
          run_publisher_command
          fail('It did not parse proxy username and password from "http_proxy" env var')
        end
      end
    end
  end

  describe "--language=ruby" do
    def run_publisher_command(*extra_args)
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
      stub_request(:get, "https://app.hiptest.com/publication/123456789/leafless_tests").
        to_return(body: File.read('samples/xml_input/Hiptest automation.xml'))
      args = [
        "--language", "ruby",
        "--output-directory", output_dir,
        "--token", "123456789",
      ] + extra_args
      publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
      publisher.run
    end

    it "exports correctly in the golden case" do
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
      args = [
        "--language", "ruby",
        "--output-directory", output_dir,
        "--token", "123456789",
      ]
      publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
      publisher.run
      expect_same_files("samples/expected_output/Hiptest publisher-rspec", output_dir)
    end

    it "can handle bad URL" do
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_raise(StandardError)
      args = [
        "--language", "ruby",
        "--token", "123456789",
      ]
      publisher = Hiptest::Publisher.new(args)
      expect{
        publisher.run
      }.to output(a_string_including("An error has occured, sorry for the inconvenience.\n" +
        "Try running the command again with --verbose for detailed output")).to_stdout
    end

    it "can handle 404 Not Found errors" do
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_return(status: 404)
      args = [
        "--language", "ruby",
        "--token", "123456789",
      ]
      publisher = Hiptest::Publisher.new(args)
      expect{
        publisher.run
      }.to output(a_string_including("No project found with this secret token.")).to_stdout
    end

    it "displays exporting scenarios, actionwords and actionword signature" do
      run_publisher_command
      expect(STDOUT).to have_printed('Exporting scenarios')
      expect(STDOUT).to have_printed('Exporting actionwords')
      expect(STDOUT).to have_printed('Exporting actionword signature')
    end

    describe "--split-scenarios" do
      it "displays exporting scenario for each scenario" do
        run_publisher_command("--split-scenarios")
        expect(STDOUT).to have_printed('Exporting scenario "A scenario in a subfolder"')
        expect(STDOUT).to have_printed('Exporting scenario "show help"')
      end
    end

    describe "--leafless-export" do
      it "displays exporting tests" do
        run_publisher_command("--leafless-export")
        expect(STDOUT).to have_printed('Exporting tests')
      end

      describe "--split-scenarios" do
        it "displays exporting test for each test" do
          run_publisher_command("--leafless-export", "--split-scenarios")
          expect(STDOUT).to have_printed('Exporting test "A scenario in a subfolder"')
          expect(STDOUT).to have_printed('Exporting test "show help"')
        end
      end
    end

    describe "--only=list" do
      it "displays available categories (tests & actionwords)" do

        expect {
          run_publisher_command("--only=list")
        }.to output([
          'For language ruby, available file groups are',
          '  - tests',
          '  - actionwords',
          '',
          'Usage examples:',
          '',
          'To export only tests files:',
          '    hiptest-publisher --language=ruby --only=tests',
          '',
          'To export both tests and actionwords files:',
          '    hiptest-publisher --language=ruby --only=tests,actionwords',
          '',
        ].join("\n")).to_stdout
      end
    end

    describe "--only=actionwords" do
      it "limits export to actionwords files" do
        run_publisher_command("--only=actionwords")
        expect(STDOUT).to have_printed("Exporting actionwords")
        expect(STDOUT).to have_not_printed("Exporting scenarios")
      end

      it "also exports actionword signature file" do
        run_publisher_command("--only=actionwords")
        expect(STDOUT).to have_printed("Exporting actionword signature")
      end
    end

    describe "--actionwords-only" do
      it "limits export to actionwords files (but deprecated in favor of --only=actionwords)" do
        run_publisher_command("--actionwords-only")
        expect(STDOUT).to have_printed("Exporting actionwords")
        expect(STDOUT).to have_not_printed("Exporting scenarios")
      end

      it "also exports actionword signature file" do
        run_publisher_command("--actionwords-only")
        expect(STDOUT).to have_printed("Exporting actionword signature")
      end
    end

    describe "--only=tests" do
      it "limits export to tests files" do
        run_publisher_command("--only=tests")
        expect(STDOUT).to have_not_printed("Exporting actionwords")
        expect(STDOUT).to have_printed("Exporting scenarios")
      end

      it "does not export actionword signature file" do
        run_publisher_command("--only=tests")
        expect(STDOUT).to have_not_printed("Exporting actionword signature")
      end
    end

    describe "--tests-only" do
      it "limits export to tests files (but deprecated in favor of --only=tests)" do
        run_publisher_command("--tests-only")
        expect(STDOUT).to have_not_printed("Exporting actionwords")
        expect(STDOUT).to have_printed("Exporting scenarios")
      end

      it "does not export actionword signature file" do
        run_publisher_command("--tests-only")
        expect(STDOUT).to have_not_printed("Exporting actionword signature")
      end
    end

    describe "--xml-file" do
      it "reads the xml directly from a xml file" do
        WebMock.reset!  # to ensure failure if any http requests are done
        run_publisher_command("--xml-file", "samples/xml_input/Hiptest publisher.xml")
        expect(STDOUT).to have_printed("Exporting actionwords")
        expect(STDOUT).to have_printed("Exporting scenarios")
      end

      it "does not print 'Fetching data from Hiptest'" do
        WebMock.reset!  # to ensure failure if any http requests are done
        run_publisher_command("--xml-file", "samples/xml_input/Hiptest publisher.xml")
        expect(STDOUT).to have_not_printed("Fetching data from Hiptest")
      end

      it "does not need --token argument" do
        expect {
          args = [
            "--output-directory", output_dir,
            "--xml-file", "samples/xml_input/Hiptest publisher.xml",
          ]
          Hiptest::Publisher.new(args, listeners: [ErrorListener.new]).run
        }.not_to raise_error
      end
    end

    describe 'custom output directories' do
      def create_config_file(name, content)
        path = File.join(output_dir, name)
        File.open(path, 'w') do |file|
          file.write(content)
        end
        path
      end

      def list_files(path)
        Dir.entries(path).reject { |f| [".", ".."].include?(f) }.sort
      end

      let(:custom_output_dir) {
        Dir.mktmpdir
      }

      it 'test output dir can be overriden by setting "tests_output_directory"' do
        path = create_config_file('plop.config', "tests_output_directory = '#{custom_output_dir}'\n")
        run_publisher_command("--config=#{path}")

        expect(list_files(output_dir)).to eq(['actionwords.rb', 'actionwords_signature.yaml', 'plop.config'])
        expect(list_files(custom_output_dir)).to eq(['project_spec.rb'])
      end

      it 'test output dir can be overriden by setting "tests_output_directory"' do
        path = create_config_file('plop.config', "actionwords_output_directory = '#{custom_output_dir}'\n")
        run_publisher_command("--config=#{path}")

        expect(list_files(output_dir)).to eq(['actionwords_signature.yaml', 'plop.config', 'project_spec.rb'])
        expect(list_files(custom_output_dir)).to eq(['actionwords.rb'])
      end
    end

    describe "actionwords modifications" do
      before(:each) do
        aw_signatures = YAML.load_file("samples/expected_output/Hiptest publisher-rspec/actionwords_signature.yaml")

        # simulate "Do something" has been deleted
        aw_signatures << {
          "name" => "Do something",
          "uid" => "a9bd8101-96bc-43d4-bd47-c429a60c6bdc",
          "parameters" => [{"name"=>"x"}]}

        # simulate "start publisher" has been created
        aw_signatures.reject! { |aw| aw["name"] == "start publisher" }

        # simulate "Parameters and assignements" has been renamed
        aw = aw_signatures.find {|e| e["name"] == "Parameters and assignements"}
        aw["name"] = "Parameters and assinements"

        # simulate "Control blocks" signature has changed
        aw = aw_signatures.find {|e| e["name"] == "Control blocks"}
        aw["parameters"] = []

        File.write("#{output_dir}/actionwords_signature.yaml", YAML.dump(aw_signatures))
      end

      describe "--show-actionwords-diff" do
        it "displays differences in actionwords" do
          expect {
            run_publisher_command("--show-actionwords-diff")
          }.to output(a_string_including([
            "1 action word deleted,",
            "run 'hiptest-publisher --language=ruby --output-directory=#{output_dir} --token=123456789 --show-actionwords-deleted' to list the name in the code",
            "- Do something",
            "",
            "1 action word created,",
            "run 'hiptest-publisher --language=ruby --output-directory=#{output_dir} --token=123456789 --show-actionwords-created' to get the definition",
            "- start publisher",
            "",
            "1 action word renamed,",
            "run 'hiptest-publisher --language=ruby --output-directory=#{output_dir} --token=123456789 --show-actionwords-renamed' to get the new name",
            "- Parameters and assinements",
            "",
            "1 action word which signature changed,",
            "run 'hiptest-publisher --language=ruby --output-directory=#{output_dir} --token=123456789 --show-actionwords-signature-changed' to get the new signature",
            "- Control blocks",
          ].join("\n"))).to_stdout
        end
      end

      describe "--show-actionwords-deleted" do
        it "displays the method names of deleted actionwords" do
          expect {
            run_publisher_command("--show-actionwords-deleted")
          }.to output(a_string_including('do_something')).to_stdout
        end
      end

      describe "--show-actionwords-created" do
        it "displays the method stubs of created actionwords" do
          expect {
            run_publisher_command("--show-actionwords-created")
          }.to output(a_string_including([
            'def start_publisher(options = {})',
            '  # TODO: Implement action: "start publisher with options #{options}"',
            '  raise NotImplementedError',
            'end',
          ].join("\n"))).to_stdout
        end
      end

      describe "--show-actionwords-renamed" do
        it "displays a tabular list of renamed actionwords with old and new method names" do
          expect {
            run_publisher_command("--show-actionwords-renamed")
          }.to output(a_string_including(
            "parameters_and_assinements\tparameters_and_assignements",
          )).to_stdout
        end
      end

      describe "--show-actionwords-signature-changed" do
        it "displays the method stubs of the modified actionwords with its new signature" do
          expect {
            run_publisher_command("--show-actionwords-signature-changed")
          }.to output(a_string_including([
            'def control_blocks(x)',
            '  # Tags: parameters dsltests',
            '  while ((x < 0))',
            '    x = x + 1',
            '  end',
            '  if ((x == 0))',
            '    # TODO: Implement result: "#{x} is now equal to zero"',
            '  else',
            '    control_blocks(x - 1)',
            '  end',
            '  raise NotImplementedError',
            'end',
          ].join("\n"))).to_stdout
        end
      end
    end


    describe "Overwriting existing files" do
      context 'when no tty is available' do
        before(:each) do
          allow($stdout).to receive(:isatty).and_return(false)
        end

        it 'skips actionwords file generation and displays a warning' do
          File.write("#{output_dir}/actionwords.rb", "This is definitelly not the action words file")
          run_publisher_command
          expect(STDOUT).to have_printed("File #{output_dir}/actionwords.rb already exists, skipping. Use --force to overwrite it")

          expect(File.read("#{output_dir}/actionwords.rb")).to eq("This is definitelly not the action words file")
        end

        it 'skips actionwords signature file generation and displays a warning' do
          File.write("#{output_dir}/actionwords_signature.yaml", "This is definitelly not the signature file")
          run_publisher_command
          expect(STDOUT).to have_printed("File #{output_dir}/actionwords_signature.yaml already exists, skipping. Use --force to overwrite it")

          expect(File.read("#{output_dir}/actionwords_signature.yaml")).to eq("This is definitelly not the signature file")
        end

        context 'when using the --force option' do
          it 'regenerates action words file' do
            File.write("#{output_dir}/actionwords.rb", "This is definitelly not the action words file")
            run_publisher_command('--force')
            expect(STDOUT).to have_not_printed("File #{output_dir}/actionwords.rb already exists, skipping. Use --force to overwrite it")

            expect(File.read("#{output_dir}/actionwords.rb")).not_to eq("This is definitelly not the action words file")
          end

          it 'regenerates the action words signature file' do
            File.write("#{output_dir}/actionwords_signature.yaml", "This is definitelly not the signature file")
            run_publisher_command('--force')
            expect(STDOUT).to have_not_printed("File #{output_dir}/actionwords_signature.yaml already exists, skipping. Use --force to overwrite it")

            expect(File.read("#{output_dir}/actionwords_signature.yaml")).not_to eq("This is definitelly not the signature file")
          end
        end
      end

      context 'when a tty is available' do
        before(:each) do
          allow($stdout).to receive(:isatty).and_return(true)
        end

        context 'asks user about overwriting action words file' do
          it 'regenerates the file is user answers "y"' do
            expect($stdin)
              .to receive(:gets)
              .and_return("y")

            File.write("#{output_dir}/actionwords.rb", "This is definitelly not the action words file")
            run_publisher_command
            expect(STDOUT).to have_printed("File #{output_dir}/actionwords.rb exists, do you want to overwrite it? [y/N]")
            expect(File.read("#{output_dir}/actionwords.rb")).not_to eq("This is definitelly not the action words file")
          end

          it 'leaves it intact otherwise' do
            expect($stdin)
              .to receive(:gets)
              .and_return("nah")

            File.write("#{output_dir}/actionwords.rb", "This is definitelly not the action words file")
            run_publisher_command
            expect(STDOUT).to have_printed("File #{output_dir}/actionwords.rb exists, do you want to overwrite it? [y/N]")
            expect(File.read("#{output_dir}/actionwords.rb")).to eq("This is definitelly not the action words file")
          end
        end

        context 'asks user about overwriting action words signature file' do
          it 'regenerates the file is user answers "y"' do
            expect($stdin)
              .to receive(:gets)
              .and_return("y")

            File.write("#{output_dir}/actionwords_signature.yaml", "This is definitelly not the signature file")
            run_publisher_command
            expect(STDOUT).to have_printed("File #{output_dir}/actionwords_signature.yaml exists, do you want to overwrite it? [y/N]")
            expect(File.read("#{output_dir}/actionwords_signature.yaml")).not_to eq("This is definitelly not the signature file")
          end

          it 'leaves it intact otherwise' do
            expect($stdin)
              .to receive(:gets)
              .and_return("nah")

            File.write("#{output_dir}/actionwords_signature.yaml", "This is definitelly not the signature file")
            run_publisher_command
            expect(STDOUT).to have_printed("File #{output_dir}/actionwords_signature.yaml exists, do you want to overwrite it? [y/N]")
            expect(File.read("#{output_dir}/actionwords_signature.yaml")).to eq("This is definitelly not the signature file")
          end
        end

        context 'when using the --force option' do
          it 'regenerates action words file' do
            File.write("#{output_dir}/actionwords.rb", "This is definitelly not the action words file")
            run_publisher_command('--force')
            expect(STDOUT).to have_not_printed("File #{output_dir}/actionwords.rb already exists, do you want to overwrite it? [y/N]")

            expect(File.read("#{output_dir}/actionwords.rb")).not_to eq("This is definitelly not the action words file")
          end

          it 'regenerates the action words signature file' do
            File.write("#{output_dir}/actionwords_signature.yaml", "This is definitelly not the signature file")
            run_publisher_command('--force')
            expect(STDOUT).to have_not_printed("File #{output_dir}/actionwords_signature.yaml already exists, do you want to overwrite it? [y/N]")

            expect(File.read("#{output_dir}/actionwords_signature.yaml")).not_to eq("This is definitelly not the signature file")
          end
        end
      end
    end
  end

  def expect_same_files(expected_directory, actual_directory)
    aggregate_failures "output files" do
      actual_files = Dir.entries(actual_directory).reject { |f| [".", ".."].include?(f) }
      expected_files = Dir.entries(expected_directory).reject { |f| [".", ".."].include?(f) }
      expect(actual_files).to match_array(expected_files)

      common_files = (actual_files & expected_files)
      common_files.each do |file|
        actual_content = File.read("#{actual_directory}/#{file}")
        expected_content = File.read("#{expected_directory}/#{file}")
        expect(actual_content).to eq(expected_content), "File #{file} output is different from its expected output"
      end
    end
  end

  describe "--push" do
    def create_file(name, content = "")
      path = File.join(output_dir, name)
      File.write(path, content)
      path
    end

    before do
      stub_request(:post, "https://app.hiptest.com/import_test_results/123/tap").
          to_return(status: 200,
                    body: '{"test_import": [{"name": "my test", "status": "passed"}]}')
    end

    it "pushes the given file" do
      result_file = create_file('result.tap')

      publisher = Hiptest::Publisher.new(["--token", "123", "--push", result_file], listeners: listeners)
      publisher.run

      expect(a_request(:post, "https://app.hiptest.com/import_test_results/123/tap").
        with { |req|
          expect(req.body).to match(/Content-Disposition: form-data;.+ filename="result.tap"/)
          expect(req.headers).to include('Content-Type' => 'multipart/form-data; boundary=-----------RubyMultipartPost')
        }
      ).to have_been_made
      expect(STDOUT).to have_printed("Posting #{result_file} to https://app.hiptest.com")
    end

    it "support globbing to push multiple files" do
      create_file('result1.tap')
      create_file('result2.tap')
      glob = File.join(output_dir, '*.tap')
      publisher = Hiptest::Publisher.new(["--token", "123", "--push", glob], listeners: listeners)

      publisher.run

      expect(a_request(:post, "https://app.hiptest.com/import_test_results/123/tap").
        with { |req|
          expect(req.body).to match(/Content-Disposition: form-data;.+ filename="result1.tap"/).
                          and match(/Content-Disposition: form-data;.+ filename="result2.tap"/)
          expect(req.headers).to include('Content-Type' => 'multipart/form-data; boundary=-----------RubyMultipartPost')
        }
      ).to have_been_made
    end

    it "displays number of passed tests" do
      result_file = create_file('result.tap')
      publisher = Hiptest::Publisher.new(["--token", "123", "--push", result_file], listeners: listeners)

      publisher.run

      expect(STDOUT).to have_printed("1 test imported\n")

      # multiple passed
      stub_request(:post, "https://app.hiptest.com/import_test_results/456/tap").
          to_return(status: 200,
                    body: '{"test_import": [{"name": "test1", "status": "passed"}, {"name": "test2", "status": "passed"}]}')
      publisher = Hiptest::Publisher.new(["--token", "456", "--push", result_file], listeners: listeners)

      publisher.run

      expect(STDOUT).to have_printed("2 tests imported\n")
    end

    it "should display an error if no tests have been imported" do
      result_file = create_file('result.tap')
      stub_request(:post, "https://app.hiptest.com/import_test_results/456/tap").
          to_return(status: 200,
                    body: '{"test_import": []}')
      publisher = Hiptest::Publisher.new(["--token", "456", "--push", result_file], listeners: listeners)

      expect {publisher.run}.to output(a_string_including("Possible causes for the lack of imported tests:")).to_stdout

      expect(STDOUT).to have_printed("0 tests imported\n")
    end

    it "displays names of passed tests with --verbose" do
      result_file = create_file('result.tap')
      stub_request(:post, "https://app.hiptest.com/import_test_results/456/tap").
          to_return(status: 200,
                    body: '{"test_import": [{"name": "test1", "status": "passed"}, {"name": "test2", "status": "passed"}]}')

      expect {
        publisher = Hiptest::Publisher.new(["--verbose", "--token", "456", "--push", result_file], listeners: listeners)
        publisher.run
      }.to output(a_string_including("Test 'test1' imported").
              and(a_string_including("Test 'test2' imported"))).to_stdout
    end

    context 'when no results have been imported' do
      before do
        stub_request(:post, "https://app.hiptest.com/import_test_results/456/tap").
            to_return(status: 200,
                      body: '{"test_import": []}')
      end

      let(:result_file) {create_file('result.tap')}


      it 'shows some help' do
        expect {
          publisher = Hiptest::Publisher.new(["--token", "456", "--push", result_file], listeners: listeners)
          publisher.run
        }.to output([
          "Possible causes for the lack of imported tests:",
          "",
          "  * Did you run the following command before executing your tests?",
          "    hiptest-publisher --token=456 --without=actionwords --test-run-id=<the ID of the test run you want to push the results to>",
          "",
          "  * Did you specify the correct push format?",
          "    Use push_format=<format> in your config file or option --push-format=<format> in the command line",
          "    Available formats are: cucumber-json, junit, nunit, robot, tap",
          ""
        ].join("\n")).to_stdout
      end

      context 'does not add the "--test-run-id=<the ID of the test run you want to push the results to>" part' do
        it 'when it was specified in the config file (even if it is a bad practice ...)' do
          config_file = create_file('hiptest-publisher.conf', [
            "token = 456",
            "test_run_id = 123"
          ].join("\n"))

          publisher = Hiptest::Publisher.new(["-c", config_file, "--push", result_file], listeners: listeners)

          expect {
            publisher.run
          }.to output([
            "Possible causes for the lack of imported tests:",
            "",
            "  * Did you run the following command before executing your tests?",
            "    hiptest-publisher --config=#{config_file} --without=actionwords",
            "",
            "  * Did you specify the correct push format?",
            "    Use push_format=<format> in your config file or option --push-format=<format> in the command line",
            "    Available formats are: cucumber-json, junit, nunit, robot, tap",
            ""
          ].join("\n")).to_stdout
        end

        it 'when it was specified in the command line args' do
          publisher = Hiptest::Publisher.new(["--token", "456", "--test-run-id", "7899", "--push", result_file], listeners: listeners)

          expect {
            publisher.run
          }.to output([
            "Possible causes for the lack of imported tests:",
            "",
            "  * Did you run the following command before executing your tests?",
            "    hiptest-publisher --token=456 --test-run-id=7899 --without=actionwords",
            "",
            "  * Did you specify the correct push format?",
            "    Use push_format=<format> in your config file or option --push-format=<format> in the command line",
            "    Available formats are: cucumber-json, junit, nunit, robot, tap",
            ""
          ].join("\n")).to_stdout
        end
      end
    end

    context 'when Hiptest returns a 404 error' do
      let(:result_file) { create_file('result.tap') }

      before do
        stub_request(:post, "https://app.hiptest.com/import_test_results/456/tap").
            to_return(status: 404,
                      body: "")
      end

      it 'displays the HTTP error code, and suggests that the token may be incorrect' do
        publisher = Hiptest::Publisher.new(["--token", "456", "--push", result_file], listeners: listeners)
        publisher.run

        expect(STDERR).to have_printed("Hiptest API returned error 404")
        expect(STDERR).to have_printed("Did you specify the project token of an existing Hiptest project?")
      end
    end

    context 'when Hiptest returns a 422 error' do
      let(:result_file) { create_file('result.jsonb') }

      before do
        stub_request(:post, "https://app.hiptest.com/import_test_results/456/jsonb").
            to_return(status: 422,
                      body: "Unknown format jsonb. Available formats are:" +
                            "\n - android-studio" +
                            "\n - cucumber-json" +
                            "\n - junit" +
                            "\n - mstest" +
                            "\n - nunit" +
                            "\n - robot" +
                            "\n - tap")
      end

      it 'displays the HTTP error code, and prints the response body as an error' do
        publisher = Hiptest::Publisher.new(["--token", "456", "--push-format", "jsonb", "--push", result_file], listeners: listeners)
        publisher.run

        expect(STDERR).to have_printed("Hiptest API returned error 422")
        expect(STDERR).to have_printed(<<~CONSOLE_OUTPUT)
          Unknown format jsonb. Available formats are:
           - android-studio
           - cucumber-json
           - junit
           - mstest
           - nunit
           - robot
           - tap
        CONSOLE_OUTPUT
      end
    end
  end

  describe "--help" do
    it 'displays help and exists' do
      expect {
        begin
          Hiptest::Publisher.new(["--help"])
          fail("it should have exited")
        rescue SystemExit
        end
      }.to output(a_string_including("Usage: ruby publisher.rb [options]")).to_stdout
    end
  end

  describe "without arguments" do
    it 'displays help and exists' do
      expect {
        begin
          Hiptest::Publisher.new([])
          fail("it should have exited")
        rescue SystemExit
        end
      }.to output(a_string_including("Usage: ruby publisher.rb [options]")).to_stdout
    end
  end

  describe "with invalid arguments" do
    def run_publisher_command(*args)
      publisher = Hiptest::Publisher.new(args, listeners: listeners)
      publisher.run
    end

    def run_publisher_expecting_exit(*args)
      begin
        run_publisher_command(*args)
        fail("running publisher with args=#{args.inspect} should have exited")
      rescue SystemExit
        # ok, it was expected
      end
    end

    context 'with filters' do
      it 'outputs an error message when there is more than one filter set' do
        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-scenario-ids', '1', '--filter-on-tags', 'plop')
        }.to output([
          "You specified multiple filters for the export.",
          "",
          "Only one filter can be applied.",
          ""
        ].join("\n")).to_stdout
      end

      it 'outputs an error message when filters are applied in conjunction with test run' do
        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-scenario-ids', '1', '--test-run-id', '12')
        }.to output([
          "Filtering can not be applied when exporting from a test run",
          ""
        ].join("\n")).to_stdout

        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-scenario-ids', '1', '--test-run-name', 'CI')
        }.to output([
          "Filtering can not be applied when exporting from a test run",
          ""
        ].join("\n")).to_stdout
      end

      it 'outputs an error message when the scenario ids is not a numeric list' do
        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-scenario-ids', 'abc')
        }.to output([
          'filter_on_scenario_ids should be a list of comma separated numeric values',
          '',
          'Found: "abc"',
          ""
        ].join("\n")).to_stdout

        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-scenario-ids', '1, 2, abc')
        }.to output([
          'filter_on_scenario_ids should be a list of comma separated numeric values',
          '',
          'Found: "abc"',
          ""
        ].join("\n")).to_stdout
      end

      it 'outputs an error message when the folder ids is not a numeric list' do
        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-folder-ids', 'abc')
        }.to output([
          'filter_on_folder_ids should be a list of comma separated numeric values',
          '',
          'Found: "abc"',
          ""
        ].join("\n")).to_stdout

        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-folder-ids', '1, 2, abc')
        }.to output([
          'filter_on_folder_ids should be a list of comma separated numeric values',
          '',
          'Found: "abc"',
          ""
        ].join("\n")).to_stdout
      end

      it 'outputs an error message when the tag list is not a valid tag list' do
        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-tags', 'abc, pli!c')
        }.to output([
          'filter_on_tags should be a list of comma separated tags in Hiptest',
          '',
          'Found: "pli!c"',
          ""
        ].join("\n")).to_stdout
      end

      it 'outputs an error message when the filter on status is applied without a test run' do
        expect {
          run_publisher_expecting_exit('-t', '123', '--filter-on-status', 'passed')
        }.to output([
          "You need to specify a test run when filtering on test status.",
          "Use options test_run_id or test_run_name.",
          ""
        ].join("\n")).to_stdout
      end
    end

    context 'with unknown language ONLY' do
      it 'outputs an error message indicating that language is unknown' do
        expect {
          run_publisher_expecting_exit("--language", "hello", "--token", "123")
        }.to output("cannot find configuration file in \"./lib/config\" for language \"hello\"\n").to_stdout
      end
    end

    context 'with unknown language and framework' do
      it 'outputs an error message indicating that language and framework are unknown' do
        expect {
          run_publisher_expecting_exit("--language", "hello", "--framework", "world", "--token", "123")
        }.to output("cannot find configuration file in \"./lib/config\" for language \"hello\" and framework \"world\"\n").to_stdout
      end
    end

    context 'with known language and unknown framework' do
      it 'outputs an error message indicating that language is known but not the framework' do
        expect {
          run_publisher_expecting_exit("--language", "ruby", "--framework", "world", "--token", "123")
        }.to output("cannot find configuration file in \"./lib/config\" for language \"ruby\" and framework \"world\"\n").to_stdout
      end
    end

    context "with missing token" do
      it "outputs an error message inviting to add --token argument" do
        expect {
          run_publisher_expecting_exit("--language", "ruby")
        }.to output(a_string_including("Missing argument --token: you must specify project secret token with --token=<project-token>")).to_stdout
      end
    end

    context "with bad token format" do
      it "outputs an error message that it must be numeric" do
        expect {
          run_publisher_expecting_exit("--token", "abc")
        }.to output(a_string_including("Invalid format --token=\"abc\": the project secret token must be numeric")).to_stdout
      end

      context "with --verbose and --test-run-name" do
        it "outputs an error message that token must be numeric *before* getting test runs list" do
          expect {
            run_publisher_expecting_exit("--token", "abc", "--verbose")
          }.to output(a_string_including("Invalid format --token=\"abc\": the project secret token must be numeric")).to_stdout
        end
      end
    end

    context "with non-numeric test-run-id" do
      it "outputs an error message that it must be numeric" do
        expect {
          run_publisher_expecting_exit("--token", "123", "--test-run-id", "125e")
        }.to output(a_string_including("Invalid format --test-run-id=\"125e\": the test run id must be numeric")).to_stdout
      end
    end

    context "with unreadable config file" do
      let(:listeners) { [] }

      it "outputs an error message that the file could not be read" do
        expect {
          run_publisher_expecting_exit("--token", "123", "--config", "polop")
        }.to output(a_string_including("Error with --config: the file \"polop\" does not exist or is not readable")).to_stdout
      end
    end

    context "with unknown category" do
      it "outputs an error message that this category does not exist" do
        expect {
          run_publisher_expecting_exit("--token", "123", "--language", "cucumber", "--only", "tests")
        }.to output(a_string_including("Error with --only: the category \"tests\" does not exist for language cucumber-ruby.")).to_stdout
      end

      it "outputs an error message that some categories do not exist" do
        expect {
          run_publisher_expecting_exit("--token", "123", "--language", "cucumber", "--only", "tests,features,toto,tata")
        }.to output(a_string_including("Error with --only: the categories \"tests\", \"toto\" and \"tata\" do not exist for language cucumber-ruby.")).to_stdout
      end

      it "outputs available categories" do
        expect {
          run_publisher_expecting_exit("--token", "123", "--language", "cucumber", "--only", "tests")
        }.to output(a_string_including("Available categories are \"features\", \"step_definitions\" and \"actionwords\".")).to_stdout
      end
    end

    context "--push" do
      context "with missing token" do
        it "outputs an error message inviting to add --token argument" do
          expect {
            run_publisher_expecting_exit("--push", "file")
          }.to output(a_string_including("Missing argument --token: you must specify project secret token with --token=<project-token>")).to_stdout
        end
      end

      context "with bad token format" do
        it "outputs an error message that it must be numeric" do
          expect {
            run_publisher_expecting_exit("--token", "abc")
          }.to output(a_string_including("Invalid format --token=\"abc\": the project secret token must be numeric")).to_stdout
        end
      end

      context "with unexisting result file" do
        it "output an error message and stops" do
          unexisting_file = "result_file.tap"
          expect {
            run_publisher_expecting_exit("--token", "123", "--push", unexisting_file)
          }.to output(a_string_including("Error with --push: the file \"result_file.tap\" does not exist or is not readable")).to_stdout
        end
      end

      context "with result file being a directory" do
        it "output an error message and stops" do
          file = output_dir + "/result_file.tap"
          Dir.mkdir(file)
          expect {
            run_publisher_expecting_exit("--token", "123", "--push", file)
          }.to output(a_string_including("Error with --push: the file \"#{file}\" is not a regular file")).to_stdout
        end
      end

      context "with option global_failure_on_missing_reports on" do
        before(:each) {
          stub_request(:post, "https://app.hiptest.com/report_global_failure/123/456/").
            to_return(body: '{"test_import": [{"name": "Simple use", "status": "failed"}]}')
        }

        context "does not raise error when" do
          it "the file is missing" do
            run_publisher_command("--token", "123",
                                  "--test-run-id", "456",
                                  "--push", 'this file does not exist',
                                  '--global-failure-on-missing-reports')
            expect(STDOUT).to have_printed('1 test imported')
          end

          it "there are no matching files" do
            run_publisher_command("--token", "123",
                                  "--test-run-id", "456",
                                  "--push", 'the files * do not exist',
                                  '--global-failure-on-missing-reports')
            expect(STDOUT).to have_printed('1 test imported')
          end
        end
      end
    end

    context "--output-directory" do
      before(:each) {
        stub_request(:get, "https://app.hiptest.com/publication/123/project").
          to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
      }

      context "with unexisting directory with writable parent" do
        it "creates the output directory automatically" do
          unexisting_dir = output_dir + "/some_dir"
          expect {
            run_publisher_command("--token", "123", "--output-directory", unexisting_dir)
          }.to change {
            Dir.exists?(unexisting_dir)
          }.from(false).to(true)
        end

        it "creates the output directory automatically, even if deep" do
          unexisting_dir = output_dir + "/some/dir/deeply/nested"
          expect {
            run_publisher_command("--token", "123", "--output-directory", unexisting_dir)
          }.to change {
            Dir.exists?(unexisting_dir)
          }.from(false).to(true)
        end
      end

      context "with unexisting directory with UNwritable parent" do
        it "output an error message and stops" do
          if Gem.win_platform?
            unwritable_dir = output_dir + '\unwritable'
            FileUtils.mkdir(unwritable_dir)
            FileUtils.chmod("a=rx", unwritable_dir)
            unexisting_dir = unwritable_dir + '\some\dir'
            expected_message = "Error with --output-directory: the directory \"#{unexisting_dir}\" can not be created because \"#{unwritable_dir.gsub('\\', '/')}\" is not writable"
          else
            unexisting_dir = '/usr/lib/some/dir'
            expected_message = 'Error with --output-directory: the directory "/usr/lib/some/dir" can not be created because "/usr/lib" is not writable'
          end

          expect {
            run_publisher_expecting_exit("--token", "123", "--output-directory", unexisting_dir)
          }.to output(a_string_including(expected_message)).to_stdout
        end
      end

      context "with existing but unwritable directory" do
        it "output an error message and stops" do
          if Gem.win_platform?
            unwritable_dir = output_dir + '\unwritable'
            FileUtils.mkdir(unwritable_dir)
            FileUtils.chmod("a=rx", unwritable_dir)
            expected_message = "Error with --output-directory: the directory \"#{unwritable_dir}\" is not writable"
          else
            unwritable_dir = "/usr/lib"
            expected_message = 'Error with --output-directory: the directory "/usr/lib" is not writable'
          end

          expect {
            run_publisher_expecting_exit("--token", "123", "--output-directory", unwritable_dir)
          }.to output(a_string_including(expected_message)).to_stdout
        end
      end

      context "with existing but is not a directory (it's a file)" do
        it "output an error message and stops" do
          file = output_dir + "/some_file"
          FileUtils.touch(file)
          expect {
            run_publisher_expecting_exit("--token", "123", "--output-directory", file)
          }.to output(a_string_including("Error with --output-directory: the file \"#{file}\" is not a directory")).to_stdout
        end
      end

      context "with unexisting xml file" do
        it "output an error message and stops" do
          file = output_dir + "/project.xml"
          expect {
            run_publisher_expecting_exit("--xml-file", file)
          }.to output(a_string_including("Error with --xml-file: the file \"#{file}\" does not exist or is not readable")).to_stdout
        end
      end

      context "with xml file being a directory" do
        it "output an error message and stops" do
          file = output_dir + "/project.xml"
          Dir.mkdir(file)
          expect {
            run_publisher_expecting_exit("--xml-file", file)
          }.to output(a_string_including("Error with --xml-file: the file \"#{file}\" is not a regular file")).to_stdout
        end
      end

      [
        '--show-actionwords-diff',
        '--show-actionwords-deleted',
        '--show-actionwords-created',
        '--show-actionwords-renamed',
        '--show-actionwords-signature-changed',
      ].each do |show_actionword_command|
        context show_actionword_command do
          context "invalid 'actionwords_signature.yaml' file" do
            it "indicates the command to create the actionwords signature file" do
              expect {
                run_publisher_expecting_exit("--token", "123", show_actionword_command, "--output-directory", output_dir)
              }.to output(a_string_including(
                "Use --actionwords-signature to generate the file \"#{output_dir}/actionwords_signature.yaml\"")).to_stdout
            end

            it "outputs an error message and stops (existing directory)" do
              expect {
                run_publisher_expecting_exit("--token", "123", show_actionword_command, "--output-directory", output_dir)
              }.to output(a_string_including(
                "Missing Action Words signature file: the file \"actionwords_signature.yaml\" " \
                "could not be found in directory \"#{output_dir}\"")).to_stdout
            end

            it "outputs an error message and stops (unexisting directory, multiple levels)" do
              unexisting_dir = output_dir + "/some/dir/deeply/nested"
              expect {
                run_publisher_expecting_exit("--token", "123", show_actionword_command, "--output-directory", unexisting_dir)
              }.to output(a_string_including(
                "Missing Action Words signature file: the file \"actionwords_signature.yaml\" " \
                "could not be found in directory \"#{unexisting_dir}\"")).to_stdout
            end

            it "outputs an error message and stops (is a directory)" do
              Dir.mkdir("#{output_dir}/actionwords_signature.yaml")
              expect {
                run_publisher_expecting_exit("--token", "123", show_actionword_command, "--output-directory", output_dir)
              }.to output(a_string_including(
                "Bad Action Words signature file: the file \"#{Pathname.new(output_dir).realpath}/actionwords_signature.yaml\" is a directory")).to_stdout
            end
          end
        end
      end
    end
  end

  describe "--language=seleniumide" do
    def run_publisher_command(*extra_args)
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_return(body: File.read('samples/xml_input/Hiptest publisher.xml'))
      stub_request(:get, "https://app.hiptest.com/publication/123456789/leafless_tests").
        to_return(body: File.read('samples/xml_input/Hiptest automation.xml'))
      args = [
        "--language", "seleniumide",
        "--output-directory", output_dir,
        "--token", "123456789",
      ] + extra_args
      publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
      publisher.run
    end

    it "produces the files as expected" do
      # this is not very representative of how a selenium export should look like...
      run_publisher_command("--leafless-export", "--split-scenarios")
      expect_same_files("samples/expected_output/Hiptest publisher-selenium", output_dir)
    end
  end

  describe "--filename-pattern" do
    # Only works --with-folders
    def run_publisher_command(*extra_args)
      stub_request(:get, "https://app.hiptest.com/publication/123456789/project").
        to_return(body: File.read('samples/xml_input/cash_withdrawal.xml'))
      args = [
        "--language", "javascript",
        "--framework", "mocha",
        "--output-directory", output_dir,
        "--with-folders",
        "--token", "123456789",
      ] + extra_args
      publisher = Hiptest::Publisher.new(args, listeners: [ErrorListener.new])
      publisher.run
    end

    it "works" do
      run_publisher_command("--filename-pattern", "%s.spec.js")
      expect_same_files("samples/expected_output/filename-pattern", output_dir)
    end
  end
end
