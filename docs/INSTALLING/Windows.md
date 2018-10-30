Installing Hiptest-publisher on Windows
=======================================

Since version 0.3.4, we support installing hiptest-publisher on Windows. Here's a quick how-to:

Install Ruby
------------

Go to [Ruby installer](http://rubyinstaller.org/), click on "Downloads" and get "Ruby 2.5.3-1 (x64)". Once the file has been downloaded, open your "Downloads" folder and run ``rubyinstaller-2.5.3-1-x64``. On the second screen, select the checkbox "Add Ruby executables to your PATH".

Now run in the prompt: ``gem install hiptest-publisher`` and you'll have hiptest-publisher installed.

Troubleshooting
---------------

### Error: 'hiptest-publisher' is not recognized as an internal or external command, operable program or batch file.

**Symptom**

During a Jenkins build, you have a Windows batch command execution invoking hiptest-publisher, but it fails and displays the following error in Jenkins build log:

```
'hiptest-publisher' is not recognized as an internal or external command, operable program or batch file.
```

Meanwhile, the command works well when you try it in a command prompt.

**Reason**

The PATH environment variable specifies the directories in which executable programs are located on the machine that can be started without knowing and typing the whole path to the file on the command line.

Windows uses two distinct PATH: one for the user and another one for the system. The problem is that the user PATH contains the path to ruby executables, like `C:\Ruby24-x64\bin` and that's why you can run hiptest-publisher in a command prompt, but the system PATH does not. As Jenkins uses the system PATH, it can't run ruby executables.

**Fix**

Two possibilities to fix this one:

1. First possibility: in Windows, edit `Path` by opening Control Panel > System > Advanced > Environment Variables. From there, search for `Path` variable in the "System variables" section. Ensure it contains the directory where you installed Ruby, like `C:\Ruby24-x64\bin`. Please note that directories are separated with semicolons `;`.

2. Second possibility: in Jenkins, modify `Path` by going to Manage Jenkins > Global Properties > Environment variables. Add another entry with the following information:

  * name: `Path`
  * value: `%Path%;C:\Ruby24-x64\bin`

### Error: Unable to download data from https://rubygems.org/

**Symptom**

When running `gem install hiptest-publisher`, you have the following error:

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

Download the [GlobalSignRootCA.pem](https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/index.rubygems.org/GlobalSignRootCA.pem) file into the `C:\Ruby23-x64\lib\ruby\2.3.0\rubygems\ssl_certs` directory. This makes RubyGems trust the certificate presented when connecting to api.rubygems.org next time you run a `gem install` command.

Then run `gem update --system` to upgrade RubyGems to its latest version which includes all required certificates.


Notes
-----

We tested this solution on a fresh Windows 10 install. If you encounter any issues, do not hesitate to contact us at support@hiptest.com so we can fix them.
