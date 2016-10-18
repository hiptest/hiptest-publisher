Installing Hiptest-publisher on Windows
=======================================

Since version 0.3.4, we support installing hiptest-publisher on Windows. Here's a quick how-to:


Install Ruby
------------

Go to [Ruby installer](http://rubyinstaller.org/), click on "Downloads" and get "Ruby 2.3.1 (x64)". Once the file has been downloaded, open your "Downloads" folder and run ``rubyinstaller-2.3.1-x64``. On the second screen, select the checkbox "Add Ruby executables to your PATH".

Now run in the prompt: ``gem install hiptest-publisher`` and you'll have hiptest-publisher installed.


Troubleshooting
---------------

### Error: Unable to download data from https://rubygems.org/

**Symptom**

When running `gem install hiptest-publisher`, I have the following error:

```
C:\Ruby23-x64>gem install hiptest-publisher
ERROR:  Could not find a valid gem 'hiptest-publisher' (>= 0), here is why:
          Unable to download data from https://rubygems.org/ - SSL_connect
          returned=1 errno=0 state=SSLv3 read server certificate B:
          certificate verify failed (https://api.rubygems.org/specs.4.8.gz)
```

**Reason**

The RubyGems command line tool embeds the certificates needed to connect securely to api.rubygems.org. The certificate has changed recently and its Root CA certificate is not embedded in RubyGems releases older than 2.6.3. To know you RubyGems version, run `gem --version`.

**Fix**

Upgrade RubyGems by temporarly using non-ssl connection:

    gem update --system --source http://rubygems.org/

It will upgrade to newest RubyGems version which includes all necessary certificates. Then run `gem install hiptest-publisher` to complete the installation.


Notes
-----

We tested this solution on a fresh Windows 10 install. If you encounter any issues, do not hesitate to contact us at support@hiptest.net so we can fix them.
