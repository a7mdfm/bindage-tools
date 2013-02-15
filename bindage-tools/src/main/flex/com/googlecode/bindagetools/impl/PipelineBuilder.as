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

package com.googlecode.bindagetools.impl {
import com.googlecode.bindagetools.BindGroup;
import com.googlecode.bindagetools.IPipeline;
import com.googlecode.bindagetools.IPipelineBuilder;
import com.googlecode.bindagetools.IPipelineStep;
import com.googlecode.bindagetools.util.preventRecursion;

import flash.events.Event;

/**
 * @private
 */
public class PipelineBuilder implements IPipelineBuilder {
  private var groups:Array;
  private var steps:Array;
  private var nextTime:Boolean;

  public function PipelineBuilder(nextTime:Boolean) {
    groups = [];
    steps = [];
    this.nextTime = nextTime;
  }

  public function append( step:IPipelineStep ):IPipelineBuilder {
    steps.push(step);
    return this;
  }

  public function convert( converter:Function ):IPipelineBuilder {
    return append(new ConvertStep(converter));
  }

  public function delay( delayMillis:int ):IPipelineBuilder {
    return append(new DelayStep(delayMillis));
  }

  public function format( format:String ):IPipelineBuilder {
    return append(new FormatStep(format));
  }

  public function group( group:BindGroup ):IPipelineBuilder {
    groups.push(group);
    return this;
  }

  public function log( level:int,
                       message:String ):IPipelineBuilder {
    return append(new LogStep(level, message));
  }

  public function throttle( intervalMillis:int ):IPipelineBuilder {
    return append(new ThrottleStep(intervalMillis));
  }

  public function trace( message:String ):IPipelineBuilder {
    return append(new TraceStep(message));
  }

  public function validate( ...condition ):IPipelineBuilder {
    return append(new ValidateStep(condition));
  }

  public function toProperty( target:Object,
                              property:Object,
                              ...additionalProperties ):IPipelineBuilder {
    var properties:Array;
    if (property is Array && additionalProperties.length == 0) {
      properties = property as Array;
    }
    else {
      properties = [property].concat(additionalProperties);
    }

    if (null == target) {
      throw new ArgumentError("target was null");
    }

    checkCustomGetterProperties(properties.slice(0, properties.length - 1));
    checkCustomSetterProperty(properties[properties.length - 1]);

    var normalizedProperties:* = normalizeProperties(properties);

    var setterTarget:IPipeline = new SetterPipeline(target, normalizedProperties);

    return toPipeline(setterTarget);
  }

  protected static function checkCustomGetterProperties( properties:Array ):void {
    for each (var property:Object in properties) {
      checkCustomGetterProperty(property);
    }
  }

  private static function checkCustomGetterProperty( property:Object ):void {
    checkNullProperty(property);
    if (!(property is String)) {
      var name:String = property.name as String;
      var getter:Function = property.getter as Function;
      var events:Array = property.events as Array;

      if (!(name && getter || name && events || getter && events)) {
        throw new ArgumentError("Custom getter property must have two of these properties: " +
        		"name:String, getter:Function, or events:Array");
      }
    }
  }

  private static function checkCustomSetterProperty( property:Object ):void {
    checkNullProperty(property);
    if (!(property is String)) {
      var name:String = property.name as String;
      var setter:Function = property.setter as Function;
      var events:Array = property.events as Array;

      if (!(name && setter || name && events || setter && events )) {
        throw new ArgumentError("Custom setter property must have two of these attributes: " +
            "name:String, setter:Function, or events:Array");
      }
    }
  }

  private static function checkNullProperty( property:Object ):void {
    if (property == null) {
      throw new ArgumentError("property was null");
    }
  }

  protected function normalizeProperties( properties:Array ):Array {
    var result:Array = [];
    for each (var property:Object in properties) {
      if (property is String) {
        for each (var prop:String in String(property).split(".")) {
          result.push(prop);
        }
      }
      else if (property.getter is Function || property.name is String) {
        result.push(property);
      }
    }
    return result;
  }

  public function toFunction( func:Function ):IPipelineBuilder {
    return toPipeline(new FunctionPipeline(func));
  }

  private function toPipeline( target:IPipeline ):IPipelineBuilder {
    var pipelineRunner:Function = runner(target);
    pipelineRunner = preventRecursion(pipelineRunner);

    function handler( event:Event ):void {
      pipelineRunner();
    }

    watch(handler);

    if (!nextTime) {
      handler(null);
    }

    return this;
  }

  public function runner( target:IPipeline ):Function {
    var pipeline:IPipeline = buildPipeline(target);

    var runner:Function = pipelineRunner(pipeline);

    return runner;
  }

  private function buildPipeline( toWrap:IPipeline ):IPipeline {
    var pipeline:IPipeline = toWrap;

    for (var i:int = steps.length - 1; i >= 0; i--) {
      var step:IPipelineStep = steps[i];

      if (step is DelayStep) {
        // We exited the groups when the delay started.  Wrap the pipeline in each group to
        // ensure we don't get round-robin bindings.
        pipeline = wrapPipelineInExclusiveGroups(pipeline);
      }
      else if (step is ThrottleStep) {
        // Depending on whether the required interval has elapsed, the throttling may or may
        // not delay execution of the next step using a timer. Therefore wrap the next step
        // in a pipeline that will recursively call into the group if necessary.
        pipeline = wrapPipelineInRecursiveGroups(pipeline);
      }

      pipeline = step.wrap(pipeline);
    }

    pipeline = wrapPipelineInExclusiveGroups(pipeline);

    return pipeline;
  }

  private function wrapPipelineInExclusiveGroups( pipeline:IPipeline ):IPipeline {
    var result:IPipeline = pipeline;
    for each (var group:BindGroup in groups) {
      result = new ExclusiveGroupPipeline(group, result);
    }
    return result;
  }

  private function wrapPipelineInRecursiveGroups( pipeline:IPipeline ):IPipeline {
    var result:IPipeline = pipeline;
    for each (var group:BindGroup in groups) {
      result = new RecursiveGroupPipeline(group, result);
    }
    return result;
  }

  protected function pipelineRunner( pipeline:IPipeline ):Function {
    throw new Error("abstract methods");
  }

  public function watch( runner:Function ):void {
    throw new Error("abstract methods");
  }

}

}
