# Shared Actionwords

## Export

You can handle shared actionwords by simply exporting your tests with :

```bash
hiptest-publisher -c <YOUR_CONFIG_PATH> --only=step_definition,step_definitions_library,library,libraries
```

By doing this, 3 new files will be created: `ActionwordLibrary` - `DefaultLibrary` - `StepDefinitionsDefault`

<br/><br/>

# Generated files

In hiptest, a library shares actionwords across your organization projects.

<br/>

## ActionwordLibrary
This file exposes the default library. Actionword class should now extend it in order to access to shared actionwords.

## DefaultLibrary
This file is the library containing all actionwords shared across your organization projects.

## StepDefinitionsDefault
It contains step definitions of shared actionwords.

<br/><br/>

# Example : Cucumber - Groovy

If it is the first time you export shared actionwords, you will have to extend the Actionwords class

```groovy
/* Actionwords.groovy */
package com.example.coffeeMachine

class Actionwords extends ActionwordLibrary {
  ...
}
```

<br/>

## Diffs

Options *--show-actionwords-{
  diff,
  diff-as-json,
  created,
  deleted,
  renamed,
  signature-changed,
  definition-changed
}* can be used in conjunction with *--library-name=default*

<br/>

## Automate existing actionword
---
```gherkin
Given we have an existing and automated actionword "I shutdown the coffee machine"
And we share it
When we want to automate
```

Basically, all we need to do is to move the existing code of the actionword into the library.

```groovy
/* Actionwords.groovy */
package com.example.coffeeMachine

class Actionwords extends ActionwordLibrary {

  ...

  // Move this actionword into DefaultLibrary.groovy
  // and delete it from here
  def iShutdownTheCoffeeMachine() {
    sut.stop()
  }
}
```

```groovy
/* DefaultLibrary.groovy */
package com.example.coffeeMachine;

@Singleton
class DefaultLibrary {
  def sut = CoffeeMachine.newInstance()

  def iShutdownTheCoffeeMachine() {
    // Paste the actionword code here!
  }
}
```

<br/>

## Automate new shared actionword
---

```gherkin
Given we have created a new shared actionword "coffee is hot"
When we want to automate it
```
After exporting, you can find the new actionword name in its step definition

**Be careful on export, do not overwrite DefaultLibrary file if it contains implemented actionwords!**

```groovy
/* StepDefinitionsDefault.groovy */
package com.example.coffeeMachine

import cucumber.api.DataTable

this.metaClass.mixin(cucumber.api.groovy.EN)

Actionwords actionwords = new Actionwords()

Then(~"^coffee is hot\$") {  ->
  // Here is the actionword name : coffeeIsHot
  actionwords.getDefaultLibrary().coffeeIsHot()
}
```

Now, all we need to do is to add the new actionword in the library file.

```groovy
/* DefaultLibrary.groovy */
package com.example.coffeeMachine;

@Singleton
class DefaultLibrary {
    def coffeeIsHot(){
        // code
    }
}

```

<br/>

## Automate a shared actionword called by an actionword
---

```gherkin
Given we have a shared actionword "I start the coffee machine using language \"lang\"" called by the actionword "The coffee machine is started"
When we want to automate it
```

If the actionword is already implemented, please follow the [Automate existing actionword](#automate-existing-actionword), else [Automate new shared actionword](#automate-new-shared-actionword).

Now the shared actionword call needs to be updated! So in our "`The coffee machine is started`":

```groovy
/* Actionwords.groovy */
package com.example.coffeeMachine

class Actionwords extends ActionwordLibrary {

  ...

  def theCoffeeMachineIsStarted() {
    // Every shared actionwords needs to be called on the library
    getDefaultLibrary().iStartTheCoffeeMachineUsingLanguageLang("en")
  }
}
```
