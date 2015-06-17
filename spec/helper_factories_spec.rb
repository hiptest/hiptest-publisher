require_relative "spec_helper"

describe HelperFactories do
  include HelperFactories

  describe "literal" do
    it "returns a Hiptest::Nodes::StringLiteral for a string" do
      expect(literal("hello")).to eq(Hiptest::Nodes::StringLiteral.new("hello"))
    end

    it "returns a Hiptest::Nodes::NumericLiteral for a float" do
      expect(literal(3.14)).to eq(Hiptest::Nodes::NumericLiteral.new("3.14"))
    end

    it "returns a Hiptest::Nodes::NumericLiteral for an integer" do
      expect(literal(42)).to eq(Hiptest::Nodes::NumericLiteral.new("42"))
    end

    it "returns a Hiptest::Nodes::BooleanLiteral for true and false" do
      expect(literal(true)).to eq(Hiptest::Nodes::BooleanLiteral.new("true"))
      expect(literal(false)).to eq(Hiptest::Nodes::BooleanLiteral.new("false"))
    end

    it "returns a Hiptest::Nodes::NullLiteral for true and false" do
      expect(literal(nil)).to eq(Hiptest::Nodes::NullLiteral.new)
    end

    it "returns itself for a Hiptest::Nodes::Literal" do
      [
        Hiptest::Nodes::StringLiteral.new("hello"),
        Hiptest::Nodes::NumericLiteral.new("3.14"),
        Hiptest::Nodes::NumericLiteral.new("42"),
        Hiptest::Nodes::BooleanLiteral.new("true"),
        Hiptest::Nodes::NullLiteral.new,
      ].each do |literal|
        expect(literal(literal)).to eq(literal)
      end
    end

    it "raises an error for other types" do*
      object = Object.new
      expect{literal(object)}.to raise_error("bad argument #{object}")
    end
  end

  describe "template_of_literals" do
    it "returns a Hiptest::Nodes::Template with chunks being each argument as literal" do
      result = template_of_literals("hello", 3.14, 42, true, false, nil)
      expect(result).to eq(
        Hiptest::Nodes::Template.new([
          Hiptest::Nodes::StringLiteral.new("hello"),
          Hiptest::Nodes::NumericLiteral.new("3.14"),
          Hiptest::Nodes::NumericLiteral.new("42"),
          Hiptest::Nodes::BooleanLiteral.new("true"),
          Hiptest::Nodes::BooleanLiteral.new("false"),
          Hiptest::Nodes::NullLiteral.new,
        ])
      )
    end
  end
end
