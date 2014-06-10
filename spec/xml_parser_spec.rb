require_relative 'spec_helper'
require_relative '../lib/zest-publisher/nodes'
require_relative '../lib/zest-publisher/xml_parser'

class TestParser < Zest::XMLParser
  def build_main_node
    build_node(@xml.css('> *').first)
  end
end

describe Zest::XMLParser do
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

  context 'literals' do
    it 'null' do
      node = build_node('<nullliteral />')

      node.is_a?(Zest::Nodes::NullLiteral)
    end

    it 'string' do
      node = build_node('<stringliteral>Ho hi</stringliteral')

      expect(node).to be_a(Zest::Nodes::StringLiteral)
      expect(node.childs[:value]).to eq('Ho hi')
    end

    it 'numeric' do
      node = build_node('<numericliteral>3.14</numericliteral')

      expect(node).to be_a(Zest::Nodes::NumericLiteral)
      expect(node.childs[:value]).to eq('3.14')
    end

    it 'boolean' do
      node = build_node('<booleanliteral>false</booleanliteral>')

      expect(node).to be_a(Zest::Nodes::BooleanLiteral)
      expect(node.childs[:value]).to eq('false')
    end
  end

  it 'variable' do
    node = build_node(@my_var)

    expect(node).to be_a(Zest::Nodes::Variable)
    expect(node.childs[:name]).to eq('my_var')
  end

  it 'field' do
    node = build_node("
      <field>
        <base>
          #{@my_var}
        </base>
        <name>accessor</name>
      </field>")

    expect(node).to be_a(Zest::Nodes::Field)
    expect(node.childs[:base]).to be_a(Zest::Nodes::Variable)
    expect(node.childs[:name]).to eq('accessor')
  end

  it 'index' do
    node = build_node("
      <index>
        <base>#{@my_var}</base>
        <expression>#{@zero}</expression>
      </index>")

    expect(node).to be_a(Zest::Nodes::Index)
    expect(node.childs[:base]).to be_a(Zest::Nodes::Variable)
    expect(node.childs[:expression]).to be_a(Zest::Nodes::NumericLiteral)
  end

  context 'operation' do
    it 'binary' do
      node = build_node("
        <operation>
          <left>#{@my_var}</left>
          <operator>+</operator>
          <right>#{@zero}</right>
        </operation>")

      expect(node).to be_a(Zest::Nodes::BinaryExpression)
      node.childs[:left].is_a?(Zest::Nodes::Variable)
      expect(node.childs[:operator]).to eq('+')
      node.childs[:right].is_a?(Zest::Nodes::NumericLiteral)
    end

    it 'unary' do
      node = build_node("
        <operation>
          <operator>!</operator>
          <expression>#{@my_var}</expression>
        </operation>")

      expect(node).to be_a(Zest::Nodes::UnaryExpression)
      expect(node.childs[:operator]).to eq('!')
      node.childs[:expression].is_a?(Zest::Nodes::Variable)
    end
  end

  it 'parenthesis' do
      node = build_node("<parenthesis>#{@my_var}</parenthesis>")

      expect(node).to be_a(Zest::Nodes::Parenthesis)
      node.childs[:content].is_a?(Zest::Nodes::Variable)
  end

  context 'list' do
    it 'empty' do
      node = build_node("<list />")

      expect(node).to be_a(Zest::Nodes::List)
      expect(node.childs[:items]).to eq([])
    end

    it 'with content' do
      node = build_node("
        <list>
          <item>#{@my_var}</item>
          <item>#{@zero}</item>
        </list>")

      expect(node).to be_a(Zest::Nodes::List)
      expect(node.childs[:items].length).to eq(2)
      expect(node.childs[:items][0]).to be_a(Zest::Nodes::Variable)
      expect(node.childs[:items][1]).to be_a(Zest::Nodes::NumericLiteral)
    end
  end

  context 'dict' do
    it 'empty' do
      node = build_node("<dict />")

      expect(node).to be_a(Zest::Nodes::Dict)
      expect(node.childs[:items]).to eq([])
    end

    it 'empty' do
      node = build_node("
        <dict>
          <key>#{@my_var}</key>
          <another_key>#{@zero}</another_key>
        </dict>")

      expect(node).to be_a(Zest::Nodes::Dict)
      expect(node.childs[:items].length).to eq(2)
      expect(node.childs[:items][0]).to be_a(Zest::Nodes::Property)
      expect(node.childs[:items][0].childs[:key]).to eq('key')
      expect(node.childs[:items][0].childs[:value]).to be_a(Zest::Nodes::Variable)
      expect(node.childs[:items][1]).to be_a(Zest::Nodes::Property)
      expect(node.childs[:items][1].childs[:key]).to eq('another_key')
      expect(node.childs[:items][1].childs[:value]).to be_a(Zest::Nodes::NumericLiteral)
    end
  end

  it 'template' do
    node = build_node("
      <template>
        <stringliteral>Check the value of</stringliteral>
        #{@my_var}
      </template>")

    node.is_a?(Zest::Nodes::Template)
    expect(node.childs[:chunks].length).to eq(2)
    expect(node.childs[:chunks][0]).to be_a(Zest::Nodes::StringLiteral)
    expect(node.childs[:chunks][1]).to be_a(Zest::Nodes::Variable)
  end

  it 'assign' do
    node = build_node(@assign_zero_to_my_var)

    node.is_a?(Zest::Nodes::Assign)
    expect(node.childs[:to]).to be_a(Zest::Nodes::Variable)
    expect(node.childs[:value]).to be_a(Zest::Nodes::NumericLiteral)
  end

  context 'call' do
    it 'no arguments' do
      node = build_node('<call><actionword>my action word</actionword></call>')

      expect(node).to be_a(Zest::Nodes::Call)
      expect(node.childs[:actionword]).to eq('my action word')
      expect(node.childs[:arguments]).to eq([])
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

      expect(node).to be_a(Zest::Nodes::Call)
      expect(node.childs[:actionword]).to eq('another action word')
      expect(node.childs[:arguments].length).to eq(2)
      expect(node.childs[:arguments][0]).to be_a(Zest::Nodes::Argument)
      expect(node.childs[:arguments][0].childs[:name]).to eq('x')
      expect(node.childs[:arguments][0].childs[:value]).to be_a(Zest::Nodes::Variable)
      expect(node.childs[:arguments][1]).to be_a(Zest::Nodes::Argument)
      expect(node.childs[:arguments][1].childs[:name]).to eq('y')
      expect(node.childs[:arguments][1].childs[:value]).to be_a(Zest::Nodes::NumericLiteral)
    end
  end

  it 'step' do
    node = build_node(@action_step)

    expect(node).to be_a(Zest::Nodes::Step)
    expect(node.childs[:key]).to eq('action')
    expect(node.childs[:value]).to be_a(Zest::Nodes::Template)
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

      expect(node).to be_a(Zest::Nodes::IfThen)
      expect(node.childs[:condition]).to be_a(Zest::Nodes::Variable)
      expect(node.childs[:then].length).to eq(1)
      expect(node.childs[:then][0]).to be_a(Zest::Nodes::Assign)
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

      expect(node).to be_a(Zest::Nodes::IfThen)
      expect(node.childs[:condition]).to be_a(Zest::Nodes::Variable)
      expect(node.childs[:then].length).to eq(1)
      expect(node.childs[:then][0]).to be_a(Zest::Nodes::Assign)
      expect(node.childs[:else].length).to eq(1)
      expect(node.childs[:else][0]).to be_a(Zest::Nodes::Call)
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

    expect(node).to be_a(Zest::Nodes::While)
    expect(node.childs[:condition]).to be_a(Zest::Nodes::Variable)
    expect(node.childs[:body].length).to eq(1)
    node.childs[:body][0].is_a?(Zest::Nodes::Assign)
  end

  context 'tag' do
    it 'simple' do
      node = build_node(@simple_tag)

      expect(node).to be_a(Zest::Nodes::Tag)
      expect(node.childs[:key]).to eq('simple')
    end

    it 'with a default value' do
      node = build_node(@key_value_tag)

      expect(node).to be_a(Zest::Nodes::Tag)
      expect(node.childs[:key]).to eq('path')
      expect(node.childs[:value]).to eq("'path/to/somewhere'")
    end
  end

  context 'parameter' do
    it 'simple' do
      node = build_node(@simple_parameter)

      expect(node.childs[:name]).to eq('x')
      expect(node.childs[:default]).to be_nil
    end

    it 'with a default value' do
      node = build_node(@valued_parameter)

      expect(node.childs[:name]).to eq('y')
      expect(node.childs[:default]).to be_a(Zest::Nodes::List)
    end
  end

  context 'actionword' do
    it 'simple' do
      node = build_node(create_actionword('a simple actionword'))

      expect(node).to be_a(Zest::Nodes::Actionword)
      expect(node.childs[:name]).to eq('a simple actionword')
      expect(node.childs[:tags]).to eq([])
      expect(node.childs[:parameters]).to eq([])
      expect(node.childs[:body]).to eq([])
    end

    it 'with tags' do
      node = build_node(create_actionword('tagged', [@simple_tag, @key_value_tag]))

      expect(node).to be_a(Zest::Nodes::Actionword)
      expect(node.childs[:tags].length).to eq(2)
      expect(node.childs[:tags][0]).to be_a(Zest::Nodes::Tag)
      expect(node.childs[:tags][1]).to be_a(Zest::Nodes::Tag)
    end

    it 'with parameters' do
      node = build_node(
        create_actionword(
          'parameterized', [], [@simple_parameter, @valued_parameter]
          )
      )

      expect(node).to be_a(Zest::Nodes::Actionword)
      expect(node.childs[:parameters].length).to eq(2)
      expect(node.childs[:parameters][0]).to be_a(Zest::Nodes::Parameter)
      expect(node.childs[:parameters][1]).to be_a(Zest::Nodes::Parameter)
    end

    it 'with steps' do
      node = build_node(
        create_actionword('with steps', [], [], [@action_step, @result_step]))

      expect(node).to be_a(Zest::Nodes::Actionword)
      expect(node.childs[:body].length).to eq(2)
      expect(node.childs[:body][0]).to be_a(Zest::Nodes::Step)
      expect(node.childs[:body][1]).to be_a(Zest::Nodes::Step)
    end
  end

  context 'scenario' do
    it 'simple' do
      node = build_node(create_scenario('a simple scenario', 'Some description'))

      expect(node).to be_a(Zest::Nodes::Scenario)
      expect(node.childs[:name]).to eq('a simple scenario')
      expect(node.childs[:description]).to eq('Some description')
      expect(node.childs[:tags]).to eq([])
      expect(node.childs[:parameters]).to eq([])
      expect(node.childs[:body]).to eq([])
    end

    it 'with tags' do
      node = build_node(create_scenario('tagged', '', [@simple_tag, @key_value_tag]))

      expect(node).to be_a(Zest::Nodes::Scenario)
      expect(node.childs[:tags].length).to eq(2)
      expect(node.childs[:tags][0]).to be_a(Zest::Nodes::Tag)
      expect(node.childs[:tags][1]).to be_a(Zest::Nodes::Tag)
    end

    it 'with parameters' do
      node = build_node(
        create_scenario(
          'parameterized', '', [], [@simple_parameter, @valued_parameter]
          )
      )

      expect(node).to be_a(Zest::Nodes::Scenario)
      expect(node.childs[:parameters].length).to eq(2)
      expect(node.childs[:parameters][0]).to be_a(Zest::Nodes::Parameter)
      expect(node.childs[:parameters][1]).to be_a(Zest::Nodes::Parameter)
    end

    it 'with steps' do
      node = build_node(
        create_scenario('with steps', '', [], [], [@action_step, @result_step]))

      expect(node).to be_a(Zest::Nodes::Scenario)
      expect(node.childs[:body].length).to eq(2)
      expect(node.childs[:body][0]).to be_a(Zest::Nodes::Step)
      expect(node.childs[:body][1]).to be_a(Zest::Nodes::Step)
    end
  end

  it 'actionwords' do
    node = build_node("<actionwords>#{create_actionword('My actionword')}</actionwords>")

    expect(node).to be_a(Zest::Nodes::Actionwords)
    expect(node.childs[:actionwords].length).to eq(1)
    expect(node.childs[:actionwords][0]).to be_a(Zest::Nodes::Actionword)
  end

  it 'scenarios' do
    node = build_node("<scenarios>#{create_scenario('My scenario')}</scenarios>")

    expect(node).to be_a(Zest::Nodes::Scenarios)
    expect(node.childs[:scenarios].length).to eq(1)
    expect(node.childs[:scenarios][0]).to be_a(Zest::Nodes::Scenario)
  end

  context 'project' do
    it 'empty project' do
      node = TestParser.new("<?xml version=\"1.0\"?>
        <project>
          <name>My project</name>
          <description>A description</description>
        </project>").build_project

      expect(node).to be_a(Zest::Nodes::Project)
      expect(node.childs[:name]).to eq('My project')
      expect(node.childs[:description]).to eq('A description')
      expect(node.childs[:scenarios]).to be_a(Zest::Nodes::Scenarios)
      expect(node.childs[:actionwords]).to be_a(Zest::Nodes::Actionwords)
    end

    it 'with scenarios and actionwords' do
      node = TestParser.new("<?xml version=\"1.0\"?>
        <project>
          <name>My project</name>
          <description>A description</description>
          <scenarios>#{create_scenario('My scenario')}</scenarios>
          <actionwords>#{create_actionword('My actionword')}</actionwords>
        </project>").build_project

      expect(node).to be_a(Zest::Nodes::Project)
      node.childs[:name] = 'My project'
      node.childs[:description] = 'A description'
      expect(node.childs[:scenarios]).to be_a(Zest::Nodes::Scenarios)
      expect(node.childs[:actionwords]).to be_a(Zest::Nodes::Actionwords)
    end
  end

  it 'parses a full example' do
    parser = Zest::XMLParser.new(File.read('samples/xml_input/Zest publisher.xml'))
    project = parser.build_project

    expect(project.childs[:name]).to eq('Zest publisher')
    expect(project.find_sub_nodes.length).to eq(63)
    expect(project.find_sub_nodes(Zest::Nodes::Step).length).to eq(3)
  end
end
