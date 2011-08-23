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
import org.hamcrest.core.anyOf;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.nullValue;

/**
 * Returns a Hamcrest matcher, matching either null or the specified matcher or value.
 *
 * @param matcherOrValue Matcher or value to be wrapped in equalTo.
 */
public function nullOr(matcherOrValue:*):Matcher {
  var matcher:Matcher = matcherOrValue is Matcher
      ? matcherOrValue
      : equalTo(matcherOrValue);
  return anyOf(nullValue(), matcher);
}

}
