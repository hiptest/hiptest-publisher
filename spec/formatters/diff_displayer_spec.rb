require_relative "../spec_helper"
require_relative "../../lib/hiptest-publisher/options_parser"
require_relative "../../lib/hiptest-publisher/signature_differ"
require_relative "../../lib/hiptest-publisher/file_writer"
require_relative "../../lib/hiptest-publisher/formatters/reporter"
require_relative "../../lib/hiptest-publisher/formatters/diff_displayer"

describe Hiptest::DiffDisplayer do
  include HelperFactories

  let(:cli_options) {
    options = CliOptions.new(language: "ruby", framework: "rspec")
    options.normalize!
    options
  }

  let(:file_writer) {
    Hiptest::FileWriter.new(Reporter.new)
  }

  let(:language_group) {
    LanguageConfigParser.new(cli_options)
  }

  let(:diff) {
    {
      created: [
        {
          name: 'My empty new actionword',
          node: make_actionword('My empty new actionword', uid: 'id1', body: [])
        },
        {
          name: 'My complex new actionword',
          node: make_actionword('My complex new actionword', uid: 'id1', parameters: [
            make_parameter('x'),
            make_parameter('y', default: literal('Hi, I am a valued parameters'))
          ], body: [
            Hiptest::Nodes::Step.new('action', Hiptest::Nodes::StringLiteral.new('Do something'))
          ])
        },
      ],
      renamed: [
        {
          name: 'My old action word',
          new_name: 'My brand new action word',
          node: make_actionword('My brand new actionword', uid: 'id1', body: [])
        }
      ],
      signature_changed: [
        {
          name: 'My action word',
          node: make_actionword('My action word', parameters: [
            make_parameter('x'),
            make_parameter('y', default: literal('Hi, I am a valued parameters'))
          ], uid: 'id1', body: [])
        }
      ],
      definition_changed: [
        {
          name: 'My updated actionword',
          node: make_actionword('My updated actionword', uid: 'id1', parameters: [
            make_parameter('x'),
            make_parameter('y', default: literal('Hi, I am a valued parameters'))
          ], body: [
            Hiptest::Nodes::Step.new('action', Hiptest::Nodes::Template.new([
              Hiptest::Nodes::StringLiteral.new('Do something with'),
              Hiptest::Nodes::Variable.new('x')
            ]))
          ])
        },
      ],
      deleted: [
        {name: 'a deleted action word'},
        {name: 'and another one who went away'}
      ]
    }
  }

  let(:subject) {Hiptest::DiffDisplayer.new(diff, cli_options, language_group, file_writer)}

  context 'display' do
    context 'uses display_* depending on the commands in cli_options' do
      def make_diff_displayer(command = nil, extra_opts: {})
        opts = {language: "ruby", framework: "rspec"}.merge(extra_opts)
        opts[command] = true unless command.nil?

        options = CliOptions.new(opts)
        options.normalize!
        lang_grp = LanguageConfigParser.new(options)

        diff_displayer = Hiptest::DiffDisplayer.new(diff, options, lang_grp, file_writer)

        allow(diff_displayer).to receive(:display_summary)
        allow(diff_displayer).to receive(:display_created)
        allow(diff_displayer).to receive(:display_renamed)
        allow(diff_displayer).to receive(:display_signature_changed)
        allow(diff_displayer).to receive(:display_definition_changed)
        allow(diff_displayer).to receive(:display_deleted)
        allow(diff_displayer).to receive(:display_as_json)
        allow(diff_displayer).to receive(:export_as_json)


        diff_displayer
      end

      def expect_only_displayer_called(diff_displayer, called_method)
        mocked_methods = [
          :display_summary,
          :display_created,
          :display_renamed,
          :display_signature_changed,
          :display_definition_changed,
          :display_deleted,
          :display_as_json,
          :export_as_json
        ]

        expect(diff_displayer).to have_received(called_method).once
        mocked_methods.each do |meth|
          next if meth == called_method
          expect(diff_displayer).not_to have_received(meth)
        end
      end

      it 'calls display_summary when no options match another displayer' do
        diff_displayer = make_diff_displayer
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :display_summary)
      end

      it 'calls display_created with option --show-actionwords-created' do
        diff_displayer = make_diff_displayer(:aw_created)
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :display_created)
      end

      it 'calls display_renamed with option --show-actionwords-renamed' do
        diff_displayer = make_diff_displayer(:aw_renamed)
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :display_renamed)
      end

      it 'calls display_signature_changed with option --show-actionwords-signature_changed' do
        diff_displayer = make_diff_displayer(:aw_signature_changed)
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :display_signature_changed)
      end

      it 'calls display_definition_changed with option --show-actionwords-definition-changed' do
        diff_displayer = make_diff_displayer(:aw_definition_changed)
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :display_definition_changed)
      end

      it 'calls display_deleted with option --show-actionwords-deleted' do
        diff_displayer = make_diff_displayer(:aw_deleted)
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :display_deleted)
      end

      it 'calls display_as_json with option --show-actionwords-diff-as-json' do
        diff_displayer = make_diff_displayer(:actionwords_diff_json)
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :display_as_json)
      end

      it 'calls export_as_json with option --show-actionwords-diff-as-json and --output-directory set' do
        output_dir = Dir.mktmpdir

        diff_displayer = make_diff_displayer(:actionwords_diff_json, extra_opts: {output_directory: output_dir})
        diff_displayer.display

        expect_only_displayer_called(diff_displayer, :export_as_json)

        FileUtils.rm_rf(output_dir)
      end
    end
  end

  context 'display_created' do
    it 'displays the skeletons for the newly created action words' do
      expect { subject.display_created }.to output([
        'def my_empty_new_actionword',
        '',
        'end',
        '',
        'def my_complex_new_actionword(x, y = \'Hi, I am a valued parameters\')',
        '  # TODO: Implement action: \'Do something\'',
        '  raise NotImplementedError',
        'end',
        '',
        ''
      ].join("\n")).to_stdout
    end
  end

  context 'display_renamed' do
    it 'displays the old/new names for the actions which have been renamed' do
      expect { subject.display_renamed }.to output([
        "my_old_action_word\tmy_brand_new_action_word",
        '',
        ''
      ].join("\n")).to_stdout
    end
  end

  context 'display_signature_changed' do
    it 'displays the skeletons for the actions which signatures have changed' do
      expect { subject.display_signature_changed }.to output([
        'def my_action_word(x, y = \'Hi, I am a valued parameters\')',
        '',
        'end',
        '',
        ''
      ].join("\n")).to_stdout
    end
  end

  context 'display_definition_changed' do
    it 'displays the skeletons for the actions which definitions have changed' do
      expect { subject.display_definition_changed }.to output([
        'def my_updated_actionword(x, y = \'Hi, I am a valued parameters\')',
        '  # TODO: Implement action: "Do something with#{x}"',
        '  raise NotImplementedError',
        'end',
        '',
        ''
      ].join("\n")).to_stdout
    end
  end

  context 'display_deleted' do
    it 'displays the name in code for deleted action words' do
      expect { subject.display_deleted }.to output([
        'a_deleted_action_word',
        'and_another_one_who_went_away',
        '',
        ''
      ].join("\n")).to_stdout
    end
  end

  context 'display_as_json' do
    it 'displays the JSON version' do
      expect { subject.display_as_json }.to output([
        %|{|,
        %|  "deleted": [|,
        %|    {|,
        %|      "name": "a deleted action word",|,
        %|      "name_in_code": "a_deleted_action_word"|,
        %|    },|,
        %|    {|,
        %|      "name": "and another one who went away",|,
        %|      "name_in_code": "and_another_one_who_went_away"|,
        %|    }|,
        %|  ],|,
        %|  "created": [|,
        %|    {|,
        %|      "name": "My empty new actionword",|,
        %|      "skeleton": "def my_empty_new_actionword\\n\\nend"|,
        %|    },|,
        %|    {|,
        %|      "name": "My complex new actionword",|,
        %|      "skeleton": "def my_complex_new_actionword(x, y = 'Hi, I am a valued parameters')\\n  # TODO: Implement action: 'Do something'\\n  raise NotImplementedError\\nend"|,
        %|    }|,
        %|  ],|,
        %|  "renamed": [|,
        %|    {|,
        %|      "name": "My old action word",|,
        %|      "old_name": "my_old_action_word",|,
        %|      "new_name": "my_brand_new_action_word"|,
        %|    }|,
        %|  ],|,
        %|  "signature_changed": [|,
        %|    {|,
        %|      "name": "My action word",|,
        %|      "skeleton": "def my_action_word(x, y = 'Hi, I am a valued parameters')\\n\\nend"|,
        %|    }|,
        %|  ],|,
        %|  "definition_changed": [|,
        %|    {|,
        %|      "name": "My updated actionword",|,
        %|      "skeleton": "def my_updated_actionword(x, y = 'Hi, I am a valued parameters')\\n  # TODO: Implement action: \\"Do something with\#{x}\\"\\n  raise NotImplementedError\\nend"|,
        %|    }|,
        %|  ]|,
        %|}|,
        '',
        ''
      ].join("\n")).to_stdout
    end
  end

  context 'export_as_json' do
    it 'writes the content of "as_api" in a JSON file inside the output directory' do
      output_dir = Dir.mktmpdir
      options = CliOptions.new({
        language: "ruby",
        framework: "rspec",
        output_directory: output_dir
      })
      options.normalize!
      lang_grp = LanguageConfigParser.new(options)
      diff_displayer = Hiptest::DiffDisplayer.new(diff, options, lang_grp, file_writer)

      expect { diff_displayer.export_as_json }.to output('').to_stdout
      expect(File.read("#{output_dir}/actionwords-diff.json")).to eq([
       %|{|,
       %|  "deleted": [|,
       %|    {|,
       %|      "name": "a deleted action word",|,
       %|      "name_in_code": "a_deleted_action_word"|,
       %|    },|,
       %|    {|,
       %|      "name": "and another one who went away",|,
       %|      "name_in_code": "and_another_one_who_went_away"|,
       %|    }|,
       %|  ],|,
       %|  "created": [|,
       %|    {|,
       %|      "name": "My empty new actionword",|,
       %|      "skeleton": "def my_empty_new_actionword\\n\\nend"|,
       %|    },|,
       %|    {|,
       %|      "name": "My complex new actionword",|,
       %|      "skeleton": "def my_complex_new_actionword(x, y = 'Hi, I am a valued parameters')\\n  # TODO: Implement action: 'Do something'\\n  raise NotImplementedError\\nend"|,
       %|    }|,
       %|  ],|,
       %|  "renamed": [|,
       %|    {|,
       %|      "name": "My old action word",|,
       %|      "old_name": "my_old_action_word",|,
       %|      "new_name": "my_brand_new_action_word"|,
       %|    }|,
       %|  ],|,
       %|  "signature_changed": [|,
       %|    {|,
       %|      "name": "My action word",|,
       %|      "skeleton": "def my_action_word(x, y = 'Hi, I am a valued parameters')\\n\\nend"|,
       %|    }|,
       %|  ],|,
       %|  "definition_changed": [|,
       %|    {|,
       %|      "name": "My updated actionword",|,
       %|      "skeleton": "def my_updated_actionword(x, y = 'Hi, I am a valued parameters')\\n  # TODO: Implement action: \\"Do something with\#{x}\\"\\n  raise NotImplementedError\\nend"|,
       %|    }|,
       %|  ]|,
       %|}|
      ].join("\n"))

      FileUtils.rm_rf(output_dir)
    end
  end

  context 'display_summary' do
    it 'displays a message when the diff is empty' do
      expect { Hiptest::DiffDisplayer.new({}, cli_options, language_group, file_writer).display_summary }.to output([
        'No action words changed',
        '',
        ''
      ].join("\n")).to_stdout
    end

    it 'gives a summary with a list of usefull commands' do
      expect {subject.display_summary}.to output([
        "2 action words deleted,",
        "run 'hiptest-publisher --show-actionwords-deleted' to list the names in the code",
        "- a deleted action word",
        "- and another one who went away",
        "",
        "2 action words created,",
        "run 'hiptest-publisher --show-actionwords-created' to get the definitions",
        "- My empty new actionword",
        "- My complex new actionword",
        "",
        "1 action word renamed,",
        "run 'hiptest-publisher --show-actionwords-renamed' to get the new name",
        "- My old action word",
        "",
        "1 action word which signature changed,",
        "run 'hiptest-publisher --show-actionwords-signature-changed' to get the new signature",
        "- My action word",
        "",
        "1 action word which definition changed:",
        "run 'hiptest-publisher --show-actionwords-definition-changed' to get the new definition",
        "- My updated actionword",
        '',
        ''
      ].join("\n")).to_stdout
    end
  end

  context 'as_api' do
    let(:as_api) {subject.as_api}

    it 'returns a JSON object with all modifications' do
      expect(as_api.keys).to contain_exactly(:created, :renamed, :signature_changed, :definition_changed, :deleted)
    end

    it 'provides the name and skeleton for newly created action words' do
      expect(as_api[:created]).to eq([
        {
          name: "My empty new actionword",
          skeleton: "def my_empty_new_actionword\n\nend"
        },
        {
          name: "My complex new actionword",
          skeleton: "def my_complex_new_actionword(x, y = 'Hi, I am a valued parameters')\n  # TODO: Implement action: 'Do something'\n  raise NotImplementedError\nend"
        }
      ])
    end

    it 'computes old and new names for renamed action words' do
      expect(as_api[:renamed]).to eq([
        {
          name: "My old action word",
          old_name: "my_old_action_word",
          new_name: "my_brand_new_action_word"
        }
      ])
    end

    it 'computes new signature/skeleton for action words which signature changed' do
      expect(as_api[:signature_changed]).to eq([
        {
          name: "My action word",
          skeleton: "def my_action_word(x, y = 'Hi, I am a valued parameters')\n\nend"
        }
      ])
    end

    it 'computes new skeleton for action words which definition changed' do
      expect(as_api[:definition_changed]).to eq([
        {
          name: "My updated actionword",
          skeleton: "def my_updated_actionword(x, y = 'Hi, I am a valued parameters')\n  # TODO: Implement action: \"Do something with\#{x}\"\n  raise NotImplementedError\nend"
        }
      ])
    end
  end
end
