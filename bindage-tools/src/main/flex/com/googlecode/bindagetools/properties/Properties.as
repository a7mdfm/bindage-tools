package com.googlecode.bindagetools.properties {
import org.hamcrest.Matcher;

/**
 * Documentation for top-level functions in the bindage-tools properties package.  The methods in
 * this class serve as documentation for the public functions in this package.
 *
 * <p>
 * <em>Note:</em> This class exists as a workaround to an asdoc bug in Flex 3, which causes
 * some top-level functions to be excluded from generated ASdoc.  We recommend that you use the
 * top-level functions directly.
 * </p>
 */
public class Properties {

  /**
   * @private
   */
  function Properties() {
  }

  /**
   * Returns a custom property object for the item at the specified index.  May be used with
   * Array and ILists.
   *
   * @param index the item index
   * @return a property object for getting/setting/watching the item at the specified index.
   */
  public function itemAt(index:int):Object {
    return com.googlecode.bindagetools.properties.itemAt(index);
  }

  /**
   * Returns a custom property object which gets the first element in an array or collection which
   * matches the specified condition, if any.  May be used with Array and ILists.
   *
   * @param matcher the condition against which array/collection elements will be tested.
   * @return a property object for getting/setting/watching the first item matching the specified
   * condition.
   */
  public function itemThat(matcher:Matcher):Object {
    return com.googlecode.bindagetools.properties.firstItemThat(matcher);
  }

  /**
   * Returns a custom property object for the style with the specified name.  May be used with
   * UIComponents.
   *
   * <p>
   * <em>Note</em>: This property should only be used as a destination property, and not as a source
   * property. There is no known listener API for UIComponent styles, making it impossible to detect
   * style changes programatically.
   * </p>
   *
   * @param styleProp the style name
   * @return a property object for getting/setting (but not watching) the style with the specified
   * name.
   */
  public function style(styleProp:String):Object {
    return com.googlecode.bindagetools.properties.style(styleProp);
  }

}

}