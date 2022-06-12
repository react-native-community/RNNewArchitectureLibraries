# Run

This doc contains the logs of the steps done to achieve the final result.

## Table of Contents

* [[Setup] Create the example-component folder and the package.json](#setup)
* [[Native Component] Create the JS import](#js-import)
* [[Native Component] Create the iOS implementation](#native-ios)
* [[Native Component] Create the Android implementation](#native-android)
* [[Native Component] Test The Native Component](#test-old-architecture)
* [[Fabric Component] Add the JavaScript specs](#fabric-specs)
* [[Fabric Component] Set up CodeGen - iOS](#ios-codegen)
* [[Fabric Component] Set up CodeGen - Android](#android-codegen)
* [[Fabric Component] Set up `podspec` file](#ios-podspec)
* [[Fabric Component] Update the Native iOS code](#fabric-ios)
* [[Fabric Component] Android: Update the Native code to use two sourcesets](#android-sourceset)
* [[Fabric Component] Android: Refactor the code to use a shared implementation](#android-refactor)
* [[Fabric Component] Unify JavaScript interface](#unify-js)
* [[Fabric Component] Test the Fabric Component](#test-fabric)

## Steps

### <a name="setup" />[[Setup] Create the example-component folder and the package.json](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/7c839743b55c8309a6c2aafb2c05916dd79516dc)

1. `mkdir example-component`
1. `touch example-component/package.json`
1. Paste the following code into the `package.json` file
```json
{
    "name": "example-component",
    "version": "0.0.1",
    "description": "Showcase Fabric component with backward compatibility",
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
    "repository": "https://github.com/<your_github_handle>/example-component",
    "author": "<Your Name> <your_email@your_provider.com> (https://github.com/<your_github_handle>)",
    "license": "MIT",
    "bugs": {
        "url": "https://github.com/<your_github_handle>/example-component/issues"
    },
    "homepage": "https://github.com/<your_github_handle>/example-component#readme",
    "devDependencies": {},
    "peerDependencies": {
        "react": "*",
        "react-native": "*"
    }
}
```

### <a name="js-import" />[[Native Component] Create the JS import](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/4f5271d9027e217b957ff1eb81989d533e79dea5)

1. `mkdir example-component/src`
1. `touch example-component/src/index.js`
1. Paste the following content into the `index.js`
```js
// @flow

import { requireNativeComponent } from 'react-native'

export default requireNativeComponent("ColoredView")
```

### <a name="native-ios" />[[Native Component] Create the iOS implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/26db86ae45ed670d714b4938479622ad9c8d7b3b)

1. `mkdir example-component/ios`
1. Open Xcode
1. Create a new static library in the `ios` folder called `RNColoredView`. Keep Objective-C as language.
1. Make that the `Create Git repository on my mac` option is **unchecked**
1. Open finder and arrange the files and folder as shown below:
    ```
    example-component
    '-> ios
        '-> RNColoredView
            '-> RNColoredView.h
            '-> RNColoredView.m
        '-> RNColoredView.xcodeproj
    ```
    It is important that the `RNColoredView.xcodeproj` is a direct child of the `example-component/ios` folder.
1. Remove the `RNColoredView.h`
1. Rename the `RNColoredView.m` into `RNColoredViewManager.m`
1. Replace the code of `RNColoredViewManager.m` with the following
    ```objective-c
    #import <React/RCTViewManager.h>

    @interface RNColoredViewManager : RCTViewManager
    @end

    @implementation RNColoredViewManager

    RCT_EXPORT_MODULE(ColoredView)

    - (UIView *)view
    {
    return [[UIView alloc] init];
    }

    RCT_CUSTOM_VIEW_PROPERTY(color, NSString, UIView)
    {
    [view setBackgroundColor:[self hexStringToColor:json]];
    }

    - hexStringToColor:(NSString *)stringToConvert
    {
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];

    unsigned hex;
    if (![stringScanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
    }

    @end
    ```
1. In the `example-component` folder, create a `example-component.podspec` file
1. Copy this code in the `podspec` file
```ruby
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name            = "example-component"
  s.version         = package["version"]
  s.summary         = package["description"]
  s.description     = package["description"]
  s.homepage        = package["homepage"]
  s.license         = package["license"]
  s.platforms       = { :ios => "11.0" }
  s.author          = package["author"]
  s.source          = { :git => package["repository"], :tag => "#{s.version}" }

  s.source_files    = "ios/**/*.{h,m,mm,swift}"

  s.dependency "React-Core"
end
```

### <a name="native-android" />[[Native Component] Create the Android implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/63283ba644ebddd2daa181bb2a2e8b88c0742f96)

1. Create a folder `example-component/android`
1. Create the module `build.gradle` file `example-component/android/build-gradle` and add this code:
    ```js
    buildscript {
        ext.safeExtGet = {prop, fallback ->
            rootProject.ext.has(prop) ? rootProject.ext.get(prop) : fallback
        }
        repositories {
            google()
        gradlePluginPortal()
        }
        dependencies {
            classpath("com.android.tools.build:gradle:7.0.4")
        }
    }

    apply plugin: 'com.android.library'

    android {
        compileSdkVersion safeExtGet('compileSdkVersion', 31)

        defaultConfig {
            minSdkVersion safeExtGet('minSdkVersion', 21)
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
1. Create the `AndroidManifest` file `example-component/android/src/main/AndroidManifest.xml` and add this code:
    ```xml
    <manifest xmlns:android="http://schemas.android.com/apk/res/android"
            package="com.rnnewarchitecturelibrary">
    </manifest>
    ```
1. Create the Fabric Component View `example-component/android/src/main/java/com/rnnewarchitecturelibrary/ColoredView.java` and add this code:
    ```java
    package com.rnnewarchitecturelibrary;

    import androidx.annotation.Nullable;
    import android.content.Context;
    import android.util.AttributeSet;

    import android.view.View;

    public class ColoredView extends View {

        public ColoredView(Context context) {
            super(context);
        }

        public ColoredView(Context context, @Nullable AttributeSet attrs) {
            super(context, attrs);
        }

        public ColoredView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
        }

    }
    ```
1. Create the component Manager `example-component/android/src/main/java/com/rnnewarchitecturelibrary/ColoredViewManager.java` and add this code:
    ```java
    package com.rnnewarchitecturelibrary;

    import androidx.annotation.Nullable;
    import com.facebook.react.module.annotations.ReactModule;
    import com.facebook.react.uimanager.SimpleViewManager;
    import com.facebook.react.uimanager.ThemedReactContext;
    import com.facebook.react.uimanager.annotations.ReactProp;
    import com.facebook.react.bridge.ReactApplicationContext;
    import android.graphics.Color;
    import java.util.Map;
    import java.util.HashMap;

    public class ColoredViewManager extends SimpleViewManager<ColoredView> {

        public static final String NAME = "ColoredView";
        ReactApplicationContext mCallerContext;

        public ColoredViewManager(ReactApplicationContext reactContext) {
            mCallerContext = reactContext;
        }

        @Override
        public String getName() {
            return NAME;
        }

        @Override
        public ColoredView createViewInstance(ThemedReactContext context) {
            return new ColoredView(context);
        }

        @ReactProp(name = "color")
        public void setColor(ColoredView view, String color) {
            view.setBackgroundColor(Color.parseColor(color));
        }

    }
    ```
1. Create the module Package descriptor file `example-component/android/src/main/java/com/rnnewarchitecturelibrary/ColoredViewPackage.java` and add this code:
    ```java
    package com.rnnewarchitecturelibrary;

    import com.facebook.react.ReactPackage;
    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.uimanager.ViewManager;

    import java.util.ArrayList;
    import java.util.Collections;
    import java.util.List;

    public class ColoredViewPackage implements ReactPackage {

        @Override
        public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
            List<ViewManager> viewManagers = new ArrayList<>();
            viewManagers.add(new ColoredViewManager(reactContext));
            return viewManagers;
        }

        @Override
        public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
            return Collections.emptyList();
        }

    }
    ```
### <a name="test-old-architecture" />[[Native Component] Test The Native Component](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/745553b6ba053b97efdb678a48c18156d47c145e)

1. At the same level of example-component run `npx react-native init OldArchitecture`
1. `cd OldArchitecture && yarn add ../example-component`
1. If running on iOS, install the dependencies with `cd ios && pod install && cd ..`
1. `npx react-native start` (In another terminal, to run Metro)
1. Run the app:
    1. For iOS: `npx react-native run-ios`
    1. For android: `npx react-native run-android`
1. Open `OldArchitecture/App.js` file and replace the content with:
    ```js
    /**
     * Sample React Native App
    * https://github.com/facebook/react-native
    *
    * @format
    * @flow strict-local
    */

    import React from 'react';
    import type {Node} from 'react';
    import {
        SafeAreaView,
        StatusBar,
        Text,
        View,
    } from 'react-native';

    import ColoredView from 'example-component/src/index'

    const App: () => Node = () => {

    return (
        <SafeAreaView>
        <StatusBar barStyle={'dark-content'} />
        <ColoredView color="#FF0099" style={{marginLeft:10, marginTop:20, width:100, height:100}}/>
        </SafeAreaView>
        );
    };

    export default App;
    ```
1. Play with the `color` property to see the View background color change

**Note:** OldArchitecture app has not been committed not to pollute the repository.

### <a name="fabric-specs" />[[Fabric Component] Add the JavaScript specs](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/0a42df7ec4d22435d5ed7376366cc0eea25ce9aa)

1. `touch example-component/src/ColoredViewNativeComponent.js`
1. Paste the following code:
    ```ts
    // @flow
    import type {ViewProps} from 'react-native/Libraries/Components/View/ViewPropTypes';
    import type {HostComponent} from 'react-native';
    import { ViewStyle } from 'react-native';
    import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

    type NativeProps = $ReadOnly<{|
    ...ViewProps,
    color: string
    |}>;

    export default (codegenNativeComponent<NativeProps>(
        'ColoredView',
    ): HostComponent<NativeProps>);
    ```

### <a name="ios-codegen" />[[Fabric Component] Set up CodeGen - iOS](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/7c5218a3a6966883c7b8b1faca618b76aeb46b3a)

1. Open the `example-component/package.json`
1. Add the following snippet at the end of it:
    ```json
    ,
    "codegenConfig": {
        "libraries": [
            {
            "name": "RNColoredViewSpec",
            "type": "components",
            "jsSrcsDir": "src"
            }
        ]
    }
    ```

### <a name="android-codegen" />[[Fabric Component] Set up CodeGen - Android](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/703dbb72b0b9a56ebb2dbd8fc3235be1febc871b)

1. Open the `example-component/android/build.gradle` file and update it as it follows:
    1. At the beginning of the file, add the following lines:
        ```diff
        +   def isNewArchitectureEnabled() {
        +       return project.hasProperty("newArchEnabled") && project.newArchEnabled == "true"
        +   }
        +
        apply plugin: 'com.android.library'
        +   if (isNewArchitectureEnabled()) {
        +       apply plugin: 'com.facebook.react'
        +   }
        ```
    1. At the end of the file, add the following lines:
        ```diff
        + if (isNewArchitectureEnabled()) {
        +     react {
        +         jsRootDir = file("../src/")
        +         libraryName = "colorview"
        +         codegenJavaPackageName = "com.rnnewarchitecturelibrary"
        +     }
        + }
        ```

### <a name="ios-podspec" />[[Fabric Component] Set up `podspec` file](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/5ad270ec73c51b5dbfa4180a3ea38e1dfb663620)

1. Open the `example-component/example-component.podspec` file
1. Before the `Pod::Spec.new do |s|` add the following code:
    ```ruby
    folly_version = '2021.06.28.00-v2'
    folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'
    ```
1. Before the `end ` tag, add the following code
    ```ruby
    # This guard prevent to install the dependencies when we run `pod install` in the old architecture.
    if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
        s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
        s.pod_target_xcconfig    = {
            "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
            "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
            "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
        }

        s.dependency "React-RCTFabric"
        s.dependency "React-Codegen"
        s.dependency "RCT-Folly", folly_version
        s.dependency "RCTRequired"
        s.dependency "RCTTypeSafety"
        s.dependency "ReactCommon/turbomodule/core"
    end
    ```

### <a name="fabric-ios">[[Fabric Component] Update the Native iOS code](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/ecedf329177991302f9c8d724bc71d49c401d731)

1. In the `example-component/ios/RNColoredView` folder, rename the `RNColoredView.m` into `RNColoredViewManager.mm`
1. Create a new header and call it `RNColoredView.h`
1. Paste the following code in the new header:
    ```objective-c
    // This guard prevent this file to be compiled in the old architecture.
    #ifdef RCT_NEW_ARCH_ENABLED
    #import <React/RCTViewComponentView.h>
    #import <UIKit/UIKit.h>

    #ifndef NativeComponentExampleComponentView_h
    #define NativeComponentExampleComponentView_h

    NS_ASSUME_NONNULL_BEGIN

    @interface RNColoredView : RCTViewComponentView
    @end

    NS_ASSUME_NONNULL_END

    #endif /* NativeComponentExampleComponentView_h */
    #endif /* RCT_NEW_ARCH_ENABLED */
    ```
1. Create a new file and call it `RNColoredView.mm`
1. Paste the following code in the new file:
    ```c++
    // This guard prevent the code from being compiled in the old architecture
    #ifdef RCT_NEW_ARCH_ENABLED
    #import "RNColoredView.h"

    #import <react/renderer/components/RNColoredViewSpec/ComponentDescriptors.h>
    #import <react/renderer/components/RNColoredViewSpec/EventEmitters.h>
    #import <react/renderer/components/RNColoredViewSpec/Props.h>
    #import <react/renderer/components/RNColoredViewSpec/RCTComponentViewHelpers.h>

    #import "RCTFabricComponentsPlugins.h"

    using namespace facebook::react;

    @interface RNColoredView () <RCTColoredViewViewProtocol>

    @end

    @implementation RNColoredView {
        UIView * _view;
    }

    + (ComponentDescriptorProvider)componentDescriptorProvider
    {
        return concreteComponentDescriptorProvider<ColoredViewComponentDescriptor>();
    }

    - (instancetype)initWithFrame:(CGRect)frame
    {
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const ColoredViewProps>();
        _props = defaultProps;

        _view = [[UIView alloc] init];

        self.contentView = _view;
    }

    return self;
    }

    - (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
    {
        const auto &oldViewProps = *std::static_pointer_cast<ColoredViewProps const>(_props);
        const auto &newViewProps = *std::static_pointer_cast<ColoredViewProps const>(props);

        if (oldViewProps.color != newViewProps.color) {
            NSString * colorToConvert = [[NSString alloc] initWithUTF8String: newViewProps.color.c_str()];
            [_view setBackgroundColor:[self hexStringToColor:colorToConvert]];
        }

        [super updateProps:props oldProps:oldProps];
    }

    Class<RCTComponentViewProtocol> ColoredViewCls(void)
    {
    return RNColoredView.class;
    }

    - hexStringToColor:(NSString *)stringToConvert
    {
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];

    unsigned hex;
    if (![stringScanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
    }

    @end
    #endif
    ```

### <a name="android-sourceset" />[[Fabric Component] Android: Update the Native code to use two sourcesets](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/69b28a9bd259e08914e2bca9f9e7176bb95d4ce8)

1. Remove the file `example-component/android/src/main/java/com/rnnewarchitecturelibrary/ColoredViewManager.java`.
1. Open the `example-component/android/build.gradle` file and add the following lines:
    ```diff
    defaultConfig {
        minSdkVersion safeExtGet('minSdkVersion', 21)
        targetSdkVersion safeExtGet('targetSdkVersion', 31)
    +     buildConfigField "boolean", "IS_NEW_ARCHITECTURE_ENABLED", isNewArchitectureEnabled().toString()
    + }
    +
    + sourceSets {
    +     main {
    +         if (isNewArchitectureEnabled()) {
    +             java.srcDirs += ['src/newarch']
    +         } else {
    +             java.srcDirs += ['src/oldarch']
    +         }
    +     }
    }
    ```
1. Create a View Manager for the New Architecture `example-component/android/src/newarch/java/com/rnnewarchitecturelibrary/ColoredViewManager.java` (Notice the `src/newarch` segment in the path) with this code:
    ```java
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
    import com.facebook.react.viewmanagers.ColoredViewManagerDelegate;
    import com.facebook.react.viewmanagers.ColoredViewManagerInterface;

    @ReactModule(name = ColoredViewManager.NAME)
    public class ColoredViewManager extends SimpleViewManager<ColoredView>
            implements ColoredViewManagerInterface<ColoredView> {

        public static final String NAME = "ColoredView";

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
            return NAME;
        }

        @NonNull
        @Override
        protected ColoredView createViewInstance(@NonNull ThemedReactContext context) {
            return new ColoredView(context);
        }

        @Override
        @ReactProp(name = "color")
        public void setColor(ColoredView view, @Nullable String color) {
            view.setBackgroundColor(Color.parseColor(color));
        }
    }
    ```
1. Create a View Manager for the Old Architecture `example-component/android/src/oldarch/java/com/rnnewarchitecturelibrary/ColoredViewManager.java` (Notice the `src/oldarch` segment in the path) with this code:
    ```java
    package com.rnnewarchitecturelibrary;

    import androidx.annotation.Nullable;
    import com.facebook.react.module.annotations.ReactModule;
    import com.facebook.react.uimanager.SimpleViewManager;
    import com.facebook.react.uimanager.ThemedReactContext;
    import com.facebook.react.uimanager.annotations.ReactProp;
    import com.facebook.react.bridge.ReactApplicationContext;
    import android.graphics.Color;
    import java.util.Map;
    import java.util.HashMap;

    public class ColoredViewManager extends SimpleViewManager<ColoredView> {

        public static final String NAME = "ColoredView";

        ReactApplicationContext mCallerContext;

        public ColoredViewManager(ReactApplicationContext reactContext) {
            mCallerContext = reactContext;
        }

        @Override
        public String getName() {
            return NAME;
        }

        @Override
        public ColoredView createViewInstance(ThemedReactContext context) {
            return new ColoredView(context);
        }

        @ReactProp(name = "color")
        public void setColor(ColoredView view, String color) {
            view.setBackgroundColor(Color.parseColor(color));
        }

    }
    ```

### <a name="android-refactor" />[[Fabric Component] Android: Refactor the code to use a shared implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/070c23b00deaf3b8318c2dd82a678177144d5c4b)

1. Create a common implementation in `example-component/android/src/main/java/com/rnnewarchitecturelibrary/ColoredViewManagerImpl.java` with the following code:
    ```java
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
    ```
1. Update the `ColoredViewManager` in the `src/newarch` path:
    ```diff
    import com.facebook.react.uimanager.ThemedReactContext;
    import com.facebook.react.uimanager.ViewManagerDelegate;
    import com.facebook.react.uimanager.annotations.ReactProp;
    import com.facebook.react.viewmanagers.ColoredViewManagerDelegate;
    import com.facebook.react.viewmanagers.ColoredViewManagerInterface;

    - @ReactModule(name = ColoredViewManager.NAME)
    + @ReactModule(name = ColoredViewManagerImpl.NAME)
    public class ColoredViewManager extends SimpleViewManager<ColoredView>
            implements ColoredViewManagerInterface<ColoredView> {

    -    public static final String NAME = "ColoredView";
    -
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
    -        return NAME;
    +        return ColoredViewManagerImpl.NAME;
        }

        @NonNull
        @Override
        protected ColoredView createViewInstance(@NonNull ThemedReactContext context) {
    -        return new ColoredView(context);
    +        return ColoredViewManagerImpl.createViewInstance(context);
        }

        @Override
        @ReactProp(name = "color")
        public void setColor(ColoredView view, @Nullable String color) {
    -        view.setBackgroundColor(Color.parseColor(color));
    +        ColoredViewManagerImpl.setColor(view, color);
        }
    }
    ```
1. Update the `ColoredViewManager` in the `src/oldarch` path:
    ```diff
    public class ColoredViewManager extends SimpleViewManager<ColoredView> {

    -    public static final String NAME = "ColoredView";
    -
        ReactApplicationContext mCallerContext;

        public ColoredViewManager(ReactApplicationContext reactContext) {
            mCallerContext = reactContext;
        }

        @Override
        public String getName() {
    -        return NAME;
    +        return ColoredViewManagerImpl.NAME;
        }

        @Override
        public ColoredView createViewInstance(ThemedReactContext context) {
    -        return new ColoredView(context);
    +        return ColoredViewManagerImpl.createViewInstance(context);
        }

        @ReactProp(name = "color")
        public void setColor(ColoredView view, String color) {
    -        view.setBackgroundColor(Color.parseColor(color));
    +        ColoredViewManagerImpl.setColor(view, color);
        }

    }
### <a name="unify-js" />[[Fabric Component] Unify JavaScript interface](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/a2fbdecac9032d4bc8279e270932816066e181dd)

1. Open the `src/index.js` file
1. Replace the code with the following:
    ```ts
    // @flow

    import { requireNativeComponent } from 'react-native'

    const isFabricEnabled = global.nativeFabricUIManager != null;

    const coloredView = isFabricEnabled ?
        require("./ColoredViewNativeComponent").default :
        requireNativeComponent("ColoredView")

    export default coloredView;
    ```

### <a name="test-fabric" />[[Fabric Component] Test the Fabric Component](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/f9379788ae7fa77fc91c58571f3b5d376004ce88)

1. At the same level of example-component run `npx react-native init NewArchitecture --version next` (`next` takes the next version that is about to be released. Any version >= 0.68 should work)
1. `cd NewArchitecture && yarn add ../example-component`
1. If running on iOS, install the dependencies with `cd ios && RCT_NEW_ARCH_ENABLED=1 pod install && cd ..`
1. `npx react-native start` (In another terminal, to run Metro)
1. Run the app:
    1. For iOS: `npx react-native run-ios`
    1. For Android: `npx react-native run-android`
1. Open `NewArchitecture/App.js` file and replace the content with the same file used for the [`OldArchitecture`](#test-old-architecture).
1. Play with the `color` property to see the View background color change

**Note:** NewArchitecture app has not been committed not to pollute the repository.


#### Android Autolinking

Autolinking doesn’t work with the new architecture out of the box. Therefore you need to ask the user of your library to do the following steps:

1. Open the `NewArchitecture/android/app/build.gradle` file and update the file as it follows:
    ```diff
        "PROJECT_BUILD_DIR=$buildDir",
        "REACT_ANDROID_DIR=$rootDir/../node_modules/react-native/ReactAndroid",
    -   "REACT_ANDROID_BUILD_DIR=$rootDir/../node_modules/react-native/ReactAndroid/build"
    +   "REACT_ANDROID_BUILD_DIR=$rootDir/../node_modules/react-native/ReactAndroid/build",
    +   "NODE_MODULES_DIR=$rootDir/../node_modules/"
        cFlags "-Wall", "-Werror", "-fexceptions", "-frtti", "-DWITH_INSPECTOR=1"
        cppFlags "-std=c++17"
    ```
1. Open the `NewArchitecture/android/app/src/main/jni/Android.mk` file and update the file as it follows:
    ```diff
        # If you wish to add a custom TurboModule or Fabric component in your app you
        # will have to include the following autogenerated makefile.
        # include $(GENERATED_SRC_DIR)/codegen/jni/Android.mk
    +
    +   # Includes the MK file for `example-component`
    +
    +   include $(NODE_MODULES_DIR)/example-component/android/build/generated/source/codegen/jni/Android.mk
        include $(CLEAR_VARS)
    ```
1. In the same file above, go to the `LOCAL_SHARED_LIBRARIES` setting and add the following line:
    ```diff
        libreact_codegen_rncore \
    +   libreact_codegen_colorview \
        libreact_debug \
    ```
1. Open the `NewArchitecture/android/app/src/main/jni/MainComponentsRegistry.cpp` file and update the file as it follows:
    1. Add the import for the calculator:
        ```diff
            #include <react/renderer/components/answersolver/ComponentDescriptors.h>
        +   #include <react/renderer/components/colorview/ComponentDescriptors.h>
            #include <react/renderer/components/rncore/ComponentDescriptors.h>
        ```
    1. Add the following check in the `sharedProviderRegistry` constructor:
        ```diff
            auto providerRegistry = CoreComponentsRegistry::sharedProviderRegistry();

        -   // Custom Fabric Components go here. You can register custom
        -   // components coming from your App or from 3rd party libraries here.
        -   //
        -   // providerRegistry->add(concreteComponentDescriptorProvider<
        -   //        AocViewerComponentDescriptor>());
        +   providerRegistry->add(concreteComponentDescriptorProvider<ColoredViewComponentDescriptor>());

            return providerRegistry;
        }
        ```
