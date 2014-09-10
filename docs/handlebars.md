A quick guide for handlebars and Zest publisher
===============================================

Zest publisher uses [handlebars](http://handlebarsjs.com/) as a templating language. This guide explains some basics about handlebars, caveats to use with Zest and explains our custom helpers.

Handlebars basics
-----------------

Handlebars and Zest-publisher caveats
-------------------------------------

### Whitespaces

Handlebars is designed to generate HTML code, where white spaces and line returns do not really count. With Zest-publisher, we generate code that will be interpreted or compiled, so those characters might be important (for example in python, indentation defines block of code).

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
For that, we added three helpers: curly, open_curly and close_curly

```handlebars
Considering my_value is "Hi !"
{{ my_value }} will display "Hi !"
{{{ my_value }}} will display "Hi !" (see above section on special characters)
{{{{ my_value }}}} will fail at compilation
{{#curly}}{{ my_value }}{{/curly}} will display "{Hi !}"
{{ open_curly }}{{ my_value }}{{ close_curly }} will also display "{Hi !}"
```

Zest custom helpers
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

### remove_quotes
```handlebars
{{ remove_quotes 'This is "my" string' }}
```

```
This is my string
```

Removes double quotes from a string.

### escape_quotes
```handlebars
{{ escape_quotes 'This is "my" string' }}
```

```
This is \"my\" string
```

Escapes double quotes from a string.

### join
```handlebars
{{ join [1, 2, 3] '-' }}
```

```
1-2-3
```

Transforms a list of object into a string, separating each value with the joiner.

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