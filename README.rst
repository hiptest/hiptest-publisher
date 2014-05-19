Zest Publisher
==============

.. image:: https://travis-ci.org/Smartesting/zest-publisher.svg?branch=master
  :target: https://travis-ci.org/Smartesting/zest-publisher

.. image:: https://badge.fury.io/rb/zest-publisher.svg
  :target: http://badge.fury.io/rb/zest-publisher

.. image:: https://codeclimate.com/github/Smartesting/zest-publisher.png
  :target: https://codeclimate.com/github/Smartesting/zest-publisher

.. image:: https://codeclimate.com/github/Smartesting/zest-publisher/coverage.png
  :target: https://codeclimate.com/github/Smartesting/zest-publisher

.. image:: https://gemnasium.com/Smartesting/zest-publisher.svg
  :target: https://gemnasium.com/Smartesting/zest-publisher


Installing
----------

You need to have `Ruby installed on your machine <https://www.ruby-lang.org/en/installation/>`_. You can then install it using gem::

  gem install zest-publisher


Exporting a project
-------------------

Go to one of your `Zest projects <https://www.zest-testing.com/#/projects>`_ and select the Settings tab.
This tab is available only for projects you own.
From there, copy the secret token and run this command line::

  zest-publisher --token=<YOUR TOKEN>

This will create a Ruby tests suite. For the moment, we support the following languages and frameworks:

 - Ruby (rspec / minitest)
 - Python (unittest)

You can specify the output language and framework in the command line, for example::

  zest-publisher --token=<YOUR TOKEN> --language=ruby --framework=minitest

For more informations on the available options, use the following command::

  zest-publisher --help

Configuration
-------------

You have the possibility to store some configuration in a file named 'config'. Copy the file config.sample provided here and update the values with the values you use.

If you have multiple projects, you can have multiple config files and select one using the --config-file option::

    # Use the default config file
    zest-publisher
    # Use the one to export as minitest
    zest-publisher --config-file=config_minitest


Adding support for other languages and framework
------------------------------------------------

See the `CONTRIBUTING.rst <https://github.com/Smartesting/zest-publisher/blob/master/CONTRIBUTING.rst>`_ help page for more information.