package com.googlecode.bindagetools {
import com.googlecode.bindagetools.impl.PipelineBuilderFactory;

/**
 * Returns a factory for creating binding pipelines between arbitrary <code>[Bindable]</code>
 * properties.
 *
 * <h3>Examples:</h3>
 *
 * <h4>Simple one-way binding:</h4>
 * <pre>
 *     bind().fromProperty(model, "submitEnabled")
 *           .toProperty(submitButton, "enabled");
 * </pre>
 *
 * <h4>Two-way bindings:</h4>
 * <pre>
 *     bind().twoWay(
 *             bind().fromProperty(person, "name"),
 *             bind().fromProperty(nameInput, "text")
 *           );
 * </pre>
 *
 * <h4>Data validation:</h4>
 * <pre>
 *     bind().fromProperty(ageStepper, "value")
 *           .validate(greaterThanOrEqualTo(0)) // (Hamcrest matcher)
 *           .toProperty(person, "age");
 * </pre>
 *
 * <h4>Data conversion</h4>
 * <pre>
 *     bind().fromProperty(ageInput, "text")
 *           .convert(toNumber())
 *           .toProperty(person, "age");
 * </pre>
 *
 * <h4>Custom conversion</h4>
 * <pre>
 *     function toTitleCase(value:String):String {
 *       return value.replace(/\b./g, // match first letter of each word
 *                            function(match:String, ... rest):String {
 *                              return match.toUpperCase(); }
 *                            });
 *     }
 *     <br/>
 *     bind().fromProperty(document, "title")
 *           .convert(toTitleCase)
 *           .toProperty(titleLabel, "text");
 * </pre>
 *
 * <h4>Conditional conversion:</h4>
 * <pre>
 *     bind().fromProperty(person, "name")
 *           .convert(ifValue(isA(emptyString()))
 *               .thenConvert(toConstant("This field is required"))
 *               .elseConvert(toConstant(null)))
 *           .toProperty(nameInput, "errorString");
 * </pre>
 *
 * <h4>Validate for conversion, convert, then validate converted value</h4>
 * <pre>
 *     bind().fromProperty(ageInput, "text")
 *           .validate(re(/\d+/)) // ("re" is the Hamcrest matcher for RegExp)
 *           .convert(toNumber())
 *           .validate(greaterThan(0))
 *           .toProperty(person, "age");
 * </pre>
 *
 * <h4>Two-way binding with validation and conversion</h4>
 * <pre>
 *     bind().twoWay(
 *             bind().fromProperty(model, "age")
 *                   .convert(valueToString()),
 *             bind().fromProperty(ageInput, "text")
 *                   .validate(isNumber())
 *                   .convert(toNumber())
 *                   .validate(greaterThan(0))
 *           );
 * </pre>
 *
 * <h4>bind() from a property to a handler function:</h4>
 * <pre>
 *     function selectAllOrNone(all:Boolean):void {
 *       if (all) {
 *         selectAll();
 *       }
 *       else {
 *         deselectAll();
 *       }
 *     }
 * <br/>
 *     bind().fromProperty(selectAllCheckbox, "selection")
 *           .toFunction(selectAllOrNone);
 * </pre>
 *
 * <h4>Interpolate values into Strings:</h4>
 * <pre>
 *     bind().fromProperty(user, "name")
 *           .format("Welcome, {0}!")
 *           .toProperty(welcomeLabel, "text");
 * </pre>
 *
 * <h4>Log when data travels through a binding pipeline:</h4>
 * <pre>
 *     bind().fromProperty(person, "name")
 *           .log(LogEventLevel.DEBUG, "person.name changed to {0}")
 *           .convert(valueToString())
 *           .log(LogEventLevel.DEBUG, "name converted to String {0}")
 *           .toProperty(nameInput, "text");
 * </pre>
 *
 * <h4>bind() from multiple sources</h4>
 * <pre>
 *     bind().fromAll(
 *             bind().fromProperty(billingSameAsShippingCheckbox, "selection"),
 *             bind().fromProperty(shippingAddressInput, "text"),
 *             bind().fromProperty(billingAddressInput, "text")
 *           )
 *           .convert(function(billSameAsShip:Boolean, shipValue:String, billValue:String):String {
 *             // Converter function is called with argument in same order as the source bindings above
 *             return billSameAsShip ? shipValue : billValue;
 *           })
 *           .toProperty(order, "billingAddress");
 * </pre>
 *
 * <h4>Bind some condition to the enablement/visibility of a control</h4>
 * The login button should be enabled only if both the username and password fields are non-empty.
 * <pre>
 *     bind().fromAll(
 *             bind().fromProperty(userNameInput, "text"),
 *             bind().fromProperty(passwordInput, "text")
 *           )
 *           .convert(toCondition(args(), everyItem(not(emptyString()))))
 *           .toProperty(loginButton, "enabled");
 * </pre>
 *
 * <h4>Group related bindings so they do not step on eachother:</h4>
 * Suppose we have a UI for entering a coupon code.  We have a checkbox,
 * "Do you have a coupon?" and a text input to enter the code.  These two UI elements represent a
 * single field in the model.
 *
 * <p>
 * When there is a coupon code in the model, the checkbox should be selected,
 * and the coupon input should display the coupon code.
 * </p>
 *
 * <p>
 * Grouping helps solve the problem where complementary bindings make a roundtrip and overwrite
 * eachother.  If groups were omitted in this example, and if the coupon input field was blank,
 * then selecting the checkbox would trigger binding 3, which would set null to the coupon code in
 * the model (since no coupon code is entered in the text box).  Setting the model would in turn
 * trigger binding 1 with the blank value, setting the checkbox selection back to false.
 * </p>
 *
 * <p>
 * When two or more bindings are grouped together, then only one binding in the group may execute
 * at a time.  If one binding in a group is running when another is triggered,
 * the second binding simply aborts until the next property change.
 * </p>
 *
 * <p>
 * Note that bindings created using <code>bind().twoWay</code> are already grouped transparently
 * for you.
 * </p>
 *
 * <pre>
 *     var couponCodeGroup:BindGroup = new BindGroup();
 *     bind().fromProperty(order, "couponCode") // binding 1
 *           .group(couponCodeGroup)
 *           .convert(toCondition(not(equalTo(null))))
 *           .toProperty(hasCouponCheckbox, "selection");
 * <br/>
 *     bind().fromProperty(order, "couponCode") // binding 2
 *           .group(couponCodeGroup)
 *           .toProperty(couponCodeInput, "text");
 * <br/>
 *     bind().fromAll( // binding 3
 *             bind().fromProperty(hasCouponCheckbox, "selection"),
 *             bind().fromProperty(couponCodeInput, "text")
 *                   .convert(emptyStringToNull())
 *           )
 *           .group(couponCodeGroup)
 *           .convert(function(hasCoupon:Boolean, couponCode:String):String {
 *             return hasCoupon ? couponCode : null;
 *           })
 *           .toProperty(order, "couponCode");
 * </pre>
 *
 * <h4>Delay execution of a binding until the user stops typing</h4>
 *
 * <p>
 * Use a delayed binding when the response to the change is a long-running or expensive operation
 * The pipeline will halt at the delay step until the specified delay has elapsed with no further
 * changes.
 * </p>
 *
 * <pre>
 *     function searchItems(searchText:String):void {
 *       // expensive filtering operation, or asynchronous webservice call
 *     }
 * <br/>
 *     bind().fromProperty(searchInput, "text")
 *           .delay(400) // milliseconds
 *           .toFunction(searchItems);
 * </pre>
 *
 * <h4>Delay execution of a binding until the next time the source value changes</h4>
 *
 * <p>
 * In the previous example, the initial binding would always run the first time (after the
 * specified delay) even though the user has entered no search terms. The nextTime() method sets a
 * flag which prevents the pipeline from running at the time the binding is first set up. On
 * subsequent changes to the source data, the pipeline will run like normal.
 * </p>
 *
 * <pre>
 *     bind().nextTime()
 *           .fromProperty(searchInput, "text")
 *           .delay(400) // millisecond
 *           .toFunction(searchItems);
 * </pre>
 */
public function bind():IPipelineBuilderFactory {
  return new PipelineBuilderFactory();
}

}
