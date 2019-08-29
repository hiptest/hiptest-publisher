RELEASING
=========

Before releasing, please ensure the new version has been added to the CHANGELOG.md file and check that the file is up to date.
Replaced the [Unreleased] link with the name of the new version and also update the link at the bottom of the file to get the diff with the previous version.

This gem is built using Juwelier. To make a new release:

```shell
rake version:bump:minor # Replace minor by major or patch, dependending on the type of release
rake release
```

This will handle tagging, building the gem and pushing it to RubyGems.
Take a look at [Juwelier's README](https://github.com/flajann2/juwelier#juwelier-craft-the-perfect-rubygem-for-ruby-23x-and-beyond) for more information.

Update CHANGELOG.md by adding the unreleased section at the beginning of the file:

```
[Unreleased]
------------

 - Nothing changed yet
```

Also add a link to the diff at the bottom of the file:

```
[Unreleased]: https://github.com/hiptest/hiptest-publisher/compare/v<current release>...master

```

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
