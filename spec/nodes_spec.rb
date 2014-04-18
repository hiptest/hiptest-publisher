require 'colorize'
require_relative '../nodes'

describe Zest::Nodes do
  context 'Node' do
    it 'initialize sets @rendered_childs to an empty dict' do
      myNode = Zest::Nodes::Node.new
      myNode.rendered_childs.should eq({})
    end

    context 'get_template_path' do
      it 'checks if the file exists in the common templates' do
        myNode = Zest::Nodes::StringLiteral.new('coucou')
        myNode.get_template_path('python').should eq('templates/common/stringliteral.erb')
      end

      it 'checks in the language template folder' do
        myNode = Zest::Nodes::Assign.new('x', 1)
        myNode.get_template_path('ruby').should eq('templates/ruby/assign.erb')
      end

      it 'checks in the framework specific folder if existing' do
        myNode = Zest::Nodes::Scenarios.new([])
        myNode.get_template_path('ruby', {framework: 'minitest'}).should eq('templates/ruby/minitest/scenarios.erb')
      end
    end

    context 'render_childs' do
      class FakeNode < Zest::Nodes::Node
        attr_reader :rendered

        def initialize
          @rendered = false
        end

        def render(lang, context)
          @rendered = true
          'Node is rendered'
        end
      end

      it 'copies the child to @rendered_childs if it does not have a render method' do
        sut = Zest::Nodes::StringLiteral.new("What is your quest ?")
        sut.rendered_childs.should eq({})
        sut.render()
        sut.rendered_childs.should eq({value: "What is your quest ?"})
      end

      it 'copies the rendered value if the child is a node instance' do
        sut = Zest::Nodes::StringLiteral.new(FakeNode.new)
        sut.render()
        sut.rendered_childs.should eq({value: 'Node is rendered'})
        sut.childs[:value].rendered.should be_true
      end

      it 'renders each child inside a list' do
        sut = Zest::Nodes::StringLiteral.new([FakeNode.new, FakeNode.new])
        sut.render()
        sut.rendered_childs.should eq({value: ['Node is rendered', 'Node is rendered']})
      end

      it 'renders child only once' do
        sut = Zest::Nodes::StringLiteral.new(FakeNode.new)
        sut.render()
        sut.rendered_childs.should eq({value: 'Node is rendered'})

        sut.childs[:value] = 'Something'
        sut.render()
        sut.rendered_childs.should eq({value: 'Node is rendered'})
      end

      it 'calls post_render_childs after rendering' do
        class Zest::Nodes::MockStringLiteral < Zest::Nodes::StringLiteral
          attr_reader :post_render_args

          def post_render_childs (context)
            @post_render_args = context
          end
        end

        sut = Zest::Nodes::MockStringLiteral.new(FakeNode.new)
        sut.render_childs('ruby', {some: 'Context'})

        sut.post_render_args.should eq({some: 'Context'})
      end
    end

    it 'render' do
      class Zest::Nodes::MockNode < Zest::Nodes::Node
        def initialize
          super()
          @childs = {plic: 'Ploc'}
        end

        def read_template(language, context = {})
          return 'This is a sample ERB: <%= @rendered_childs %>'
        end
      end

      sut = Zest::Nodes::MockNode.new
      sut.render.should eq('This is a sample ERB: {:plic=>"Ploc"}')
      sut.rendered.should eq('This is a sample ERB: {:plic=>"Ploc"}')
    end

    it 'indent_block' do
      sut = Zest::Nodes::Node.new
      block = ["A single line", "Two\nLines", "Three\n  indented\n    lines"]
      sut.indent_block(block).should eq([
        "  A single line",
        "  Two",
        "  Lines",
        "  Three",
        "    indented",
        "      lines",
        ""
        ].join("\n"))
    end

    context 'find_sub_nodes' do
      before(:all) do
        @literal = Zest::Nodes::Literal.new(1)
        @var = Zest::Nodes::Variable.new('x')
        @assign = Zest::Nodes::Assign.new(@var, @literal)
      end

      it 'finds all sub-nodes (including self)' do
        @literal.find_sub_nodes.should eq([@literal])
        @assign.find_sub_nodes.should eq([@assign, @var, @literal])
      end

      it 'can be filter by type' do
        @assign.find_sub_nodes(Zest::Nodes::Variable).should eq([@var])
      end

      it 'can be unflattened (but it has no interest ...)' do
        @assign.find_sub_nodes(nil, false).should eq([
          @assign,
          [
            [@var, []],
            [@literal, []]
          ]
        ])
      end
    end
  end

  context 'Item' do
    context 'post_render_childs' do
      it 'finds all variable declared in the steps' do
        item = Zest::Nodes::Item.new('my item', [], [], [
          Zest::Nodes::Step.new(
            'result',
            Zest::Nodes::Template.new([
              Zest::Nodes::Variable.new('x'),
              Zest::Nodes::StringLiteral.new('should equals 0')
            ])),
          Zest::Nodes::Assign.new(
            Zest::Nodes::Variable.new('y'),
            Zest::Nodes::Variable.new('x')
          )
        ])
        item.post_render_childs

        item.variables.map {|v| v.childs[:name]}.should eq(['x', 'y'])
      end

      it 'saves two lists of parameters: with and without default value' do
        simple = Zest::Nodes::Parameter.new('simple')
        valued = Zest::Nodes::Parameter.new('non_valued', '0')
        item = Zest::Nodes::Item.new('my item', [], [simple, valued])
        item.post_render_childs

        item.non_valued_parameters.should eq([simple])
        item.valued_parameters.should eq([valued])
      end
    end
  end

  context 'Actionword' do
    it 'has_step return true if body has at least one step' do
      step = Zest::Nodes::Step.new('action', 'value')
      myNode = Zest::Nodes::Actionword.new('name', tags = [], parameters = [], body = [step])
      myNode.has_step.should eq(true)
    end
    it 'has_step return false if no step in body' do
      myNode = Zest::Nodes::Actionword.new('name', tags = [], parameters = [], body = [])
      myNode.has_step.should eq(false)
    end

  end
end