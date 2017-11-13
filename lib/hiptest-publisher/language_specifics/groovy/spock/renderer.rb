require 'hiptest-publisher/base_renderer'

module Hiptest
  class Renderer < Hiptest::BaseRenderer
    def walk_scenario(scenario)
      base = super(scenario)
      puts "Overriding RenderContextMaker for Groovy/Spock".white
      return base
    end
  end
end
