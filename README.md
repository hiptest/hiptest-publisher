Zest Publisher
==============

[![Build Status](https://travis-ci.org/Smartesting/zest-publisher.svg?branch=master)](https://travis-ci.org/Smartesting/zest-publisher)
[![Gem version](https://badge.fury.io/rb/zest-publisher.svg)](http://badge.fury.io/rb/zest-publisher)
[![Code climate](https://codeclimate.com/github/Smartesting/zest-publisher.png)](https://codeclimate.com/github/Smartesting/zest-publisher)
[![Coverage](https://codeclimate.com/github/Smartesting/zest-publisher/coverage.png)](https://codeclimate.com/github/Smartesting/zest-publisher)
[![Dependencies](https://gemnasium.com/Smartesting/zest-publisher.svg)](https://gemnasium.com/Smartesting/zest-publisher)


Installing
----------

You need to have [Ruby installed on your machine](https://www.ruby-lang.org/en/installation/). You can then install it using gem:

```shell
gem install zest-publisher
```

Exporting a project
-------------------

Go to one of your [Zest projects](https://www.zest-testing.com/#/projects) and select the Settings tab.
This tab is available only for projects you own.
From there, copy the secret token and run this command line:

```shell
zest-publisher --token=<YOUR TOKEN>
```

This will create a Ruby tests suite. For the moment, we support the following languages and frameworks:

 - Ruby (rspec / minitest)
 - Python (unittest)
 - Java (JUnit)

You can specify the output language and framework in the command line, for example:

```shell
zest-publisher --token=<YOUR TOKEN> --language=ruby --framework=minitest
```

You can use a configuration file, for example:

```shell
zest-publisher --config=config_file
```

with config file contains:

```
token = '<YOUR TOKEN>'
language = 'java'
output_directory = '<YOUR OUTPUT DIRECTORY>'
package = 'com.youcompagny'
```

For more information on the available options, use the following command:

```shell
zest-publisher --help
```

Configuration
-------------

You have the possibility to store some configuration in a file named 'config'. Copy the file config.sample provided here and update the values with the values you use.

If you have multiple projects, you can have multiple config files and select one using the --config-file option:

```shell
# Use the default config file
zest-publisher
# Use the one to export as minitest
zest-publisher --config-file=config_minitest
```


Adding support for other languages and framework
------------------------------------------------

See the [CONTRIBUTING](https://github.com/Smartesting/zest-publisher/blob/master/CONTRIBUTING.md>) help page for more information.