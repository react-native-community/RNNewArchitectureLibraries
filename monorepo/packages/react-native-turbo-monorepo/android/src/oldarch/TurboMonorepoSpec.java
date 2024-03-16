package com.turbomonorepo;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Promise;

abstract class TurboMonorepoSpec extends ReactContextBaseJavaModule {
  TurboMonorepoSpec(ReactApplicationContext context) {
    super(context);
  }

  public abstract void addListener(String eventName);

  public abstract void removeListeners(double count);

  public abstract void multiply(double a, double b, Promise promise);
}
