RELEASING
=========

This gem is built using jeweler. To make a new release:

```shell
rake version:bump:minor # Replace minor by major or patch, dependending on the type of release
rake release
```


This will handle tagging, building the gem and pushing it to RubyGems.
Take a look at [Jeweler's README](https://github.com/technicalpickles/jeweler#jeweler-craft-the-perfect-rubygem) for more information.

