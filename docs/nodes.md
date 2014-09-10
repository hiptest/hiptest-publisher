Zest nodes documentation
========================

Each element in a Zest project is translated in Zest publisher as a Node. This documentation will show for each type of Node its equivalent in Zest and some hints on its content.
To ease understanding, we'll sort them by type.

Some knowledge of the [Zest test description language](https://zest.smartesting.com/tdl_documentation.html) is needed here as all example will be written with this language (you can have example in your project by opening a scenario and clicking on the "Go to code" link above the definition).

Literals and types
------------------

### NullLiteral

```ruby
nil
```

Well, not much to say, this node has no child.


### StringLiteral

```ruby
'A string wrap in single quotes'
```

This node has a single child, 'value' which contains the value of the string.

### NumericLiteral

```ruby
3
```

This node has a single child, 'value'. Note that this value is a string and no difference is done between integer and floats.


### BooleanLiteral

```ruby
false
```

This node has a single child, 'value'. Node that the value is a string.

### Variable

```ruby
my_wonderful_variable
```

This name has a single child, 'name'.


### List

```ruby
[1, 'list', "of", 'things']
```

This node has a single child, 'items', that is a list of nodes.


### Dict

```ruby
{a: '1', b: 2}
```

This node has a single child, 'items', that is a list of ``Property`` nodes.

### Property

This node is never directly written in Zest. It has two children, 'key' and 'value'.


### Template

```ruby
"A string with double quote and potentially replaced ${variables}"
```

This type of node has a single child, 'chunks' which list the parts of the template based on the replacements done in the template.

Some example might be easier to explain:
 - "My template" will have only one chunk that will be a StringLiteral with value 'My template'
 - "My template: ${x}" will have two chunks: the first one is a StringLiteral with value 'My template: ', the second one will be a Variable with name 'x'
 - "My template: ${x} is a variable" will have three chunks: the first one is a StringLiteral with value 'My template: ', the second one will be a Variable with name 'x' and the last one a StringLiteral with value ' is a variable'

Data access
-----------

### Field

```ruby
x.size
```

This node has two children:
 - base: a node corresponding to the part before the dot (in the previous example, a Variable named 'x')
 - name: a string containing the accessed field (in the previous example, 'size')

### Index

```ruby
my_list[2]
```

This node has two children:
 - base: a node corresponding to th part before the dot (in the previous example, a Variable called 'my_list')
 - expression: a node corresponding to the accessed index (in the previous example, a NumericLiteral with value 2)

Expressions
-----------

### BinaryExpression

```ruby
3 + 4
```

This node has three children:
 - left: a node representing the left part of the expression (in our example, a NumericLiteral with value 3)
 - operator: a string representing the operator (in our example: '+')
 - right: a node representing the right part of the expression (in our example, a NumericLiteral with value 4)


### UnaryExpression

```ruby
-3
```

This node has two children:
 - operator: a string representin the operator (in our example, '-')
 - expression: a node representing the operated expression (in our example, a NumericLiteral with value 3)


### Parenthesis

```ruby
(3 + 2)
```

This node has a single child, 'content', a node representing the content of the parenthesis (in our example, a BinaryExpression)


Statements
----------

### Step

```ruby
step {
  action: "Select the book ${title}"
}
```

This node a two chidren:
 - key: a string representing the type of step (action or result)
 - value: a node representing the step value (in the previous example, a Template)


### Call

```ruby
call 'my_actionword' (x = 2)
```

This node has two children:
 - actionword: a string representing the name of the called action word (in our example 'my_actionword')
 - arguments: a list of Argument nodes


### Argument

This node has two children:
 - name: a string representing the name of the actionword parameter (in the previous example, 'x')
 - value: a node representing the value of the argument (in the previous example, a NumericLireal with value 2)


### Assign

```ruby
a := 3
```

This node has two children:
 - to: a node corresponding to the assigned value (in our example, a Variable called 'a')
 - value: a node corresponding to the assigned value (in our example, a NumericLiteral with value 3)


### IfThen

```ruby
if (x == 2)
  call 'my_actionword'
end

if (x == 2)
  call 'my_actionword'
else
  call 'another_actionword'
end
```

This node has three children:
 - condition: a node representing the condition expression
 - then: a list of nodes representing the statements if the condition is satisfied
 - else: a list of nodes representing the statements if the condition is not satisfied


### While

```ruby
while (x == 2)
  call 'my_actionword'
end
```

This node has two children:
 - condition: a node representing the condition
 - body: a list of nodes representing the statements to be executed during the loop


Datatable
---------

### Datatable

This type of node has only one child, 'datasets', which is a list of Dataset nodes.


### Dataset

In Zest, a dataset correspond to a line of a datatable.

This type of node has two children:
 - name: a string giving the name of the dataset (the column "Dataset name" in Zest)
 - arguments: a list of Argument nodes, corresponding to the user input.
