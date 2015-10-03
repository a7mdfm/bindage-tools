### In Development ###

### Version 0.0.6 - 2012-03-12 ###

  * [Issue 10](https://code.google.com/p/bindage-tools/issues/detail?id=10): Ability to specify event types in custom binding properties.
  * [Issue 18](https://code.google.com/p/bindage-tools/issues/detail?id=18): Ability to set up bindings without running them initially.
  * [Issue 19](https://code.google.com/p/bindage-tools/issues/detail?id=19): style(name) custom property for component styles
  * [Issue 20](https://code.google.com/p/bindage-tools/issues/detail?id=20): firstItemThat(Matcher) and everyItemThat(Matcher) custom properties
  * Improved exception messages from toCondition to make programming mistakes easier to recognize and correct.

### Version 0.0.5 - 2011-06-10 ###

  * [Issue 11](https://code.google.com/p/bindage-tools/issues/detail?id=11): (Enhancement) Introduce an MXML namespace for BindageTools
  * [Issue 13](https://code.google.com/p/bindage-tools/issues/detail?id=13): (Defect) Move Swiz annotation processor into its own artifact: com.googlecode.bindage-tools:bindage-tools-swiz
  * [Issue 14](https://code.google.com/p/bindage-tools/issues/detail?id=14): (Defect) Compiled locales causes build error for clients

### Version 0.0.4 - 2011-05-27 ###

Changes:

  * [Issue 7](https://code.google.com/p/bindage-tools/issues/detail?id=7): (Enhancement) Bind.fromProperty and IPipelineBuilder.toProperty should accept arrays
  * [Issue 8](https://code.google.com/p/bindage-tools/issues/detail?id=8): (Enhancement) IPipelineBuilder.toFunction should expand arrays as arguments (superseded by [Issue 9](https://code.google.com/p/bindage-tools/issues/detail?id=9))
  * [Issue 9](https://code.google.com/p/bindage-tools/issues/detail?id=9): (Enhancement) Refactor framework to disambiguate arrays and varargs

#### Summary of usage changes ####

Previously, a multi-source binding could use collection matchers (e.g. array(...matchers), hasItem(matcher)) to check multiple values in the pipeline:

```
    Bind.fromAll(
        Bind.fromProperty(userNameInput, "text"),
        Bind.fromProperty(passwordInput, "text")
        )
        .convert(toCondition(everyItem(not(emptyString()))))
        .toProperty(loginButton, "enabled");
```

This was problematic because it was impossible to tell the difference between a multi-source binding, and a single-source binding where the source contained an array object.

In the revised design, an array value from a source object will remain an array, instead of being interpreted as a list of arguments.

However it is often necessary to treat multiple arguments as an array for matching purposes.  We have added the args() converter function for this purpose:

```
    Bind.fromAll(
        Bind.fromProperty(userNameInput, "text"),
        Bind.fromProperty(passwordInput, "text")
        )
        .convert(toCondition(args(), everyItem(not(emptyString()))))
        .toProperty(loginButton, "enabled");
```

In this release, the functions toCondition, ifValue, and IPipelineBuilder.validate have been enhanced to accept the following possible arguments:
  * (func:Function) - a function which accepts as many values as are in the pipeline and returns a Boolean value.  Previously this option was available to IPipelineBuilder.validate but not toCondition or ifValue functions.
  * (func:Function, matcher:Matcher) - a function which takes the values in the pipeline and returns a value which will be checked against the matcher.  Previously this option was available to IPipelineBuilder.validate but not toCondition or ifValue functions.
  * (...matchers:Matcher) - multiple matchers, each corresponding to the value in the pipeline at the same index.  This is a convenience option identical in behavior to (args(), array(matchers)).

When migrating to this release, existing clients will want to search their code to Bind.fromAll usages, and ensure that any steps using an array matcher to match multiple arguments from the pipeline are using the args() option to explicitly convert multiple arguments to an array before sending it to the matcher.

#### Summary of API changes ####

IPipeline:
  * New interface representing an executable binding pipeline.

IPipelineBuilder:
  * runner method arguments changed from (func:Function) to (target:IPipeline)

IPipelineStep:
  * Method wrapStep(next:Function):Function replaced by wrap(next:IPipeline):IPipeline

Global functions:
  * Introduced args() converter, which converts pipeline arguments to an array, suitable for use with matchers.
  * ifValue(condition:Matcher) arguments changed to (...conditions) (see above).
  * toCondition(condition:Matcher) arguments changed to (...conditions) (see above).

### Version 0.0.3 - 2011-05-05 ###

Changes:
  * [Issue 2](https://code.google.com/p/bindage-tools/issues/detail?id=2): (Enhancement) Add pipeline step trace(message:String).  For situations that call for trace instead of mx.logging.
  * [Issue 4](https://code.google.com/p/bindage-tools/issues/detail?id=4): (Fixed) toCondition(matcher) throws exception with multiple pipeline values
  * [Issue 5](https://code.google.com/p/bindage-tools/issues/detail?id=5): (Enhancement) isNumeric() matcher for Strings.  The isNumber() matcher from Hamcrest does not work with Strings.  Use isNumeric() to validate that a string can be converted to a number.

### Version 0.0.2 - 2011-04-13 ###

Changes:
  * Dramatically reduced file size
  * Changed Maven groupId to com.googlecode.bindage-tools

### Version 0.0.1-SNAPSHOT - 2011-04-01 ###

Initial release