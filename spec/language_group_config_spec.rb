require "spec_helper"
require_relative "../lib/hiptest-publisher/options_parser"

describe LanguageGroupConfig do
  include HelperFactories

  let(:root_folder) { make_folder("Import-Export Business") }
  let(:trade_folder) { make_folder("Global trades", parent: root_folder) }

  let(:buy_folder) { make_folder("Buy goods", parent: trade_folder) }
  let(:buy_pontarlier_scenario) { make_scenario("Buy Pontarlier", folder: buy_folder) }

  let(:sell_folder) { make_folder("Sell goods", parent: trade_folder) }
  let(:sell_mont_dor_scenario) { make_scenario("Sell Mont d'Or", folder: sell_folder) }

  let(:loan_folder) { make_folder("Loan goods", parent: root_folder) }

  let(:project) { make_project("Import-Export Business",
    scenarios: [buy_pontarlier_scenario, sell_mont_dor_scenario],
    folders: [root_folder, trade_folder, buy_folder, sell_folder, loan_folder],
  )}

  context "outputing scenarios" do

    context "without --split-scenarios" do
      let(:split_scenarios) { false }

      {
        "java"                => "/ProjectTest.java",
        "java-testng"         => "/ProjectTest.java",
        "javascript"          => "/project_test.js",
        "javascript-jasmine"  => "/project_test.js",
        "javascript-mocha"    => "/project_test.js",
        "python"              => "/test_project.py",
        "robotframework"      => "/project.txt",
        "ruby"                => "/project_spec.rb",
        "ruby-minitest"       => "/project_test.rb",
        "seleniumide"         => "/project.html",
        "csharp"              => "/ProjectTest.cs",
        "php"                 => "/TestProject.php"
      }.each do |dialect, output_file|
        it "for #{dialect} language, it outputs scenarios in file #{output_file}" do
          language, framework = dialect.split("-", 2)
          language_group_config = language_group_config_for(
            only: "tests",
            language: language,
            framework: framework,
            split_scenarios: split_scenarios,
          )
          filenames = language_group_config.each_node_rendering_context(project).map(&:path)
          expect(filenames).to eq([output_file])
        end
      end
    end

    context "with --split-scenarios" do
      let(:split_scenarios) { true }

      {
        "java"                => ["/BuyPontarlierTest.java", "/SellMontDOrTest.java"],
        "java-testng"         => ["/BuyPontarlierTest.java", "/SellMontDOrTest.java"],
        "javascript"          => ["/Buy_Pontarlier_test.js", "/Sell_Mont_dOr_test.js"],
        "javascript-jasmine"  => ["/Buy_Pontarlier_test.js", "/Sell_Mont_dOr_test.js"],
        "javascript-mocha"    => ["/Buy_Pontarlier_test.js", "/Sell_Mont_dOr_test.js"],
        "python"              => ["/test_Buy_Pontarlier.py", "/test_Sell_Mont_dOr.py"],
        "robotframework"      => ["/test_Buy_Pontarlier.txt", "/test_Sell_Mont_dOr.txt"],
        "ruby"                => ["/Buy_Pontarlier_spec.rb", "/Sell_Mont_dOr_spec.rb"],
        "ruby-minitest"       => ["/Buy_Pontarlier_test.rb", "/Sell_Mont_dOr_test.rb"],
        "seleniumide"         => ["/Buy_Pontarlier.html", "/Sell_Mont_dOr.html"],
        "csharp"              => ["/BuyPontarlierTest.cs", "/SellMontDOrTest.cs"],
        "php"                 => ["/Test_Buy_Pontarlier.php", "/Test_Sell_Mont_dOr.php"],
      }.each do |dialect, output_files|
        it "for #{dialect} language, it outputs scenarios in files #{output_files.join(', ')}" do
          language, framework = dialect.split("-", 2)
          language_group_config = language_group_config_for(
            only: "tests",
            language: language,
            framework: framework,
            split_scenarios: split_scenarios,
          )
          filenames = language_group_config.each_node_rendering_context(project).map(&:path)
          expect(filenames).to eq(output_files)
        end
      end
    end

    context "with --split-scenarios --with-folders" do
      let(:split_scenarios) { true }

      {
        "java"                => ["/GlobalTrades/BuyGoods/BuyPontarlierTest.java", "/GlobalTrades/SellGoods/SellMontDOrTest.java"],
        "java-testng"         => ["/GlobalTrades/BuyGoods/BuyPontarlierTest.java", "/GlobalTrades/SellGoods/SellMontDOrTest.java"],
        "javascript"          => ["/Global_trades/Buy_goods/Buy_Pontarlier_test.js", "/Global_trades/Sell_goods/Sell_Mont_dOr_test.js"],
        "javascript-jasmine"  => ["/Global_trades/Buy_goods/Buy_Pontarlier_test.js", "/Global_trades/Sell_goods/Sell_Mont_dOr_test.js"],
        "javascript-mocha"    => ["/Global_trades/Buy_goods/Buy_Pontarlier_test.js", "/Global_trades/Sell_goods/Sell_Mont_dOr_test.js"],
        "python"              => ["/Global_trades/Buy_goods/test_Buy_Pontarlier.py", "/Global_trades/Sell_goods/test_Sell_Mont_dOr.py"],
        "robotframework"      => ["/Global_trades/Buy_goods/test_Buy_Pontarlier.txt", "/Global_trades/Sell_goods/test_Sell_Mont_dOr.txt"],
        "ruby"                => ["/Global_trades/Buy_goods/Buy_Pontarlier_spec.rb", "/Global_trades/Sell_goods/Sell_Mont_dOr_spec.rb"],
        "ruby-minitest"       => ["/Global_trades/Buy_goods/Buy_Pontarlier_test.rb", "/Global_trades/Sell_goods/Sell_Mont_dOr_test.rb"],
        "seleniumide"         => ["/Global_trades/Buy_goods/Buy_Pontarlier.html", "/Global_trades/Sell_goods/Sell_Mont_dOr.html"],
        "csharp"              => ["/GlobalTrades/BuyGoods/BuyPontarlierTest.cs", "/GlobalTrades/SellGoods/SellMontDOrTest.cs"],
        "php"              => ["/Global_trades/Buy_goods/Test_Buy_Pontarlier.php", "/Global_trades/Sell_goods/Test_Sell_Mont_dOr.php"],
      }.each do |dialect, output_files|
        it "for #{dialect} language, it outputs scenarios in files #{output_files.join(', ')}" do
          language, framework = dialect.split("-", 2)
          language_group_config = language_group_config_for(
            only: "tests",
            language: language,
            framework: framework,
            split_scenarios: split_scenarios,
            with_folders: true,
          )
          filenames = language_group_config.each_node_rendering_context(project).map(&:path)
          expect(filenames).to eq(output_files)
        end
      end
    end
  end


  context "outputing feature files" do
    ['cucumber', 'specflow'].each do |language|
      it "with Gherkin language, ignores folder nodes without any scenarios" do
        language_group_config = language_group_config_for(
          only: "features",
          language: language
        )
        nodes = language_group_config.nodes(project)
        # using node names to limit output when test fails
        expect(node_names(nodes)).not_to include(*node_names([root_folder, trade_folder, loan_folder]))
      end
    end

    ['cucumber', 'specflow'].each do |language|
      it "with #{language} language --split-scenarios is forced" do

        language_group_config_splitted = language_group_config_for(
          only: "features",
          language: language,
          split_scenarios: true,
        )
        filenames_splitted = language_group_config_splitted.each_node_rendering_context(project).map(&:path)

        language_group_config_not_splitted = language_group_config_for(
          only: "features",
          language: language,
          split_scenarios: false,
        )
        filenames_not_splitted = language_group_config_not_splitted.each_node_rendering_context(project).map(&:path)

        expect(filenames_not_splitted).to eq(filenames_splitted)
      end
    end

    context "without --with-folders" do
      let(:with_folders) { false }
      let(:output_files) { ["/Buy_goods.feature", "/Sell_goods.feature"] }

      ['cucumber', 'specflow'].each do |language|
        it "for #{language} language, it outputs scenarios in feature files based on the folder" do
          language_group_config = language_group_config_for(
            only: "features",
            language: language,
            with_folders: with_folders,
          )
          filenames = language_group_config.each_node_rendering_context(project).map(&:path)
          expect(filenames).to eq(output_files)
        end
      end
    end

    context "with --with-folders" do
      let(:with_folders) { true }
      let(:output_files) { ["/Global_trades/Buy_goods.feature", "/Global_trades/Sell_goods.feature"] }


      ['cucumber', 'specflow'].each do |language|
        it "for #{language} language, it outputs scenarios in feature files based on the folder" do
          language_group_config = language_group_config_for(
            only: "features",
            language: language,
            with_folders: with_folders,
          )
          filenames = language_group_config.each_node_rendering_context(project).map(&:path)
          expect(filenames).to eq(output_files)
        end
      end
    end
  end

  context "outputing actionwords" do
    {
      "cucumber"            => "/actionwords.rb",
      "java"                => "/Actionwords.java",
      "java-testng"         => "/Actionwords.java",
      "javascript"          => "/actionwords.js",
      "javascript-jasmine"  => "/actionwords.js",
      "javascript-mocha"    => "/actionwords.js",
      "python"              => "/actionwords.py",
      "robotframework"      => "/keywords.txt",
      "ruby"                => "/actionwords.rb",
      "ruby-minitest"       => "/actionwords.rb",
      "seleniumide"         => "/actionwords.html",
      "csharp"              => "/Actionwords.cs",
      "specflow"            => "/Actionwords.cs",
      "php"                 => "/Actionwords.php",
    }.each do |dialect, output_file|
      it "for #{dialect} language, it outputs actionwords in file #{output_file}" do
        language, framework = dialect.split("-", 2)
        language_group_config = language_group_config_for(
          only: "actionwords",
          language: language,
          framework: framework,
        )
        filenames = language_group_config.each_node_rendering_context(project).map(&:path)
        expect(filenames).to eq([output_file])
      end
    end
  end

  def node_names(nodes)
    nodes.map {|n| n.children[:name] }
  end
end
