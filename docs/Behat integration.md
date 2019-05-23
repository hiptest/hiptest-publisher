Integrate hiptest actions words into behat with AbstractClass
=====================

Integration with [Behat](https://github.com/Behat/Behat) can be quite simple.

With the given file structure you can integrate HipTest with no impact to your current framework's test code architecture.

```php
./behat/bootstrap/Feature/Context/FeatureContext.php
./behat/bootstrap/Feature/Context/CustomerContext.php
./behat/bootstrap/Feature/Context/ApiContext.php
./behat/bootstrap/Feature/Context/actionwords_signature.yaml
./features/authenticate_checkout.feature
```

##### 1. Export features

```
hiptest-publisher -c config_with_access --only features -out ./features
```
```gherkin
#file: ./features/helloworld.feature

Feature: Authenticate checkout
In order to sell goods to our staff with special prices
they have to pass authentication form
so then we can offer special prices to them

Scenarios: Prompt anon users to authenticate at checkout
    Given I am non authenticated customer
    And I have a "Specifications by Examples" book in my basket
    When I follow to checkout
    And I choose "internal checkout"
    Then I am prompted to pass authentication
```
##### 2. Export action words
```
hiptest-publisher -c config_with_access --only step_definitions -out ./behat/bootstrap/Feature/Context
hiptest-publisher -c config_with_access --actionwords-signature -out ./behat/bootstrap/Feature/Context

```
##### 3. Extend you base context with FeatureContext abstract class
`file: ./behat/bootstrap/Feature/Context/FeatureContext.php`
```php
<?php

namespace Feature\Context\CustomerContext;

use Behat\Behat\Context\Context;
use Behat\Behat\Tester\Exception\PendingException;

abstract class FeatureContext extends Context{

    /**
       * @When /^I follow to checkout$/
       */
      public function iFollowToCheckout(){
        throw new PendingException();
      }

}
```

##### 4. Implement your actionword in your main context

- You need to add `@override` to each step definition that implements your action word
 (So that Behat doesn't argue on duplicated step)
- When you export actionwords with update you need to make sure
 the method in `FeatureContext.php` is still overridden in your main context

`#file ./behat/bootstrap/Feature/Context/CustomerContext.php`
```php
<?php

namespace Feature\Context\CustomerContext;

use Feature\Context\FeatureContext;

class CustomerContext extends FeatureContext{

    /**
       * @override @When /^I follow to checkout$/
       */
      public function iFollowToCheckout(){
        // your code goes here
      }

}
```

#### Print FeatureContext.php in the way you need

hiptest-publisher allows you to override FeatureContext template.

Copy original behat templates to your project dir
`cp -r ./path-to-hiptest-repo/lib/templates/behat ./project/behat/bootstrap/template`

`#file: ./behat/bootstrap/template/behat/actionwords.hbs`

```php
<?php

namespace Acme\Context;

use Behat\Behat\Context\Context;
use Behat\Behat\Tester\Exception\PendingException;

abstract class FeatureContext extends AcmeContext{{#curly}}{{#indent}}
{{#each rendered_children.actionwords}}
{{#clear_empty_lines}}
{{{this}}}
{{/clear_empty_lines}}
{{/each}}{{/indent}}
{{/curly}}
```
At next actionwords exporting let hiptest-publisher know where to look at overridden templates
`hiptest-publisher --overriden-templates="./behat/bootstrap/template/behat/"`
