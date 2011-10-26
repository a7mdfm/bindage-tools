package com.googlecode.bindagetools.properties {
import mx.core.UIComponent;

/**
 * Returns a custom property object for the style with the specified name.  May be used with
 * UIComponents.
 *
 * @param styleProp the style name
 * @return a property object for getting/setting (but not watching) the style with the specified
 * name.
 */
public function style(styleProp:String):Object {
  if (styleProp == null) {
    throw new ArgumentError("style name was null");
  }

  function getter(component:UIComponent):* {
    return component.getStyle(styleProp);
  }

  function setter(component:UIComponent, value:*):void {
    component.setStyle(styleProp, value);
  }

  return {
    name: styleProp,
    getter: getter,
    setter: setter
  }
}

}
