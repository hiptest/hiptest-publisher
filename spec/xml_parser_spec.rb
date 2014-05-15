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
            <stringliteral>should be equal to 10</stringliteral>
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

      node.should be_a(Zest::Nodes::StringLiteral)
      node.childs[:value].should eq('Ho hi')
    end

    it 'numeric' do
      node = build_node('<numericliteral>3.14</numericliteral')

      node.should be_a(Zest::Nodes::NumericLiteral)
      node.childs[:value].should eq('3.14')
    end

    it 'boolean' do
      node = build_node('<booleanliteral>false</booleanliteral>')

      node.should be_a(Zest::Nodes::BooleanLiteral)
      node.childs[:value].should eq('false')
    end
  end

  it 'variable' do
    node = build_node(@my_var)

    node.should be_a(Zest::Nodes::Variable)
    node.childs[:name].should eq('my_var')
  end

  it 'field' do
    node = build_node("
      <field>
        <base>
          #{@my_var}
        </base>
        <name>accessor</name>
      </field>")

    node.should be_a(Zest::Nodes::Field)
    node.childs[:base].should be_a(Zest::Nodes::Variable)
    node.childs[:name].should eq('accessor')
  end

  it 'index' do
    node = build_node("
      <index>
        <base>#{@my_var}</base>
        <expression>#{@zero}</expression>
      </index>")

    node.should be_a(Zest::Nodes::Index)
    node.childs[:base].should be_a(Zest::Nodes::Variable)
    node.childs[:expression].should be_a(Zest::Nodes::NumericLiteral)
  end

  context 'operation' do
    it 'binary' do
      node = build_node("
        <operation>
          <left>#{@my_var}</left>
          <operator>+</operator>
          <right>#{@zero}</right>
        </operation>")

      node.should be_a(Zest::Nodes::BinaryExpression)
      node.childs[:left].is_a?(Zest::Nodes::Variable)
      node.childs[:operator].should eq('+')
      node.childs[:right].is_a?(Zest::Nodes::NumericLiteral)
    end

    it 'unary' do
      node = build_node("
        <operation>
          <operator>!</operator>
          <expression>#{@my_var}</expression>
        </operation>")

      node.should be_a(Zest::Nodes::UnaryExpression)
      node.childs[:operator].should eq('!')
      node.childs[:expression].is_a?(Zest::Nodes::Variable)
    end
  end

  it 'parenthesis' do
      node = build_node("<parenthesis>#{@my_var}</parenthesis>")

      node.should be_a(Zest::Nodes::Parenthesis)
      node.childs[:content].is_a?(Zest::Nodes::Variable)
  end

  context 'list' do
    it 'empty' do
      node = build_node("<list />")

      node.should be_a(Zest::Nodes::List)
      node.childs[:items].should eq([])
    end

    it 'with content' do
      node = build_node("
        <list>
          <item>#{@my_var}</item>
          <item>#{@zero}</item>
        </list>")

      node.should be_a(Zest::Nodes::List)
      node.childs[:items].length.should eq(2)
      node.childs[:items][0].should be_a(Zest::Nodes::Variable)
      node.childs[:items][1].should be_a(Zest::Nodes::NumericLiteral)
    end
  end

  context 'dict' do
    it 'empty' do
      node = build_node("<dict />")

      node.should be_a(Zest::Nodes::Dict)
      node.childs[:items].should eq([])
    end

    it 'empty' do
      node = build_node("
        <dict>
          <key>#{@my_var}</key>
          <another_key>#{@zero}</another_key>
        </dict>")

      node.should be_a(Zest::Nodes::Dict)
      node.childs[:items].length.should eq(2)
      node.childs[:items][0].should be_a(Zest::Nodes::Property)
      node.childs[:items][0].childs[:key].should eq('key')
      node.childs[:items][0].childs[:value].should be_a(Zest::Nodes::Variable)
      node.childs[:items][1].should be_a(Zest::Nodes::Property)
      node.childs[:items][1].childs[:key].should eq('another_key')
      node.childs[:items][1].childs[:value].should be_a(Zest::Nodes::NumericLiteral)
    end
  end

  it 'template' do
    node = build_node("
      <template>
        <stringliteral>Check the value of</stringliteral>
        #{@my_var}
      </template>")

    node.is_a?(Zest::Nodes::Template)
    node.childs[:chunks].length.should eq(2)
    node.childs[:chunks][0].should be_a(Zest::Nodes::StringLiteral)
    node.childs[:chunks][1].should be_a(Zest::Nodes::Variable)
  end

  it 'assign' do
    node = build_node(@assign_zero_to_my_var)

    node.is_a?(Zest::Nodes::Assign)
    node.childs[:to].should be_a(Zest::Nodes::Variable)
    node.childs[:value].should be_a(Zest::Nodes::NumericLiteral)
  end

  context 'call' do
    it 'no arguments' do
      node = build_node('<call><actionword>my action word</actionword></call>')

      node.should be_a(Zest::Nodes::Call)
      node.childs[:actionword].should eq('my action word')
      node.childs[:arguments].should eq([])
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

      node.should be_a(Zest::Nodes::Call)
      node.childs[:actionword].should eq('another action word')
      node.childs[:arguments].length.should eq(2)
      node.childs[:arguments][0].should be_a(Zest::Nodes::Argument)
      node.childs[:arguments][0].childs[:name].should eq('x')
      node.childs[:arguments][0].childs[:value].should be_a(Zest::Nodes::Variable)
      node.childs[:arguments][1].should be_a(Zest::Nodes::Argument)
      node.childs[:arguments][1].childs[:name].should eq('y')
      node.childs[:arguments][1].childs[:value].should be_a(Zest::Nodes::NumericLiteral)
    end
  end

  it 'step' do
    node = build_node(@action_step)

    node.should be_a(Zest::Nodes::Step)
    node.childs[:key].should eq('action')
    node.childs[:value].should be_a(Zest::Nodes::Template)
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

      node.should be_a(Zest::Nodes::IfThen)
      node.childs[:condition].should be_a(Zest::Nodes::Variable)
      node.childs[:then].length.should eq(1)
      node.childs[:then][0].should be_a(Zest::Nodes::Assign)
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

      node.should be_a(Zest::Nodes::IfThen)
      node.childs[:condition].should be_a(Zest::Nodes::Variable)
      node.childs[:then].length.should eq(1)
      node.childs[:then][0].should be_a(Zest::Nodes::Assign)
      node.childs[:else].length.should eq(1)
      node.childs[:else][0].should be_a(Zest::Nodes::Call)
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

    node.should be_a(Zest::Nodes::While)
    node.childs[:condition].should be_a(Zest::Nodes::Variable)
    node.childs[:body].length.should eq(1)
    node.childs[:body][0].is_a?(Zest::Nodes::Assign)
  end

  context 'tag' do
    it 'simple' do
      node = build_node(@simple_tag)

      node.should be_a(Zest::Nodes::Tag)
      node.childs[:key].should eq('simple')
    end

    it 'with a default value' do
      node = build_node(@key_value_tag)

      node.should be_a(Zest::Nodes::Tag)
      node.childs[:key].should eq('path')
      node.childs[:value].should eq("'path/to/somewhere'")
    end
  end

  context 'parameter' do
    it 'simple' do
      node = build_node(@simple_parameter)

      node.childs[:name].should eq('x')
      node.childs[:default].should be_nil
    end

    it 'with a default value' do
      node = build_node(@valued_parameter)

      node.childs[:name].should eq('y')
      node.childs[:default].should be_a(Zest::Nodes::List)
    end
  end

  context 'actionword' do
    it 'simple' do
      node = build_node(create_actionword('a simple actionword'))

      node.should be_a(Zest::Nodes::Actionword)
      node.childs[:name].should eq('a simple actionword')
      node.childs[:tags].should eq([])
      node.childs[:parameters].should eq([])
      node.childs[:body].should eq([])
    end

    it 'with tags' do
      node = build_node(create_actionword('tagged', [@simple_tag, @key_value_tag]))

      node.should be_a(Zest::Nodes::Actionword)
      node.childs[:tags].length.should eq(2)
      node.childs[:tags][0].should be_a(Zest::Nodes::Tag)
      node.childs[:tags][1].should be_a(Zest::Nodes::Tag)
    end

    it 'with parameters' do
      node = build_node(
        create_actionword(
          'parameterized', [], [@simple_parameter, @valued_parameter]
          )
      )

      node.should be_a(Zest::Nodes::Actionword)
      node.childs[:parameters].length.should eq(2)
      node.childs[:parameters][0].should be_a(Zest::Nodes::Parameter)
      node.childs[:parameters][1].should be_a(Zest::Nodes::Parameter)
    end

    it 'with steps' do
      node = build_node(
        create_actionword('with steps', [], [], [@action_step, @result_step]))

      node.should be_a(Zest::Nodes::Actionword)
      node.childs[:body].length.should eq(2)
      node.childs[:body][0].should be_a(Zest::Nodes::Step)
      node.childs[:body][1].should be_a(Zest::Nodes::Step)
    end
  end

  context 'scenario' do
    it 'simple' do
      node = build_node(create_scenario('a simple scenario', 'Some description'))

      node.should be_a(Zest::Nodes::Scenario)
      node.childs[:name].should eq('a simple scenario')
      node.childs[:description].should eq('Some description')
      node.childs[:tags].should eq([])
      node.childs[:parameters].should eq([])
      node.childs[:body].should eq([])
    end

    it 'with tags' do
      node = build_node(create_scenario('tagged', '', [@simple_tag, @key_value_tag]))

      node.should be_a(Zest::Nodes::Scenario)
      node.childs[:tags].length.should eq(2)
      node.childs[:tags][0].should be_a(Zest::Nodes::Tag)
      node.childs[:tags][1].should be_a(Zest::Nodes::Tag)
    end

    it 'with parameters' do
      node = build_node(
        create_scenario(
          'parameterized', '', [], [@simple_parameter, @valued_parameter]
          )
      )

      node.should be_a(Zest::Nodes::Scenario)
      node.childs[:parameters].length.should eq(2)
      node.childs[:parameters][0].should be_a(Zest::Nodes::Parameter)
      node.childs[:parameters][1].should be_a(Zest::Nodes::Parameter)
    end

    it 'with steps' do
      node = build_node(
        create_scenario('with steps', '', [], [], [@action_step, @result_step]))

      node.should be_a(Zest::Nodes::Scenario)
      node.childs[:body].length.should eq(2)
      node.childs[:body][0].should be_a(Zest::Nodes::Step)
      node.childs[:body][1].should be_a(Zest::Nodes::Step)
    end
  end

  it 'actionwords' do
    node = build_node("<actionwords>#{create_actionword('My actionword')}</actionwords>")

    node.should be_a(Zest::Nodes::Actionwords)
    node.childs[:actionwords].length.should eq(1)
    node.childs[:actionwords][0].should be_a(Zest::Nodes::Actionword)
  end

  it 'scenarios' do
    node = build_node("<scenarios>#{create_scenario('My scenario')}</scenarios>")

    node.should be_a(Zest::Nodes::Scenarios)
    node.childs[:scenarios].length.should eq(1)
    node.childs[:scenarios][0].should be_a(Zest::Nodes::Scenario)
  end

  context 'project' do
    it 'empty project' do
      node = TestParser.new("<?xml version=\"1.0\"?>
        <project>
          <name>My project</name>
          <description>A description</description>
        </project>").build_project

      node.should be_a(Zest::Nodes::Project)
      node.childs[:name].should eq('My project')
      node.childs[:description].should eq('A description')
      node.childs[:scenarios].should be_nil
      node.childs[:actionwords].should be_nil
    end

    it 'with scenarios and actionwords' do
      node = TestParser.new("<?xml version=\"1.0\"?>
        <project>
          <name>My project</name>
          <description>A description</description>
          <scenarios>#{create_scenario('My scenario')}</scenarios>
          <actionwords>#{create_actionword('My actionword')}</actionwords>
        </project>").build_project

      node.should be_a(Zest::Nodes::Project)
      node.childs[:name] = 'My project'
      node.childs[:description] = 'A description'
      node.childs[:scenarios].should be_a(Zest::Nodes::Scenarios)
      node.childs[:actionwords].should be_a(Zest::Nodes::Actionwords)
    end
  end

  it 'parses a full example' do
    parser = Zest::XMLParser.new(File.read('samples/xml_input/Zest publisher.xml'))
    project = parser.build_project

    project.childs[:name].should eq('Zest publisher')
    project.find_sub_nodes.length.should eq(63)
    project.find_sub_nodes(Zest::Nodes::Step).length.should eq(3)
  end
end