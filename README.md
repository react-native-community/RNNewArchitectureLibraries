# Run

This run is used to show an advanced use of a component which use the state to load images on **iOS**.

Loading images on **Android** is done with Fresco, so the android component won't actually use the state. The example is still helpful to show how to configure auto-linking properly when there is some custom C++ state.

## Table of Content

* [[Setup] Create the image-component folder and the package.json](#setup)
* [[Fabric Component] Create the TS specs](#ts-specs)
* [[Fabric Component] Setup Codegen](#codegen)
* [[Fabric Componenr] Create the podspec for iOS](#ios-podspec)
* [[Fabric Component] Create the Basic Component](#ios-basic)
* [[Fabric Component] Configure podspec and package.json to work with custom C++ Files](#ios-cxx-podspec)
* [[Fabric Component] Implement Cxx state](#ios-cxx-advanced)
* [[Fabric Component] Update the iOS Code](#update-ios-code)
* [[Test iOS] Test your iOS Component](#test-ios)
* [[Fabric Component] Add Android implementation](#android-impl)

## Steps

### <a name="setup">[[Setup] Create the image-component folder and the package.json]()

1. `mkdir image-component`
2. `touch image-component/package.json`
3. Paste the following code into the `package.json` file
```json
{
    "name": "image-component",
    "version": "0.0.1",
    "description": "Showcase Fabric component with state",
    "react-native": "src/index",
    "source": "src/index",
    "files": [
        "src",
        "android",
        "ios",
        "example-component.podspec",
        "!android/build",
        "!ios/build",
        "!**/__tests__",
        "!**/__fixtures__",
        "!**/__mocks__"
    ],
    "keywords": ["react-native", "ios", "android"],
    "repository": "https://github.com/<your_github_handle>/image-component",
    "author": "<Your Name> <your_email@your_provider.com> (https://github.com/<your_github_handle>)",
    "license": "MIT",
    "bugs": {
        "url": "https://github.com/<your_github_handle>/image-component/issues"
    },
    "homepage": "https://github.com/<your_github_handle>/image-component#readme",
    "devDependencies": {},
    "peerDependencies": {
        "react": "*",
        "react-native": "*"
    }
}
```

### <a name="ts-import" />[[Fabric Component] Create the TS specs]()

1. `mkdir image-component/src`
1. `touch image-component/src/ImageComponentNativeComponent.ts`
1. Paste the following content into the `ImageComponentNativeComponent.ts`
```ts
import type { ViewProps } from 'ViewPropTypes';
import type { HostComponent } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type {ImageSource} from 'react-native/Libraries/Image';

export interface NativeProps extends ViewProps {
  image?: ImageSource;
  // add other props here
}

export default codegenNativeComponent<NativeProps>(
  'RTNImageComponent'
) as HostComponent<NativeProps>;
```

### <a name="codegen" />[[Fabric Component] Setup Codegen]()

1. Open the `image-component/package.json`
2. Add the following snippet at the end of it:
```json
, "codegenConfig": {
    "name": "RTNImageViewSpec",
    "type": "all",
    "jsSrcsDir": "src"
}
```

### <a name="ios-podspec" />[[Fabric Component] Create the podspec for iOS]()

* Create a `image-component.podspec` file
* Paste the following content into it:

```ruby
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name            = "image-component"
  s.version         = package["version"]
  s.summary         = package["description"]
  s.description     = package["description"]
  s.homepage        = package["homepage"]
  s.license         = package["license"]
  s.platforms       = { :ios => "11.0" }
  s.author          = package["author"]
  s.source          = { :git => package["repository"], :tag => "#{s.version}" }

  s.source_files    = "ios/**/*.{h,m,mm,swift}"

  install_modules_dependencies(s)
end
```

### <a name="ios-basic" />[[Fabric Component] Create the Basic Component]()

* Create the `ios` folder as sibling of the `src` one
* Add the `RTNImageComponentViewManager.mm` file
    ```cpp
    #import <React/RCTLog.h>
    #import <React/RCTUIManager.h>
    #import <React/RCTViewManager.h>

    @interface RTNImageComponentViewManager : RCTViewManager
    @end

    @implementation RTNImageComponentViewManager

    RCT_EXPORT_MODULE(RTNImageComponent)

    RCT_EXPORT_VIEW_PROPERTY(image, UIImage *)

    @end
    ```
* Create the `RTNImageComponentView.h`
    ```cpp
    #import <React/RCTViewComponentView.h>
    #import <UIKit/UIKit.h>

    NS_ASSUME_NONNULL_BEGIN

    @interface RTNImageComponentView : RCTViewComponentView

    @end

    NS_ASSUME_NONNULL_END
    ```
* Create the `RTNImageComponentView.mm`
    ```cpp
    #import "RTNImageComponentView.h"

    #import <react/renderer/components/RTNImageViewSpec/ComponentDescriptors.h>
    #import <react/renderer/components/RTNImageViewSpec/EventEmitters.h>
    #import <react/renderer/components/RTNImageViewSpec/Props.h>
    #import <react/renderer/components/RTNImageViewSpec/RCTComponentViewHelpers.h>

    #import "RCTFabricComponentsPlugins.h"

    using namespace facebook::react;

    @interface RTNImageComponentView () <RCTRTNImageComponentViewProtocol>
    @end

    @implementation RTNImageComponentView {
    UIView *_view;
    UIImageView *_imageView;
    UIImage *_image;
    }

    + (ComponentDescriptorProvider)componentDescriptorProvider
    {
    return concreteComponentDescriptorProvider<RTNImageComponentComponentDescriptor>();
    }

    - (instancetype)initWithFrame:(CGRect)frame
    {
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const RTNImageComponentProps>();
        _props = defaultProps;

        _view = [[UIView alloc] init];
        _view.backgroundColor = [UIColor redColor];

        _imageView = [[UIImageView alloc] init];
        [_view addSubview:_imageView];

        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
        [_imageView.topAnchor constraintEqualToAnchor:_view.topAnchor constant:10],
        [_imageView.leftAnchor constraintEqualToAnchor:_view.leftAnchor constant:10],
        [_imageView.bottomAnchor constraintEqualToAnchor:_view.bottomAnchor constant:-10],
        [_imageView.rightAnchor constraintEqualToAnchor:_view.rightAnchor constant:-10],
        ]];
        _imageView.image = _image;

        self.contentView = _view;
    }

    return self;
    }

    - (void)prepareForRecycle
    {
    [super prepareForRecycle];
    _image = nil;
    }

    - (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
    {
    [super updateProps:props oldProps:oldProps];
    }

    - (void)updateState:(facebook::react::State::Shared const &)state
            oldState:(facebook::react::State::Shared const &)oldState
    {
    auto _state = std::static_pointer_cast<RTNImageComponentShadowNode::ConcreteState const>(state);
    auto _oldState = std::static_pointer_cast<RTNImageComponentShadowNode::ConcreteState const>(oldState);
    }

    @end

    Class<RCTComponentViewProtocol> RTNImageComponentCls(void)
    {
    return RTNImageComponentView.class;
    }
    ```

### <a name="ios-cxx-podspec">[[Fabric Component] Configure podspec and package.json to work with custom C++ Files]()

* Alongside the `ios` and the `src` folder, create a new `cxx` folder.
* Open the `image-component.podspec` file
* change the following line to include also the content of the cxx folder:
```diff
- s.source_files    = "ios/**/*.{h,m,mm,cpp,swift}"
+ s.source_files    = "{cxx,ios}/**/*.{h,m,mm,cpp,swift}"
```
* open the `package.json` file and add the `cxx` folder in the files list
```diff
  "files": [
        "src",
        "android",
        "ios",
+       "cxx",
        "example-component.podspec",
```

### <a name="ios-cxx-advanced" />[[Fabric Component] Implement Cxx state]()

**Note: In this section we are going to add a bunch of C++ code. This contains the custom logic of your component, that's why React NAtive can't generate it automatically for your app.**

* In the cxx folder, create a new `RTNImageComponentCustomNativeState.h` file
  ```cpp
    #pragma once

    #ifdef ANDROID
    #include <folly/dynamic.h>
    #include <react/renderer/mapbuffer/MapBuffer.h>
    #include <react/renderer/mapbuffer/MapBufferBuilder.h>
    #endif

    #include <react/renderer/imagemanager/ImageRequest.h>
    #include <react/renderer/imagemanager/primitives.h>

    namespace facebook {
    namespace react {

    /*
    * State for <Slider> component.
    */
    class RTNImageComponentCustomNativeState final {
    public:
    RTNImageComponentCustomNativeState(
        ImageSource const &imageSource,
        ImageRequest imageRequest)
        : imageSource_(imageSource),
            imageRequest_(
                std::make_shared<ImageRequest>(std::move(imageRequest))){};

    RTNImageComponentCustomNativeState() = default;

    ImageSource getImageSource() const;
    ImageRequest const &getImageRequest() const;

    #ifdef ANDROID
    SliderState(RTNImageComponentCustomNativeState const &previousState, folly::dynamic data){};

    /*
    * Empty implementation for Android because it doesn't use this class.
    */
    folly::dynamic getDynamic() const {
        return {};
    };
    MapBuffer getMapBuffer() const {
        return MapBufferBuilder::EMPTY();
    };
    #endif

    private:
    ImageSource imageSource_;
    std::shared_ptr<ImageRequest> imageRequest_;
    };

    } // namespace react
    } // namespace facebook
  ```
* In the cxx folder, create a new `RTNImageComponentCustomNativeState.cpp` file
  ```cpp
    #include "RTNImageComponentCustomNativeState.h"

    namespace facebook::react {

    ImageSource RTNImageComponentCustomNativeState::getImageSource() const {
        return imageSource_;
    }

    ImageRequest const &RTNImageComponentCustomNativeState::getImageRequest() const {
        return *imageRequest_;
    }

    } // namespace facebook::react
  ```
* In the cxx folder, create a new `RTNImageComponentCustomShadowNode.h` file
  ```cpp
    #pragma once
    #include "RTNImageComponentCustomNativeState.h"

    #include <jsi/jsi.h>
    #include <react/renderer/components/RTNImageViewSpec/EventEmitters.h>
    #include <react/renderer/components/RTNImageViewSpec/Props.h>
    #include <react/renderer/components/view/ConcreteViewShadowNode.h>

    #include <react/renderer/imagemanager/ImageManager.h>
    #include <react/renderer/imagemanager/primitives.h>

    namespace facebook {
    namespace react {

    JSI_EXPORT extern const char RTNImageComponentComponentName[];

    /*
    * `ShadowNode` for <Slider> component.
    */
    class RTNImageComponentCustomShadowNode final
        : public ConcreteViewShadowNode<
            RTNImageComponentComponentName,
            RTNImageComponentProps,
            RTNImageComponentEventEmitter,
            RTNImageComponentCustomNativeState> {
    public:
    using ConcreteViewShadowNode::ConcreteViewShadowNode;

    // Associates a shared `ImageManager` with the node.
    void setImageManager(const SharedImageManager &imageManager);

    static RTNImageComponentCustomNativeState initialStateData(
        ShadowNodeFragment const &fragment,
        ShadowNodeFamilyFragment const &familyFragment,
        ComponentDescriptor const &componentDescriptor) {
        auto imageSource = ImageSource{ImageSource::Type::Invalid};
        return {imageSource, {imageSource, nullptr}};
    }

    #pragma mark - LayoutableShadowNode

    void layout(LayoutContext layoutContext) override;

    private:
    void updateStateIfNeeded();

    ImageSource getImageSource() const;

    SharedImageManager imageManager_;
    };

    } // namespace react
    } // namespace facebook
  ```
* In the cxx folder, create a new `RTNImageComponentCustomShadowNode.cpp` file
  ```cpp
    #include "RTNImageComponentCustomShadowNode.h"

    #include <react/renderer/core/LayoutContext.h>

    namespace facebook {
    namespace react {

    extern const char RTNImageComponentComponentName[] =
        "RTNImageComponent";

    void RTNImageComponentCustomShadowNode::setImageManager(
        const SharedImageManager &imageManager) {
        ensureUnsealed();
        imageManager_ = imageManager;
    }

    void RTNImageComponentCustomShadowNode::updateStateIfNeeded() {
        const auto &newImageSource = getImageSource();

        auto const &currentState = getStateData();

        auto imageSource = currentState.getImageSource();

        bool anyChanged = newImageSource != imageSource;

        if (!anyChanged) {
            return;
        }

        // Now we are about to mutate the Shadow Node.
        ensureUnsealed();

        // It is not possible to copy or move image requests from SliderLocalData,
        // so instead we recreate any image requests (that may already be in-flight?)
        // TODO: check if multiple requests are cached or if it's a net loss
        auto state = RTNImageComponentCustomNativeState{
            newImageSource,
            imageManager_->requestImage(newImageSource, getSurfaceId())};
        setStateData(std::move(state));
    }

    ImageSource RTNImageComponentCustomShadowNode::getImageSource()
        const {
        return getConcreteProps().image;
    }

    void RTNImageComponentCustomShadowNode::layout(
        LayoutContext layoutContext) {
        updateStateIfNeeded();
        ConcreteViewShadowNode::layout(layoutContext);
    }

    } // namespace react
    } // namespace facebook
  ```
* In the `cxx/react/renderer/components/RTNImageViewSpec` folder, create a new `ComponentDescriptors.h` file
  ```cpp
    #include <react/renderer/core/ConcreteComponentDescriptor.h>
    #include "RTNImageComponentCustomShadowNode.h"

    namespace facebook {
    namespace react {

    /*
    * Descriptor for <RTNImageComponentCustomComponentDescriptor>
    * component.
    */
    class RTNImageComponentCustomComponentDescriptor final
        : public ConcreteComponentDescriptor<
            RTNImageComponentCustomShadowNode> {
    public:
    RTNImageComponentCustomComponentDescriptor(
        ComponentDescriptorParameters const &parameters)
        : ConcreteComponentDescriptor(parameters),
            imageManager_(std::make_shared<ImageManager>(contextContainer_)) {}

    void adopt(ShadowNode::Unshared const &shadowNode) const override {
        ConcreteComponentDescriptor::adopt(shadowNode);

        auto compShadowNode =
            std::static_pointer_cast<RTNImageComponentCustomShadowNode>(
                shadowNode);

        // `RTNImageComponentCustomShadowNode` uses `ImageManager` to
        // initiate image loading and communicate the loading state
        // and results to mounting layer.
        compShadowNode->setImageManager(imageManager_);
    }

    private:
    const SharedImageManager imageManager_;
    };

    } // namespace react
    } // namespace facebook
  ```

### <a name="update-ios-code" /> [[Fabric Component] Update the iOS Code]()

* Open the `ios/RTNImageComponentView.mm` and update the code as it follows:
```diff
#import "RTNImageComponentView.h"

#import <react/renderer/components/RTNImageViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RTNImageViewSpec/EventEmitters.h>
#import <react/renderer/components/RTNImageViewSpec/Props.h>
#import <react/renderer/components/RTNImageViewSpec/RCTComponentViewHelpers.h>
+ #import "ComponentDescriptors.h"

+ #import <React/RCTImageResponseDelegate.h>
+ #import <React/RCTImageResponseObserverProxy.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

- @interface RTNImageComponentView () <RCTRTNImageComponentViewProtocol>
+ @interface RTNImageComponentView () <RCTRTNImageComponentViewProtocol, RCTImageResponseDelegate>

@implementation RTNImageComponentView {
  UIView *_view;
  UIImageView *_imageView;
  UIImage *_image;
+  ImageResponseObserverCoordinator const *_imageCoordinator;
+  RCTImageResponseObserverProxy _imageResponseObserverProxy;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
-  return concreteComponentDescriptorProvider<RTNImageComponentComponentDescriptor>();
+  return concreteComponentDescriptorProvider<RTNImageComponentCustomComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  //...

      _imageView.image = _image;

+    _imageResponseObserverProxy = RCTImageResponseObserverProxy(self);

    self.contentView = _view;
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
+  self.imageCoordinator = nullptr;
  _image = nil;
}

- (void)updateState:(facebook::react::State::Shared const &)state
           oldState:(facebook::react::State::Shared const &)oldState
{
  auto _state = std::static_pointer_cast<RTNImageComponentCustomShadowNode::ConcreteState const>(state);
  auto _oldState = std::static_pointer_cast<RTNImageComponentCustomShadowNode::ConcreteState const>(oldState);

+  auto data = _state->getData();
+
+  bool havePreviousData = _oldState != nullptr;
+
+  auto getCoordinator = [](ImageRequest const *request) -> ImageResponseObserverCoordinator const * {
+    if (request) {
+      return &request->getObserverCoordinator();
+    } else {
+      return nullptr;
+    }
+  };
+
+  if (!havePreviousData || data.getImageSource() != _oldState->getData().getImageSource()) {
+    self.imageCoordinator = getCoordinator(&data.getImageRequest());
+  }
}

+ #pragma mark - ImageCoordination
+
+ - (void)setImageCoordinator:(const ImageResponseObserverCoordinator *)coordinator
+ {
+   if (_imageCoordinator) {
+     _imageCoordinator->removeObserver(_imageResponseObserverProxy);
+   }
+   _imageCoordinator = coordinator;
+   if (_imageCoordinator) {
+     _imageCoordinator->addObserver(_imageResponseObserverProxy);
+   }
+ }

+ - (void)setImage:(UIImage *)image
+ {
+   if ([image isEqual:_image]) {
+     return;
+   }
+
+   _imageView.image = image;
+ }

+ #pragma mark - RCTImageResponseDelegate
+
+ - (void)didReceiveImage:(UIImage *)image metadata:(id)metadata fromObserver:(void const *)observer
+ {
+   if (observer == &_imageResponseObserverProxy) {
+     self.image = image;
+   }
+ }
+
+ - (void)didReceiveProgress:(float)progress fromObserver:(void const *)observer
+ {
+ }
+
+ - (void)didReceiveFailureFromObserver:(void const *)observer
+ {
+ }

```

### <a name="test-ios" />[[Test iOS] Test your iOS Component]()

**Note:** The app code is not committed to the repo to highlight only important changes

* At the same level of the `image-component` folder, run the command:
```sh
npx react-native init NewArchitecture --version next
```
* `cd NewArchitecture`
* `yarn add ../image-component`
* `cd ios`
* `bundle install`
* `RCT_NEW_ARCH_ENABLED=1 bundle exec pod install`
* Replace the content of the App.ts file with the following
```ts
/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  useColorScheme,
  View,
} from 'react-native';

import {
  Colors
} from 'react-native/Libraries/NewAppScreen';

import ImageComponentNativeComponent from 'image-component/src/ImageComponentNativeComponent';

function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          }}>
          <ImageComponentNativeComponent image={{
              uri: 'https://reactnative.dev/img/tiny_logo.png',
            }} style={{width:100, height:100}}/>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

export default App;
```
* `open NewArchitecture.xcworkspace`
* Press the run button on Xcode

### <a name="android-impl">[[Fabric Component] Add Android implementation]()

* Create an `android` folder next to the `ios` one
* Create the `build.gradle` file with the following content:
```groovy
buildscript {
    ext.safeExtGet = {prop, fallback ->
        rootProject.ext.has(prop) ? rootProject.ext.get(prop) : fallback
    }
    repositories {
        google()
        gradlePluginPortal()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.2.0")
    }
}

apply plugin: 'com.android.library'
apply plugin: 'com.facebook.react'

android {
    compileSdkVersion safeExtGet('compileSdkVersion', 31)

    defaultConfig {
        minSdkVersion safeExtGet('minSdkVersion', 23)
        targetSdkVersion safeExtGet('targetSdkVersion', 31)
    }
}

repositories {
    maven {
        // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
        url "$projectDir/../node_modules/react-native/android"
    }
    mavenCentral()
    google()
}

dependencies {
    implementation 'com.facebook.react:react-native:+'
}
```
* Create a folder `src/main` and create the `AndroidManifest.xml` inside that folder. The Manifest has this content:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.imagecomponentlibrary">
</manifest>
```
* Create the `ImageComponentView.java` in the `android/app/src/main/java/com/imagecomponent` folder
```java
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
```
* Create the `ImageComponentViewManager.java` in the `android/app/src/main/java/com/imagecomponent` folder
```java
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
```
* Create the `ImageComponentViewPackage.java` in the `android/app/src/main/java/com/imagecomponent` folder
```java
package com.imagecomponentlibrary;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ImageComponentViewPackage implements ReactPackage {

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.singletonList(new ImageComponentViewManager(reactContext));
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }

}
```
* Create a custom `CMakeLists.txt` file in the `image-component/cxx` folder. We need to use some custom C++ files and the `CMakeLists.txt` is the file that instructs Android on where these files can be found. The content is the following:
```c
cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

file(
  GLOB react_codegen_SRCS CONFIGURE_DEPENDS
  *.cpp
  react/renderer/components/RTNImageViewSpec/*.cpp
  ../android/build/generated/source/codegen/jni/react/renderer/components/RTNImageViewSpec/EventEmitters.cpp
  ../android/build/generated/source/codegen/jni/react/renderer/components/RTNImageViewSpec/Props.cpp
  ../android/build/generated/source/codegen/jni/RTNImageViewSpec-generated.cpp
)

add_library(
  react_codegen_RTNImageViewSpec
  SHARED
  ${react_codegen_SRCS}
)

target_include_directories(
  react_codegen_RTNImageViewSpec
  PUBLIC
  .
  react/renderer/components/RTNImageViewSpec
  ../android/build/generated/source/codegen/jni
  ../android/build/generated/source/codegen/jni/react/renderer/components/RTNImageViewSpec
)

target_link_libraries(
  react_codegen_RTNImageViewSpec
  fbjni
  folly_runtime
  glog
  jsi
  react_codegen_rncore
  react_debug
  react_nativemodule_core
  react_render_core
  react_render_debug
  react_render_graphics
  react_render_imagemanager
  react_render_mapbuffer
  rrc_image
  rrc_view
  turbomodulejsijni
  yoga
)

target_compile_options(
  react_codegen_RTNImageViewSpec
  PRIVATE
  -DLOG_TAG=\"ReactNative\"
  -fexceptions
  -frtti
  -std=c++17
  -Wall
)
```
