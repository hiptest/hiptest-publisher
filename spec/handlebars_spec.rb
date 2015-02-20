require 'pry'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/handlebars'

describe Hiptest::Handlebars do
  context 'Context' do
    context 'Complete use' do
      let(:ctx) { Hiptest::Handlebars::Context.new }

      it 'renders simple templates' do
        expect(ctx.compile("Hello world").call).to eq("Hello world")
      end

      it 'supports templates with parameters' do
        expect(ctx.compile("Hello {{name}}").call(name: "Mr. Anderson")).to eq("Hello Mr. Anderson")
      end

      it 'can handle simple partials' do
        binding.pry
        ctx.register_partial('plic', "Plic")
        expect(ctx.compile("Hello {{> plic}}").call).to eq("Hello Plic")
      end

      context 'helpers' do
        before do
          ctx.register_helper('alsowith') do |this, context, block|
            block.fn(context)
          end

          ctx.register_helper(:twice) do |this, block|
            "#{block.fn}#{block.fn}"
          end
        end

        it "correctly passes context and implementation" do
          t = ctx.compile("it's so {{#alsowith weather}}*{{summary}}*{{/alsowith}}!")
          t.call(:weather => {:summary => "sunny"}).should eql "it's so *sunny*!"
        end

        it "doesn't nee a context or arguments to the call" do
          t = ctx.compile("{{#twice}}Hurray!{{/twice}}")
          t.call.should eql "Hurray!Hurray!"
        end
      end
    end
  end
  context 'Template'
end