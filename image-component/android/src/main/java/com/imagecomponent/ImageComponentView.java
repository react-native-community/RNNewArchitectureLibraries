package com.imagecomponentlibrary;

import android.content.Context;
import android.net.Uri;
import android.util.AttributeSet;
import androidx.annotation.Nullable;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.react.bridge.ReadableMap;

class ImageComponentView extends SimpleDraweeView {

  public ImageComponentView(Context context) {
    super(context);
  }

  public ImageComponentView(Context context, @Nullable AttributeSet attrs) {
      super(context, attrs);
  }

  public ImageComponentView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
      super(context, attrs, defStyleAttr);
  }

  void setImage(@Nullable ReadableMap source) {
    String uri = source != null ? source.getString("uri") : null;
    Uri imageUri = Uri.parse(uri);
    this.setImageURI(imageUri);
  }
}
