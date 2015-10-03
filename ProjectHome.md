## Introduction ##

BindageTools is an alternative to Flex's BindingUtils class, providing an intuitive, flexible API for creating and managing data bindings.

Out of the box, Flex provides great support for declarative data binding in MXML. Declarative bindings are null-safe, run automatically on set up, and are automatically torn down when components are removed from the stage. Additionally, declarative bindings allow you to combine data from several places (e.g. `text="Welcome {person.name + ' ' + person.surname}"`).

However, once you drop down to ActionScript most of that convenience goes away. Flex's built-in `BindingUtils` class only has a few features, and its API is a little awkward.

BindageTools bridges the data binding feature gap between ActionScript and MXML. It also provides many additional features not available in MXML to overcome common UI binding problems (continue reading below for examples).

## News ##

### 2012-03-12: Version 0.0.6 released ###

  * [Issue 10](https://code.google.com/p/bindage-tools/issues/detail?id=10): (Enhancement) Ability to specify event types in custom binding properties.
  * [Issue 18](https://code.google.com/p/bindage-tools/issues/detail?id=18): (Enhancement) Ability to set up bindings without running them initially.
  * [Issue 19](https://code.google.com/p/bindage-tools/issues/detail?id=19): (Enhancement) style(name) custom property for component styles
  * [Issue 20](https://code.google.com/p/bindage-tools/issues/detail?id=20): (Enhancement) firstItemThat(Matcher) and everyItemThat(Matcher) custom properties
  * (Defect) Improved exception messages from toCondition to make programming mistakes easier to recognize and correct.

See ChangeLog for full history.

## Examples ##

### Simple one-way binding ###

```
Bind.fromProperty(model, "submitEnabled")
    .toProperty(submitButton, "enabled");
```

### Two-way bindings ###

```
Bind.twoWay(
    Bind.fromProperty(person, "name"),
    Bind.fromProperty(nameInput, "text"));
```

### Data validation ###

```
Bind.fromProperty(ageStepper, "value")
    .validate(greaterThanOrEqualTo(0)) // (Hamcrest matcher)
    .toProperty(person, "age");
```

### Data conversion ###

```
Bind.fromProperty(ageInput, "text")
    .convert(toNumber())
    .toProperty(person, "age");
```

### Custom conversion ###

```
function toTitleCase(value:String):String {
  return value.replace(/\b./g, // match first letter of each word
                       function(match:String, ... rest):String {
                         return match.toUpperCase(); }
                       });
}

Bind.fromProperty(document, "title")
    .convert(toTitleCase)
    .toProperty(titleLabel, "text");
```

### Conditional conversion ###

```
Bind.fromProperty(person, "name")
    .convert(ifValue(isA(emptyString()))
        .thenConvert(toConstant("This field is required"))
        .elseConvert(toConstant(null)))
    .toProperty(nameInput, "errorString");
```

### Validate for conversion, convert, then validate converted value ###

```
Bind.fromProperty(ageInput, "text")
    .validate(re(/\d+/)) // ("re" is the Hamcrest matcher for RegExp)
    .convert(toNumber())
    .validate(greaterThan(0))
    .toProperty(person, "age");
```

### Two-way binding with validation and conversion ###

```
Bind.twoWay(
    Bind.fromProperty(model, "age")
        .convert(valueToString()),
    Bind.fromProperty(ageInput, "text")
        .validate(isNumeric())
        .convert(toNumber())
        .validate(greaterThan(0)));
```

### Bind from a property to a handler function ###

```
function selectAllOrNone(all:Boolean):void {
  if (all) {
    selectAll();
  }
  else {
    deselectAll();
  }
}
 
Bind.fromProperty(selectAllCheckbox, "selection")
    .toFunction(selectAllOrNone);
```

### Interpolate values into Strings ###

```
Bind.fromProperty(user, "name")
    .format("Welcome, {0}!")
    .toProperty(welcomeLabel, "text");
```

### Log when data travels through a binding pipeline ###

```
Bind.fromProperty(person, "name")
    .log(LogEventLevel.DEBUG, "person.name changed to {0}")
    .convert(valueToString())
    .log(LogEventLevel.DEBUG, "name converted to String {0}")
    .toProperty(nameInput, "text");
```

### Bind from multiple sources ###

```
Bind.fromAll(
    Bind.fromProperty(billingSameAsShippingCheckbox, "selection"),
    Bind.fromProperty(shippingAddressInput, "text"),
    Bind.fromProperty(billingAddressInput, "text")
    )
    .convert(function(billSameAsShip:Boolean, shipValue:String, billValue:String):String {
      // Converter function is called with argument in same order as the source bindings above
      return billSameAsShip ? shipValue : billValue;
    })
    .toProperty(order, "billingAddress");
```

### Bind some condition to the enablement/visibility of a control ###

The login button should be enabled only if both the username and password fields are non-empty.

```
Bind.fromAll(
    Bind.fromProperty(userNameInput, "text"),
    Bind.fromProperty(passwordInput, "text")
    )
    .convert(toCondition(args(), everyItem(not(emptyString()))))
    .toProperty(loginButton, "enabled");
```

### Group related bindings so they do not step on eachother ###

Suppose we have a UI for entering a coupon code. We have a checkbox, "Do you have a coupon?" and a text input to enter the code. These two UI elements represent a single field in the model.
When there is a coupon code in the model, the checkbox should be selected, and the coupon input should display the coupon code.

Grouping helps solve the problem where complementary bindings make a roundtrip and overwrite eachother. If groups were omitted in this example, and if the coupon input field was blank, then selecting the checkbox would trigger binding 3, which would set null to the coupon code in the model (since no coupon code is entered in the text box). Setting the model would in turn trigger binding 1 with the blank value, setting the checkbox selection back to false.

When two or more bindings are grouped together, then only one binding in the group may execute at a time. If one binding in a group is running when another is triggered, the second binding simply aborts until the next property change.

Note that bindings created using Bind.twoWay are already grouped transparently for you.

```
var couponCodeGroup:BindGroup = new BindGroup();
Bind.fromProperty(order, "couponCode") // binding 1
    .group(couponCodeGroup)
    .convert(toCondition(not(equalTo(null))))
    .toProperty(hasCouponCheckbox, "selection");
 
Bind.fromProperty(order, "couponCode") // binding 2
    .group(couponCodeGroup)
    .toProperty(couponCodeInput, "text");
 
Bind.fromAll( // binding 3
    Bind.fromProperty(hasCouponCheckbox, "selection"),
    Bind.fromProperty(couponCodeInput, "text")
        .convert(emptyStringToNull())
    )
    .group(couponCodeGroup)
    .convert(function(hasCoupon:Boolean, couponCode:String):String {
      return hasCoupon ? couponCode : null;
    })
    .toProperty(order, "couponCode");
```

### Set up a binding without running it right away ###

Occasionally it is necessary to set up a binding but not run it right away--instead, it should run the next time the source property or properties change.

```
function validateName(name:String):String {
  return name && name.length > 0
    ? null
    : "Name is required.";
}

// Do not show error message initially
Bind.nextTime()
    .fromProperty(model, "name")
    .convert(validateName)
    .toProperty(nameInput, "errorString");
```

### Swiz Integration ###

See SwizIntegration