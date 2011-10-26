package com.googlecode.bindagetools.properties {
import flash.events.Event;

import mx.binding.utils.ChangeWatcher;
import mx.core.Application;
import mx.core.UIComponent;

import org.flexunit.Assert;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.hasProperties;
import org.hamcrest.object.hasProperty;
import org.hamcrest.object.instanceOf;

public class StyleTest {

  private var component:UIComponent;

  public function StyleTest() {
  }

  [Before]
  public function setUp():void {
    component = new UIComponent();
    Application(Application.application).addChild(component);
  }

  [After]
  public function tearDown():void {
    Application(Application.application).removeChild(component);
  }

  [Test( expects=ArgumentError )]
  public function styleNullName():void {
    style(null);
  }

  [Test]
  public function styleProperties():void {
    assertThat(style("errorColor"),
               hasProperties({
                               name: "errorColor",
                               getter: instanceOf(Function),
                               setter: instanceOf(Function)
                             }));

    assertThat(style("focusThickness"),
               hasProperty("name", "focusThickness"));
  }

  [Test]
  public function styleGetter():void {
    component.setStyle("errorColor", 0xFF8080);

    assertThat(style("errorColor").getter(component),
               equalTo(0xFF8080));
  }

  [Test]
  public function styleSetter():void {
    style("focusThickness").setter(component, 20);

    assertThat(component.getStyle("focusThickness"),
               equalTo(20));
  }

  [Test]
  public function styleChangeWatcherDoesntBlowUp():void {
    function handler(event:Event):void {
      Assert.fail("Should never be called");
    }

    var watcher:ChangeWatcher = ChangeWatcher.watch(component, style("focusThickness"), handler);

    component.setStyle("focusThickness", 20);

    assertThat(watcher.getValue(), equalTo(20));
  }

}

}
