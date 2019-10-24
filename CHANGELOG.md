HipTest Publisher Changelog
===========================

[Unreleased]
------------

 - Add support for Swift/XCTest ([#134](https://github.com/hiptest/hiptest-publisher/pull/134) [bangroot])

 - Add cache for the XML downloaded from HipTest.
   By default, files will be valid for 60 seconds but can be changed by using `--cache-duration=120` for example.

[1.29.2]
--------

 - Fix escaping in string literals for Java and C# ([#157](https://github.com/hiptest/hiptest-publisher/issues/157) - [hiptest#195](https://github.com/hiptest/hiptest-issue-tracker/issues/195))

[1.29.1]
--------

 - Allow any characters for the meta value ([#155](https://github.com/hiptest/hiptest-publisher/issues/155))


[1.29.0]
--------

 - Make `rake install` work with ruby 2.6
 - `--parameter-delimiter` option now accepts empty string

[1.28.0]
--------

 - Fix bug where parameter-delimiter value was not recognized in command line ([#147](https://github.com/hiptest/hiptest-publisher/issues/147))
 - Add option --http-proxy to specify proxy to use ([#132](https://github.com/hiptest/hiptest-publisher/issues/132))

[1.27.1]
--------

 - Add CodeceptJS to language list in OptionsParser.languages

[1.27.0]
--------

 - Enable accessing scenario tags in datasets
   ([#142](https://github.com/hiptest/hiptest-publisher/pull/142) [nono0481])

 - Added support for CodeceptJS testing framework
   ([#130](https://github.com/hiptest/hiptest-publisher/pull/130) [DavertMik])

[1.26.0]
--------

 - Shared actionwords handling for Cucumber/Typescript

[1.25.0]
--------

 - Shared actionwords handling for Behave

[1.24.0]
--------

 - Add #case, #when and #when_includes handlebars helpers
 - Modify #if_includes handlebars helper to work with strings

[1.23.5]
--------

 - Load i18n path also when used as a library

[1.23.4]
--------

 - Add I18n to enable localizing (and clearing the code)

[1.23.3]
--------

 - Update multipart-post to 2.1.1 to handle issues with Ruby < 2.5
   (see: https://github.com/socketry/multipart-post/issues/61)

[1.23.2]
--------

 - Force Nokogiri < 1.10 to keep support for Ruby 2.2
 - Add deprecation notifications for Ruby 2.2

[1.23.1]
--------

  - Handle new shared actionword architecture

[1.22.0]
--------

  - Add support for Cucumber/Typescript
  - Unlock Nokogiri update to 1.9.1

[1.21.0]
--------

  - Add option --execution-environment to push results in the specified execution environment name

[1.20.0]
--------

 - Add --meta option to add more flexibility in code generation
   (see: https://github.com/hiptest/hiptest-publisher/blob/master/docs/Using%20meta%20data.md#using-meta-data)

[1.19.3]
--------

  - Do not leave trailing whitespaces with {{comment}} helper

[1.19.2]
--------
  - Fix description in Gherkin exports

[1.19.1]
--------
  - Fix description in Gherkin exports

[1.19.0]
--------
  - Do not comment description in Gherkin exports

[1.18.1]
--------
 - Show message when calling an actionword using an unknown UID

[1.18.0]
--------
  - Add option [no-]parent-folders-tags to choose if parent tags are rendered in feature files

[1.17.2]
--------
  - Fix UIDCall handling for shared actionwords

[1.17.1]
--------
  - update version number

[1.16.6]
--------
  - Add the if_includes handlebars helper
  - Add options "parameter-delimiter" allowing to remove quotes around parameters in Gherkin export
    (or replace it by anything else in fact)

[1.16.5]
--------
  - Fix UIDCall handling for behat

[1.16.4]
--------
  - Handling tags for shared actionwords

[1.16.3]
--------
  - Fix behat rendering of shared actionwords

[1.16.2]
--------
  - Remove unnecessary templates for cucumber/groovy

[1.16.0]
--------
  - Shared actionwords handling for behat

[1.15.0]
--------
  - Shared actionwords handling for groovy/spock

[1.14.0]
--------

 - Shared actionwords handling for cucumber/groovy

[1.13.0]
--------

 - Add Cucumber/Groovy support
   ([#54](https://github.com/hiptest/hiptest-publisher/issues/54))

[1.12.0]
--------

 - Add JBehave support
   ([#38](https://github.com/hiptest/hiptest-publisher/issues/38))

 - Add option --with-dataset-names
   ([#105](https://github.com/hiptest/hiptest-publisher/issues/105))

 - Reorder steps by regexp length for Behave
   ([#104](https://github.com/hiptest/hiptest-publisher/issues/104))


<!-- List of releases -->
[Unreleased]: https://github.com/hiptest/hiptest-publisher/compare/v1.29.2...master
[1.29.2]:     https://github.com/hiptest/hiptest-publisher/compare/v1.29.1...v1.29.2
[1.29.1]:     https://github.com/hiptest/hiptest-publisher/compare/v1.29.0...v1.29.1
[1.29.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.28.0...v1.29.0
[1.28.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.27.1...v1.28.0
[1.27.1]:     https://github.com/hiptest/hiptest-publisher/compare/v1.27.0...v1.27.1
[1.27.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.26.0...v1.27.0
[1.26.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.25.0...v1.26.0
[1.25.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.24.0...v1.25.0
[1.24.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.23.5...v1.24.0
[1.23.5]:     https://github.com/hiptest/hiptest-publisher/compare/v1.23.4...v1.23.5
[1.23.4]:     https://github.com/hiptest/hiptest-publisher/compare/v1.23.3...v1.23.4
[1.23.3]:     https://github.com/hiptest/hiptest-publisher/compare/v1.23.2...v1.23.3
[1.23.2]:     https://github.com/hiptest/hiptest-publisher/compare/v1.23.1...v1.23.2
[1.23.1]:     https://github.com/hiptest/hiptest-publisher/compare/v1.22.0...v1.23.1
[1.22.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.21.0...v1.22.0
[1.21.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.20.0...v1.21.0
[1.20.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.19.3...v1.20.0
[1.19.3]:     https://github.com/hiptest/hiptest-publisher/compare/v1.19.2...v1.19.3
[1.19.2]:     https://github.com/hiptest/hiptest-publisher/compare/v1.19.1...v1.19.2
[1.19.1]:     https://github.com/hiptest/hiptest-publisher/compare/v1.19.0...v1.19.1
[1.19.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.18.1...v1.19.0
[1.18.1]:     https://github.com/hiptest/hiptest-publisher/compare/v1.18.0...v1.18.1
[1.18.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.17.2...v1.18.0
[1.17.2]:     https://github.com/hiptest/hiptest-publisher/compare/v1.17.1...v1.17.2
[1.17.1]:     https://github.com/hiptest/hiptest-publisher/compare/v1.16.6...v1.17.1
[1.16.6]:     https://github.com/hiptest/hiptest-publisher/compare/v1.16.5...v1.16.6
[1.16.5]:     https://github.com/hiptest/hiptest-publisher/compare/v1.16.4...v1.16.5
[1.16.4]:     https://github.com/hiptest/hiptest-publisher/compare/v1.16.3...v1.16.4
[1.16.3]:     https://github.com/hiptest/hiptest-publisher/compare/v1.16.2...v1.16.3
[1.16.2]:     https://github.com/hiptest/hiptest-publisher/compare/v1.16.0...v1.16.2
[1.16.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.15.0...v1.16.0
[1.15.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.14.0...v1.15.0
[1.14.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.13.0...v1.14.0
[1.13.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.12.0...v1.13.0
[1.12.0]:     https://github.com/hiptest/hiptest-publisher/compare/v1.11.1...v1.12.0


<!-- List of contributors -->
[atulhm]: https://github.com/atulhm
[bangroot]: https://github.com/bangroot
[ClaudiaJ]: https://github.com/ClaudiaJ
[daniel-kun]: https://github.com/daniel-kun
[DavertMik]: https://github.com/DavertMik
[etorreborre]: https://github.com/etorreborre
[Jesterovskiy]: https://github.com/Jesterovskiy
[lostiniceland]: https://github.com/lostiniceland
[mhfrantz]: https://github.com/mhfrantz
[nono0481]: https://github.com/nono0481
[tenpaiyomi]: https://github.com/tenpaiyomi
[tikolakin]: https://github.com/tikolakin
[weeksghost]: https://github.com/weeksghost
