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

      show_summary
    end

    def display_as_json
      puts as_json
      puts ""
    end

    def as_json
      data = {}

      unless @diff[:deleted].nil?
        data[:deleted] = @diff[:deleted].map {|aw|
          {
            name: aw[:name],
            name_in_code: @language_config.name_action_word(aw[:name])
          }
        }
      end

      unless @diff[:created].nil?
        data[:created] = @diff[:created].map {|aw|
          {
            name: aw[:name],
            skeleton: actionword_skeleton(aw)
          }
        }
      end

      unless @diff[:renamed].nil?
        data[:renamed] = @diff[:renamed].map {|aw|
          {
            name: aw[:name],
            old_name: @language_config.name_action_word(renamed[:name]),
            new_name: @language_config.name_action_word(renamed[:new_name])
          }
        }
      end

      unless @diff[:signature_changed].nil?
        data[:signature_changed] = @diff[:signature_changed].map {|aw|
          {
            name: aw[:name],
            skeleton: actionword_skeleton(aw)
          }
        }
      end

      unless @diff[:definition_changed].nil?
        data[:definition_changed] = @diff[:definition_changed].map {|aw|
          {
            name: aw[:name],
            skeleton: actionword_skeleton(aw)
          }
        }
      end

      return data
    end

    private

    def show_summary
      command_line = @cli_options.command_line_used(exclude: [:actionwords_diff])

      unless @diff[:deleted].nil?
        output([
          "#{pluralize(@diff[:deleted].length, "action word")} deleted,",
          "run '#{command_line} --show-actionwords-deleted' to list the #{pluralize_word(@diff[:deleted].length, "name")} in the code",
          @diff[:deleted].map {|d| "- #{d[:name]}"}.join("\n")
        ])
      end

      unless @diff[:created].nil?
        output([
          "#{pluralize(@diff[:created].length, "action word")} created,",
          "run '#{command_line} --show-actionwords-created' to get the #{pluralize_word(@diff[:created].length, "definition")}",
          @diff[:created].map {|c| "- #{c[:name]}"}.join("\n")
        ])
      end

      unless @diff[:renamed].nil?
        output([
          "#{pluralize(@diff[:renamed].length, "action word")} renamed,",
          "run '#{command_line} --show-actionwords-renamed' to get the new #{pluralize_word(@diff[:renamed].length, "name")}",
          @diff[:renamed].map {|r| "- #{r[:name]} => #{r[:new_name]}"}.join("\n")
        ])
      end

      unless @diff[:signature_changed].nil?
        output([
          "#{pluralize(@diff[:signature_changed].length, "action word")} which signature changed,",
          "run '#{command_line} --show-actionwords-signature-changed' to get the new #{pluralize_word(@diff[:signature_changed].length, "signature")}",
          @diff[:signature_changed].map {|c| "- #{c[:name]}"}.join("\n")
        ])
      end

      unless @diff[:definition_changed].nil?
        output([
          "#{pluralize(@diff[:definition_changed].length, "action word")} which definition changed:",
          "run '#{command_line} --show-actionwords-definition-changed' to get the new #{pluralize_word(@diff[:definition_changed].length, "definition")}",
          @diff[:definition_changed].map {|c| "- #{c[:name]}"}.join("\n")
        ])
      end

      if @diff.empty?
        output("No action words changed")
      end
    end

    def output(lines, add_empty_line: true)
      lines = [lines] unless lines.is_a? Array

      puts lines.join("\n")
      puts "" if add_empty_line
    end

    def actionword_skeleton(actionword)
      return if actionwords_group_config.nil?

      node_rendering_context = actionwords_group_config.build_node_rendering_context(actionword[:node])
      actionword[:node].render(node_rendering_context)
    end

    def print_updated_aws(actionwords)
      return if actionwords.nil?

      actionwords.each do |actionword|
        output(actionword_skeleton(actionword))
      end
    end

    def actionwords_group_config
      @actionwords_group_config ||= @language_config.language_group_configs.select { |language_group_config|
        language_group_config[:group_name] == "actionwords"
      }.first
    end
  end
end
