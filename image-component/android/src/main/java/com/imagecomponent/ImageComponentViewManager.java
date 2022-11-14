package com.imagecomponentlibrary;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewManagerDelegate;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.viewmanagers.RTNImageComponentManagerDelegate;
import com.facebook.react.viewmanagers.RTNImageComponentManagerInterface;

/** View manager for {@link NativeViewVithState} components. */
@ReactModule(name = ImageComponentViewManager.REACT_CLASS)
public class ImageComponentViewManager extends SimpleViewManager<ImageComponentView>
    implements RTNImageComponentManagerInterface<ImageComponentView> {

  public static final String REACT_CLASS = "RTNImageComponent";
  ReactApplicationContext mCallerContext;
  private final ViewManagerDelegate<ImageComponentView> mDelegate;


  public ImageComponentViewManager(ReactApplicationContext reactContext) {
      mCallerContext = reactContext;
      mDelegate = new RTNImageComponentManagerDelegate<>(this);
  }

  @Nullable
  @Override
  protected ViewManagerDelegate<ImageComponentView> getDelegate() {
    return mDelegate;
  }

  @NonNull
  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @NonNull
  @Override
  protected ImageComponentView createViewInstance(@NonNull ThemedReactContext reactContext) {
    return new ImageComponentView(reactContext);
  }

  @Override
  @ReactProp(name = "image")
  public void setImage(ImageComponentView view, @Nullable ReadableMap value) {
    view.setImage(value);
  }
}
