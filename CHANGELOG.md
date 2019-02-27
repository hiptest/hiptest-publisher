HipTest Publisher Changelog
===========================

1.21.0
------

  - Add option --execution-environment to push results in the specified execution environment name

1.20.0
------

 - Add --meta option to add more flexibility in code generation (see: https://github.com/hiptest/hiptest-publisher/blob/master/docs/Using%20meta%20data.md#using-meta-data)

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
  - Add options "parameter-delimiter" allowing to remove quotes around parameters in Gherkin export (or replace it by anything else in fact)

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

 - Add Cucumber/Groovy support [#54]

1.12.0
------

 - Add JBehave support [#38]
 - Add option --with-dataset-names [#105]
 - Reorder steps by regexp length for Behave [#104]
