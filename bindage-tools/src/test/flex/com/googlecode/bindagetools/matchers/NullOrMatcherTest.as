/*
 * Copyright 2011 Overstock.com and others.
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

package com.googlecode.bindagetools.matchers {
import org.hamcrest.Matcher;
import org.hamcrest.assertThat;
import org.hamcrest.number.greaterThan;
import org.hamcrest.object.equalTo;
import org.hamcrest.text.emptyString;

public class NullOrMatcherTest {

  public function NullOrMatcherTest() {
  }

  private var matcher:Matcher;

  [Test]
  public function nullOrGreaterThanZeroMatcher():void {
    matcher = nullOr(greaterThan(0));
    assertThat(matcher.matches(null));
    assertThat(matcher.matches(1));
    assertThat(matcher.matches(0),
               equalTo(false));
  }

  [Test]
  public function nullOrEmptyStringMatcher():void {
    matcher = nullOr(emptyString());

    assertThat(matcher.matches(null));
    assertThat(matcher.matches(""));
    assertThat(matcher.matches("   "));
    assertThat(matcher.matches("sdlkfjsl"),
               equalTo(false));
  }

  [Test]
  public function nullOrValue():void {
    matcher = nullOr("abc");

    assertThat(matcher.matches(null));
    assertThat(matcher.matches("abc"));
    assertThat(matcher.matches("xyz"),
               equalTo(false));
  }

}

}
