RELEASING
=========

Before releasing, please ensure that CHANGELOG.md contains references to the changes that have been made since last release. Don't worry about the `[Unreleased]` parts, this will be handled by the next command lines.

To make a new release:

```shell
rake version:bump:minor # Replace minor by major or patch, dependending on the type of release
rake do_release
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
