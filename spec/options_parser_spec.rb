require "spec_helper"
require_relative "../lib/hiptest-publisher/options_parser"
require_relative "../lib/hiptest-publisher/formatters/reporter"

describe OptionParser do

  context "with config file" do
    it "merges options from config file" do
      f = Tempfile.new('config')
      File.write(f, "language = java")
      options = OptionsParser.parse([
                                      "--config-file", f.path], NullReporter.new)
      expect(options.language).to eq("java")
    end

    it "does not overwrite an option already defined on cli" do
      f = Tempfile.new('config')
      File.write(f, "language = java\nframework = tartanpion")
      options = OptionsParser.parse([
                                      "--language", "ruby",
                                      "--config-file", f.path], NullReporter.new)
      expect(options.language).to eq("ruby")
      expect(options.framework).to eq("tartanpion")
    end

    it "understands 'false', 'no', '0', etc. as boolean false" do
      f = Tempfile.new('config')
      %w"false False FaLsE no 0 NO".each do |falsy_value|
        File.write(f,
                   "with_folders = #{falsy_value}\n" +
                     "split_scenarios = plop#{falsy_value}plop")
        options = OptionsParser.parse([
                                        "--config-file", f.path], NullReporter.new)
        expect(options.with_folders).to eq(false), "'#{falsy_value}' in config file should be interpreted as boolean false"
        expect(options.split_scenarios).not_to eq(false), "value containing '#{falsy_value}' in config file should not be interpreted as boolean false"
      end
    end

    it "understands all combinations of no_uids/uids = true/false" do
      f = Tempfile.new('config')
      File.write(f, "no_uids = true")
      options = OptionsParser.parse(["--config-file", f.path], Reporter.new([ErrorListener.new]))
      expect(options.uids).to be_falsy

      File.write(f, "no_uids = false")
      options = OptionsParser.parse(["--config-file", f.path], Reporter.new([ErrorListener.new]))
      expect(options.uids).to be_truthy

      File.write(f, "uids = true")
      options = OptionsParser.parse(["--config-file", f.path], Reporter.new([ErrorListener.new]))
      expect(options.uids).to be_truthy

      File.write(f, "uids = false")
      options = OptionsParser.parse(["--config-file", f.path], Reporter.new([ErrorListener.new]))
      expect(options.uids).to be_falsy
    end

    it "works if config file is nil" do
      options = CliOptions.new
      options.config = nil
      expect {FileConfigParser.update_options(options, NullReporter.new)}.not_to raise_error
    end

    it "resolves the real path relative to config file" do
      f = Tempfile.new('config')

      File.write(f, "overriden_templates = ./templates")
      options = OptionsParser.parse(["--config-file", f.path], Reporter.new([ErrorListener.new]))
      expect(Pathname.new(options.overriden_templates).absolute?).to be true
      expect(options.overriden_templates).to eq(File.join(File.dirname(f.path), 'templates'))

      File.write(f, "output_directory = ./tests")
      options = OptionsParser.parse(["--config-file", f.path], Reporter.new([ErrorListener.new]))
      expect(Pathname.new(options.output_directory).absolute?).to be true
      expect(options.output_directory).to eq(File.join(File.dirname(f.path), 'tests'))
    end

    it 'does not resolves the path if the given path is absolute' do
      f = Tempfile.new('config')

      File.write(f, "overriden_templates = /home/user/hps/robot/templates")
      options = OptionsParser.parse(["--config-file", f.path], Reporter.new([ErrorListener.new]))
      expect(options.overriden_templates).to eq("/home/user/hps/robot/templates")
    end
  end

  it "does not resolve paths if the value does not come from config file" do
    options = OptionsParser.parse(["--overriden-templates=./templates", "--output-directory=./tests"], NullReporter.new)
    expect(options.overriden_templates).to eq('./templates')
    expect(options.output_directory).to eq('./tests')
  end

  it "recognizes --no-uids correctly" do
    options = OptionsParser.parse(["--no-uids"], NullReporter.new)
    expect(options.uids).to be(false)
  end
end


