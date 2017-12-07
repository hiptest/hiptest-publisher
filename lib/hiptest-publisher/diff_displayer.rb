module Hiptest
  class DiffDisplayer
    def initialize(diff, cli_options, language_config, file_writer)
      @diff = diff
      @cli_options = cli_options
      @language_config = language_config
      @file_writer = file_writer
    end

    def display
      return export_as_json if @cli_options.actionwords_diff_json && @cli_options.output_directory
      return display_as_json if @cli_options.actionwords_diff_json
      return display_deleted if @cli_options.aw_deleted
      return display_created if @cli_options.aw_created
      return display_renamed if @cli_options.aw_renamed
      return display_signature_changed if @cli_options.aw_signature_changed
      return display_definition_changed if @cli_options.aw_definition_changed

      display_summary
    end

    def display_created
      return display_skeletons(@diff[:created])
    end

    def display_renamed
      return if @diff[:renamed].nil?

      output(@diff[:renamed].map {|renamed|
        "#{@language_config.name_action_word(renamed[:name])}\t#{@language_config.name_action_word(renamed[:new_name])}"
      })
    end

    def display_signature_changed
      display_skeletons(@diff[:signature_changed])
    end

    def display_definition_changed
      display_skeletons(@diff[:definition_changed])
    end

    def display_deleted
      return if @diff[:deleted].nil?

      output(@diff[:deleted].map {|deleted|
        @language_config.name_action_word(deleted[:name])
      })
    end

    def export_as_json
      @file_writer.write_to_file(
        "#{@cli_options.output_directory}/actionwords-diff.json",
        "Exporting actionwords diff") {
        JSON.pretty_generate(as_api)
      }
    end

    def display_as_json
      output(JSON.pretty_generate(as_api))
    end

    def as_api
      data = {}

      data[:deleted] = @diff[:deleted].map {|aw|
        {
          name: aw[:name],
          name_in_code: @language_config.name_action_word(aw[:name])
        }
      } unless @diff[:deleted].nil?

      data[:created] = @diff[:created].map {|aw|
        {
          name: aw[:name],
          skeleton: actionword_skeleton(aw)
        }
      } unless @diff[:created].nil?

      data[:renamed] = @diff[:renamed].map {|aw|
        {
          name: aw[:name],
          old_name: @language_config.name_action_word(aw[:name]),
          new_name: @language_config.name_action_word(aw[:new_name])
        }
      } unless @diff[:renamed].nil?

      data[:signature_changed] = @diff[:signature_changed].map {|aw|
        {
          name: aw[:name],
          skeleton: actionword_skeleton(aw)
        }
      } unless @diff[:signature_changed].nil?


      data[:definition_changed] = @diff[:definition_changed].map {|aw|
        {
          name: aw[:name],
          skeleton: actionword_skeleton(aw)
        }
      } unless @diff[:definition_changed].nil?

      return data
    end

    def display_summary
      command_line = @cli_options.command_line_used(exclude: [:actionwords_diff])

      unless @diff[:deleted].nil?
        output([
          "#{pluralize(@diff[:deleted].length, "action word")} deleted,",
          "run '#{command_line} --show-actionwords-deleted' to list the #{pluralize_word(@diff[:deleted].length, "name")} in the code",
          displayable_list(@diff[:deleted])
        ])
      end

      unless @diff[:created].nil?
        output([
          "#{pluralize(@diff[:created].length, "action word")} created,",
          "run '#{command_line} --show-actionwords-created' to get the #{pluralize_word(@diff[:created].length, "definition")}",
          displayable_list(@diff[:created])
        ])
      end

      unless @diff[:renamed].nil?
        output([
          "#{pluralize(@diff[:renamed].length, "action word")} renamed,",
          "run '#{command_line} --show-actionwords-renamed' to get the new #{pluralize_word(@diff[:renamed].length, "name")}",
          displayable_list(@diff[:renamed])
        ])
      end

      unless @diff[:signature_changed].nil?
        output([
          "#{pluralize(@diff[:signature_changed].length, "action word")} which signature changed,",
          "run '#{command_line} --show-actionwords-signature-changed' to get the new #{pluralize_word(@diff[:signature_changed].length, "signature")}",
          displayable_list(@diff[:signature_changed])
        ])
      end

      unless @diff[:definition_changed].nil?
        output([
          "#{pluralize(@diff[:definition_changed].length, "action word")} which definition changed:",
          "run '#{command_line} --show-actionwords-definition-changed' to get the new #{pluralize_word(@diff[:definition_changed].length, "definition")}",
          displayable_list(@diff[:definition_changed])
        ])
      end

      if @diff.empty?
        output("No action words changed")
      end
    end

    private

    def output(lines, add_empty_line: true)
      puts Array(lines).join("\n")
      puts "" if add_empty_line
    end

    def displayable_list(actionwords)
      actionwords.map {|c| "- #{c[:name]}"}.join("\n")
    end

    def actionword_skeleton(actionword)
      return if actionwords_group_config.nil?

      node_rendering_context = actionwords_group_config.build_node_rendering_context(actionword[:node])
      actionword[:node].render(node_rendering_context)
    end

    def display_skeletons(actionwords)
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
