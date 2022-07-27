# Run

This doc contains the logs of the steps done to achieve the final result.

## Table of Contents

* [[Setup] Create the colored-view folder and the package.json](#setup)
* [[Native Component] Create the JS import](#js-import)
* [[Native Component] Create the iOS implementation](#native-ios)
* [[Native Component] Create the Android implementation](#native-android)
* [[Native Component] Test The Native Component](#test-old-architecture)
* [[Fabric Component] Add the JavaScript specs](#fabric-specs)
* [[Fabric Component] Set up CodeGen](#codegen)
* [[Fabric Component] Update gradle](#update-gradle)
* [[Fabric Component] Set up `podspec` file](#ios-podspec)
* [[Fabric Component] Update the Native iOS code](#fabric-ios)

## Steps

### <a name="setup" />[[Setup] Create the colored-view folder and the package.json](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. `mkdir colored-view`
1. `touch colored-view/package.json`
1. Paste the following code into the `package.json` file
```json
{
    "name": "colored-view",
    "version": "0.0.1",
    "description": "Showcase Fabric component with backward compatibility",
    "react-native": "src/index",
    "source": "src/index",
    "files": [
        "src",
        "android",
        "ios",
        "colored-view.podspec",
        "!android/build",
        "!ios/build",
        "!**/__tests__",
        "!**/__fixtures__",
        "!**/__mocks__"
    ],
    "keywords": ["react-native", "ios", "android"],
    "repository": "https://github.com/<your_github_handle>/colored-view",
    "author": "<Your Name> <your_email@your_provider.com> (https://github.com/<your_github_handle>)",
    "license": "MIT",
    "bugs": {
        "url": "https://github.com/<your_github_handle>/colored-view/issues"
    },
    "homepage": "https://github.com/<your_github_handle>/colored-view#readme",
    "devDependencies": {},
    "peerDependencies": {
        "react": "*",
        "react-native": "*"
    }
}
```

### <a name="js-import" />[[Native Component] Create the JS import](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. `mkdir colored-view/src`
1. `touch colored-view/src/index.js`
1. Paste the following content into the `index.js`
```js
// @flow

import { requireNativeComponent } from 'react-native'

export default requireNativeComponent("ColoredView")
```

### <a name="native-ios" />[[Native Component] Create the iOS implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. `mkdir colored-view/ios`
1. Create a new file `ios/RNColoredViewManager.m` with the following code:
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
1. In the `colored-view` folder, create a `colored-view.podspec` file
1. Copy this code in the `podspec` file
```ruby
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name            = "colored-view"
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

### <a name="native-android" />[[Native Component] Create the Android implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. Create a folder `colored-view/android`
1. Create the module `build.gradle` file `colored-view/android/build-gradle` and add this code:
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
            classpath("com.android.tools.build:gradle:7.2.0")
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
1. Create the `AndroidManifest` file `colored-view/android/src/main/AndroidManifest.xml` and add this code:
    ```xml
    <manifest xmlns:android="http://schemas.android.com/apk/res/android"
            package="com.rnnewarchitecturelibrary">
    </manifest>
    ```
1. Create the Fabric Component View `colored-view/android/src/main/java/com/rnnewarchitecturelibrary/ColoredView.java` and add this code:
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
1. Create the component Manager `colored-view/android/src/main/java/com/rnnewarchitecturelibrary/ColoredViewManager.java` and add this code:
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
1. Create the module Package descriptor file `colored-view/android/src/main/java/com/rnnewarchitecturelibrary/ColoredViewPackage.java` and add this code:
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

### <a name="test-old-architecture" />[[Native Component] Test The Native Component](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. At the same level of colored-view run `npx react-native init OldArchitecture --version 0.70.0-rc.2`
1. `cd OldArchitecture && yarn add ../colored-view`
1. If running on iOS, install the dependencies with `cd ios && bundle install && bundle exec pod install && cd ..`
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

    import ColoredView from 'colored-view/src/index'

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

### <a name="fabric-specs" />[[Fabric Component] Add the JavaScript specs](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. `touch colored-view/src/ColoredViewNativeComponent.js`
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

### <a name="codegen" />[[Fabric Component] Set up CodeGen](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/7c5218a3a6966883c7b8b1faca618b76aeb46b3a)

1. Open the `colored-view/package.json`
1. Add the following snippet at the end of it:
    ```json
    ,
    "codegenConfig": {
        "name": "RNColoredViewSpec",
        "type": "components",
        "jsSrcsDir": "src"
    }
    ```

### <a name="update-gradle" />[[Fabric Component] Update gradle](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/703dbb72b0b9a56ebb2dbd8fc3235be1febc871b)

1. Open the `colored-view/android/build.gradle` file and update it as it follows:
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

### <a name="ios-podspec" />[[Fabric Component] Set up `podspec` file](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. Open the `colored-view/colored-view.podspec` file
1. Before the `Pod::Spec.new do |s|` add the following code:
    ```ruby
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
        s.dependency "RCT-Folly"
        s.dependency "RCTRequired"
        s.dependency "RCTTypeSafety"
        s.dependency "ReactCommon/turbomodule/core"
    end
    ```

### <a name="fabric-ios">[[Fabric Component] Update the Native iOS code](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. In the `colored-view/ios` folder, rename the `RNColoredViewManager.m` into `RNColoredViewManager.mm`
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
