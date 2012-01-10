/*
 * Copyright 2012 Overstock.com and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.googlecode.bindagetools.properties {

import com.googlecode.bindagetools.Bean;

import mx.collections.ArrayCollection;

import org.hamcrest.assertThat;
import org.hamcrest.core.allOf;
import org.hamcrest.core.not;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.hasProperties;
import org.hamcrest.object.hasProperty;
import org.hamcrest.object.instanceOf;
import org.hamcrest.object.nullValue;

public class ItemThatTest {

  public function ItemThatTest() {
  }

  [Test( expected="ArgumentError" )]
  public function itemThatNullMatcher():void {
    itemThat(null);
  }

  [Test]
  public function itemThatProperties():void {
    assertThat(itemThat(equalTo("a")),
               allOf(
                   hasProperties({
                                   name: "getItemAt",
                                   getter: instanceOf(Function)
                                 }),
                   not(hasProperty("setter"))
               ));
  }

  [Test]
  public function testItemThatWithArrayCollection():void {
    var a:Bean = newBean("a");
    var b:Bean = newBean("b");
    var c:Bean = newBean("c");
    var coll:ArrayCollection = new ArrayCollection([a, b, c]);

    assertThat(itemThat(hasProperty("foo", "a")).getter(coll), equalTo(a));
    assertThat(itemThat(hasProperty("foo", "b")).getter(coll), equalTo(b));
    assertThat(itemThat(hasProperty("foo", "c")).getter(coll), equalTo(c));
    assertThat(itemThat(hasProperty("foo", "d")).getter(coll), nullValue());
  }

  [Test]
  public function testItemAtWithArray():void {
    var a:Bean = newBean("a");
    var b:Bean = newBean("b");
    var c:Bean = newBean("c");
    var coll:Array = [a, b, c];

    assertThat(itemThat(hasProperty("foo", "a")).getter(coll), equalTo(a));
    assertThat(itemThat(hasProperty("foo", "b")).getter(coll), equalTo(b));
    assertThat(itemThat(hasProperty("foo", "c")).getter(coll), equalTo(c));
    assertThat(itemThat(hasProperty("foo", "d")).getter(coll), nullValue());
  }

  private function newBean(fooValue:String):Bean {
    var bean:Bean = new Bean();
    bean.foo = fooValue;
    return bean;
  }

}

}
