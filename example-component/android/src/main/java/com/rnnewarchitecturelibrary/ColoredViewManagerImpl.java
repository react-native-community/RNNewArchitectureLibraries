package com.rnnewarchitecturelibrary;

import androidx.annotation.Nullable;
import com.facebook.react.uimanager.ThemedReactContext;
import android.graphics.Color;

public class ColoredViewManagerImpl {

    public static final String NAME = "ColoredView";

    public static ColoredView createViewInstance(ThemedReactContext context) {
        return new ColoredView(context);
    }

    public static void setColor(ColoredView view, String color) {
        view.setBackgroundColor(Color.parseColor(color));
    }

}