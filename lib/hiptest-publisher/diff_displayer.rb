module Hiptest
  class DiffDisplayer
    def initialize(diff, cli_options, language_config)
      @diff = diff
      @cli_options = cli_options
      @language_config = language_config
    end

    def display
      if @cli_options.aw_deleted
        return if @diff[:deleted].nil?

        @diff[:deleted].map {|deleted|
          puts @language_config.name_action_word(deleted[:name])
        }
        return
      end

      if @cli_options.aw_created
        print_updated_aws(@diff[:created])
        return
      end

      if @cli_options.aw_renamed
        return if @diff[:renamed].nil?

        @diff[:renamed].map {|renamed|
          puts "#{@language_config.name_action_word(renamed[:name])}\t#{@language_config.name_action_word(renamed[:new_name])}"
        }
        return
      end

      if @cli_options.aw_signature_changed
        print_updated_aws(@diff[:signature_changed])
        return
      end

      if @cli_options.aw_definition_changed
        print_updated_aws(@diff[:definition_changed])
        return
      end

      command_line = @cli_options.command_line_used(exclude: [:actionwords_diff])

      unless @diff[:deleted].nil?
        puts "#{pluralize(@diff[:deleted].length, "action word")} deleted,"
        puts "run '#{command_line} --show-actionwords-deleted' to list the #{pluralize_word(@diff[:deleted].length, "name")} in the code"
        puts @diff[:deleted].map {|d| "- #{d[:name]}"}.join("\n")
        puts ""
      end

      unless @diff[:created].nil?
        puts "#{pluralize(@diff[:created].length, "action word")} created,"
        puts "run '#{command_line} --show-actionwords-created' to get the #{pluralize_word(@diff[:created].length, "definition")}"

        puts @diff[:created].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      unless @diff[:renamed].nil?
        puts "#{pluralize(@diff[:renamed].length, "action word")} renamed,"
        puts "run '#{command_line} --show-actionwords-renamed' to get the new #{pluralize_word(@diff[:renamed].length, "name")}"
        puts @diff[:renamed].map {|r| "- #{r[:name]} => #{r[:new_name]}"}.join("\n")
        puts ""
      end

      unless @diff[:signature_changed].nil?
        puts "#{pluralize(@diff[:signature_changed].length, "action word")} which signature changed,"
        puts "run '#{command_line} --show-actionwords-signature-changed' to get the new #{pluralize_word(@diff[:signature_changed].length, "signature")}"
        puts @diff[:signature_changed].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      unless @diff[:definition_changed].nil?
        puts "#{pluralize(@diff[:definition_changed].length, "action word")} which definition changed:"
        puts "run '#{command_line} --show-actionwords-definition-changed' to get the new #{pluralize_word(@diff[:definition_changed].length, "definition")}"
        puts @diff[:definition_changed].map {|c| "- #{c[:name]}"}.join("\n")
        puts ""
      end

      if @diff.empty?
        puts "No action words changed"
        puts ""
      end
    end

    def print_updated_aws(actionwords)
      return if actionwords.nil?

      @language_config.language_group_configs.select { |language_group_config|
        language_group_config[:group_name] == "actionwords"
      }.each do |language_group_config|
        actionwords.each do |actionword|
          node_rendering_context = language_group_config.build_node_rendering_context(actionword[:node])
          puts actionword[:node].render(node_rendering_context)
          puts ""
        end
      end
    end
  end
end
