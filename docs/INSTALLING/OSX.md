Installing hiptest-publisher on OSX
===================================

Many thanks to Adam (@apowers313) for documenting the installation with the default OSX ruby. If you use RVM, using ``gem install hiptest-publisher`` should be enough.

tl;dr: run these commands:

```shell
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1
export ARCHFLAGS="-arch x86_64"
gem install hiptest-publisher --user-install -n~/bin
```

Problem 1 - libxml2 is missing
------------------------------

The symptom looks something like this:

> checking for xmlParseDoc() in -llibxml2... no
> libxml2 is missing.  Please locate mkmf.log to investigate how it is failing.
> *** extconf.rb failed ***
> [ garbage scrolls on and on ]

Note that for me it wasn't actually missing, it was failing to link because it was trying to link against the 'i386' version instead of the 'x86_64' version. Setting the environment variable `ARCHFLAGS="-arch x86_64"` fixes this problem.


Problem 2: still failing
------------------------

At this point the build is still failing with `libxml2 missing`, but looking through the logs it has different compile problems. Unfortunately I don't have the logs, but the fix was `NOKOGIRI_USE_SYSTEM_LIBRARIES=1`


Problem 3: Permission denied
----------------------------

Now it's trying to install a binary to a bad directory:

> Building native extensions.  This could take a while...
> ERROR:  While executing gem ... (Errno::EPERM)
> Operation not permitted - /usr/bin/nokogiri

The fix for this is to install the gem locally instead of globally using the command `gem install hiptest-publisher --user-install -n~/bin`
