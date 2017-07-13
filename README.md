Hiptest Publisher
==============

[![Build Status Linux](https://travis-ci.org/hiptest/hiptest-publisher.svg?branch=master)](https://travis-ci.org/hiptest/hiptest-publisher)
[![Build Status Windows](https://ci.appveyor.com/api/projects/status/ciahcci0ayr1oihr/branch/master?svg=true)](https://ci.appveyor.com/project/hiptest/hiptest-publisher)
[![Gem Version](https://badge.fury.io/rb/hiptest-publisher.svg)](http://badge.fury.io/rb/hiptest-publisher)
[![Code Climate](https://codeclimate.com/github/hiptest/hiptest-publisher/badges/gpa.svg)](https://codeclimate.com/github/hiptest/hiptest-publisher)
[![Test Coverage](https://codeclimate.com/github/hiptest/hiptest-publisher/badges/coverage.svg)](https://codeclimate.com/github/hiptest/hiptest-publisher)
[![Dependency Status](https://gemnasium.com/hiptest/hiptest-publisher.svg)](https://gemnasium.com/hiptest/hiptest-publisher)


Installing
----------

### Docker Installation

You can build the docker image or use an already built docker image for hiptest/hiptest-publisher.

You can use the docker image just like the command line installation. The image includes a script that runs
docker with the necessary options. Copy the script from the image using these commands:

```shell
cid=$(docker create hiptest/hiptest-publisher) &&
docker cp $cid:/usr/src/app/bin/hiptest-publisher-docker hiptest-publisher &&
docker rm $cid > /dev/null
```

Now you can use `hiptest-publisher` in order to run the program.

Suggestions for installation of the hiptest-publisher script:

* Copy hiptest-publisher to a path directory (e.g. ~/bin or /usr/local/bin).
* Create an alias for hiptest-publisher: `alias 'hiptest-publisher=/path/to/hiptest-publisher'`

### Local Installation

You need to have [Ruby installed on your machine](https://www.ruby-lang.org/en/installation/). You can then install it using gem:

```shell
gem install hiptest-publisher
```

Note: for Windows users, take a look at [this Windows installation guide](docs/INSTALLING/Windows.md).

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

Exporting a test run
--------------------

You can generate the test suite from a test run of your project by specifying option `--test-run-id=<xxx>` when calling `hiptest-publisher`. You can find the test run id in the address bar of your browser. If your browser address is `http://hiptest.net/app#/projects/1234/testRuns/6941`, then your test run id is `6941`. You can generate your tests from your test with this command line:

```shell
hiptest-publisher --token=<YOUR TOKEN> --test-run-id=6941
```

Available options
-----------------

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
        --filename-pattern=PATTERN   Filename pattern (containing %s)
    -c, --config-file=PATH           Configuration file
        --overriden-templates=PATH   Folder for overriden templates
        --test-run-id=ID             Export data from a test run identified by its id
        --test-run-name=NAME         Export data from a test run identified by its name
        --only=CATEGORIES            Restrict export to given file categories (--only=list to list them)
    -x, --xml-file=PROJECT_XML       XML file to use instead of fetching it from Hiptest
        --tests-only                 (deprecated) alias for --only=tests (default: false)
        --actionwords-only           (deprecated) alias for --only=actionwords (default: false)
        --actionwords-signature      Export actionwords signature (default: false)
        --show-actionwords-diff      Show actionwords diff since last update (summary) (default: false)
        --show-actionwords-deleted   Output signature of deleted action words (default: false)
        --show-actionwords-created   Output code for new action words (default: false)
        --show-actionwords-renamed   Output signatures of renamed action words (default: false)
        --show-actionwords-signature-changed
                                     Output signatures of action words for which signature changed (default: false)
        --show-actionwords-definition-changed
                                     Output action words for which definition changed (default: false)
        --with-folders               Use folders hierarchy to export files in respective directories (default: false)
        --split-scenarios            Export each scenario in a single file  (except for Gherkin based languages) (default: false)
        --leafless-export            Use only last level action word (default: false)
    -s, --site=SITE                  Site to fetch from (default: https://hiptest.net)
    -p, --push=FILE.TAP              Push a results file to the server
        --push-format=tap            Format of the test results (junit, nunit, tap, robot) (default: tap)
        --sort=[id,order,alpha]      Sorting of tests in output: id will sort them by age, order will keep the same order than in hiptest (only with --with-folders option, will fallback to id otherwise), alpha will sort them by name (default: order)
        --[no-]uids                  Export UIDs (note: can be disabled only for Gherkin-based exports, may cause issue when pushing results back) (default: true)
        --keep-filenames             Keep the same name as in Hiptest for the test files (note: may cause encoding issues) (default: false)
        --keep-foldernames           Keep the same name as in Hiptest for the folders (note: may cause encoding issues) (default: false)
        --filter-on-scenario-ids     Filter on scenario ids (use commas to separate ids when fetching multiple scenarios)
        --filter-on-folder-ids       Filter on folder ids (use commas to separate ids when fetching multiple folders)
        --filter-on-scenario-name    Filter on scenario name (only one name is accepted)
        --filter-on-folder-name      Filter on folder name (only one name is accepted)
        --filter-on-tags             Filter on scenarios and folder tags (use commas to separate tags when using multiple tags)
        --filter-on-status=STATUS    Filter on test status in last build (use in conjunction with a test run)
    -v, --verbose                    Run verbosely (default: false)
    -H, --languages-help             Show languages and framework options
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

Note that options from command line arguments override options from config file.

Posting results to Hiptest
--------------------------

You can use the options --push to push the results back to Hiptest. For this, you first need to generate the test code from a Test run by specifying option ``--test-run-id=<xxx>`` during code generation (or add it to the configuration file).
The tests must then generate a test report that is supported by Hiptest. Currently four types of test results are handled:
 - jUnit XML format
 - [NUnit XML v2 format](https://github.com/nunit/docs/wiki/XML-Formats#v2-test-results)
 - [TAP (Test Anything Protocol)](https://testanything.org/)
 - Robot framework XML output

You can specify the type of export when pushing by using the option "--push-format=[junit|nunit|tap|robot]" or specifying it in the config file.

You can push multiple files at once (using wildcard) but in that case, do not forget to add quotes. For examples:

    hiptest-publisher --config-file=<path to your config file> --push="reports/*.xml"

The number of imported test results will be displayed. For debugging purposes, you can display imported tests individually with the `--verbose` option.

Development
-----------

While developing, you can install the gem locally by issuing

```
rake install
```

You can also run the command directly with `bundle exec ruby -I lib bin/hiptest-publisher`. It is handy to define an alias so you can test your code easily:

```
# this alias will only work when run from the root of the project
alias hiptest-publisher='bundle exec ruby -I lib bin/hiptest-publisher'
```


Adding support for other languages and framework
------------------------------------------------

See the [CONTRIBUTING](https://github.com/hiptest/hiptest-publisher/blob/master/docs/CONTRIBUTING.md) help page for more information.

Contributors
------------

The @hiptest team, @mhfrantz, @tikolakin, @atulhm, @etorreborre, @daniel-kun, @weeksghost
