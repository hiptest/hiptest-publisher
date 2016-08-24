require_relative "spec_helper"
require_relative "../lib/hiptest-publisher/gherkin_adder"

describe Hiptest::GherkinAdder do
  include HelperFactories

  let(:actionword_name) { "Hello \"name\"" }
  let(:actionword) {
    make_actionword(actionword_name, parameters: [
      make_parameter("name", default: literal("World")),
    ])
  }

  let(:call) {
    make_call(actionword_name, annotation: "given", arguments: [
      make_argument("name", literal("John")),
    ])
  }

  let(:scenario) {
    make_scenario("My scenario", body: [
      call,
    ])
  }

  let(:project) {
    make_project("My project", scenarios: [scenario], actionwords: [actionword])
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
    let(:call) { make_call(actionword_name, annotation: "when") }

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

    shared_examples "generic gherkin annotations" do
      it "uses 'Given' as default annotation in gherkin code" do
        expect(gherkin_annotation).to eq("Given")
      end

      it "uses '* ' as default annotation in gherkin text" do
        expect(gherkin_text).to eq("* I say hello world")
      end
    end

    context "without annotation on call" do
      let(:call) { make_call(actionword_name) }

      include_examples "generic gherkin annotations"
    end

    context "with empty annotation on call" do
      let(:call) { make_call(actionword_name, annotation: "") }

      include_examples "generic gherkin annotations"
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
      let(:call)  { make_call(actionword_name, annotation: "when", arguments: [
          make_argument("hello", literal("Guten tag")),
        ])
      }

      it "keeps the quoted text untouched nevertheless" do
        expect(gherkin_text).to eq("When I say \"hello\"")
        expect(gherkin_pattern).to eq("^I say \"hello\"$")
      end
    end
  end

  context "actionword with one parameter without default value" do
    let(:actionword_name) { "Hello \"name\"" }
    let(:actionword) { make_actionword(actionword_name, parameters: [make_parameter("name")]) }

    it "adds corresponding :gherkin_pattern to Actionword" do
      expect(gherkin_pattern).to eq("^Hello \"(.*)\"$")
    end

    context "called without arguments" do
      let(:call) { make_call(actionword_name, annotation: "and") }

      it "uses empty string as default value for gherkin_text" do
        expect(gherkin_text).to eq("And Hello \"\"")
      end
    end
  end

  context "actionword with one parameter" do
    let(:actionword) {
      make_actionword(actionword_name, parameters: [
        make_parameter("name", default: literal("World")),
      ])
    }

    context "inlined" do
      let(:actionword_name) { "Hello \"name\"" }

      it "adds corresponding :gherkin_pattern to Actionword" do
        expect(gherkin_pattern).to eq("^Hello \"(.*)\"$")
      end

      context "called with a string argument" do
        let(:call) {
          make_call(actionword_name, annotation: "given", arguments: [
            make_argument("name", literal("John")),
          ])
        }

        it "adds corresponding :gherkin_text to Call" do
          expect(gherkin_text).to eq("Given Hello \"John\"")
        end
      end

      context "called with a variable argument" do
        let(:call) {
          make_call(actionword_name, annotation: "given", arguments: [
            make_argument("name", variable("name")),
          ])
        }

        it "adds the variable name enclosed with chevrons <>" do
          expect(gherkin_text).to eq("Given Hello \"<name>\"")
        end
      end

      context "called without arguments" do
        let(:call) { make_call(actionword_name, annotation: "given") }

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
          make_call(actionword_name, annotation: "given", arguments: [
            make_argument("name", literal("John")),
          ])
        }

        it "adds the argument value at the end of the gherkin text" do
          expect(gherkin_text).to eq("Given Hello to all of you \"John\"")
        end
      end

      context "called with a variable argument" do
        let(:call) {
          make_call(actionword_name, annotation: "given", arguments: [
            make_argument("name", variable("name")),
          ])
        }

        it "adds the variable name enclosed with chevrons <>" do
          expect(gherkin_text).to eq("Given Hello to all of you \"<name>\"")
        end
      end

      context "called without arguments" do
        let(:call) { make_call(actionword_name, annotation: "given") }

        it "adds the default value at the end of the gherkin text" do
          expect(gherkin_text).to eq("Given Hello to all of you \"World\"")
        end
      end
    end
  end

  context "actionword with multiple parameters" do
    let(:actionword) {
      make_actionword(actionword_name, parameters: [
        make_parameter("name1", default: literal("Riri")),
        make_parameter("name2", default: literal("Fifi")),
        make_parameter("name3", default: literal("Loulou")),
      ])
    }

    context "inlined" do
      let(:actionword_name) { "Hello \"name1\", \"name2\", \"name3\"" }

      it "adds corresponding :gherkin_pattern to Actionword" do
        expect(gherkin_pattern).to eq("^Hello \"(.*)\", \"(.*)\", \"(.*)\"$")
      end

      context "called with no arguments" do
        let(:call) { make_call(actionword_name, annotation: "given") }

        it "adds :gherkin_text to Call using default parameters values" do
          expect(gherkin_text).to eq("Given Hello \"Riri\", \"Fifi\", \"Loulou\"")
        end
      end

      context "called with all arguments filled" do
        let(:call) {
          make_call(actionword_name, annotation: "given", arguments: [
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
        let(:call) { make_call(actionword_name, annotation: "given") }

        it "adds :gherkin_text to Call using default parameters values at the end" do
          expect(gherkin_text).to eq("Given Hello to all of you \"Riri\" \"Fifi\" \"Loulou\"")
        end
      end

      context "called with all arguments filled" do
        let(:call) {
          make_call(actionword_name, annotation: "given", arguments: [
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
      make_actionword(actionword_name, parameters: [
        make_parameter("name", default: literal("Tom")),
        make_parameter("day", default: literal("Monday")),
        make_parameter("temperature", default: literal("25°C")),
        make_parameter("weather", default: literal("Sunny")),
        # "something" is not a parameter
      ])
    }

    let(:call) {
      make_call(actionword_name, arguments: [
        make_argument("weather", literal("rainy")),
        make_argument("name", literal("Captain obvious")),
        make_argument("something", literal("in the way")), # it's a trap !
      ])
    }

    it "produces the expected :gherkin_pattern" do
      expect(gherkin_pattern).to eq("^good morning \"(.*)\", we are \"(.*)\"\\. Say \"something\"! \"(.*)\" \"(.*)\"$")
    end

    it "produces the expected :gherkin_annotation" do
      expect(gherkin_annotation).to eq("Given")
    end

    it "produces the expected :gherkin_text" do
      expect(gherkin_text).to eq("* good morning \"Captain obvious\", we are \"Monday\". Say \"something\"! \"25°C\" \"rainy\"")
    end
  end

  context "using templated parameters and arguments" do # same, but with templates
    let(:actionword_name) { "good morning \"name\", we are \"day\". Say \"something\"!" }

    let(:actionword) {
      make_actionword(actionword_name, parameters: [
        make_parameter("name", default: template_of_literals("Tom")),
        make_parameter("day", default: template_of_literals("Mon", "day")),
        make_parameter("temperature", default: template_of_literals("25°C")),
        make_parameter("weather", default: template_of_literals("Sunny")),
        # "something" is not a parameter
      ])
    }

    let(:call) {
      make_call(actionword_name, arguments: [
        make_argument("weather", template_of_literals("rainy")),
        make_argument("name", template_of_literals("Captain obvious")),
        make_argument("something", template_of_literals("in the way")), # it's a trap !
      ])
    }

    it "produces the expected :gherkin_pattern" do
      expect(gherkin_pattern).to eq("^good morning \"(.*)\", we are \"(.*)\"\\. Say \"something\"! \"(.*)\" \"(.*)\"$")
    end

    it "produces the expected :gherkin_annotation" do
      expect(gherkin_annotation).to eq("Given")
    end

    it "produces the expected :gherkin_text" do
      expect(gherkin_text).to eq("* good morning \"Captain obvious\", we are \"Monday\". Say \"something\"! \"25°C\" \"rainy\"")
    end
  end

  context "annotation picking with multiple calls" do
    let(:project) {
      make_project("My project", scenarios: [scenario, other_scenario], actionwords: [actionword_hello, actionword_bonjour])
    }
    let(:scenario) { make_scenario("My scenario") }
    let(:other_scenario) { make_scenario("Other scenario") }
    let(:actionword_hello) { make_actionword("Hello") }
    let(:actionword_bonjour) { make_actionword("Bonjour") }


    context "with And annotation" do
      let(:scenario) {
        make_scenario("My scenario", body: [
          make_call(actionword_hello.children[:name], annotation: "when"),
          make_call(actionword_bonjour.children[:name], annotation: "and"),
        ])
      }

      it "picks the last meaningful annotation" do
        expect(actionword_bonjour.children[:gherkin_annotation]).to eq("When")
      end
    end

    context "with And annotation as first step" do
      let(:other_scenario) {
        make_scenario("My scenario", body: [
          make_call(actionword_bonjour.children[:name], annotation: "and"),
        ])
      }

      it "uses 'Given' by default" do
        expect(actionword_bonjour.children[:gherkin_annotation]).to eq("Given")
      end

      context "with another scenario using Then defined before" do
        let(:scenario) {
          make_scenario("My scenario", body: [
            make_call(actionword_hello.children[:name], annotation: "then"),
          ])
        }

        it "uses 'Given' by default" do
          expect(actionword_bonjour.children[:gherkin_annotation]).to eq("Given")
        end
      end
    end

    context "with multiple annotations used for the same actionword" do
      let(:scenario) {
        make_scenario("My scenario", body: [
          make_call(actionword_bonjour.children[:name], annotation: "given"),
          make_call(actionword_bonjour.children[:name], annotation: "when"),
          make_call(actionword_bonjour.children[:name], annotation: "then"),
        ])
      }
      let(:other_scenario) {
        make_scenario("Other scenario", body: [
          make_call(actionword_bonjour.children[:name], annotation: "given"),
          make_call(actionword_bonjour.children[:name], annotation: "then"),
          make_call(actionword_bonjour.children[:name], annotation: "and"),
        ])
      }

      it "uses the one used the most" do
        # in this case, it's then, used three times
        expect(actionword_bonjour.children[:gherkin_annotation]).to eq("Then")
      end
    end

    context "with unused actionword" do
      it "has no annotation (nil)" do
        expect(actionword_bonjour.children[:gherkin_annotation]).to be_nil
      end
    end
  end

  context "action word with special parameters" do
    let(:actionword_name) { "I open \"site\" and see:" }

    let(:actionword) {
      make_actionword(actionword_name, parameters: [
        make_parameter("site"),
        make_parameter("__free_text", default: literal(""))
      ])
    }

    let(:call) {
      make_call(actionword_name, arguments: [
        make_argument("site", literal("Google")),
        make_argument("__free_text", literal("I'm feeling lucky"))
      ])
    }

    it 'does not render the __free_text argument in gherkin_text (the template will do it)' do
      expect(gherkin_text).to eq("* I open \"Google\" and see:")
    end

    it 'does not add a capturing group in the gherkin_pattern for the __free_text argument' do
      expect(gherkin_pattern).to eq("^I open \"(.*)\" and see:$")
    end
  end

  context "call to unknown actionword" do
    let(:call) { make_call("Hi \"name\"", annotation: "given") }

    it "is not handled and behavior is undefined"
  end
end
