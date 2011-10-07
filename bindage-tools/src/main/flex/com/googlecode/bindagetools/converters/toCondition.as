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

package com.googlecode.bindagetools.converters {
import org.hamcrest.Matcher;
import org.hamcrest.collection.array;

/**
 * Returns a converter function which returns a Boolean value indicating whether the pipeline
 * argument(s) match the specified condition.
 *
 * @param args the condition that pipeline argument(s) will be tested against. Valid values:
 * <ul>
 * <li>A <code>function(arg0, arg1, ... argN):Boolean</code>.  In this case, the function is
 * called with the pipeline arguments, and the result determines whether the pipeline continues
 * executing.</li>
 * <li>A <code>function(arg0, arg1, ... argN):* </code> followed by a <code>Matcher</code>. In
 * this case the function is called with the pipeline argument(s), and the result is validated
 * against the matcher.</li>
 * <li>One or more <code>Matcher</code>s.  In this case, the pipeline argument(s) are validated
 * against the corresponding matcher. In multi-source pipelines, there must be the same number of
 * matchers as pipeline arguments</li>
 * </ul>
 * @throws ArgumentError if the validator arguments are invalid
 * @see com.googlecode.bindagetools.converters.args
 */
public function toCondition( ...args:Array ):Function {
  var usageErrorString:String = "Expecting arguments (condition:Function), (attribute:Function, " +
                                "condition:Matcher) or (...conditions:Matchers)";

  if (args.length == 0) {
    throw new ArgumentError(usageErrorString);
  }
  else if (args.length == 1 && args[0] is Function) {
    // shortcut.  toCondition(function) without a matcher is the same as calling
    // that function directly.
    return args[0];
  }
  else if (args.length == 2 && args[0] is Function && args[1] is Matcher) {
    var attribute:Function = args[0];
    var condition:Matcher = args[1];
    return function(...values):Boolean {
      var matchValue:* = attribute.apply(null, values);
      return condition.matches(matchValue);
    }
  }
  else {
    for each (var cond:* in args) {
      if (!(cond is Matcher)) {
        throw new ArgumentError(usageErrorString);
      }
    }

    var arrayCondition:Matcher = array(args);
    var expectedArgs:Number = args.length;

    return function(...values):Boolean {
      if (expectedArgs != values.length) {
        throw new ArgumentError("Argument count does not agree with matcher count: expected " +
                                expectedArgs + ", received " + values.length +
                                ". Did you forget args()?");
      }

      return arrayCondition.matches(values);
    };
  }
}

}
