require 'pp'
require 'parslet'

module Hiptest
  module Handlebars
    class HandlebarsParser < Parslet::Parser
      rule(:space)       { match('\s').repeat(1) }
      rule(:space?)      { space.maybe }
      rule(:dot)         { str('.') }
      rule(:ocurly)      { str('{')}
      rule(:ccurly)      { str('}')}

      rule(:identifier)  { match['a-zA-Z0-9_'].repeat(1) }
      rule(:path)        { identifier >> (dot >> identifier).repeat }

      rule(:replacement) { ocurly >> ocurly >> space? >> path.as(:item) >> space? >> ccurly >> ccurly}
      rule(:safe_replacement) { ocurly >> replacement >> ccurly }

      rule(:noise) { match('[^{}]').repeat(1).as(:content) }

      rule(:block) { (noise | replacement | safe_replacement).repeat }

      root :block
    end

    class Context
      attr_reader :js, :partials, :helpers

      def initialize
        src = File.open(::Handlebars::Source.bundled_path, 'r').read
        @js = ExecJS.compile(src)

        @partials = {}
        @helpers = {}
      end

      def compile(*args)
        Hiptest::Handlebars::Template.new(self, *args)
      end

      def register_helper(name, &fn)
        @helpers[name] = fn
      end

      def register_partial(name, content)
        @partials[name] = content
      end
    end

    class Template
      def initialize(context, template)
        @context = context
        @template = template
      end

      def call(*args)
        @context.js.call([
          "(function (partials, helpers, tmpl, args) {",
          "  Object.keys(partials).forEach(function (key) {",
          "    Handlebars.registerPartial(key, partials[key]);",
          "  })",
          "  Object.keys(helpers).forEach(function (key) {",
          "    Handlebars.registerHelper(key, function () {",
          "      return helpers[key].apply(this, arguments);",
          "    });",
          "  })",
          "  return Handlebars.compile(tmpl).apply(null, args);",
          "})"].join("\n"), @context.partials, @context.helpers, @template, args)
      end
    end
  end
end
