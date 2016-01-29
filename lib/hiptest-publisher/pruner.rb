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
      prune_actionwords
      return @xml
    end

    private

    def prune_tags
      filter_tags = Set.new @options.filter_tags.split(',')
      return if filter_tags.empty?
      puts "Pruning scenarios for tags: #{filter_tags.to_a.join(',')}" if @options.verbose
      @xml.css('> project > scenarios > scenario').each { |scenario|
        puts "Scenario: #{scenario.css('> name')}" if @options.verbose
        scenario_tags = Set.new scenario.css('> tags > tag > key').to_ary.map { |element| element.text }
        scenario_tags.each { |tag|
          puts "  tag: #{tag}"
        } if @options.verbose
        # Remove the scenario if it doesn't have any of the desired tags
        if filter_tags.disjoint?(scenario_tags)
          puts "Pruning!"
          scenario.remove
        end
      }
    end

    def prune_actionwords
      # Collect the actionwords used by all scenarios.
      used = collect_actionwords_used
      # Extend them with actionwords used by other used actionwords.
      used = actionwords_dependencies(used)
      puts "There are a total of #{used.size} actionwords used" if @options.verbose
      # Remove actionwords that are not used at all.
      remove_unused_actionwords(used)
    end

    # Remove actionwords that are not used at all.
    def remove_unused_actionwords(used)
      puts "Pruning unused actionwords" if @options.verbose
      @xml.css('> project > actionwords > actionword').each { |actionword|
        name = actionword_name(actionword)
        next if used.include?(name)
        puts "Removing actionword #{name}" if @options.verbose
        actionword.remove
      }
    end

    # Collect the actionwords used by all scenarios.
    def collect_actionwords_used
      puts "Collecting actionwords used in any scenario" if @options.verbose
      used = Set.new
      @xml.css('> project > scenarios > scenario').each { |scenario|
        scenario.css('> steps > call').each { |call|
          actionword = call_actionword(call)
          if used.add?(actionword)
            puts "Discovered actionword used by scenario: #{actionword}" if @options.verbose
          end
        }
      }
      puts "Collected #{used.size} actionwords used by scenarios" if @options.verbose
      return used
    end

    def call_actionword(call)
      return call.css('> actionword').first.text
    end

    def actionword_name(actionword)
      return actionword.css('> name').first.text
    end

    # Extend them with actionwords used by other used actionwords.
    def actionwords_dependencies(used)
      pass = 0
      while true
        pass += 1
        puts "Finding actionwords used by other actionwords, pass #{pass}" if @options.verbose
        more = actionwords_dependencies_once(used)
        return used if more.empty?
        puts "Found #{more.size} additional actionwords, pass #{pass}" if @options.verbose
        used.merge(more)
      end
      puts "Found no additional actionwords, pass #{pass}" if @options.verbose
      return used
    end

    # Return actionwords used by any of the specified words.
    def actionwords_dependencies_once(used)
      more = Set.new
      @xml.css('> project > actionwords > actionword').each { |actionword|
        name = actionword_name(actionword)
        # See if this actionword calls others.
        actionword.css('> steps > call').each { |call|
          called_actionword = call_actionword(call)
          unless used.include?(called_actionword)
            if more.add?(called_actionword)
              puts "Discovered actionword used by actionword: #{called_actionword}" if @options.verbose
            end
          end
        }
      }
      return more
    end

  end
end
