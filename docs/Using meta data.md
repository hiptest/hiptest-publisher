Using meta data
===============

Meta are some data you want to be able to use in your templates but do not want to hardcode there. You can specify them in the command line using the ```--meta=key:value,key2:value2``` argument and reference them in your templates with {{ context.meta.key}}.

A classical example would be to run the same tests against multiple browser. Let's have a look at the last overiden template from [this blogpost about overriding templates](https://hiptest.com/blog/automation/customising-your-export-with-hiptest-publisher-part-ii-customising-the-templates/). In this blog-post, the driver type was hard-coded.
Let's do this better with meta data.

First, the template:

```
package {{{ context.package }}}{{{ relative_package }}};

import junit.framework.TestCase;
{{#if needs_to_import_actionwords? }}import {{{ context.package }}}.Actionwords;
{{/if}}
public class {{{ clear_extension context.filename }}} extends TestCase {{#curly}}
{{#indent}}{{#if has_tags?}}{{#comment '//'}}Tags: {{join rendered_children.tags ' '}}
{{/comment}}{{/if}}
public Actionwords {{{ context.call_prefix }}} = new Actionwords();
protected void setUp() throws Exception {{#curly}}{{#indent}}
super.setUp();{{/indent}}
{{> body}}
{{#indent}}WebDriver driver = new {{context.meta.webdriver}};{{/indent}}
{{/curly}}

{{#each rendered_children.scenarios}}{{{this}}}
{{/each}}
{{/indent}}
{{/curly}}
```

And now, in the CI script:

```
hiptest-publisher -c hiptest-publisher.conf --meta=webdriver:ChromeDriver --test-run-id=1234 --without=actionwords
mvn test
hiptest-publisher -c hiptest-publisher.conf --test-run-id=1234 -p "target/surefire-reports/*.xml"
hiptest-publisher -c hiptest-publisher.conf --meta=webdriver:GeckoDriver --test-run-id=5678 --without=actionwords
mvn test
hiptest-publisher -c hiptest-publisher.conf --test-run-id=5678 -p "target/surefire-reports/*.xml"
```

No need to have two sets of overriden templates anymore.
