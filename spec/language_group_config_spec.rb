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

  context "outputing files" do
    {
      "cucumber" => {
        []                                       => [ "[features]",
                                                      "/buy_goods.feature",
                                                      "/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios"]                    => [ "[features]",
                                                      "/buy_goods.feature",
                                                      "/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--with-folders"]                       => [ "[features]",
                                                      "/global_trades/buy_goods.feature",
                                                      "/global_trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[features]",
                                                      "/global_trades/buy_goods.feature",
                                                      "/global_trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--keep-filenames"]                      => ["[features]",
                                                      "/Buy goods.feature",
                                                      "/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[features]",
                                                      "/Global trades/buy_goods.feature",
                                                      "/Global trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[features]",
                                                      "/Global trades/Buy goods.feature",
                                                      "/Global trades/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ]
      },

      "csharp" => {
        []                                       => [ "[tests]",
                                                      "/ProjectTest.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/BuyPontarlierTest.cs",
                                                      "/SellMontDOrTest.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/GlobalTrades/BuyGoodsTest.cs",
                                                      "/GlobalTrades/SellGoodsTest.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/GlobalTrades/BuyGoods/BuyPontarlierTest.cs",
                                                      "/GlobalTrades/SellGoods/SellMontDOrTest.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy PontarlierTest.cs",
                                                      "/Sell Mont d'OrTest.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/BuyGoodsTest.cs",
                                                      "/Global trades/SellGoodsTest.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goodsTest.cs",
                                                      "/Global trades/Sell goodsTest.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs"
                                                    ]
      },

      "java" => {
        []                                       => [ "[tests]",
                                                      "/ProjectTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/BuyPontarlierTest.java",
                                                      "/SellMontDOrTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/BuyGoodsTest.java",
                                                      "/global_trades/SellGoodsTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/BuyPontarlierTest.java",
                                                      "/global_trades/sell_goods/SellMontDOrTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy PontarlierTest.java",
                                                      "/Sell Mont d'OrTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/BuyGoodsTest.java",
                                                      "/Global trades/SellGoodsTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goodsTest.java",
                                                      "/Global trades/Sell goodsTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ]
      },

      "java-testng" => {
        []                                       => [ "[tests]",
                                                      "/ProjectTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/BuyPontarlierTest.java",
                                                      "/SellMontDOrTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/BuyGoodsTest.java",
                                                      "/global_trades/SellGoodsTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/BuyPontarlierTest.java",
                                                      "/global_trades/sell_goods/SellMontDOrTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy PontarlierTest.java",
                                                      "/Sell Mont d'OrTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/BuyGoodsTest.java",
                                                      "/Global trades/SellGoodsTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goodsTest.java",
                                                      "/Global trades/Sell goodsTest.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ]
      },

      "javascript" => {
        []                                       => [ "[tests]",
                                                      "/project_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/buy_pontarlier_test.js",
                                                      "/sell_mont_d_or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/buy_goods_test.js",
                                                      "/global_trades/sell_goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/buy_pontarlier_test.js",
                                                      "/global_trades/sell_goods/sell_mont_d_or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy Pontarlier_test.js",
                                                      "/Sell Mont d'Or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/buy_goods_test.js",
                                                      "/Global trades/sell_goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goods_test.js",
                                                      "/Global trades/Sell goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ]
      },

      "javascript-jasmine" => {
        []                                       => [ "[tests]",
                                                      "/project_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/buy_pontarlier_test.js",
                                                      "/sell_mont_d_or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/buy_goods_test.js",
                                                      "/global_trades/sell_goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/buy_pontarlier_test.js",
                                                      "/global_trades/sell_goods/sell_mont_d_or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy Pontarlier_test.js",
                                                      "/Sell Mont d'Or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/buy_goods_test.js",
                                                      "/Global trades/sell_goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goods_test.js",
                                                      "/Global trades/Sell goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ]
      },

      "javascript-mocha" => {
        []                                       => [ "[tests]",
                                                      "/project_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/buy_pontarlier_test.js",
                                                      "/sell_mont_d_or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/buy_goods_test.js",
                                                      "/global_trades/sell_goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/buy_pontarlier_test.js",
                                                      "/global_trades/sell_goods/sell_mont_d_or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy Pontarlier_test.js",
                                                      "/Sell Mont d'Or_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/buy_goods_test.js",
                                                      "/Global trades/sell_goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goods_test.js",
                                                      "/Global trades/Sell goods_test.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ]
      },

      "php" => {
        []                                       => [ "[tests]",
                                                      "/ProjectTest.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/BuyPontarlierTest.php",
                                                      "/SellMontDOrTest.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/GlobalTrades/BuyGoodsTest.php",
                                                      "/GlobalTrades/SellGoodsTest.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/GlobalTrades/BuyGoods/BuyPontarlierTest.php",
                                                      "/GlobalTrades/SellGoods/SellMontDOrTest.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy PontarlierTest.php",
                                                      "/Sell Mont d'OrTest.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/BuyGoodsTest.php",
                                                      "/Global trades/SellGoodsTest.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goodsTest.php",
                                                      "/Global trades/Sell goodsTest.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php"
                                                    ]
      },

      "python" => {
        []                                       => [ "[tests]",
                                                      "/test_project.py",
                                                      "[actionwords]",
                                                      "/actionwords.py",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/test_buy_pontarlier.py",
                                                      "/test_sell_mont_d_or.py",
                                                      "[actionwords]",
                                                      "/actionwords.py",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/test_buy_goods.py",
                                                      "/global_trades/test_sell_goods.py",
                                                      "[actionwords]",
                                                      "/actionwords.py",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/test_buy_pontarlier.py",
                                                      "/global_trades/sell_goods/test_sell_mont_d_or.py",
                                                      "[actionwords]",
                                                      "/actionwords.py",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/test_Buy Pontarlier.py",
                                                      "/test_Sell Mont d'Or.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/test_buy_goods.py",
                                                      "/Global trades/test_sell_goods.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/test_Buy goods.py",
                                                      "/Global trades/test_Sell goods.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ]
      },

      "robotframework" => {
        []                                       => ["[tests]",
                                                      "/test_project.txt",
                                                      "[actionwords]",
                                                      "/keywords.txt"
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/test_buy_pontarlier.txt",
                                                      "/test_sell_mont_d_or.txt",
                                                      "[actionwords]",
                                                      "/keywords.txt",
                                                    ],
        ["--with-folders"]                        =>["[tests]",
                                                      "/global_trades/test_buy_goods.txt",
                                                      "/global_trades/test_sell_goods.txt",
                                                      "[actionwords]",
                                                      "/keywords.txt"
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/test_buy_pontarlier.txt",
                                                      "/global_trades/sell_goods/test_sell_mont_d_or.txt",
                                                      "[actionwords]",
                                                      "/keywords.txt",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/test_Buy Pontarlier.txt",
                                                      "/test_Sell Mont d'Or.txt",
                                                      "[actionwords]",
                                                      "/keywords.txt"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/test_buy_goods.txt",
                                                      "/Global trades/test_sell_goods.txt",
                                                      "[actionwords]",
                                                      "/keywords.txt"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/test_Buy goods.txt",
                                                      "/Global trades/test_Sell goods.txt",
                                                      "[actionwords]",
                                                      "/keywords.txt"
                                                    ]
      },

      "ruby" => {
        []                                       => [ "[tests]",
                                                      "/project_spec.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/buy_pontarlier_spec.rb",
                                                      "/sell_mont_d_or_spec.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/buy_goods_spec.rb",
                                                      "/global_trades/sell_goods_spec.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/buy_pontarlier_spec.rb",
                                                      "/global_trades/sell_goods/sell_mont_d_or_spec.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy Pontarlier_spec.rb",
                                                      "/Sell Mont d'Or_spec.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/buy_goods_spec.rb",
                                                      "/Global trades/sell_goods_spec.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goods_spec.rb",
                                                      "/Global trades/Sell goods_spec.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ]
      },

      "ruby-minitest" => {
        []                                       => [ "[tests]",
                                                      "/project_test.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/buy_pontarlier_test.rb",
                                                      "/sell_mont_d_or_test.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--with-folders"]                       => [ "[tests]",
                                                      "/global_trades/buy_goods_test.rb",
                                                      "/global_trades/sell_goods_test.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/global_trades/buy_goods/buy_pontarlier_test.rb",
                                                      "/global_trades/sell_goods/sell_mont_d_or_test.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb",
                                                    ],
        ["--split-scenarios", "--keep-filenames"] => ["[tests]",
                                                      "/Buy Pontarlier_test.rb",
                                                      "/Sell Mont d'Or_test.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[tests]",
                                                      "/Global trades/buy_goods_test.rb",
                                                      "/Global trades/sell_goods_test.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[tests]",
                                                      "/Global trades/Buy goods_test.rb",
                                                      "/Global trades/Sell goods_test.rb",
                                                      "[actionwords]",
                                                      "/actionwords.rb"
                                                    ]
      },

      "seleniumide" => {
        []                                       => [ "[tests]",
                                                      "/project.html",
                                                      "[actionwords]",
                                                      "/actionwords.html",
                                                    ],
        ["--split-scenarios"]                    => [ "[tests]",
                                                      "/Buy_Pontarlier.html",
                                                      "/Sell_Mont_dOr.html",
                                                      "[actionwords]",
                                                      "/actionwords.html",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[tests]",
                                                      "/Global_trades/Buy_goods/Buy_Pontarlier.html",
                                                      "/Global_trades/Sell_goods/Sell_Mont_dOr.html",
                                                      "[actionwords]",
                                                      "/actionwords.html",
                                                    ],
      },

      "specflow" => {
        []                                       => [ "[features]",
                                                      "/BuyGoods.feature",
                                                      "/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--split-scenarios"]                    => [ "[features]",
                                                      "/BuyGoods.feature",
                                                      "/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--with-folders"]                       => [ "[features]",
                                                      "/GlobalTrades/BuyGoods.feature",
                                                      "/GlobalTrades/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[features]",
                                                      "/GlobalTrades/BuyGoods.feature",
                                                      "/GlobalTrades/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs",
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[features]",
                                                      "/Global trades/Buy goods.feature",
                                                      "/Global trades/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.cs",
                                                      "[actionwords]",
                                                      "/Actionwords.cs"
                                                    ]
      },
      "behave" => {
        []                                       => [ "[features]",
                                                      "/buy_goods.feature",
                                                      "/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/steps.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ],
        ["--split-scenarios"]                    => ["[features]",
                                                     "/buy_goods.feature",
                                                     "/sell_goods.feature",
                                                     "[step_definitions]",
                                                     "/steps.py", "[actionwords]",
                                                     "/actionwords.py"
                                                    ],
        ["--with-folders"]                       => [ "[features]",
                                                      "/global_trades/buy_goods.feature",
                                                      "/global_trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/steps.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[features]",
                                                      "/global_trades/buy_goods.feature",
                                                      "/global_trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/steps.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ],
        ["--keep-filenames"]                      => ["[features]",
                                                      "/Buy goods.feature",
                                                      "/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/steps.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[features]",
                                                      "/Global trades/buy_goods.feature",
                                                      "/Global trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/steps.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[features]",
                                                      "/Global trades/Buy goods.feature",
                                                      "/Global trades/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/steps.py",
                                                      "[actionwords]",
                                                      "/actionwords.py"
                                                    ]
      },
      "behat" => {
        []                                       => [ "[features]",
                                                      "/buy_goods.feature",
                                                      "/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/FeatureContext.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                      "[step_definitions_library]"
                                                    ],
        ["--split-scenarios"]                    => [ "[features]",
                                                      "/buy_goods.feature",
                                                      "/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/FeatureContext.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                      "[step_definitions_library]"
                                                    ],
        ["--with-folders"]                       => [ "[features]",
                                                      "/global_trades/buy_goods.feature",
                                                      "/global_trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/FeatureContext.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                      "[step_definitions_library]"
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[features]",
                                                      "/global_trades/buy_goods.feature",
                                                      "/global_trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/FeatureContext.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                      "[step_definitions_library]"
                                                    ],
        ["--keep-filenames"]                      => ["[features]",
                                                      "/Buy goods.feature",
                                                      "/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/FeatureContext.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                      "[step_definitions_library]"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[features]",
                                                      "/Global trades/buy_goods.feature",
                                                      "/Global trades/sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/FeatureContext.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                      "[step_definitions_library]"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[features]",
                                                      "/Global trades/Buy goods.feature",
                                                      "/Global trades/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/FeatureContext.php",
                                                      "[actionwords]",
                                                      "/Actionwords.php",
                                                      "[step_definitions_library]"
                                                    ]
      },
      "cucumber-javascript" => {
        []                                       => [ "[features]",
                                                      "/Buy_goods.feature",
                                                      "/Sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.js",
                                                      "[actionwords]", "/actionwords.js"
                                                    ],
        ["--split-scenarios"]                    => [ "[features]",
                                                      "/Buy_goods.feature",
                                                      "/Sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders"]                       => [ "[features]",
                                                      "/Global_trades/Buy_goods.feature",
                                                      "/Global_trades/Sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[features]",
                                                      "/Global_trades/Buy_goods.feature",
                                                      "/Global_trades/Sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.js",
                                                      "[actionwords]", "/actionwords.js"
                                                    ],
        ["--keep-filenames"]                      => ["[features]",
                                                      "/Buy goods.feature",
                                                      "/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[features]",
                                                      "/Global trades/Buy_goods.feature",
                                                      "/Global trades/Sell_goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[features]",
                                                      "/Global trades/Buy goods.feature",
                                                      "/Global trades/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/step_definitions.js",
                                                      "[actionwords]",
                                                      "/actionwords.js"
                                                    ]
      },
      "jbehave" => {
        []                                       => [ "[stories]",
                                                      "/Buy_goods.story",
                                                      "/Sell_goods.story",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.java",
                                                      "[actionwords]", "/Actionwords.java"
                                                    ],
        ["--split-scenarios"]                    => [ "[stories]",
                                                      "/Buy_goods.story",
                                                      "/Sell_goods.story",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--with-folders"]                       => [ "[stories]",
                                                      "/Global_trades/Buy_goods.story",
                                                      "/Global_trades/Sell_goods.story",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[stories]",
                                                      "/Global_trades/Buy_goods.story",
                                                      "/Global_trades/Sell_goods.story",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.java",
                                                      "[actionwords]", "/Actionwords.java"
                                                    ],
        ["--keep-filenames"]                      => ["[stories]",
                                                      "/Buy goods.story",
                                                      "/Sell goods.story",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[stories]",
                                                      "/Global trades/Buy_goods.story",
                                                      "/Global trades/Sell_goods.story",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[stories]",
                                                      "/Global trades/Buy goods.story",
                                                      "/Global trades/Sell goods.story",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.java",
                                                      "[actionwords]",
                                                      "/Actionwords.java"
                                                    ]
      },
      "cucumber-groovy" => {
        []                                       => [ "[features]",
                                                      "/BuyGoods.feature",
                                                      "/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.groovy",
                                                      "[step_definitions_library]",
                                                      "[actionwords]", "/Actionwords.groovy"
                                                    ],
        ["--split-scenarios"]                    => [ "[features]",
                                                      "/BuyGoods.feature",
                                                      "/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.groovy",
                                                      "[step_definitions_library]",
                                                      "[actionwords]",
                                                      "/Actionwords.groovy"
                                                    ],
        ["--with-folders"]                       => [ "[features]",
                                                      "/global_trades/BuyGoods.feature",
                                                      "/global_trades/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.groovy",
                                                      "[step_definitions_library]",
                                                      "[actionwords]",
                                                      "/Actionwords.groovy"
                                                    ],
        ["--split-scenarios", "--with-folders"]  => [ "[features]",
                                                      "/global_trades/BuyGoods.feature",
                                                      "/global_trades/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.groovy",
                                                      "[step_definitions_library]",
                                                      "[actionwords]", "/Actionwords.groovy"
                                                    ],
        ["--keep-filenames"]                      => ["[features]",
                                                      "/Buy goods.feature",
                                                      "/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.groovy",
                                                      "[step_definitions_library]",
                                                      "[actionwords]",
                                                      "/Actionwords.groovy"
                                                    ],
        ["--with-folders", "--keep-foldernames"]  => ["[features]",
                                                      "/Global trades/BuyGoods.feature",
                                                      "/Global trades/SellGoods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.groovy",
                                                      "[step_definitions_library]",
                                                      "[actionwords]",
                                                      "/Actionwords.groovy"
                                                    ],
        ["--with-folders", "--keep-filenames", "--keep-foldernames"]  => [
                                                      "[features]",
                                                      "/Global trades/Buy goods.feature",
                                                      "/Global trades/Sell goods.feature",
                                                      "[step_definitions]",
                                                      "/StepDefinitions.groovy",
                                                      "[step_definitions_library]",
                                                      "[actionwords]",
                                                      "/Actionwords.groovy"
                                                    ]
      },
    }.each do |dialect, output_files_for_options|
      context dialect do
        output_files_for_options.each do |options, output_files|
          it "with #{options.join(' ')}: outputs in files #{output_files}" do
            language, framework = dialect.split("-", 2)
            args = options
            args += ["--output-directory", "/"]
            args += ["--language", language]
            args += ["--framework", framework] if framework
            cli_options = OptionsParser.parse(args, error_reporter)
            cli_options.normalize!
            language_config = LanguageConfigParser.new(cli_options)
            filenames = []
            language_config.language_group_configs.each do |language_group_config|
              next if ['library', 'libraries'].include?(language_group_config[:group_name])

              filenames << "[#{language_group_config[:group_name]}]"
              filenames << language_group_config.each_node_rendering_context(project).map(&:path)
            end
            filenames.flatten!

            expect(filenames).to eq(output_files)
          end
        end
      end
    end
  end


  context "outputing feature files" do
    ['cucumber', 'specflow', 'behave', 'behat'].each do |language|
      it "with Gherkin language, ignores folder nodes without any scenarios" do
        language_group_config = language_group_config_for(
          only: "features",
          language: language
        )
        nodes = language_group_config.nodes(project)
        # using node names to limit output when test fails
        expect(node_names(nodes)).not_to include(*node_names([root_folder, trade_folder, loan_folder]))
      end

      it "with Gherkin language, export folder nodes without any scenarios if --empty-folders is specified" do
        language_group_config = language_group_config_for(
          only: "features",
          language: language,
          empty_folders: true
        )
        nodes = language_group_config.nodes(project)
        # using node names to limit output when test fails
        expect(node_names(nodes)).to include(*node_names([root_folder, trade_folder, loan_folder, sell_folder, buy_folder]))
      end
    end

    ['cucumber', 'specflow', 'behave', 'behat'].each do |language|
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
  end

  def node_names(nodes)
    nodes.map {|n| n.children[:name] }
  end
end
