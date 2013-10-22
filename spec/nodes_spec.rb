require 'colorize'
require_relative '../nodes'

describe Zest::Nodes do
  context 'Node' do
    it 'initialize sets @rendered_childs to an empty dict' do
      myNode = Zest::Nodes::Node.new
      myNode.rendered_childs.should eq({})
    end

    it 'get_template_path' do
      myNode = Zest::Nodes::Node.new
      myNode.get_template_path('python').should eq('templates/python/node.erb')
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

      it 'renderes each child inside a list' do
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

        def read_template(language)
          return 'This is a sample ERB: <%= @rendered_childs %>'
        end
      end

      sut = Zest::Nodes::MockNode.new
      sut.render.should eq('This is a sample ERB: {:plic=>"Ploc"}')
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
  end
end