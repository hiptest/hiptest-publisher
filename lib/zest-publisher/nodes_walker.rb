module Zest
  module Nodes
    class Walker

      def walk_project(project)
        walk_scenarios project.children[:scenarios]
        walk_actionwords project.children[:actionwords]
      end

      def walk_actionwords(actionwords)
        actionwords.children[:actionwords].each do |actionword|
          walk_actionword actionword
        end
      end

      def walk_actionword(actionword)
        walk_name(actionword.children[:name])
        walk_tags(actionword.children[:tags])
        walk_parameters(actionword.children[:parameters])
        walk_body(actionword.children[:body])
      end

      def walk_scenarios(scenarios)
        scenarios.children[:scenarios].each do |scenario|
          walk_scenario scenario
        end
      end

      def walk_scenario(scenario)
        walk_name(scenario.children[:name])
        walk_description(scenario.children[:description])
        walk_tags(scenario.children[:tags])
        walk_parameters(scenario.children[:parameters])
        walk_body(scenario.children[:body])
      end

      def walk_body(statements)
        statements.each do |statement|
          walk_node(statement)
        end
      end

      def walk_node(statement)
        statement_name = statement.class.name.split('::').last.downcase
        self.send("walk_#{statement_name}", statement)
      end

      def walk_call(call)
        walk_name(call.children[:actionword])
        walk_arguments(call.children[:arguments])
      end

      def walk_arguments(arguments)
        arguments.each do |argument|
          walk_argument argument
        end
      end

      def walk_argument(argument)
        walk_name argument.children[:name]
        walk_node argument.children[:value]
      end

      def walk_nullliteral literal
      end

      def walk_stringliteral(string)
        walk_value(string.children[:value])
      end

      def walk_booleanliteral(boolean)
        walk_value(boolean.children[:value])
      end

      def walk_variable(variable)
      end

      def walk_numericliteral(numericliteral)
        walk_value(numericliteral.children[:value])
      end

      def walk_value(value)

      end

      def walk_assign(assign)

      end

      def walk_ifthen(ifthen)

      end

      def walk_dict(dict)

      end

      def walk_template(template)

      end

      def walk_step(step)

      end

      def walk_while(while_statement)

      end

      def walk_parameters(parameters)
        parameters.each do |parameter|
          walk_parameter(parameter)
        end
      end

      def walk_parameter(parameter)
      end

      def walk_tags(tags)
        # code here
      end

      def walk_tag(tag)
      end

      def walk_description(description)
      end

      def walk_name(name)
      end

      def walk_property(property)

      end

      def walk_field(field)

      end

      def walk_index(index)

      end

      def walk_binaryexpression(binary_expression)

      end

      def walk_unaryexpression(unary_expression)

      end

      def walk_parenthesis(parenthesis)

      end

      def walk_list(list)

      end

    end
  end
end