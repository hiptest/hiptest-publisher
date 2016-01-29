require 'set'

require_relative 'utils'

module Hiptest
  class Pruner

    def initialize(xml, options)
      @xml = xml
      @options = options
    end

    def prune
      prune_tags
      return @xml
    end

    private

    def prune_tags
      filter_tags = Set.new @options.filter_tags.split(',')
      return if filter_tags.empty?
      puts "Pruning scenarios for tags: #{filter_tags.to_a.join(',')}" if @options.verbose
      @xml.css('> project > scenarios > scenario').each {|scenario|
        puts "Scenario: #{scenario.css('> name')}" if @options.verbose
        scenario_tags = Set.new scenario.css('> tags > tag > key').to_ary.map { |element| element.text }
        scenario_tags.each { |tag|
          puts "  tag: #{tag}"
        } if @options.verbose
        # Remove the scenario if it doesn't have any of the desired tags
        scenario.remove if filter_tags.disjoint?(scenario_tags)
      }
      # TODO
    end
  end
end
