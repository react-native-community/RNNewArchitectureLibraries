package com.rnnewarchitecturelibrary;

import android.graphics.Color;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewManagerDelegate;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.viewmanagers.ColoredViewManagerInterface;
import com.facebook.react.viewmanagers.ColoredViewManagerDelegate;

    
@ReactModule(name = ColoredViewManagerImpl.NAME)
public class ColoredViewManager extends SimpleViewManager<ColoredView>
        implements ColoredViewManagerInterface<ColoredView> {

    private final ViewManagerDelegate<ColoredView> mDelegate;

    public ColoredViewManager(ReactApplicationContext context) {
        mDelegate = new ColoredViewManagerDelegate<>(this);
    }

    @Nullable
    @Override
    protected ViewManagerDelegate<ColoredView> getDelegate() {
        return mDelegate;
    }

    @NonNull
    @Override
    public String getName() {
        return ColoredViewManagerImpl.NAME;
    }

    @NonNull
    @Override
    protected ColoredView createViewInstance(@NonNull ThemedReactContext context) {
        return ColoredViewManagerImpl.createViewInstance(context);
    }

    @Override
    @ReactProp(name = "color")
    public void setColor(ColoredView view, @Nullable String color) {
        ColoredViewManagerImpl.setColor(view, color);
    }
}