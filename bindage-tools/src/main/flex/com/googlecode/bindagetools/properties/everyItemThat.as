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

import org.hamcrest.Matcher;

/**
 * Returns a custom property object which gets an array of every element in an array or collection
 * which matches the specified condition.  May be used with Array and ILists.
 *
 * @param matcher the condition against which array/collection elements will be tested.
 * @return a property object for getting/setting/watching the first item matching the specified
 * condition.
 */
public function everyItemThat(matcher:Matcher):Object {
  if (null == matcher) {
    throw new ArgumentError("matcher was null");
  }

  function getter(obj:Object):* {
    var result:Array = [];

    for (var i:int = 0; i < obj.length; i++) {
      var item:* = obj[i];
      if (matcher.matches(item)) {
        result.push(item);
      }
    }

    return result;
  }

  return {
    name: "getItemAt",
    getter: getter
  };
}

}
