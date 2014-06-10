require 'colorize'

require_relative 'spec_helper'
require_relative '../lib/zest-publisher/nodes'

describe Zest::Nodes do
  context 'Node' do
    it 'initialize sets @rendered_childs to an empty dict' do
      myNode = Zest::Nodes::Node.new
      expect(myNode.rendered_childs).to eq({})
    end

    context 'get_template_path' do
      it 'checks if the file exists in the common templates' do
        myNode = Zest::Nodes::StringLiteral.new('coucou')
        expect(myNode.get_template_path('python')).to eq('./lib/templates/common/stringliteral.erb')
      end

      it 'checks in the language template folder' do
        myNode = Zest::Nodes::Assign.new('x', 1)
        expect(myNode.get_template_path('ruby')).to eq('./lib/templates/ruby/assign.erb')
      end

      it 'checks in the framework specific folder if existing' do
        myNode = Zest::Nodes::Scenarios.new([])
        myNode.instance_variable_set(:@context, {framework: 'minitest'})
        expect(myNode.get_template_path('ruby')).to eq('./lib/templates/ruby/minitest/scenarios.erb')
      end
    end

    context 'render_childs' do
      it 'copies the child to @rendered_childs if it does not have a render method' do
        sut = Zest::Nodes::StringLiteral.new("What is your quest ?")
        expect(sut.rendered_childs).to eq({})
        sut.render_childs('ruby')
        expect(sut.rendered_childs).to eq({value: "What is your quest ?"})
      end

      it 'copies the rendered value if the child is a node instance' do
        child = Zest::Nodes::StringLiteral.new('What is your quest ?')
        allow(child).to receive(:render).and_return('What is your quest ?')
        sut = Zest::Nodes::Parenthesis.new(child)

        sut.render_childs('ruby')
        expect(sut.rendered_childs).to eq({content: 'What is your quest ?'})
        expect(child).to have_received(:render).once
      end

      it 'renders each child inside a list' do
        sut = Zest::Nodes::List.new([
          Zest::Nodes::StringLiteral.new('What is your quest ?'),
          Zest::Nodes::StringLiteral.new('To seek the Holy grail'),
        ])
        sut.render_childs('ruby')
        expect(sut.rendered_childs).to eq({:items => [
          "'What is your quest ?'",
          "'To seek the Holy grail'"
        ]})
      end

      it 'renders child only once' do
        child = Zest::Nodes::StringLiteral.new('What is your quest ?')
        allow(child).to receive(:render).and_return('What is your quest ?')
        sut = Zest::Nodes::Parenthesis.new(child)

        sut.render_childs('ruby')
        expect(child).to have_received(:render).once

        sut.render_childs('ruby')
        expect(child).to have_received(:render).once
      end

      it 'calls post_render_childs after rendering' do
        sut = Zest::Nodes::StringLiteral.new('What is the air-speed velocity of an unladen swallow?')
        allow(sut).to receive(:post_render_childs)
        sut.render_childs('ruby')
        expect(sut).to have_received(:post_render_childs).once
      end
    end

    it 'render' do
      sut = Zest::Nodes::Node.new()
      allow(sut).to receive(:read_template).and_return('This is a sample ERB: <%= @rendered_childs %>')
      sut.instance_variable_set(:@childs, {plic: 'Ploc'})

      expect(sut.render).to eq('This is a sample ERB: {:plic=>"Ploc"}')
      expect(sut.rendered).to eq('This is a sample ERB: {:plic=>"Ploc"}')
    end

    context 'indent_block' do
      it 'indent a block' do
        sut = Zest::Nodes::Node.new
        block = ["A single line", "Two\nLines", "Three\n  indented\n    lines"]
        expect(sut.indent_block(block)).to eq([
          "  A single line",
          "  Two",
          "  Lines",
          "  Three",
          "    indented",
          "      lines",
          ""
          ].join("\n"))
      end

      it 'can have a specified indentation' do
        sut = Zest::Nodes::Node.new
        expect(sut.indent_block(["La"], "---")).to eq("---La\n")
      end

      it 'if no indentation is specified, it uses the one from the context' do
        sut = Zest::Nodes::Node.new
        sut.instance_variable_set(:@context, {:indentation => '~'})

        expect(sut.indent_block(["La"])).to eq("~La\n")
      end

      it 'default indentation is wo spaces' do
        sut = Zest::Nodes::Node.new
        expect(sut.indent_block(["La"])).to eq("  La\n")
      end

      it 'also accepts a separator to join the result (aded to te line return)' do
        sut = Zest::Nodes::Node.new
        expect(sut.indent_block(["A", "B\nC", "D\nE"], '  ', '#')).to eq("  A\n#  B\n  C\n#  D\n  E\n")
      end
    end

    context 'find_sub_nodes' do
      before(:all) do
        @literal = Zest::Nodes::Literal.new(1)
        @var = Zest::Nodes::Variable.new('x')
        @assign = Zest::Nodes::Assign.new(@var, @literal)
      end

      it 'finds all sub-nodes (including self)' do
        expect(@literal.find_sub_nodes).to eq([@literal])
        expect(@assign.find_sub_nodes).to eq([@assign, @var, @literal])
      end

      it 'can be filter by type' do
        expect(@assign.find_sub_nodes(Zest::Nodes::Variable)).to eq([@var])
      end

      it 'can be unflattened (but it has no interest ...)' do
        expect(@assign.find_sub_nodes(nil, false)).to eq([
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

        expect(item.variables.map {|v| v.childs[:name]}).to eq(['x', 'y'])
      end

      it 'saves two lists of parameters: with and without default value' do
        simple = Zest::Nodes::Parameter.new('simple')
        valued = Zest::Nodes::Parameter.new('non_valued', '0')
        item = Zest::Nodes::Item.new('my item', [], [simple, valued])
        item.post_render_childs

        expect(item.non_valued_parameters).to eq([simple])
        expect(item.valued_parameters).to eq([valued])
      end
    end
    context 'has_parameters?' do
      it 'returns false if has not parameter' do
        item = Zest::Nodes::Item.new('my item', [], [])
        expect(item.has_parameters?).to be_falsey
      end
      it 'returns true if has at least one parameter' do
        item = Zest::Nodes::Item.new('my item', [], [Zest::Nodes::Parameter.new('piou')])
        expect(item.has_parameters?).to be_truthy
      end
    end
  end

  context 'Actionword' do
    context 'has_step?' do
      it 'returns true if body has at least one step' do
        step = Zest::Nodes::Step.new('action', 'value')
        myNode = Zest::Nodes::Actionword.new('name', tags = [], parameters = [], body = [step])
        expect(myNode.has_step?).to be_truthy
      end
      it 'returns false if there is no step in body' do
        myNode = Zest::Nodes::Actionword.new('name', tags = [], parameters = [], body = [])
        expect(myNode.has_step?).to be_falsey
      end
    end
  end

  context 'Call' do
    context 'has_arguments?' do
      it 'returns false if has no argument' do
        call = Zest::Nodes::Call.new('', [])
        expect(call.has_arguments?).to be_falsey
      end

      it 'returns true if has at least one argument' do
        call = Zest::Nodes::Call.new('', [Zest::Nodes::Argument.new('name', 'value')])
        expect(call.has_arguments?).to be_truthy
      end
    end
  end
end