HipTest Publisher Changelog
===========================

1.27.0
------

 - Enable accessing scenario tags in datasets
   ([#142](https://github.com/hiptest/hiptest-publisher/pull/142) [nono0481])

 - Added support for CodeceptJS testing framework
   ([#130](https://github.com/hiptest/hiptest-publisher/pull/130) [DavertMik])

1.26.0
------

 - Shared actionwords handling for Cucumber/Typescript

1.25.0
------

 - Shared actionwords handling for Behave

1.24.0
------

 - Add #case, #when and #when_includes handlebars helpers
 - Modify #if_includes handlebars helper to work with strings

1.23.5
------

 - Load i18n path also when used as a library

1.23.4
------

 - Add I18n to enable localizing (and clearing the code)

1.23.3
------

 - Update multipart-post to 2.1.1 to handle issues with Ruby < 2.5
   (see: https://github.com/socketry/multipart-post/issues/61)

1.23.2
------

 - Force Nokogiri < 1.10 to keep support for Ruby 2.2
 - Add deprecation notifications for Ruby 2.2

1.23.1
------

  - Handle new shared actionword architecture

1.22.0
------

  - Add support for Cucumber/Typescript
  - Unlock Nokogiri update to 1.9.1

1.21.0
------

  - Add option --execution-environment to push results in the specified execution environment name

1.20.0
------

 - Add --meta option to add more flexibility in code generation
   (see: https://github.com/hiptest/hiptest-publisher/blob/master/docs/Using%20meta%20data.md#using-meta-data)

1.19.3
------

  - Do not leave trailing whitespaces with {{comment}} helper

1.19.2
------
  - Fix description in Gherkin exports

1.19.1
------
  - Fix description in Gherkin exports

1.19.0
------
  - Do not comment description in Gherkin exports

1.18.1
------
 - Show message when calling an actionword using an unknown UID

1.18.0
------
  - Add option [no-]parent-folders-tags to choose if parent tags are rendered in feature files

1.17.2
------
  - Fix UIDCall handling for shared actionwords

1.17.1
------
  - update version number

1.16.6
------
  - Add the if_includes handlebars helper
  - Add options "parameter-delimiter" allowing to remove quotes around parameters in Gherkin export
    (or replace it by anything else in fact)

1.16.5
------
  - Fix UIDCall handling for behat

1.16.4
------
  - Handling tags for shared actionwords

1.16.3
------
  - Fix behat rendering of shared actionwords

1.16.2
------
  - Remove unnecessary templates for cucumber/groovy

1.16.0
------
  - Shared actionwords handling for behat

1.15.0
------
  - Shared actionwords handling for groovy/spock

1.14.0
------

 - Shared actionwords handling for cucumber/groovy

1.13.0
------

 - Add Cucumber/Groovy support
   ([#54](https://github.com/hiptest/hiptest-publisher/issues/54))

1.12.0
------

 - Add JBehave support
   ([#38](https://github.com/hiptest/hiptest-publisher/issues/38))

 - Add option --with-dataset-names
   ([#105](https://github.com/hiptest/hiptest-publisher/issues/105))

 - Reorder steps by regexp length for Behave
   ([#104](https://github.com/hiptest/hiptest-publisher/issues/104))


Contributors
=============

 - [nono0481](https://github.com/nono0481)
 - [DavertMik](https://github.com/DavertMik)
 - [mhfrantz](https://github.com/mhfrantz)
 - [tikolakin](https://github.com/tikolakin)
 - [atulhm](https://github.com/atulhm)
 - [etorreborre](https://github.com/etorreborre)
 - [daniel-kun](https://github.com/daniel-kun)
 - [weeksghost](https://github.com/weeksghost)
 - [lostiniceland](https://github.com/lostiniceland)
 - [ClaudiaJ](https://github.com/ClaudiaJ)
 - [Jesterovskiy](https://github.com/Jesterovskiy)
 - [tenpaiyomi](https://github.com/tenpaiyomi)
 - [hiptest team](https://github.com/hiptest)