describe CliOptions do
  describe "#normalize!" do
    it "replaces --actionwords-only by --only=actionwords" do
      options = CliOptions.new(actionwords_only: true)

      options.normalize!

      expect(options.only).to eq("actionwords")
    end

    it "replaces --tests-only by --only=tests" do
      options = CliOptions.new(tests_only: true)

      options.normalize!

      expect(options.only).to eq("tests")
    end

    it "adds the framework of the language when framework is missing" do
      options = CliOptions.new(language: "cucumber")

      options.normalize!

      expect(options.framework).to eq("ruby")
    end

    it "sets the framework to '' if cannot find the language when framework is missing" do
      options = CliOptions.new(language: "gloubiboulga")

      options.normalize!

      expect(options.framework).to eq("")
    end

    it "splits <language>-<framework> into language and framework values" do
      options = CliOptions.new(language: "ruby-rspec")

      options.normalize!

      expect(options.language).to eq("ruby")
      expect(options.framework).to eq("rspec")
    end

    it "returns the modified keys" do
      options = CliOptions.new(language: "ruby-rspec")

      expect(options.normalize!).to eq({
                                         language: "ruby",
                                         framework: "rspec",
                                       })
    end

    it "returns falsy if nothing modified" do
      options = CliOptions.new

      expect(options.normalize!).to be_nil
    end

    it "adds context.no_uids for compatibility" do
      options = CliOptions.new(uids: true)
      options.normalize!
      expect(options.no_uids).to be(false)
      options = CliOptions.new(uids: false)
      options.normalize!
      expect(options.no_uids).to be(true)
    end

    context 'without' do
      it 'replaces --without=actionwords by --only=tests in classic frameworks' do
        options = CliOptions.new(language: 'ruby', without: 'actionwords')
        options.normalize!

        expect(options.only).to eq("tests")
      end

      it 'replaces --without=actionwords by --only=features,step_definitions in Gherkin frameworks' do
        options = CliOptions.new(language: 'cucumber', without: 'actionwords')
        options.normalize!

        expect(options.only).to eq("features,step_definitions")
      end

      context 'basically makes only with all options excepted the specified ones' do
        it 'works with classic test frameworks' do
          options = CliOptions.new(language: 'ruby', without: 'tests')
          options.normalize!

          expect(options.only).to eq("actionwords")
        end

        context 'works with Gherkin based frameworks' do
          it 'can exclude the steps definitions (why ?)' do
            options = CliOptions.new(language: 'cucumber', without: 'features')
            options.normalize!

            expect(options.only).to eq("step_definitions,actionwords")
          end

          it 'can exclude both features and step definitions' do
            options = CliOptions.new(language: 'cucumber', without: 'features,step_definitions')
            options.normalize!

            expect(options.only).to eq("actionwords")
          end
        end
      end
    end
  end

  describe '#command_line_used' do
    it 'displays the command line used' do
      options = OptionsParser.parse(["-l", "ruby", "--only", "actionwords"], NullReporter.new)
      expect(options.command_line_used).to eq('hiptest-publisher --language=ruby --only=actionwords')
    end

    it 'does not include options from the config file or default ones' do
      options = OptionsParser.parse(["-c", "hiptest-publisher.conf"], NullReporter.new)
      expect(options.command_line_used).to eq('hiptest-publisher --config=hiptest-publisher.conf')
    end

    it 'can exclude some of the options' do
      options = OptionsParser.parse(["-l", "ruby", "-f", "minitest", "--only", "actionwords"], NullReporter.new)
      expect(options.command_line_used(exclude: [:only, :language])).to eq('hiptest-publisher --framework=minitest')
    end

    it 'does not leave and ugly white-space at the end' do
      options = OptionsParser.parse(["-l", "ruby"], NullReporter.new)
      expect(options.command_line_used(exclude: [:language])).to eq('hiptest-publisher')
    end
  end
end


describe NodeRenderingContext do
  subject(:node_rendering_context) do
    NodeRenderingContext.new(
      path: '/output/directory/features/cart/payment/pay_by_credit_card.feature',
      relative_path: 'cart/payment/pay_by_credit_card.feature',
    # other options not detailed here...
    )
  end

  describe '#folder' do
    it 'returns the absolute folder to the file' do
      expect(node_rendering_context.folder).to eq('/output/directory/features/cart/payment')
    end
  end

  describe '#relative_folder' do
    it 'returns the folder to the file relative to the output directory' do
      expect(node_rendering_context.relative_folder).to eq('cart/payment')
    end
  end
end


