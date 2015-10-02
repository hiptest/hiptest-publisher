Hiptest Publisher
==============

[![Build Status](https://travis-ci.org/hiptest/hiptest-publisher.svg?branch=master)](https://travis-ci.org/hiptest/hiptest-publisher)
[![Gem Version](https://badge.fury.io/rb/hiptest-publisher.svg)](http://badge.fury.io/rb/hiptest-publisher)
[![Code Climate](https://codeclimate.com/github/hiptest/hiptest-publisher/badges/gpa.svg)](https://codeclimate.com/github/hiptest/hiptest-publisher)
[![Test Coverage](https://codeclimate.com/github/hiptest/hiptest-publisher/badges/coverage.svg)](https://codeclimate.com/github/hiptest/hiptest-publisher)
[![Dependency Status](https://gemnasium.com/hiptest/hiptest-publisher.svg)](https://gemnasium.com/hiptest/hiptest-publisher)


Installing
----------

You need to have [Ruby installed on your machine](https://www.ruby-lang.org/en/installation/). You can then install it using gem:

```shell
gem install hiptest-publisher
```

Note: for Windows user, take a look, at [this (short) documentation](docs/Windows.md).

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
 - Cucumber Ruby
 - Python (unittest)
 - Java (JUnit / TestNg)
 - Robot Framework
 - Selenium IDE
 - Javascript (qUnit / Jasmine)

You can specify the output language and framework in the command line, for example:

```shell
hiptest-publisher --token=<YOUR TOKEN> --language=ruby --framework=minitest
```

When publishing, you'll notice a file called ``actionwords_signature.yaml``. Store this file in your code repository, it will be used to [handle updates of the action word](docs/upgrading_actionwords.md).

For more information on the available options, use the following command:

```shell
hiptest-publisher --help
```

You could obtain for example:

```shell
Exports tests from Hiptest for automation.

Specific options:
    -t, --token=TOKEN                Secret token (available in your project settings)
    -l, --language=LANG              Target language (default: ruby)
    -f, --framework=FRAMEWORK        Test framework to use
    -o, --output-directory=PATH      Output directory (default: .)
    -c, --config-file=PATH           Configuration file
        --overriden-templates=PATH   Folder for overriden templates
        --test-run-id=ID             Export data from a test run
        --scenario-ids=IDS           Filter scenarios by ids
        --scenario-tags=TAGS         Filter scenarios by tags
        --only=CATEGORIES            Restrict export to given file categories (--only=list to list them)
        --tests-only                 (deprecated) alias for --only=tests (default: false)
        --actionwords-only           (deprecated) alias for --only=actionwords (default: false)
        --actionwords-signature      Export actionwords signature (default: false)
        --show-actionwords-diff      Show actionwords diff since last update (summary) (default: false)
        --show-actionwords-deleted   Output signature of deleted action words (default: false)
        --show-actionwords-created   Output code for new action words (default: false)
        --show-actionwords-renamed   Output signatures of renamed action words (default: false)
        --show-actionwords-signature-changed
                                     Output signatures of action words for which signature changed (default: false)
        --split-scenarios            Export each scenario in a single file (default: false)
        --leafless-export            Use only last level action word (default: false)
    -s, --site=SITE                  Site to fetch from (default: https://hiptest.net)
    -p, --push=FILE.TAP              Push a results file to the server
        --push-format=tap            Format of the test results (tap, junit, robot) (default: tap)
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
package = 'com.youcompany'
```

Posting results to Hiptest
--------------------------

You can use the options --push to push the results to Hiptest. For this, you first need to generate the test code from a Test run by specifying option ``--test_run_id=<xxx>`` during code generation (or add it to the configuration file).
The tests must then generate a test report that is supported by Hiptest. Currently three types of test results are handled:
 - tap (Test Anything Protocol)
 - jUnit XML style
 - Robot framework XML output

You can specify the type of export when pushing by using the option "--push-format=[tap|junit|robot]" or specifying it in the config file.

Adding support for other languages and framework
------------------------------------------------

See the [CONTRIBUTING](https://github.com/hiptest/hiptest-publisher/blob/master/docs/CONTRIBUTING.md>) help page for more information.
