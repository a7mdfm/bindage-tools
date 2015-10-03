# Introduction #

BindageTools includes a Swiz custom annotation processor that can greatly simplify setup / teardown of your data bindings.

Include the following in your Swiz configuration:

```
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml"
                xmlns:swiz="http://swiz.swizframework.org"
                xmlns:bindage="http://bindage-tools.googlecode.com/swiz">

  <swiz:Swiz>

    ...

    <swiz:customProcessors>
      <bindage:DataBindingProcessor />
    </swiz:customProcessors>
  </swiz:Swiz>

  ...

</mx:Application>
```

This sets up Swiz so that any public method with the annotation `[DataBinding]` in a view or bean will be executed on set up.

```
[Bindable]
class ContactEditPresentationModel {
  [Inject]
  public var contact:Contact;

  [Dispatcher]
  public var dispatcher:IEventDispatcher;

  public var firstName:String;

  public var firstNameErrorString:String;

  public var lastName:String;

  public var lastNameErrorString:String;

  public var saveEnabled:Boolean;

  [DataBinding]
  public function initBindings():void {
    Bind.fromProperty(contact, "firstName")
        .toProperty(this, "firstName");

    Bind.fromProperty(contact, "lastName")
        .toProperty(this, "lastName");

    Bind.fromProperty(this, "firstName")
        .convert(validateRequiredString)
        .to(this, "firstNameErrorString");
        
    Bind.fromProperty(this, "lastName")
        .convert(validateRequiredString)
        .to(this, "lastNameErrorString");
        
    Bind.fromAll(
        Bind.fromProperty(this, "firstNameErrorString"),
        Bind.fromProperty(this, "lastNameErrorString")
        )
        .convert(toCondition(everyItem(equalTo(null))))
        .toProperty(this, "saveEnabled");
  }

  private function validateRequiredString(value:String):String {
    if (value == null || value.length == 0) {
      return "This field is required.";
    }
    return null;
  }

  public function save():void {
    if (saveEnabled) {
      dispatcher.dispatchEvent(
        new SaveContactEvent(contact.id, firstName, lastName));
    }
  }
}
```

When the view or bean is torn down, any data bindings that were created with BindageTools API inside during that method's execution will be automatically destroyed.

If you must create or destroy data bindings outside the Swiz setup lifecycle, consider using the method `BindTracker.collect(Function)` to help in tracking and cleaning up data bindings.

_Note_: Data bindings in Swiz beans runs during the normal setup phase.  However in the case of views, setup may be deferred until after FlexEvent.CREATION\_COMPLETE to ensure that all UI fields are initialized.  This prevent null reference bugs in views using lazy initialization, such as `ViewStack`.