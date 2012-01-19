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
import org.hamcrest.collection.array;
import org.hamcrest.core.allOf;
import org.hamcrest.core.not;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.hasProperties;
import org.hamcrest.object.hasProperty;
import org.hamcrest.object.instanceOf;
import org.hamcrest.text.containsString;

public class EveryItemThatTest {

  public function EveryItemThatTest() {
  }

  [Test( expected="ArgumentError" )]
  public function everyItemThatNullMatcher():void {
    everyItemThat(null);
  }

  [Test]
  public function everyItemThatProperties():void {
    assertThat(everyItemThat(equalTo("a")),
               allOf(
                   hasProperties({
                                   name: "getItemAt",
                                   getter: instanceOf(Function)
                                 }),
                   not(hasProperty("setter"))
               ));
  }

  [Test]
  public function everyItemThatWithArrayCollection():void {
    var coll:ArrayCollection = new ArrayCollection(["aaa", "aba", "abc"]);

    assertThat(everyItemThat(containsString("a")).getter(coll), array("aaa", "aba", "abc"));
    assertThat(everyItemThat(containsString("b")).getter(coll), array("aba", "abc"));
    assertThat(everyItemThat(containsString("c")).getter(coll), array("abc"));
    assertThat(everyItemThat(containsString("d")).getter(coll), array());
  }

  [Test]
  public function everyItemThatWithArray():void {
    var coll:Array = ["aaa", "aba", "abc"];

    assertThat(everyItemThat(containsString("a")).getter(coll), array("aaa", "aba", "abc"));
    assertThat(everyItemThat(containsString("b")).getter(coll), array("aba", "abc"));
    assertThat(everyItemThat(containsString("c")).getter(coll), array("abc"));
    assertThat(everyItemThat(containsString("d")).getter(coll), array());
  }

  private function newBean(fooValue:String):Bean {
    var bean:Bean = new Bean();
    bean.foo = fooValue;
    return bean;
  }

}

}
