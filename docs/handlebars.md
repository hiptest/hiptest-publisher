A quick guide for handlebars and Hiptest publisher
==================================================

Hiptest publisher uses [handlebars](http://handlebarsjs.com/) as a templating language. This guide explains [some basics about handlebars](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#handlebars-basics), [caveats to use with Hiptest](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#handlebars-and-hiptest-publisher-caveats), [available data for each node](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#available-values-in-templates) and explains our [custom helpers](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#hiptest-custom-helpers).


Handlebars basics
-----------------

We chose handlebars as the templating system as it is language agnostic and pretty simple to use. The main commands you will need to use will be:

 - ``{{{ my_value }}}``: will output the value of the variable 'my_value'
 - ``{{#if my_value}}Hello{{/if}}``: will output "Hello" if the variable 'my_value' is true (or not empty)
 - ``{{#if my_value}}Hello{{else}}Goodbye{{/if}}``: same as before but will also display "Goodbye" if 'my_value' if false or empty
 - ``{{#each my_list}}{{{this}}}{{/each}}``: will output every element of 'my_list'
 - ``{{> my_partial}}``: will render the templates names '_my_partial.hbs' with the same context (so you don't have to repeat yourself)

Helpers can be used with the notation ``{{{ helperName value }}}`. You will mainly use our [custom helpers](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#hiptest-custom-helpers), we provide an example for each one.


Handlebars and hiptest-publisher caveats
----------------------------------------

### Whitespaces

Handlebars is designed to generate HTML code, where white spaces and line returns do not really matter. With hiptest-publisher, we generate code that will be interpreted or compiled, so those characters might be important (for example in python, indentation defines block of code).

This explains why templates might look a bit bulky. For the same reason, there is no indentation of the handlebars code. It would look way nicer, but the output code would have a really weird indentation.

### No new lines at end of file

You might have seen that almost all templates do not have a new line at the end of the file. This is done to avoid getting a weird output.

Even statements (calling a function, assigning a variable etc) do not generate new line. This should be handled by the ``{{each}}`` block that iterates on statements.

Example:
```handlebars
{{#each statements}}{{{this}}}
{{/each}}
```

Will generate a output with each statement on a separate line. it is easier to handle it this way than adding a line return after each statement.

### Special characters

Handlebars automagically escapes some characters ('<' for example) which is great when generating HTML but not that much when generating code (``if (x &gt; 0)`` does not make sense in many languages).
To avoid this problem, it is better to use the triple bracket notation that will consider the strings a safe.

```handlebars
{{{ my_value }}} is better than {{ my_value }} to get usable code :)
```

### {Curly braces}

Handlebars relies heavily on curly braces but they are not the only ones. You might run into problems when trying to output curly braces that you do not wnat to be interpreted.
For that, we added three helpers: [curly](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#curly), [open_curly](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#open_curly) and [close_curly](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md#close_curly).

```handlebars
Considering my_value is "Hi !"
{{ my_value }} will display "Hi !"
{{{ my_value }}} will display "Hi !" (see above section on special characters)
{{{{ my_value }}}} will fail at compilation
{{#curly}}{{ my_value }}{{/curly}} will display "{Hi !}"
{{ open_curly }}{{ my_value }}{{ close_curly }} will also display "{Hi !}"
```

### Definition rendering

In most cases, rendering a scenario or an action word definition use the same code. To keep DRY, there is support for a partial template.

This template must be named '_body.hbs' and contain the code to render the steps. In a scenario/action word template, simply use ``{{> body}}`` to get the definition rendered.

Available values in templates
-----------------------------

In any template, you will have access to the following elements:
 - node: is the currently rendered node. In most cases, you will not need it. The main use case is accessing the project in the list of scenarios (``node.parent``) to get the project name.
 - rendered_children: contains the node's children already rendered. If you write your templates based on existing ones, the content should be pretty straightfoward. For more explanations on the content, you can have a look at the [nodes documentation](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md).
 - context: the rendering context. It is related to the language and the file to which the rendering is output. It contains some useful external information determined from user config:
   - ``context.call_prefix`` is the name of the actionwords instance, used to prefix actionwords calls
   - ``context.filename`` is the filename of the rendered output file, like ``WelcomeTest.js``
   - ``context.folder`` is the full absolute folder of the rendered output file, like ``/home/john/project/tests/greeter``
   - ``context.package`` is the package name
   - ``context.path`` is the full absolute path of the rendered output file, like ``/home/john/project/tests/greeter/WelcomeTest.js``
   - ``context.relative_folder`` is the folder relative to the output directory, like ``greeter`` if ``/home/john/project/tests`` is the output directory
   - ``context.relative_path`` is the path relative to the output directory, like ``greeter/WelcomeTest.js`` if ``/home/john/project/tests`` is the output directory
   - ``context.uids`` is ``false`` if option ``--no-uids`` has been used, ``true`` otherwise

For some nodes, we add some extra context shown below for each type of node. Following the Ruby naming convention, names ending with a question mark are booleans.

Those data can be directly used inside handlebars condition. For example in ``scenario.hbs``:

```handlebars
{{#if has_parameters?}}show the parameters{{/if}}
```

### actionword

``has_parameters?`` is true when the action word or scenario has parameters.

``has_tags?`` is true when tags have been set on the scenario or action word.

``has_step?`` is true if there is at least one step (action/result in Hiptest) in the definition.

``is_empty?`` is true when the definition is empty.

### scenario

The same values are available than  for actionword, plus:
 - ``project_name``: provides the project's name.
 - ``has_datasests?``: true if there is at least one dataset defined

### dataset

``scenario_name``, the name of the scenario the dataset belongs to


### scenarios

``project_name`` provides the project's name.

### call

``has_arguments?`` is true when arguments are given when calling the action word.

### ifthen

``has_else?`` is true when the ``else`` part is specified.

### parameter

``has_default_value?`` is true when the parameter is defined with a default value.

### tag

``has_value?`` is true when the tag has a value (for example: "priority:1" in Hiptest, 1 is the value).

### template

A bit more explanation is needed here.

In Hiptest, templates are double quoted string. It is possible to include some variables inside (for example: "Ensure value is: ${x}"). When exporting the data, the string is splitted into chunks. With the previous example, there will be two chunks: 'Ensure value is: ' which will be a ``Hiptest::Nodes::StringLiteral`` instance and x which will be a ``Hiptest::Nodes::Variable`` instance.

``treated_chunks`` gives the list of chunks with an extra information (``is_variable?``) that tells if the chunks is a variable of not. It also provide the raw node.

``variable_names`` list the name of all variables used in the template.

The main use for that is to be able to generate code that will do the replacement in string. The easiest way to understand this is to have a look at the ``template.hbs`` file in the Java or Python directory.

Hiptest custom helpers
-------------------

We provide a few custom helpers that can be used in templates. For each one, we show an example on how to use it and below the output it will provide.


### literate
```handlebars
{{ literate "àéïøù" }}
```

```
aeiou
```

Replaces all special characters (for example accents) into a non-special character.

### normalize
```handlebars
{{ normalize "àé ï-ø 'ù'" }}
```

```
ae_i_o_u
```

Transforms a string so it can be used for coding (no special characters, no quotes, no spaces).

### underscore
```handlebars
{{ underscore "My scenario" }}
```

```
my_scenario
```

Normalizes a string and tranforms it to snake case.

### camelize
```handlebars
{{ camelize "My second scenario" }}
```

```
MySecondScenario
```

Normalizes a string and transforms it to camel case.

### camelize_lower
```handlebars
{{ camelize_lower "My second scenario" }}
```

```
mySecondScenario
```

Same as camelize, except that the first letter will me lowerized.

### clear_extension
```handlebars
{{ clear_extension "example.java" }}
```

```
example
```

Given a filename, removes the extension.

### to_string
```handlebars
{{ to_string true }}
```

```
true
```

Transforms a value to a string (mainly needed for boolean values)

### remove_double_quotes
```handlebars
{{ remove_double_quotes 'This is "my" string' }}
```

```
This is my string
```

Removes double quotes from a string.

### escape_double_quotes
```handlebars
{{ escape_double_quotes 'This is "my" string' }}
```

```
This is \"my\" string
```

Escapes double quotes from a string.

### remove_single_quotes
```handlebars
{{ remove_single_quotes "This is 'my' string" }}
```

```
This is my string
```

Removes single quotes from a string.

### escape_single_quotes
```handlebars
{{ escape_single_quotes "This is 'my' string" }}
```

```
This is \'my\' string
```

Escapes single quotes from a string.

### join
```handlebars
{{ join [1, 2, 3] '-' }}
```

```
1-2-3
```

Transforms a list of object into a string, separating each value with the joiner.

If can also accept a block for rendering. In this case, the current item is referred as ``this`` (like in an ``each`` block):

```handlebars
{{#join [1, 2, 3] ' || ' }}<b>{{this}}</b>{{/join}}
```

```
<b>1</b> || <b>2</b> || <b>3</b>
```

### indent
```handlebars
{{#indent}}
First line
Another line
{{/indent}}
```

```
  First line
  Another line
```

Indents the content of a block. Default indentation is two spaces but can be changed at language level.

### clear_empty_lines
```handlebars
{{#clear_empty_lines}}
First line

Another line
{{/clear_empty_lines}}
```

```
First line
Another line
```

Removes all empty lines from the content of the block. Lines containing only white characters (spaces, tabulation etc) will also be removed.


### comment
```handlebars
{{#comment '//'}}
First line
Another line
{{/comment}}
```

```
// First line
// Another line
```

Comments lines in a block. It automatically add a space between the commenter and the beginning of each line.


### curly
```handlebars
if (x == 0) {{#curly}}x++{{/curly}}
```

```
if (x == 0) {x++}
```

Wraps the block with curly braces ("{}"). This is mainly used to avoid problems with handlebars interpreting the braces you want to be outputed (for example block delimiters in Java)


### open_curly
```handlebars
{{ open_curly }}
```

```
{
```

Outputs an opening curly bracket.

### close_curly
```handlebars
{{ close_curly }}
```

```
}
```

Outputs an closing curly bracket.

### tab
```handlebars
{{ tab }}
```

Outputs a tabulation character.

### if_includes
``` handlebars
{{ #if_includes array element}}
  case true
{{ else }}
  case false
{{ /if_includes }}
```
Outputs the true block if array contains element otherwise the false one.
