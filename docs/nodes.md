HipTest nodes documentation
===========================

Each element in a HipTest project is translated in HipTest publisher as a Node. This documentation will show for each type of Node its equivalent in HipTest and some hints on its content.
To ease understanding, we'll sort them by type.

Some knowledge of the [HipTest test description language](https://hiptest.net/tdl_documentation.html) is needed here as all example will be written with this language (you can have example in your project by opening a scenario and clicking on the "Go to code" link above the definition).

Literals and types
------------------

### [NullLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#nullliteral)

```ruby
nil
```

Well, not much to say, this node has no child.


### [StringLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#stringliteral)

```ruby
'A string wrap in single quotes'
```

This node has a single child, 'value' which contains the value of the string.

### [NumericLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#numericliteral)

```ruby
3
```

This node has a single child, 'value'. Note that this value is a string and no difference is done between integer and floats.


### [BooleanLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#booleanliteral)

```ruby
false
```

This node has a single child, 'value'. Node that the value is a string.

### [Variable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#variable)

```ruby
my_wonderful_variable
```

This name has a single child, 'name'.


### [List](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#list)

```ruby
[1, 'list', "of", 'things']
```

This node has a single child, 'items', that is a list of nodes.


### [Dict](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#dict)

```ruby
{a: '1', b: 2}
```

This node has a single child, 'items', that is a list of [Property](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#property) nodes.

### [Property](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#property)

This node is never directly written in HipTest. It has two children, 'key' and 'value'.


### [Template](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#template)

```ruby
"A string with double quote and potentially replaced ${variables}"
```

This type of node has a single child, 'chunks' which list the parts of the template based on the replacements done in the template.

Some example might be easier to explain:
 - "My template" will have only one chunk that will be a [StringLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#stringliteral) with value 'My template'
 - "My template: ${x}" will have two chunks: the first one is a [StringLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#stringliteral) with value 'My template: ', the second one will be a [Variable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#variable) with name 'x'
 - "My template: ${x} is a variable" will have three chunks: the first one is a [StringLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#stringliteral) with value 'My template: ', the second one will be a [Variable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#variable) with name 'x' and the last one a [StringLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#stringliteral) with value ' is a variable'

Data access
-----------

### [Field](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#field)

```ruby
x.size
```

This node has two children:
 - base: a node corresponding to the part before the dot (in the previous example, a [Variable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#variable) named 'x')
 - name: a string containing the accessed field (in the previous example, 'size')

### [Index](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#index)

```ruby
my_list[2]
```

This node has two children:
 - base: a node corresponding to th part before the dot (in the previous example, a [Variable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#variable) called 'my_list')
 - expression: a node corresponding to the accessed index (in the previous example, a [NumericLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#numericliteral) with value 2)

Expressions
-----------

### [BinaryExpression](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#binaryexpression)

```ruby
3 + 4
```

This node has three children:
 - left: a node representing the left part of the expression (in our example, a [NumericLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#numericliteral) with value 3)
 - operator: a string representing the operator (in our example: '+')
 - right: a node representing the right part of the expression (in our example, a [NumericLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#numericliteral) with value 4)


### [UnaryExpression](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#unaryexpression)

```ruby
-3
```

This node has two children:
 - operator: a string representin the operator (in our example, '-')
 - expression: a node representing the operated expression (in our example, a [NumericLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#numericliteral) with value 3)


### [Parenthesis](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#parenthesis)

```ruby
(3 + 2)
```

This node has a single child, 'content', a node representing the content of the parenthesis (in our example, a [BinaryExpression](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#binaryexpression))


Statements
----------

### [Step](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#step)

```ruby
step {
  action: "Select the book ${title}"
}
```

This node a two chidren:
 - key: a string representing the type of step (action or result)
 - value: a node representing the step value (in the previous example, a [Template](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#template))


### [Call](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#call)

```ruby
call given 'my_actionword' (x = 2)
```

This node has three children:
 - annotation: a string representing the kind of step in Gherkin laguage: given, when, then, and, etc... It is null if none is specified
 - actionword: a string representing the name of the called action word (in our example 'my_actionword')
 - arguments: a list of [Argument](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#argument) nodes


### [Argument](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#argument)

This node has two children:
 - name: a string representing the name of the actionword parameter (in the previous example, 'x')
 - value: a node representing the value of the argument (in the previous example, a [NumericLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#numericliteral) with value 2)


### [Assign](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#assign)

```ruby
a := 3
```

This node has two children:
 - to: a node corresponding to the assigned value (in our example, a [Variable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#variable) called 'a')
 - value: a node corresponding to the assigned value (in our example, a [NumericLiteral](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#numericliteral) with value 3)


### [IfThen](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#ifthen)

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


### [While](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#while)

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

### [Datatable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#datatable)

This type of node has only one child, 'datasets', which is a list of [Dataset](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#dataset) nodes.


### [Dataset](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#dataset)

In HipTest, a dataset correspond to a line of a datatable.

This type of node has two children:
 - name: a string giving the name of the dataset (the column "[Dataset](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#dataset) name" in HipTest)
 - arguments: a list of [Argument](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#argument) nodes, corresponding to the user input.


HipTest objects
---------------

### [Actionword](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#actionword)

This type of node has four children:
 - name: a string representing the action word name
 - tags: a list of [Tag](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#tag) nodes
 - parameters: a list of [Parameter](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#parameter) node
 - body: a list of nodes representing the action word definition


### [Scenario](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#scenario)

A scenario has the same children than an [Actionword](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#actionword), plus two extra ones:
 - description: a string
 - datatable: a [Datatable](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#datatable) node


### [Parameter](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#parameter)

This type of node describes a scenario or actionword parameter. It has two children:
 - name: a string, the parameter's name
 - default: a node representing the parameter's default value or nil if there is no default value specified

It is also possible to access the 'type' attribute of a parameter node.

### [Tag](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#tag)
```
@mytag @a_valued_tag:42
```

This type of node has two children:
 - key: a string reprenting the part before the colon. In the previous example: 'mytag' or 'a_valued_tag'
 - value: a string representing the part after the color. In the previous example: '42'

### [Actionwords](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#actionwords)

The list of the project's action words. Contains a single child, 'actionwords' which is the list.

### [Scenarios](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#scenarios)

Same as [Actionword](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#actionword)s but for scenarios. The list name is 'scenarios'.

Use `folder` to get the containing folder.

### [Folder](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#folder)

Represent a folder in the scenario's hierarchical view in HipTest. It has three children:
 - name: a string
 - description: a string
 - subfolders: a list of [Folder](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#folder) nodes
 - scenarios: a list of [Scenario](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#scenario) nodes

It is possible to access a folder's parent via the `parent` attribute. Note that the `parent` of the root folder is the [TestPlan](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#testplan). Use `folder` to get the parent folder, or `nil` if the folder is the root folder.

Use `root?` to know if the folder is the root folder.

### [TestPlan](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#testplan)

Stores all the folders of a project. It has two children:
 - root_folder: a [Folder](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#folder) node, the root folder of the project
 - folders: a list of [Folder](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#folder) node, all the project's folders

### [Project](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#project)

The root node. It has five children:
 - name: a string
 - description: a string
 - test_plan: the [TestPlan](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#testplan) node for the project
 - scenarios: the [Scenarios](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#scenarios) node for the project
 - actionwords: the [Actionwords](https://github.com/hiptest/hiptest-publisher/blob/master/docs/nodes.md#actionwords) node for the project
