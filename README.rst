Zest Publisher
==============

.. image:: https://api.travis-ci.org/Smartesting/zest-publisher.png

Installing
----------

Clone the repository::

  git clone https://github.com/Smartesting/zest-publisher.git

Install the dependencies using Bundle (you might need to have RVM (http://rvm.io/) installed)::

  bundle install


Exporting a project
-------------------

Go to your Zest project and copy the secret token from the settings tab. Then simply run this command line::

  ruby publisher.rb --token=<YOUR TOKEN>

This will create a Ruby tests suite. For the moment, only Ruby/rspec is supported.
We plan to add new languages and frameworks during the coming months.


Configuration
-------------

You have the possibility to store some configuration in a file named 'config'. Copy the file config.sample provided here and update the values with the values you use.

If you have multiple projects, you can have multiple config files and select one using the --config-file option::

    # Use the default config file
    ruby publisher.rb
    # Use the one to export as minitest
    ruby publisher.rb --config-file=config_minitest


Contributing
------------

Do not hesitate to contribute to the project by adding support for your favorite language or test framework as explained below. This tool was built to be configurable and have the possibility to export tests in any language.

We did our best to make it as simple as possible, but some knowledge of Ruby and `Zest test description language <https://zest.smartesting.com/tdl_documentation.html>`_ is needed to add support for new languages/frameworks.

Adding support for a new language
---------------------------------

Let's say we want to add support for Scala export.

The first step is to write the tests. Copy the file ``spec/render_template_spec.rb.sample``  to ``spec/render_scala_spec.rb`` and edit it with your favorite editor. Replace ``<My language>`` by ``scala`` and ``<The test framework>`` by test framework that will be considered as default for all Scala exports (well, you added support for Scala, you can at least have the right to chose what the tests framework will be ;) ).

Run the following command line::

    bin/rspec spec/render_scala_spec.rb -f d

Normally, you should see a lot of tests failing and that's totally normal (only 5 tests should pass).
Now you have to update the expected output when exporting in Scala. That is the variables ``@<some name, mainly about the Foo Fighters>`` declared in the ``before(:each)`` block. For all expected output, we also added the corresponding text in Zest test description language.

Once all the expectation are written, is it time to write the template. The simplest way is to copy the Ruby sources::

    mkdir templates/scala
    cp templates/ruby/*.erb templates/scala/


Now edit each template file to generate proper Scala code (you will need some knowledge of Ruby and ERB, the default templating system of Ruby) until all tests are working.

Note: templates to describe variables and literals are located in ``templates/common``. If you need to override them, simply copy them to ``templates/scala``.

The last step is to write the config file for the language. It is located at ``templates/scala/config``. It will allow you to define the names of the generated files::

    [tests]
    filename = 'project_tests.scala'

    [actionwords]
    filename = 'actionwords.scala'


You can also define some default context for the code generation (that is accessible in the templates as context[:some_key]). For example, in you test scenarios, you need to define a variable name for the action word library::

    [tests]
    filename = 'project_tests.scala'
    action_word_library = 'ActionWord'


Now in every node rendered in the scenarios, you can access ``context[action_word_library]`` in the template during rendering.

Once this is all done, you should be able to generate the Scala tests by running::

    ruby publisher.rb --language=scala


Note: we also added some helpers while rendering scenarios and actionwords:

@variables
  The list of variables defind in the actionword or scenario.

@non_valued_parameters
  The list of parameters which do not have a default value

@valued_parameters
  The list of parameters which do have a default value

Adding support for a new framework
----------------------------------

Let's say you want to add support for Scala Specs (considering Scalatest is the default Scala framework).

First, let's write some tests. Open ``specs/render_scala_spec.rb`` and go to the end of the file.

Add the following lines before the last ``end`` tag::

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

Run the tests::

    bin/rspec spec/render_scala_spec.rb -f d

Normally, you should see one test failing (the scenario generation). To get it working, you will have to override the scenario template file::

    mkdir templates/scala/specs
    cp templates/scala/scenario.rb templates/scala/specs/scenario.rb

Edit the file so it generates proper Scala/Specs code. You should now be able to generate your tests using the following line::

    ruby publisher.rb --language=scala --framework=specs
