require_relative 'spec_helper'
require_relative 'xml_parser_shared'

require_relative '../lib/hiptest-publisher/nodes'
require_relative '../lib/hiptest-publisher/xml_parser'


class TestParser < Hiptest::XMLParser
  def build_main_node
    build_node(@xml.css('> *').first)
  end
end

describe Hiptest::XMLParser do
  def create_item(type, name, description = '', tags = [], parameters = [], steps = [])
    name_tag = "<name>#{name}</name>"
    description_node = "<description>#{description}</description>"
    tags_node = tags.empty? ? '' : "<tags>#{tags.join}</tags>"
    parameters_node = parameters.empty? ? '' : "<parameters>#{parameters.join}</parameters>"
    steps_node = steps.empty? ? '' : "<steps>#{steps.join}</steps>"

    "<#{type}>
      #{name_tag}
      #{description_node}
      #{tags_node}
      #{parameters_node}
      #{steps_node}
     </#{type}
    "
  end

  def create_actionword(name, tags = [], parameters = [], steps = [])
    create_item('actionword', name, '', tags, parameters, steps)
  end

  def create_scenario(name, description = '', tags = [], parameters = [], steps = [])
    create_item('scenario', name, description, tags, parameters, steps)
  end

  def create_actionword_snapshot(name, tags = [], parameters = [], steps = [])
    create_item('actionwordSnapshot', name, '', tags, parameters, steps)
  end

  def create_scenario_snapshot(name, description = '', tags = [], parameters = [], steps = [])
    create_item('scenarioSnapshot', name, description, tags, parameters, steps)
  end

  def build_node(xml)
    xml = "<?xml version=\"1.0\"?>#{xml}"
    parser = TestParser.new(xml)
    parser.build_main_node
  end

  before(:each) do
    @zero = '<numericliteral>0</numericliteral>'
    @my_var = '<var>my_var</var>'
    @assign_zero_to_my_var = "
      <assign>
        <to>#{@my_var}</to>
        <value>#{@zero}</value>
      </assign>"
    @simple_tag = '<tag><key>simple</key></tag>'
    @key_value_tag = "<tag><key>path</key><value>'path/to/somewhere'</value></tag>"
    @action_step = "
      <step>
        <action>
          <template>
            <stringliteral>Click on logout link</stringliteral>
          </template>
        </action>
      </step>"
    @result_step = "
      <step>
        <result>
          <template>
            #{@my_var}
            <stringliteral>equals to 10</stringliteral>
          </template>
        </result>
      </step>"

    @simple_parameter = '<parameter><name>x</name></parameter>'
    @valued_parameter = '<parameter>
            <name>y</name>
            <default_value>
              <list />
            </default_value>
          </parameter>'

  end

  context 'test DSL elements' do
    context 'literals' do
      it 'null' do
        node = build_node('<nullliteral />')

        node.is_a?(Hiptest::Nodes::NullLiteral)
      end

      it 'string' do
        node = build_node('<stringliteral>Ho hi</stringliteral')

        expect(node).to be_a(Hiptest::Nodes::StringLiteral)
        expect(node.children[:value]).to eq('Ho hi')
      end

      it 'numeric' do
        node = build_node('<numericliteral>3.14</numericliteral')

        expect(node).to be_a(Hiptest::Nodes::NumericLiteral)
        expect(node.children[:value]).to eq('3.14')
      end

      it 'boolean' do
        node = build_node('<booleanliteral>false</booleanliteral>')

        expect(node).to be_a(Hiptest::Nodes::BooleanLiteral)
        expect(node.children[:value]).to eq('false')
      end
    end

    it 'variable' do
      node = build_node(@my_var)

      expect(node).to be_a(Hiptest::Nodes::Variable)
      expect(node.children[:name]).to eq('my_var')
    end

    it 'field' do
      node = build_node("
        <field>
          <base>
            #{@my_var}
          </base>
          <name>accessor</name>
        </field>")

      expect(node).to be_a(Hiptest::Nodes::Field)
      expect(node.children[:base]).to be_a(Hiptest::Nodes::Variable)
      expect(node.children[:name]).to eq('accessor')
    end

    it 'index' do
      node = build_node("
        <index>
          <base>#{@my_var}</base>
          <expression>#{@zero}</expression>
        </index>")

      expect(node).to be_a(Hiptest::Nodes::Index)
      expect(node.children[:base]).to be_a(Hiptest::Nodes::Variable)
      expect(node.children[:expression]).to be_a(Hiptest::Nodes::NumericLiteral)
    end

    context 'operation' do
      it 'binary' do
        node = build_node("
          <operation>
            <left>#{@my_var}</left>
            <operator>+</operator>
            <right>#{@zero}</right>
          </operation>")

        expect(node).to be_a(Hiptest::Nodes::BinaryExpression)
        node.children[:left].is_a?(Hiptest::Nodes::Variable)
        expect(node.children[:operator]).to eq('+')
        node.children[:right].is_a?(Hiptest::Nodes::NumericLiteral)
      end

      it 'unary' do
        node = build_node("
          <operation>
            <operator>!</operator>
            <expression>#{@my_var}</expression>
          </operation>")

        expect(node).to be_a(Hiptest::Nodes::UnaryExpression)
        expect(node.children[:operator]).to eq('!')
        node.children[:expression].is_a?(Hiptest::Nodes::Variable)
      end
    end

    it 'parenthesis' do
        node = build_node("<parenthesis>#{@my_var}</parenthesis>")

        expect(node).to be_a(Hiptest::Nodes::Parenthesis)
        node.children[:content].is_a?(Hiptest::Nodes::Variable)
    end

    context 'list' do
      it 'empty' do
        node = build_node("<list />")

        expect(node).to be_a(Hiptest::Nodes::List)
        expect(node.children[:items]).to eq([])
      end

      it 'with content' do
        node = build_node("
          <list>
            <item>#{@my_var}</item>
            <item>#{@zero}</item>
          </list>")

        expect(node).to be_a(Hiptest::Nodes::List)
        expect(node.children[:items].length).to eq(2)
        expect(node.children[:items][0]).to be_a(Hiptest::Nodes::Variable)
        expect(node.children[:items][1]).to be_a(Hiptest::Nodes::NumericLiteral)
      end
    end

    context 'dict' do
      it 'empty' do
        node = build_node("<dict />")

        expect(node).to be_a(Hiptest::Nodes::Dict)
        expect(node.children[:items]).to eq([])
      end

      it 'empty' do
        node = build_node("
          <dict>
            <key>#{@my_var}</key>
            <another_key>#{@zero}</another_key>
          </dict>")

        expect(node).to be_a(Hiptest::Nodes::Dict)
        expect(node.children[:items].length).to eq(2)
        expect(node.children[:items][0]).to be_a(Hiptest::Nodes::Property)
        expect(node.children[:items][0].children[:key]).to eq('key')
        expect(node.children[:items][0].children[:value]).to be_a(Hiptest::Nodes::Variable)
        expect(node.children[:items][1]).to be_a(Hiptest::Nodes::Property)
        expect(node.children[:items][1].children[:key]).to eq('another_key')
        expect(node.children[:items][1].children[:value]).to be_a(Hiptest::Nodes::NumericLiteral)
      end
    end

    it 'template' do
      node = build_node("
        <template>
          <stringliteral>Check the value of</stringliteral>
          #{@my_var}
        </template>")

      node.is_a?(Hiptest::Nodes::Template)
      expect(node.children[:chunks].length).to eq(2)
      expect(node.children[:chunks][0]).to be_a(Hiptest::Nodes::StringLiteral)
      expect(node.children[:chunks][1]).to be_a(Hiptest::Nodes::Variable)
    end

    it 'assign' do
      node = build_node(@assign_zero_to_my_var)

      node.is_a?(Hiptest::Nodes::Assign)
      expect(node.children[:to]).to be_a(Hiptest::Nodes::Variable)
      expect(node.children[:value]).to be_a(Hiptest::Nodes::NumericLiteral)
    end

    context 'call' do
      it 'no arguments' do
        node = build_node('<call><actionword>my action word</actionword></call>')

        expect(node).to be_a(Hiptest::Nodes::Call)
        expect(node.children[:actionword]).to eq('my action word')
        expect(node.children[:arguments]).to eq([])
      end

      it 'with arguments' do
        node = build_node("
          <call>
            <actionword>another action word</actionword>
            <arguments>
              <argument>
                <name>x</name>
                <value>#{@my_var}</value>
              </argument>
              <argument>
                <name>y</name>
                <value>#{@zero}</value>
              </argument>
            </arguments>
          </call>")

        expect(node).to be_a(Hiptest::Nodes::Call)
        expect(node.children[:actionword]).to eq('another action word')
        expect(node.children[:arguments].length).to eq(2)
        expect(node.children[:arguments][0]).to be_a(Hiptest::Nodes::Argument)
        expect(node.children[:arguments][0].children[:name]).to eq('x')
        expect(node.children[:arguments][0].children[:value]).to be_a(Hiptest::Nodes::Variable)
        expect(node.children[:arguments][1]).to be_a(Hiptest::Nodes::Argument)
        expect(node.children[:arguments][1].children[:name]).to eq('y')
        expect(node.children[:arguments][1].children[:value]).to be_a(Hiptest::Nodes::NumericLiteral)
      end
    end

    it 'step' do
      node = build_node(@action_step)

      expect(node).to be_a(Hiptest::Nodes::Step)
      expect(node.children[:key]).to eq('action')
      expect(node.children[:value]).to be_a(Hiptest::Nodes::Template)
    end

    context 'if' do
      it 'simple' do
        node = build_node("
          <if>
            <condition>#{@my_var}</condition>
            <then>
              #{@assign_zero_to_my_var}
            </then>
          </if>")

        expect(node).to be_a(Hiptest::Nodes::IfThen)
        expect(node.children[:condition]).to be_a(Hiptest::Nodes::Variable)
        expect(node.children[:then].length).to eq(1)
        expect(node.children[:then][0]).to be_a(Hiptest::Nodes::Assign)
      end

      it 'with an else statement' do
        node = build_node("
          <if>
            <condition>#{@my_var}</condition>
            <then>
              #{@assign_zero_to_my_var}
            </then>
            <else>
              <call><actionword>my action word</actionword></call>
            </else>
          </if>")

        expect(node).to be_a(Hiptest::Nodes::IfThen)
        expect(node.children[:condition]).to be_a(Hiptest::Nodes::Variable)
        expect(node.children[:then].length).to eq(1)
        expect(node.children[:then][0]).to be_a(Hiptest::Nodes::Assign)
        expect(node.children[:else].length).to eq(1)
        expect(node.children[:else][0]).to be_a(Hiptest::Nodes::Call)
      end
    end

    it 'while' do
      node = build_node("
        <while>
          <condition>#{@my_var}</condition>
          <body>
            #{@assign_zero_to_my_var}
          </body>
        </while>")

      expect(node).to be_a(Hiptest::Nodes::While)
      expect(node.children[:condition]).to be_a(Hiptest::Nodes::Variable)
      expect(node.children[:body].length).to eq(1)
      node.children[:body][0].is_a?(Hiptest::Nodes::Assign)
    end
  end

  context 'tag' do
    it 'simple' do
      node = build_node(@simple_tag)

      expect(node).to be_a(Hiptest::Nodes::Tag)
      expect(node.children[:key]).to eq('simple')
    end

    it 'with a default value' do
      node = build_node(@key_value_tag)

      expect(node).to be_a(Hiptest::Nodes::Tag)
      expect(node.children[:key]).to eq('path')
      expect(node.children[:value]).to eq("'path/to/somewhere'")
    end
  end

  context 'parameter' do
    it 'simple' do
      node = build_node(@simple_parameter)

      expect(node.children[:name]).to eq('x')
      expect(node.children[:default]).to be_nil
    end

    it 'with a default value' do
      node = build_node(@valued_parameter)

      expect(node.children[:name]).to eq('y')
      expect(node.children[:default]).to be_a(Hiptest::Nodes::List)
    end
  end

  context 'models' do
    context 'actionword' do
      it_behaves_like 'actionword' do
        def actionword_maker(*args)
          create_actionword(*args)
        end
      end
    end

    context 'actionwordSnapshot' do
      it_behaves_like 'actionword' do
        def actionword_maker(*args)
          create_actionword_snapshot(*args)
        end
      end
    end

    it 'datatable' do
      node = build_node([
        '<datatable>',
        '  <dataset>',
        '    <name>My first set</name>',
        '    <arguments>',
        '      <argument>',
        '        <name>x</name>',
        '        <value>',
        '          <numericliteral>1</numericliteral>',
        '        </value>',
        '      </argument>',
        '      <argument>',
        '        <name>y</name>',
        '        <value>',
        '          <stringliteral>1</stringliteral>',
        '        </value>',
        '      </argument>',
        '    </arguments>',
        '  </dataset>',
        '  <dataset>',
        '    <name>My second set</name>',
        '    <arguments>',
        '      <argument>',
        '        <name>x</name>',
        '        <value>',
        '          <numericliteral>15</numericliteral>',
        '        </value>',
        '      </argument>',
        '      <argument>',
        '        <name>y</name>',
        '        <value>',
        '          <stringliteral>Some value</stringliteral>',
        '        </value>',
        '      </argument>',
        '    </arguments>',
        '  </dataset>',
        '</datatable>'
      ].join("\n"))

      expect(node).to be_a(Hiptest::Nodes::Datatable)

      datasets = node.children[:datasets]
      expect(datasets.length).to eq(2)
      expect(datasets[0]).to be_a(Hiptest::Nodes::Dataset)
      expect(datasets[1]).to be_a(Hiptest::Nodes::Dataset)
    end

    it 'dataset' do
      node = build_node([
        '<dataset>',
        '  <name>My second set</name>',
        '  <arguments>',
        '    <argument>',
        '      <name>x</name>',
        '      <value>',
        '        <numericliteral>15</numericliteral>',
        '      </value>',
        '    </argument>',
        '    <argument>',
        '      <name>y</name>',
        '      <value>',
        '        <stringliteral>Some value</stringliteral>',
        '      </value>',
        '    </argument>',
        '  </arguments>',
        '</dataset>'
      ].join("\n"))

      expect(node).to be_a(Hiptest::Nodes::Dataset)
      expect(node.children[:name]).to eq('My second set')
      args = node.children[:arguments]

      expect(args.length).to eq(2)
      expect(args[0]).to be_a(Hiptest::Nodes::Argument)
      expect(args[0].children[:name]).to eq('x')
      expect(args[0].children[:value]).to be_a(Hiptest::Nodes::NumericLiteral)
      expect(args[0].children[:value].children[:value]).to eq('15')

      expect(args[1]).to be_a(Hiptest::Nodes::Argument)
      expect(args[1].children[:name]).to eq('y')
      expect(args[1].children[:value]).to be_a(Hiptest::Nodes::StringLiteral)
      expect(args[1].children[:value].children[:value]).to eq('Some value')
    end

    context 'scenario' do
      it_behaves_like 'scenario' do
        def scenario_maker(*args)
          create_scenario(*args)
        end
      end
    end

    context 'scenarioSnapshot' do
      it_behaves_like 'scenario' do
        def scenario_maker(*args)
          create_scenario_snapshot(*args)
        end
      end
    end

    context 'actionwords' do
      it_behaves_like 'actionwords' do
        let(:container_name) {'actionwords'}

        def actionword_maker(*args)
          create_actionword(*args)
        end
      end
    end

    context 'actionwordSnapshots' do
      it_behaves_like 'actionwords' do
        let(:container_name) {'actionwordSnapshots'}

        def actionword_maker(*args)
          create_actionword_snapshot(*args)
        end
      end
    end

    context 'scenarios' do
      it_behaves_like 'scenarios' do
        let(:container_name) {'scenarios'}

        def scenario_maker(*args)
          create_scenario(*args)
        end
      end
    end

    context 'scenarioSnapshots' do
      it_behaves_like 'scenarios' do
        let(:container_name) {'scenarioSnapshots'}

        def scenario_maker(*args)
          create_scenario_snapshot(*args)
        end
      end
    end

    context 'testPlan and folder' do
      let(:folder_node_type) {'folder'}
      let(:folder_container) {'testPlan'}

      it_behaves_like 'folder structure'
    end

    context 'folderSnapshots and folderSnapshot' do
      let(:folder_node_type) {'folderSnapshot'}
      let(:folder_container) {'folderSnapshots'}

      it_behaves_like 'folder structure'
    end

    context 'project' do
      it 'empty project' do
        node = TestParser.new("<?xml version=\"1.0\"?>
          <project>
            <name>My project</name>
            <description>A description</description>
          </project>").build_project

        expect(node).to be_a(Hiptest::Nodes::Project)
        expect(node.children[:name]).to eq('My project')
        expect(node.children[:description]).to eq('A description')
        expect(node.children[:scenarios]).to be_a(Hiptest::Nodes::Scenarios)
        expect(node.children[:actionwords]).to be_a(Hiptest::Nodes::Actionwords)
      end

      it 'with scenarios and actionwords' do
        node = TestParser.new("<?xml version=\"1.0\"?>
          <project>
            <name>My project</name>
            <description>A description</description>
            <scenarios>#{create_scenario('My scenario')}</scenarios>
            <actionwords>#{create_actionword('My actionword')}</actionwords>
          </project>").build_project

        expect(node).to be_a(Hiptest::Nodes::Project)
        node.children[:name] = 'My project'
        node.children[:description] = 'A description'
        expect(node.children[:scenarios]).to be_a(Hiptest::Nodes::Scenarios)
        expect(node.children[:actionwords]).to be_a(Hiptest::Nodes::Actionwords)
      end

      it 'assign scenario to folders when needed' do
        node = TestParser.new("<?xml version=\"1.0\"?>
          <project>
            <name>My project</name>
            <description>A description</description>
            <testPlan>
              <folder>
                <name>My folder</name>
                <uid>12345</uid>
              </folder>
            </testPlan>
            <scenarios>
              <scenario>
                <name>In a folder</name>
                <folderUid>12345</name>
              </scenario>
              <scenario>
                <name>Not in a folder</name>
              </scenario>
            </scenarios>
          </project>").build_project

        scenarios = node.find_sub_nodes(Hiptest::Nodes::Scenario)
        expect(scenarios.length).to eq(2)

        folder = node.find_sub_nodes(Hiptest::Nodes::Folder).first
        expect(folder.children[:scenarios]).to eq([scenarios.first])
      end
    end
  end

  context 'parses a full example' do
    it 'from a project export'  do
      parser = Hiptest::XMLParser.new(File.read('samples/xml_input/Hiptest publisher.xml'))
      project = parser.build_project

      expect(project.children[:name]).to eq('Hiptest publisher')
      expect(project.find_sub_nodes.length).to eq(95)
      expect(project.find_sub_nodes(Hiptest::Nodes::Folder).length).to eq(4)
      expect(project.find_sub_nodes(Hiptest::Nodes::Scenario).length).to eq(2)
      expect(project.find_sub_nodes(Hiptest::Nodes::Actionword).length).to eq(4)
      expect(project.find_sub_nodes(Hiptest::Nodes::Step).length).to eq(4)
      expect(project.find_sub_nodes(Hiptest::Nodes::Datatable).length).to eq(2)
      expect(project.find_sub_nodes(Hiptest::Nodes::Dataset).length).to eq(0)
      expect(project.find_sub_nodes(Hiptest::Nodes::Test).length).to eq(0)
    end

    it 'from a test export' do
      parser = Hiptest::XMLParser.new(File.read('samples/xml_input/Hiptest automation.xml'))
      project = parser.build_project

      expect(project.children[:name]).to eq('Hiptest publisher')
      # Folder are not exported
      expect(project.find_sub_nodes(Hiptest::Nodes::Folder).length).to eq(0)
      # Scenarios are not exported in automation export, Tests are exported instead
      expect(project.find_sub_nodes(Hiptest::Nodes::Scenario).length).to eq(0)
      # Only leaf and used actionwords are exported
      expect(project.find_sub_nodes(Hiptest::Nodes::Actionword).length).to eq(1)
      # Two tests where generated from the scenarios
      expect(project.find_sub_nodes(Hiptest::Nodes::Test).length).to eq(2)
    end

    it 'from a test_run export' do
      parser = Hiptest::XMLParser.new(File.read('samples/xml_input/Hiptest test run.xml'))
      project = parser.build_project

      expect(project.children[:name]).to eq('Hiptest publisher')
      # And not four as previously, folder without scenarios are not added in a test run
      expect(project.find_sub_nodes(Hiptest::Nodes::Folder).length).to eq(3)
      expect(project.find_sub_nodes(Hiptest::Nodes::Scenario).length).to eq(2)
      expect(project.find_sub_nodes(Hiptest::Nodes::Actionword).length).to eq(4)
    end
  end
end
