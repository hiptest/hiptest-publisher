Hiptest Publisher
==============

[![Build Status](https://travis-ci.org/Smartesting/zest-publisher.svg?branch=master)](https://travis-ci.org/Smartesting/zest-publisher)
[![Gem version](https://badge.fury.io/rb/zest-publisher.svg)](http://badge.fury.io/rb/zest-publisher)
[![Code Climate](https://codeclimate.com/github/hiptest/hiptest-publisher/badges/gpa.svg)](https://codeclimate.com/github/hiptest/hiptest-publisher)
[![Test Coverage](https://codeclimate.com/github/hiptest/hiptest-publisher/badges/coverage.svg)](https://codeclimate.com/github/hiptest/hiptest-publisher)
[![Dependencies](https://gemnasium.com/Smartesting/zest-publisher.svg)](https://gemnasium.com/Smartesting/zest-publisher)


Installing
----------

You need to have [Ruby installed on your machine](https://www.ruby-lang.org/en/installation/). You can then install it using gem:

```shell
gem install hiptest-publisher
```

Exporting a project
-------------------

Go to one of your [Hiptest projects](https://hiptest.net/#/projects) and select the Settings tab.
This tab is available only for projects you own.
From there, copy the secret token and run this command line:

```shell
hiptest-publisher --token=<YOUR TOKEN>
```

This will create a Ruby tests suite. For the moment, we support the following languages and frameworks:

 - Ruby (rspec / minitest)
 - Python (unittest)
 - Java (JUnit)

You can specify the output language and framework in the command line, for example:

```shell
hiptest-publisher --token=<YOUR TOKEN> --language=ruby --framework=minitest
```


For more information on the available options, use the following command:

```shell
hiptest-publisher --help
```

You could obtain for example:

```shell
Specific options:
    -t, --token=TOKEN                Secret token (available in your project settings)
    -l, --language=LANG              Target language (default: ruby)
    -f, --framework=FRAMEWORK        Test framework to use
    -o, --output-directory=PATH      Output directory (default: .)
    -c, --config-file=PATH           Configuration file (default: config)
        --scenario-ids=IDS           Filter scenarios by ids
        --scenario-tags=TAGS         Filter scenarios by tags
        --tests-only                 Export only the tests (default: false)
        --actionwords-only           Export only the actionwords (default: false)
        --split-scenarios            Export each scenario in a single file (default: false)
        --leafless-export            Use only last level action word (default: false)
    -s, --site=SITE                  Site to fetch from (default: https://hiptest.net)
    -v, --verbose                    Run verbosely (default: false)
    -H, --languages-help             Show languages and framework options
    -F, --filters-help               Show help about scenario filtering
    -h, --help                       Show this message
```

Configuration
-------------

You have the possibility to store some configuration in a file named 'config'. Copy the file config.sample provided here and update the values with the values you use.

If you have multiple projects, you can have multiple config files and select one using the --config-file option:

```shell
# Use the default config file
hiptest-publisher
# Use the one to export as minitest
hiptest-publisher --config-file=config_minitest
```

For example, for java you can use this config file content:

```
token = '<YOUR TOKEN>'
language = 'java'
output_directory = '<YOUR OUTPUT DIRECTORY>'
package = 'com.youcompagny'
```

Adding support for other languages and framework
------------------------------------------------

See the [CONTRIBUTING](https://github.com/hiptest/hiptest-publisher/blob/master/docs/CONTRIBUTING.md>) help page for more information.
