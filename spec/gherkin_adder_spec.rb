require_relative "spec_helper"
require_relative "../lib/hiptest-publisher/gherkin_adder"

describe Hiptest::GherkinAdder do
  include HelperFactories

  let(:actionword_name) { "Hello \"name\"" }
  let(:actionword) {
    make_actionword(actionword_name, [], [
      make_parameter("name", literal("World")),
    ])
  }

  let(:call) {
    make_annotated_call("given", actionword_name, [
      make_argument("name", literal("John")),
    ])
  }

  let(:scenario) {
    make_scenario("My scenario", [], [], [
      call,
    ])
  }

  let(:scenarios) { [scenario] }
  let(:actionwords) { [actionword] }
  let(:tests) { [] }
  let(:project) {
    make_project("My project", scenarios, tests, actionwords)
  }

  subject(:gherkin_text) { call.children[:gherkin_text] }
  subject(:gherkin_annotation) { actionword.children[:gherkin_annotation] }
  subject(:gherkin_pattern) { actionword.children[:gherkin_pattern] }

  before(:each) {
    Hiptest::GherkinAdder.add(project)
  }

  context "actionword without parameters" do
    let(:actionword_name) { "I say hello world" }
    let(:actionword) { make_actionword(actionword_name) }
    let(:call) { make_annotated_call("when", actionword_name) }

    it "adds the corresponding :gherkin_text to Call" do
      Hiptest::GherkinAdder.add(project)
      expect(call.children[:gherkin_text]).to eq("When I say hello world")
    end

    it "adds the corresponding :gherkin_annotation to Actionword" do
      Hiptest::GherkinAdder.add(project)
      expect(actionword.children[:gherkin_annotation]).to eq("When")
    end

    it "adds the corresponding :gherkin_pattern to Actionword" do
      Hiptest::GherkinAdder.add(project)
      expect(actionword.children[:gherkin_pattern]).to eq("^I say hello world$")
    end

    context "with actionword name containing with regex reserved characters" do
      let(:actionword_name) { "Nom. de. Zeués... [|]\\+*?()$^ Marty!?" }

      it "escapes the characters in the :gherkin_pattern" do
        expect(gherkin_pattern).to eq("^Nom\\. de\\. Zeués\\.\\.\\. \\[\\|\\]\\\\\\+\\*\\?\\(\\)\\$\\^ Marty!\\?$")
      end
    end

    context "with actionword name containing with regex reserved characters" do
      let(:actionword_name) { "hello\\world" }

      it "escapes the characters in the :gherkin_pattern" do
        expect(gherkin_pattern).to eq("^hello\\\\world$")
      end
    end

    context "without annotation on call" do
      let(:call) { make_call(actionword_name) }

      it "uses 'Given' as default annotation" do
        expect(gherkin_text).to eq("Given I say hello world")
        expect(gherkin_annotation).to eq("Given")
      end
    end

    context "with empty annotation on call" do
      let(:call) { make_annotated_call("", actionword_name) }

      it "uses 'Given' as default annotation" do
        expect(gherkin_text).to eq("Given I say hello world")
        expect(gherkin_annotation).to eq("Given")
      end
    end

    context "with 1 quote in its name" do
      let(:actionword_name) { "I say \"hello world" }

      it "keeps the quoted text untouched" do
        expect(gherkin_text).to eq("When I say \"hello world")
        expect(gherkin_pattern).to eq("^I say \"hello world$")
      end
    end

    context "with 2 quotes in its name" do
      let(:actionword_name) { "I say \"hello world\"" }

      it "keeps the quoted text untouched" do
        expect(gherkin_text).to eq("When I say \"hello world\"")
        expect(gherkin_pattern).to eq("^I say \"hello world\"$")
      end
    end

    context "but with quoted text, and with a call having a matching argument (which is invalid because actionword has no parameters)" do
      let(:actionword_name) { "I say \"hello\"" }
      let(:call)  { make_annotated_call("when", actionword_name, [
          make_argument("hello", literal("Guten tag")),
        ])
      }

      it "keeps the quoted text untouched nevertheless" do
        expect(gherkin_text).to eq("When I say \"hello\"")
        expect(gherkin_pattern).to eq("^I say \"hello\"$")
      end
    end
  end

  context "actionword with one parameter without default value and called without parameters" do
    let(:actionword_name) { "Hello \"name\"" }
    let(:actionword) { make_actionword(actionword_name, [], [make_parameter("name")]) }

    it "adds corresponding :gherkin_pattern to Actionword" do
      expect(gherkin_pattern).to eq("^Hello \"(.*)\"$")
    end

    context "called without parameters" do
      let(:call) { make_annotated_call("and", actionword_name) }

      it "uses empty string as default value for gherkin_text" do
        expect(gherkin_text).to eq("And Hello \"\"")
      end
    end
  end

  context "actionword with one parameter" do
    let(:actionword) {
      make_actionword(actionword_name, [], [
        make_parameter("name", literal("World")),
      ])
    }

    context "inlined" do
      let(:actionword_name) { "Hello \"name\"" }

      it "adds corresponding :gherkin_pattern to Actionword" do
        expect(gherkin_pattern).to eq("^Hello \"(.*)\"$")
      end

      context "called with an argument" do
        let(:call) {
          make_annotated_call("given", actionword_name, [
            make_argument("name", literal("John")),
          ])
        }

        it "adds corresponding :gherkin_text to Call" do
          expect(gherkin_text).to eq("Given Hello \"John\"")
        end
      end

      context "called without parameters" do
        let(:call) { make_annotated_call("given", actionword_name) }

        it "uses the default value of the actionword parameter" do
          expect(gherkin_text).to eq("Given Hello \"World\"")
        end
      end
    end

    context "not inlined" do
      let(:actionword_name) { "Hello to all of you" }

      it "adds corresponding :gherkin_pattern to Actionword" do
        expect(gherkin_pattern).to eq("^Hello to all of you \"(.*)\"$")
      end

      context "called with an argument" do
        let(:call) {
          make_annotated_call("given", actionword_name, [
            make_argument("name", literal("John")),
          ])
        }

        it "adds the argument value at the end of the gherkin text" do
          expect(gherkin_text).to eq("Given Hello to all of you \"John\"")
        end
      end

      context "called without parameters" do
        let(:call) { make_annotated_call("given", actionword_name) }

        it "adds the default value at the end of the gherkin text" do
          expect(gherkin_text).to eq("Given Hello to all of you \"World\"")
        end
      end
    end
  end

  context "actionword with multiple parameters" do
    let(:actionword) {
      make_actionword(actionword_name, [], [
        make_parameter("name1", literal("Riri")),
        make_parameter("name2", literal("Fifi")),
        make_parameter("name3", literal("Loulou")),
      ])
    }

    context "inlined" do
      let(:actionword_name) { "Hello \"name1\", \"name2\", \"name3\"" }

      it "adds corresponding :gherkin_pattern to Actionword" do
        expect(gherkin_pattern).to eq("^Hello \"(.*)\", \"(.*)\", \"(.*)\"$")
      end

      context "called with no arguments" do
        let(:call) { make_annotated_call("given", actionword_name) }

        it "adds :gherkin_text to Call using default parameters values" do
          expect(gherkin_text).to eq("Given Hello \"Riri\", \"Fifi\", \"Loulou\"")
        end
      end

      context "called with all arguments filled" do
        let(:call) {
          make_annotated_call("given", actionword_name, [
            # unordered, just to see if it works
            make_argument("name2", literal("Paul")),
            make_argument("name3", literal("Jacques")),
            make_argument("name1", literal("Pierre")),
          ])
        }

        it "adds :gherkin_text to Call using call arguments values" do
          expect(gherkin_text).to eq("Given Hello \"Pierre\", \"Paul\", \"Jacques\"")
        end
      end
    end

    context "not inlined" do
      let(:actionword_name) { "Hello to all of you" }

      it "adds corresponding :gherkin_pattern to Actionword" do
        expect(gherkin_pattern).to eq("^Hello to all of you \"(.*)\" \"(.*)\" \"(.*)\"$")
      end

      context "called with no arguments" do
        let(:call) { make_annotated_call("given", actionword_name) }

        it "adds :gherkin_text to Call using default parameters values at the end" do
          expect(gherkin_text).to eq("Given Hello to all of you \"Riri\" \"Fifi\" \"Loulou\"")
        end
      end

      context "called with all arguments filled" do
        let(:call) {
          make_annotated_call("given", actionword_name, [
            # unordered, just to see if it works
            make_argument("name2", literal("Paul")),
            make_argument("name3", literal("Jacques")),
            make_argument("name1", literal("Pierre")),
          ])
        }

        it "adds :gherkin_text to Call and appends call arguments values in the order defined by the actionword" do
          expect(gherkin_text).to eq("Given Hello to all of you \"Pierre\" \"Paul\" \"Jacques\"")
        end
      end
    end
  end

  context "actionword with mixed cases" do
    let(:actionword_name) { "good morning \"name\", we are \"day\". Say \"something\"!" }

    let(:actionword) {
      make_actionword(actionword_name, [], [
        make_parameter("name", literal("Tom")),
        make_parameter("day", literal("Monday")),
        make_parameter("temperature", literal("25°C")),
        make_parameter("weather", literal("Sunny")),
        # "something" is not a parameter
      ])
    }

    let(:call) {
      make_call(actionword_name, [
        make_argument("weather", literal("rainy")),
        make_argument("name", literal("Captain obvious")),
        make_argument("something", literal("in the way")), # it's a trap !
      ])
    }

    it "produces the expected :gherkin_pattern" do
      expect(gherkin_pattern).to eq("^good morning \"(.*)\", we are \"(.*)\"\\. Say \"something\"! \"(.*)\" \"(.*)\"$")
    end

    it "produces the expected :gherkin_text" do
      expect(gherkin_text).to eq("Given good morning \"Captain obvious\", we are \"Monday\". Say \"something\"! \"25°C\" \"rainy\"")
    end
  end

  context "using templated parameters and arguments" do # same, but with templates
    let(:actionword_name) { "good morning \"name\", we are \"day\". Say \"something\"!" }

    let(:actionword) {
      make_actionword(actionword_name, [], [
        make_parameter("name", template_of_literals("Tom")),
        make_parameter("day", template_of_literals("Mon", "day")),
        make_parameter("temperature", template_of_literals("25°C")),
        make_parameter("weather", template_of_literals("Sunny")),
        # "something" is not a parameter
      ])
    }

    let(:call) {
      make_call(actionword_name, [
        make_argument("weather", template_of_literals("rainy")),
        make_argument("name", template_of_literals("Captain obvious")),
        make_argument("something", template_of_literals("in the way")), # it's a trap !
      ])
    }

    it "produces the expected :gherkin_pattern" do
      expect(gherkin_pattern).to eq("^good morning \"(.*)\", we are \"(.*)\"\\. Say \"something\"! \"(.*)\" \"(.*)\"$")
    end

    it "produces the expected :gherkin_text" do
      expect(gherkin_text).to eq("Given good morning \"Captain obvious\", we are \"Monday\". Say \"something\"! \"25°C\" \"rainy\"")
    end
  end


  context "call to unknown actionword" do
    let(:call) { make_annotated_call("given", "Hi \"name\"") }

    it "is not handled and behavior is undefined"
  end
end
