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

If you have multiple projects, you can have multiple config files and select one using the --config-file option:

    # Use the default config file
    ruby publisher.rb
    # Use the one to export as minitest
    ruby publisher.rb --config-file=config_minitest


Adding support for a new language
---------------------------------

This tool was built to be configurable and have the possibility to export tests in any language.