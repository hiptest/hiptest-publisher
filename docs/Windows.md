Installing Hiptest-publisher on Windows
=======================================

Since version 0.3.4, we support installing hiptest-publisher on Windows. Here's a quick how-to:

Install Ruby
------------

Go to [Ruby installer](http://rubyinstaller.org/), click on "Downloads" and get "Ruby 2.1.5". Once the file has been downloaded, open your "Downloads" folder and run ``rubyinstaller-.1.5``. On the second screen, select the checkbox "Add Ruby executables to your PATH".

Open a command prompt and type ``gem --version``. If the answer is 2.2.2, follow [those guidelines](https://gist.github.com/luislavena/f064211759ee0f806c88#installing-using-update-packages-new) to fix a known issue with this version and Windows. If it says 2.2.3, you're good to continue :)

Now run in the prompt: ``gem install hiptest-publisher`` and you'll have hiptest-publisher installed.

Notes
-----

We tested this solution on a fresh Windows 8 install. If you encounter issues, do not hesitate to contact us (support@hiptest.net) so we can fix the issues.
