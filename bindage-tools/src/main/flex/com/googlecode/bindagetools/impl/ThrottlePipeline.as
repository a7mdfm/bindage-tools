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
import com.googlecode.bindagetools.IPipeline;

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

public class ThrottlePipeline implements IPipeline {

  private var intervalMillis:int;
  private var next:IPipeline;

  private var nextTime:int = 0;

  private var timer:Timer = null;
  private var nextArgs:Array;

  public function ThrottlePipeline( intervalMillis:int, next:IPipeline ) {
    this.intervalMillis = intervalMillis;
    this.next = next;
  }

  public function run( args:Array ):void {
    var currentTime:int = getTimer();

    if (timer != null) {
      nextArgs = args;
    }
    else if (currentTime >= nextTime) {
      nextTime = currentTime + intervalMillis;

      next.run(args);
    }
    else {
      nextArgs = args;

      timer = new Timer(nextTime - currentTime, 1);
      timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerElapsed);
      timer.start();
    }
  }

  private function timerElapsed( event:TimerEvent ):void {
    var args:Array = nextArgs;

    timer = null;
    nextArgs = null;
    nextTime = getTimer() + intervalMillis;

    next.run(args);
  }

}

}