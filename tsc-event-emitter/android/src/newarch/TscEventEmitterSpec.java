package com.tsceventemitter;

import com.facebook.react.bridge.ReactApplicationContext;

abstract class TscEventEmitterSpec extends NativeTscEventEmitterSpec {
  TscEventEmitterSpec(ReactApplicationContext context) {
    super(context);
  }
}
