require 'pry'

require_relative 'spec_helper'
require_relative '../lib/hiptest-publisher/handlebars'

describe Hiptest::Handlebars do
  context 'HandlebarsParser' do
    it 'does stuff' do
      parser = Hiptest::Handlebars::HandlebarsParser.new
      binding.pry
    end
  end

  context 'Context' do
    let(:ctx) { Hiptest::Handlebars::Context.new }

    it 'renders simple templates' do
      expect(ctx.compile("Hello world").call).to eq("Hello world")
    end

    it 'supports templates with parameters' do
      expect(ctx.compile("Hello {{name}}").call(name: "Mr. Anderson")).to eq("Hello Mr. Anderson")
    end

    it 'can handle simple partials' do
      ctx.register_partial('plic', "Plic")
      expect(ctx.compile("Hello {{> plic}}").call).to eq("Hello Plic")
    end

    it 'can handle partials using parameters' do
      ctx.register_partial('brackets', "[{{name}}]")
      expect(ctx.compile("Hello {{> brackets}}").call(name: 'world')).to eq("Hello [world]")
    end

    context 'helpers' do
      # Those examples come from Handlebars.rb specs
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
        expect(t.call(:weather => {:summary => "sunny"})).to eq("it's so *sunny*!")
      end

      it "doesn't nee a context or arguments to the call" do
        t = ctx.compile("{{#twice}}Hurray!{{/twice}}")
        expect(t.call).to eq("Hurray!Hurray!")
      end
    end
  end
  context 'Template'
end