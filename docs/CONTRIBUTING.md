Contributing
============

Do not hesitate to contribute to the project by adding support for your favorite language or test framework as explained below. This tool was built to be configurable and have the possibility to export tests in any language.

We did our best to make it as simple as possible, but some knowledge of ruby, handlebars and [HipTest test description language](https://app.hiptest.com/tdl_documentation.html) is needed to add support for new languages/frameworks.

Adding support for a new language
---------------------------------

Let's say we want to add support for Scala export.

The first step is to write the tests. Copy the file ``spec/render_template_spec.rb.sample``  to ``spec/render/scala_spec.rb`` and edit it with your favorite editor. Replace ``<My language>`` by ``scala`` and ``<The test framework>`` by test framework that will be considered as default for all Scala exports (well, you added support for Scala, you can at least have the right to chose what the tests framework will be ;) ).

Run the following command line:

```shell
rspec spec/render/scala_spec.rb -f d
```

Note for Gherkin based languages (such as Cucumber, Specflow, Behave, Behat, Lettuce and so on): those languages have another list of tests. If you want to add support for this kind of language, use ``spec/render__gherkin_template_spec.rb.sample`` file as a template instead. Good news, there are way less parts to complete for those languages :)

Normally, you should see a lot of tests failing and that's totally normal (only 5 tests should pass).
Now you have to update the expected output when exporting in Scala. That is the variables ``@<some name, mainly about the Foo Fighters>`` declared in the ``before(:each)`` block. For all expected output, we also added the corresponding text in HipTest test description language.

Once all the expectations are written, it is time to write the template. The simplest way is to copy the Ruby sources:

```shell
mkdir lib/templates/scala
cp lib/templates/ruby/*.hbs lib/templates/scala/
```


Now edit each template file to generate proper Scala code ([a quick guide for handlebars and Hiptest publisher](https://github.com/hiptest/hiptest-publisher/blob/master/docs/handlebars.md>)) until all tests are working.

Note: templates to describe variables and literals are located in ``templates/common``. If you need to override them, simply copy them to ``templates/scala``.

The last step is to write the config file for the language. It is located at ``config/scala.conf``. It will allow you to define the names of the generated files:

```
[tests]
filename = 'project_tests.scala'

[actionwords]
filename = 'actionwords.scala'
```


You can also define some default context for the code generation (that is accessible in the templates as context[:some_key]). For example, in you test scenarios, you need to define a variable name for the action word library:

```
[tests]
filename = 'project_tests.scala'
action_word_library = 'Actionword'
```


Now in every node rendered in the scenarios, you can access ``context.action_word_library`` in the template during rendering.

Once this is all done, you should be able to generate the Scala tests by running:

```shell
hiptest-publisher --language=scala
```


Adding support for a new framework
----------------------------------

Let's say you want to add support for Scala Specs (considering Scalatest is the default Scala framework).

First, let's write some tests. Open ``spec/render/scala_spec.rb`` and go to the end of the file.

Add the following lines before the last ``end`` tag:

```ruby
context 'specs' do
  before(:each) do
    @full_scenario_rendered = [
      "class CompareToPiSpec extends Specification",
      "<some more Scala code>",
      ""].join("\n")
  end

  it_behaves_like "a renderer" do
    let(:language) {'scala'}
    let(:framework) {'specs'}
  end
end
```


Run the tests:

```shell
rspec spec/render/scala_spec.rb -f d
```


Normally, you should see one test failing (the scenario generation). To get it working, you will have to override the scenario template file:

```shell
mkdir templates/scala/specs
cp templates/scala/scenario.rb templates/scala/specs/scenario.rb
```

Edit the file so it generates proper Scala/Specs code. You can also customize the config file for the framework located at ``config/scala-specs.conf``.

You should now be able to generate your tests using the following line:

```shell
rake install
hiptest-publisher --language=scala --framework=specs
```
