package com.googlecode.bindagetools.util {

import flash.events.Event;
import mx.binding.utils.ChangeWatcher;
import mx.core.EventPriority;
import mx.events.PropertyChangeEvent;

/**
 * An extension of mx.binding.utils.ChangeWatcher which supports
 */
public class EventChangeWatcher extends ChangeWatcher {

  public static function watch(host:Object,
                               chain:Object,
                               handler:Function,
                               commitOnly:Boolean = false,
                               useWeakReference:Boolean = false):ChangeWatcher {
    if (!(chain is Array)) {
      chain = [ chain ];
    }

    if (chain.length > 0) {
      var next:ChangeWatcher = watch(null, chain.slice(1), handler, commitOnly, useWeakReference);

      var access:Object = chain[0];

      var w:ChangeWatcher = access is String || !access.events
        ? new ChangeWatcher(access, handler, commitOnly, next)
        : new EventChangeWatcher(access, handler, commitOnly, next);

      // no idea why this property isn't visible to us, it's in the API docs.
      //w.useWeakReference = useWeakReference;

      w.reset(host);

      return w;
    }
    else {
      return null;
    }
  }

  private var events:Object;
  private var host:Object;
  private var name:String;
  private var getter:Function;
  private var handler:Function;
  private var next:ChangeWatcher;

  private var isExecuting:Boolean;

  public function EventChangeWatcher(access:Object,
                                     handler:Function,
                                     commitOnly:Boolean = false,
                                     next:ChangeWatcher = null) {
    super(access, handler, commitOnly, next);

    this.host = null;
    this.name = access is String ? access as String : access.name;
    this.getter = access is String ? null : access.getter;
    this.events = access is String ? null : access.events;
    this.handler = handler;
    this.next = next;
    
    this.isExecuting = false;
  }

  override public function reset(newHost:Object):void {
    var event:String;

    if (host != null) {
      for each (event in events) {
        host.removeEventListener(event, wrapHandler);
      }
    }

    this.host = newHost;

    if (host != null) {
      for each (event in events) {
        host.addEventListener(event, 
                              wrapHandler, 
                              false, 
                              EventPriority.BINDING,
                              /* this.useWeakReference not visible?? */ false);
      }
    }

    if (next) {
      next.reset(getHostPropertyValue());
    }
  }

  override public function setHandler(handler: Function):void {
    this.handler = handler;
    this.next.setHandler(handler);
  }
  
  private function getHostPropertyValue():Object {
    return host == null
        ? null 
        : getter != null 
            ? getter(host) 
            : host[name];
  }

  private function wrapHandler(event:Event):void
  {
    if (!isExecuting) {
      try {
        isExecuting = true;

        if (next) {
          next.reset(getHostPropertyValue());
        }

        if (event is PropertyChangeEvent) {
          if ((event as PropertyChangeEvent).property == name) {
            handler(event as PropertyChangeEvent);
          }
        }
        else {
          handler(event);
        }
      }
      finally {
        isExecuting = false;
      }
    }
  }

}

}
