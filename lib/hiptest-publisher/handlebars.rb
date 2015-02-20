require 'execjs'
require 'handlebars/source'

module Hiptest
  module Handlebars
    class Context
      attr_reader :js

      def initialize
        # src = File.open(::Handlebars::Source.bundled_path, 'r').read
        src =  File.open('/home/vincent/dev/hiptest/hiptest-publisher/handlebars.js').read
        @js = ExecJS.compile(src)
      end

      def compile(*args)
        Hiptest::Handlebars::Template.new(self, *args)
      end

      def register_helper(name, &fn)
        @js.call('Handlebars.registerHelper', name, fn)
      end

      def register_partial(name, content)
        @js.call('(function (n, p) {Handlebars.registerPartial(n, p);})', name, content)
      end
    end

    class Template
      def initialize(context, template)
        @context = context
        @template = template
      end

      def call(*args)
        @context.js.call("(function (tmpl, args) {return Handlebars.compile(tmpl).apply(null, args)})", @template, args)
      end
    end
  end
end
