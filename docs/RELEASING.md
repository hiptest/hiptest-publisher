RELEASING
=========

Before relasing, please ensure the new version has been added to the CHANGELOG.md file and check that the file is up to date.

This gem is built using Juwelier. To make a new release:

```shell
rake version:bump:minor # Replace minor by major or patch, dependending on the type of release
rake release
```

This will handle tagging, building the gem and pushing it to RubyGems.
Take a look at [Juwelier's README](https://github.com/flajann2/juwelier#juwelier-craft-the-perfect-rubygem-for-ruby-23x-and-beyond) for more information.

Next you should update all the samples projects to use the new hiptest-publisher version. To do that, clone the repository

```shell
git clone git@github.com:hiptest/hiptest-publisher-samples.git
```
and run the commands:

```shell
cd hiptest-publisher-samples
bin/clone-all
bin/update-hps-version <NEW VERSION NUMBER>
```
Next check Travis CI is ok.