describe LanguageConfigParser do

  let(:options) {CliOptions.new(language: "ruby").tap {|options| options.normalize!}}

  describe "#filtered_group_names" do
    it "rejects groups not specified in --only clip option" do
      options = CliOptions.new(language: "ruby", only: "actionwords")
      options.normalize!
      expect(LanguageConfigParser.new(options).filtered_group_names).to match_array(["actionwords"])

      options = CliOptions.new(language: "ruby", only: "actionwords,tests")
      options.normalize!
      expect(LanguageConfigParser.new(options).filtered_group_names).to match_array(["actionwords", "tests"])
    end

    it "keeps all groups if --only option is not specified" do
      options = CliOptions.new(language: "ruby")
      options.normalize!
      expect(LanguageConfigParser.new(options).filtered_group_names).to match_array(["actionwords", "tests"])
    end
  end

  describe ".config_path_for" do
    context "given a language" do
      it "searches an language configuration file in lib/config/<language>-<first framework>.conf" do
        expect(LanguageConfigParser.config_path_for(options)).to end_with("lib/config/ruby-rspec.conf")
      end

      it "searches an language configuration file in lib/config/<language>.conf if no frameworks for the language" do
        options = CliOptions.new(language: "robotframework")
        options.normalize!
        expect(LanguageConfigParser.config_path_for(options)).to end_with("lib/config/robotframework.conf")
      end
    end

    context "given a language and a framework" do
      it "searches an language configuration file in lib/config/<language>-<framework>" do
        options.framework = "minitest"
        expect(LanguageConfigParser.config_path_for(options)).to end_with("lib/config/ruby-minitest.conf")
      end

      it "fails if framework does not no match anything" do
        options.framework = "youplala"
        expect {LanguageConfigParser.config_path_for(options)}.
          to raise_error('cannot find configuration file in "./lib/config" for language "ruby" and framework "youplala"')
      end
    end

    it "raises an error if language config file could not be found" do
      options.language = "carakoko"
      options.framework = "lalakoko"
      expect {LanguageConfigParser.config_path_for(options)}.
        to raise_error('cannot find configuration file in "./lib/config" for language "carakoko" and framework "lalakoko"')
    end
  end

  describe "#new" do
    it "returns the LanguageConfigParser for given options" do
      expect(LanguageConfigParser.new(options)).to be_a LanguageConfigParser
    end

    it "raises an error if language config file cannot be found" do
      options = CliOptions.new(language: "carakoko")
      options.normalize!
      expect {LanguageConfigParser.new(options)}.
        to raise_error('cannot find configuration file in "./lib/config" for language "carakoko"')
    end
  end

  describe "#language_group_configs" do
    let(:step_definitions_path) {'/path/step_definitions_output'}
    let(:actionwords_output_directory) {'/path/actionwords_output'}

    let(:cli_options) do
      options = CliOptions.new(language: "behat").tap {|options| options.normalize!}
      options.step_definitions_output_directory = step_definitions_path
      options.actionwords_output_directory = actionwords_output_directory
      options
    end

    let(:languageConfigParser) do
      lcp = LanguageConfigParser.new(cli_options)
      allow(lcp).to receive(:filtered_group_names) {["step_definitions"]}
      lcp
    end

    it "must copy the step_definitions_output_directory content to step_definitions_library_output_directory" do
      languageConfigParser.language_group_configs

      expect(cli_options.step_definitions_library_output_directory).to eq(step_definitions_path)
    end

    it "must copy the actionwords_output_directory content to libraries_output_directory" do
      languageConfigParser.language_group_configs

      expect(cli_options.libraries_output_directory).to eq(actionwords_output_directory)
    end

    it "must copy the actionwords_output_directory content to library_output_directory" do
      languageConfigParser.language_group_configs

      expect(cli_options.library_output_directory).to eq(actionwords_output_directory)
    end
  end
end

describe LanguageGroupConfig do
  context "shorten_filename" do
    let(:options) {CliOptions.new(split_scenarios: true, filename_pattern: "%s_spec.rb").tap {|options| options.normalize!}}
    let(:config) {LanguageGroupConfig.new(options)}

    it "truncates file name when its length exceeds 255 character" do
      filename = 'Hiptest_is_a_collaborative_testing_platform_in_the_cloud_that_allows_the_software_delivery_team_to_codesign_acceptance_tests_It_provides_a_realtime_environment_for_designing_executing_and_refactoring_tests_Ultimately_Hiptest_enables_to automate_tests_that_become_the_living_specification_of_your_Apps'
      shorten_filename = config.shorten_filename(filename)
      filename_md5 = Digest::MD5.hexdigest(filename)

      expect(shorten_filename.length).to eq(247) # 255 - 8 (the length of "_spec.rb")
      expect(shorten_filename).to eq("Hiptest_is_a_collaborative_testing_platform_in_the_cloud_that_allows_the_software_delivery_team_to_codesign_acceptance_tests_It_provides_a_realtime_environment_for_designing_executing_and_refactoring_tests_Ultimatel#{filename_md5}")
    end

    it "maintains file name when its length is lower than 255 character" do
      shorten_filename = config.shorten_filename('My_Scenario')

      expect(shorten_filename).to eq("My_Scenario")
    end
  end
end
