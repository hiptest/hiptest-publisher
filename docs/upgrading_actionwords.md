Upgrading actionwords
=====================

Since version 0.4.0, hiptest-publisher comes with a system allowing finer updates of the action words, so you do not have to regenerate the full action words skeleton.
The first thing to do is to check if a file called ``actionwords_signature.yaml`` has been generated in the folder were your action words and tests are stored. If this file in not available, regenerate the whole project:

```shell
hiptest-publisher -c <path to your configuration file>
```

Now, the actionwords signature file should be present. Manually fix the action words if changes have been made (for the last time you'll have to use the diff system) and save the files in your repository.

Checking for action words changes
---------------------------------


Run the following command to see what changed since your last synchronization:

```shell
hiptest-publisher -c <path to your configuration file> --show-actionwords-diff
```

This will give your an overview of the changes.

Updating the action words
-------------------------

```shell
hiptest-publisher -c <path to your configuration file> --show-actionwords-deleted
```

This command will generate the name of the action words that have been deleted (as they are named in the action words file). You'll have to manually delete each of them.

The next step is to get the skeleton for the newly created action words, this can be done with this command:

```shell
hiptest-publisher -c <path to your configuration file> --show-actionwords-created
```

Copy the output to the action words file and implement what is needed.

```shell
hiptest-publisher -c <path to your configuration file> --show-actionwords-renamed
```

This command will generate a list of old and new names. You can update the action words file manually or use a tool such as ``sed`` to rename all occurences manually. The output is made so it can be easily understood by machines.

The last step to do is to run:

```shell
hiptest-publisher -c <path to your configuration file> --show-actionwords-signature-changed
```

This will generate the new signature of action words for which the parameters have changed (for example a new parameter has been added or an existing one has been renamed).
Update the action words file to integrate those changes (and eventually update the code of the action word if needed).

Generating the signature
------------------------

Once the action words have been updated, run this command:

```shell
hiptest-publisher -c <path to your configuration file> --actionwords-signature
```

This will regenerate the yaml file containing the definition of the action words. Commit your changes (both in implementation and the signature file) and repeat the process next time the project action words are updated.
