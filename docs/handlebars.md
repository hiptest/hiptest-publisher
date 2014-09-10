A quick guide for handlebars and Zest publisher
===============================================

Zest publisher uses [handlebars](http://handlebarsjs.com/) as a templating language. This guide explains some basics about handlebars, caveats to use with Zest and explains our custom helpers.

Handlebars basics
-----------------

Handlebars and Zest caveats
---------------------------

Zest custom helpers
-------------------

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
{{remove_quotes 'This is "my" string' }}
```

```
This is my string
```

Removes double quotes from a string.

### escape_quotes
```handlebars
{{escape_quotes 'This is "my" string' }}
```

```
This is \"my\" string
```

Escapes double quotes from a string.

### join
```handlebars
{{join [1, 2, 3] '-'}}
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