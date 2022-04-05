# RUN

This doc contains the logs of the steps done to achieve the final result.

## Table of contents

* [[Setup] Create the example-library folder and the package.json](#setup)
* [[Native Module] Create the JS import](#js-import)
* [[Native Module] Create the iOS implementation](#ios-native)
* [[Native Module] Create the Android implementation](#android-native)
* [[Native Module] Test The Native Module](#test-native)
* [[TurboModule] Add the JavaScript specs](#js-spec)
* [[TurboModule] Set up CodeGen - iOS](#ios-codegen)
* [[TurboModule] Set up CodeGen - Android](#android-codegen)
* [[TurboModule] Set up podspec file](#ios-autolinking)
* [[TurboModule] Update the Native iOS code](#ios-tm-code)
* [[TurboModule] Android: Convert ReactPackage to a backward compatible TurboReactPackage](#android-backward)
* [[TurboModule] Android: Update the Native code to use two sourcesets](#android-sourceset)
* [[TurboModule] Android: Refactor the code to use a shared implementation](#android-refactor)
* [[TurboModule] Unify JavaScript interface](#js-unification)
* [[TurboModule] Test the Turbomodule](#tm-test)

## Steps

### <a name="setup" />[[Setup] Create the example-library folder and the package.json](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/0f64d565f214c2848b475e743834da5751abc8e0)

1. `mkdir example-library`
1. `touch example-library/package.json`
1. Paste the following code into the `package.json` file
```json
{
    "name": "example-library",
    "version": "0.0.1",
    "description": "Showcase Turbomodule with backward compatibility",
    "react-native": "src/index",
    "source": "src/index",
    "files": [
        "src",
        "android",
        "ios",
        "example-library.podspec",
        "!android/build",
        "!ios/build",
        "!**/__tests__",
        "!**/__fixtures__",
        "!**/__mocks__"
    ],
    "keywords": ["react-native", "ios", "android"],
    "repository": "https://github.com/<your_github_handle>/example-library",
    "author": "<Your Name> <your_email@your_provider.com> (https://github.com/<your_github_handle>)",
    "license": "MIT",
    "bugs": {
        "url": "https://github.com/<your_github_handle>/example-library/issues"
    },
    "homepage": "https://github.com/<your_github_handle>/example-library#readme",
    "devDependencies": {},
    "peerDependencies": {
        "react": "*",
        "react-native": "*"
    }
}
```

### <a name="js-import" />[[Native Module] Create the JS import](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/952ea481f17733037278e2367270fd238097b9d9)

1. `mkdir example-library/src`
1. `touch example-library/src/index.js`
1. Paste the following content into the `index.js`
```js
// @flow
import { NativeModules } from 'react-native'

export default NativeModules.Calculator;
```

### <a name="ios-native" />[[Native Module] Create the iOS implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/b2d189c362aeff4dddf36010639ca076969ca831)

1. `mkdir example-library/ios`
1. Open Xcode
1. Create a new static library in the `ios` folder called `RNCalculator`. Keep Objective-C as language.
1. Make that the `Create Git repository on my mac` option is **unchecked**
1. Open finder and arrange the files and folder as shown below:
    ```
    example-library
    '-> ios
        '-> RNCalculator
            '-> RNCalculator.h
            '-> RNCalculator.m
        '-> RNCalculator.xcodeproj
    ```
    It is important that the `RNCalculator.xcodeproj` is a direct child of the `example-library/ios` folder.
1. Open the `RNCalculator.h` file and update the code as it follows:
    ```diff
    - #import <Foundation/Foundation.h>
    + #import <React/RCTBridgeModule.h>

    + @interface RNCalculator : NSObject <RCTBridgeModule>

    @end
    ```
1. Open the `RNCalculator.m` file and replace the code with the following:
    ```objective-c
    #import "RNCalculator.h"

    @implementation RNCalculator

    RCT_EXPORT_MODULE(Calculator)

    RCT_REMAP_METHOD(add, addA:(NSInteger)a
                            andB:(NSInteger)b
                    withResolver:(RCTPromiseResolveBlock) resolve
                    withRejecter:(RCTPromiseRejectBlock) reject)
    {
        NSNumber *result = [[NSNumber alloc] initWithInteger:a+b];
        resolve(result);
    }

    @end
    ```
1. In the `example-library` folder, create a `example-library.podspec` file
1. Copy this code in the `podspec` file
```ruby
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name            = "example-library"
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

### <a name="android-native" />[[Native Module] Create the Android implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/07ffb547c9ff56a6a577291628f4750ddddd2d85)

1. Create a folder `example-library/android`
1. Create a file `example-library/android/build.gradle` and add this code:
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
1. Create a file `example-library/android/src/main/AndroidManifest.xml` and add this code:
    ```xml
    <manifest xmlns:android="http://schemas.android.com/apk/res/android"
            package="com.rnnewarchitecturelibrary">
    </manifest>
    ```
1. Create a file `example-library/android/src/main/java/com/rnnewarchitecturelibrary/CalculatorModule.java` and add this code:
    ```java
    package com.rnnewarchitecturelibrary;

    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.Promise;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.bridge.ReactContext;
    import com.facebook.react.bridge.ReactContextBaseJavaModule;
    import com.facebook.react.bridge.ReactMethod;
    import java.util.Map;
    import java.util.HashMap;

    public class CalculatorModule extends ReactContextBaseJavaModule {
        CalculatorModule(ReactApplicationContext context) {
            super(context);
        }

        @Override
        public String getName() {
            return "Calculator";
        }

        @ReactMethod
        public void add(int a, int b, Promise promise) {
            promise.resolve(a + b);
        }
    }
    ```
1. Create a file `example-library/android/src/main/java/com/rnnewarchitecturelibrary/CalculatorPackage.java` and add this code:
    ```java
    package com.rnnewarchitecturelibrary;

    import com.facebook.react.ReactPackage;
    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.uimanager.ViewManager;

    import java.util.ArrayList;
    import java.util.Collections;
    import java.util.List;

    public class CalculatorPackage implements ReactPackage {

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        modules.add(new CalculatorModule(reactContext));
        return modules;
    }

    }
    ```

### <a name="test-native" />[[Native Module] Test The Native Module](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/dc01e6b2ff57f02e612956af317b85e16c786d5b)

1. At the same level of example-library run `npx react-native init OldArchitecture`
1. `cd OldArchitecture && yarn add ../example-library`
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
    import {useState} from "react";
    import type {Node} from 'react';
    import {
    SafeAreaView,
    StatusBar,
    Text,
    Button,
    } from 'react-native';
    import Calculator from 'example-library/src/index'
    const App: () => Node = () => {
    const [currentResult, setResult] = useState<number | null>(null);
    return (
        <SafeAreaView>
        <StatusBar barStyle={'dark-content'}/>
        <Text style={{marginLeft:20, marginTop:20}}>3+7={currentResult ?? "??"}</Text>
        <Button title="Compute" onPress={async () => {
            const result = await Calculator.add(3, 7);
            setResult(result);
        }} />
        </SafeAreaView>
    );
    };
    export default App;
    ```
1. To run the App on iOS, install the dependencies: `cd ios && pod install && cd ..`
1. `npx react-native start` (In another terminal, to run Metro)
1. Run the app
    1. if using iOS: `npx react-native run-ios`
    1. if using Android: `npx react-native run-android`
1. Click on the `Compute` button and see the app working

**Note:** OldArchitecture app has not been committed not to pollute the repository.

### <a name="js-spec" />[[TurboModule] Add the JavaScript specs](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/f2ce0d7e0892f36987b91d4e0c132d4a5e717993)

1. `touch example-library/src/NativeCalculator.js`
1. Paste the following code:
    ```ts
    // @flow
    import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
    import { TurboModuleRegistry } from 'react-native';

    export interface Spec extends TurboModule {
    // your module methods go here, for example:
    add(a: number, b: number): Promise<number>;
    }
    export default (TurboModuleRegistry.get<Spec>(
    'Calculator'
    ): ?Spec);
    ```

### <a name="ios-codegen" />[[TurboModule] Set up CodeGen - iOS](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/ef9a68a6b5b16c64db8210dde1fa11ba9e259414)

1. Open the `example-library/package.json`
1. Add the following snippet at the end of it:
    ```json
    ,
    "codegenConfig": {
        "libraries": [
            {
            "name": "RNCalculatorSpec",
            "type": "modules",
            "jsSrcsDir": "src"
            }
        ]
    }
    ```

### <a name="android-codegen" />[[TurboModule] Set up CodeGen - Android](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/83d61423e806c75ef75bf287ace3555e2edf18d5)

1. Open the `example-library/android/build.gradle` file and update the code as follows:
    ```diff
    + def isNewArchitectureEnabled() {
    +    return project.hasProperty("newArchEnabled") && project.newArchEnabled == "true"
    +}

    apply plugin: 'com.android.library'
    +if (isNewArchitectureEnabled()) {
    +    apply plugin: 'com.facebook.react'
    +}

    // ... other parts of the build file

    dependencies {
        implementation 'com.facebook.react:react-native:+'
    }

    + if (isNewArchitectureEnabled()) {
    +     react {
    +         jsRootDir = file("../src/")
    +         libraryName = "calculator"
    +         codegenJavaPackageName = "com.rnnewarchitecturelibrary"
    +     }
    + }

### <a name="ios-autolinking" />[[TurboModule] Set up `podspec` file](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/bfd95bedb64b5ba2a4bf5951e6dcfc540bfb650d)

1. Open the `example-library/example-library.podspec` file
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
            "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
        }

        s.dependency "React-Codegen"
        s.dependency "RCT-Folly", folly_version
        s.dependency "RCTRequired"
        s.dependency "RCTTypeSafety"
        s.dependency "ReactCommon/turbomodule/core"
    end
    ```

### <a name="ios-tm-code" />[[TurboModule] Update the Native iOS code](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/a1fda810e297a3de530233cfaa88ee76b7898fa3)

1. In the `ios/RNCalculator` folder, rename the `RNCalculator.m` into `RNCalculator.mm`
1. Open it and add the following `import`:
    ```c++
    // Thanks to this guard, we won't import this header when we build for the old architecture.
    #ifdef RCT_NEW_ARCH_ENABLED
    #import "RNCalculatorSpec.h"
    #endif
    ```
1. Then, before the `@end` keyword, add the following code:
    ```c++
    // Thanks to this guard, we won't compile this code when we build for the old architecture.
    #ifdef RCT_NEW_ARCH_ENABLED
    - (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
        (const facebook::react::ObjCTurboModule::InitParams &)params
    {
        return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
    }
    #endif
    ```

### <a name="android-backward" />[[TurboModule] Android: Convert ReactPackage to a backward compatible TurboReactPackage](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/f75ead561004db2a03da62fe35562055ef20f870)

1. Open the `example-library/android/src/main/java/com/rnnewarchitecturelibrary/CalculatorModule.java` and modify it as it follows:
    ```diff
    public class CalculatorModule extends ReactContextBaseJavaModule {

    +    public static final String NAME = "Calculator";

        CalculatorModule(ReactApplicationContext context) {
            super(context);
        }

        @Override
        public String getName() {
    -       return "Calculator";
    +       return NAME;
        }
    ```
1. Open the `example-library/android/src/main/java/com/rnnewarchitecturelibrary/CalculatorPackage.java` and replace its content with:
    ```java
    package com.rnnewarchitecturelibrary;

    import androidx.annotation.Nullable;
    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.module.model.ReactModuleInfo;
    import com.facebook.react.module.model.ReactModuleInfoProvider;
    import com.facebook.react.TurboReactPackage;
    import com.facebook.react.uimanager.ViewManager;

    import java.util.ArrayList;
    import java.util.Collections;
    import java.util.List;
    import java.util.HashMap;
    import java.util.Map;

    public class CalculatorPackage extends TurboReactPackage {

        @Nullable
        @Override
        public NativeModule getModule(String name, ReactApplicationContext reactContext) {
            if (name.equals(CalculatorModule.NAME)) {
                return new CalculatorModule(reactContext);
            } else {
                return null;
            }
        }

        @Override
        public ReactModuleInfoProvider getReactModuleInfoProvider() {
            return () -> {
                final Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
                moduleInfos.put(
                        CalculatorModule.NAME,
                        new ReactModuleInfo(
                                CalculatorModule.NAME,
                                CalculatorModule.NAME,
                                false, // canOverrideExistingModule
                                false, // needsEagerInit
                                true, // hasConstants
                                false, // isCxxModule
                                false // isTurboModule
                ));
                return moduleInfos;
            };
        }
    }
    ```

### <a name="android-sourceset" />[[TurboModule] Android: Update the Native code to use two sourcesets](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/83787af8e43ee073f8577076b2dd8e1c68c06cc7)

1. Open the `example-library/android/build.gradle` file and update the code as it follows:
    ```diff
        defaultConfig {
            minSdkVersion safeExtGet('minSdkVersion', 21)
            targetSdkVersion safeExtGet('targetSdkVersion', 31)
    +        buildConfigField "boolean", "IS_NEW_ARCHITECTURE_ENABLED", isNewArchitectureEnabled().toString()
    +    }
    +
    +    sourceSets {
    +        main {
    +            if (isNewArchitectureEnabled()) {
    +                java.srcDirs += ['src/newarch']
    +            } else {
    +                java.srcDirs += ['src/oldarch']
    +            }
    +        }
        }
    }
    ```
1. Open the `example-library/android/src/main/java/com/rnnewarchitecturelibrary/CalculatorPackage.java` and update the `getReactModuleInfoProvider` function as it follows:
    ```diff
    public ReactModuleInfoProvider getReactModuleInfoProvider() {
        return () -> {
            final Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
    +       boolean isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
            moduleInfos.put(
                    CalculatorModule.NAME,
                    new ReactModuleInfo(
                            CalculatorModule.NAME,
                            CalculatorModule.NAME,
                            false, // canOverrideExistingModule
                            false, // needsEagerInit
                            true, // hasConstants
                            false, // isCxxModule
    -                       false, // isTurboModule
    +                       isTurboModule // isTurboModule
            ));
            return moduleInfos;
        };
    ```
1. Create a file `example-library/android/src/newarch/java/com/rnnewarchitecturelibrary/CalculatorModule.java` (notice the `newarch` child of the `src` folder) and paste the following code:
    ```java
    package com.rnnewarchitecturelibrary;

    import androidx.annotation.NonNull;
    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.Promise;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.bridge.ReactContext;
    import com.facebook.react.bridge.ReactContextBaseJavaModule;
    import com.facebook.react.bridge.ReactMethod;
    import java.util.Map;
    import java.util.HashMap;

    public class CalculatorModule extends NativeCalculatorSpec {

        public static final String NAME = "Calculator";

        CalculatorModule(ReactApplicationContext context) {
            super(context);
        }

        @Override
        @NonNull
        public String getName() {
            return NAME;
        }

        @Override
        public void add(double a, double b, Promise promise) {
            promise.resolve(a + b);
        }
    }
    ```
1. Create a file `example-library/android/src/oldarch/java/com/rnnewarchitecturelibrary/CalculatorModule.java` (notice the `oldarch` child of the `src` folder) and paste the following code:
    ```java
    package com.rnnewarchitecturelibrary;

    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.Promise;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.bridge.ReactContext;
    import com.facebook.react.bridge.ReactContextBaseJavaModule;
    import com.facebook.react.bridge.ReactMethod;
    import java.util.Map;
    import java.util.HashMap;

    public class CalculatorModule extends ReactContextBaseJavaModule {

        public static final String NAME = "Calculator";

        CalculatorModule(ReactApplicationContext context) {
            super(context);
        }

        @Override
        public String getName() {
            return NAME;
        }

        @ReactMethod
        public void add(int a, int b, Promise promise) {
            promise.resolve(a + b);
        }
    }
    ```

### <a name="android-refactor" />[[TurboModule] Android: Refactor the code to use a shared implementation](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/cf685ef79a41fc9b9d05fcd1d1d73d4715e59d84)

1. Create a new `example-library/android/src/main/java/com/rnnewarchitecturelibrary/CalculatorModuleImpl.java` file (notice that the `src`'s subfolder is now `main`) and paste the following code:
    ```java
    package com.rnnewarchitecturelibrary;

    import androidx.annotation.NonNull;
    import com.facebook.react.bridge.Promise;
    import java.util.Map;
    import java.util.HashMap;

    public class CalculatorModuleImpl {

        public static final String NAME = "Calculator";

        public static void add(double a, double b, Promise promise) {
            promise.resolve(a + b);
        }

    }
    ```
1. Open the `example-library/android/src/main/java/com/rnnewarchitecturelibrary/CalculatorPackage.java` file and replace all the instances of `CalculatorModule` with `CalculatorModuleImpl`
1. Open the `example-library/android/src/newarch/java/com/rnnewarchitecturelibrary/CalculatorModule.java` file and update it as it follows:
    ```diff
    public class CalculatorModule extends NativeCalculatorSpec {

    -    public static final String NAME = "Calculator";

        CalculatorModule(ReactApplicationContext context) {
            super(context);
        }

        @Override
        @NonNull
        public String getName() {
    -        return NAME;
    +        return CalculatorModuleImpl.NAME;
        }

        @Override
        public void add(double a, double b, Promise promise) {
    -        promise.resolve(a + b);
    +        CalculatorModuleImpl.add(a, b, promise);
        }
    }
    ```
1. Open the `example-library/android/src/oldarch/java/com/rnnewarchitecturelibrary/CalculatorModule.java` and update it as it follows:
    ```diff
    public class CalculatorModule extends ReactContextBaseJavaModule {

    -    public static final String NAME = "Calculator";

        CalculatorModule(ReactApplicationContext context) {
            super(context);
        }

        @Override
        public String getName() {
    -        return NAME;
    +        return CalculatorModuleImpl.NAME;
        }

        @ReactMethod
        public void add(int a, int b, Promise promise) {
    -        promise.resolve(a + b);
    +        CalculatorModuleImpl.add(a, b, promise);
        }
    }
### <a name="js-unification" />[[TurboModule] Unify JavaScript interface](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/05b5ace4945e20490c5473f9b619990598e22d5c)

1. Open the `src/index.js` file
1. Replace the code with the following:
    ```ts
    // @flow
    import { NativeModules } from 'react-native'

    const isTurboModuleEnabled = global.__turboModuleProxy != null;

    const calculator = isTurboModuleEnabled ?
    require("./NativeCalculator").default :
    NativeModules.Calculator;

    export default calculator;
    ```

### <a name="tm-test" />[[TurboModule] Test the Turbomodule](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/6cb79101a2b4aa0db1481ef35e96a9d2cb6beaad)

1. At the same level of example-library run `npx react-native init NewArchitecture --version next` (`next` takes the next version that is about to be released. Any version >= 0.68 should work)
1. `cd NewArchitecture && yarn add ../example-library`
1. Open `NewArchitecture/App.js` file and replace the content with the same file used for the [`OldArchitecture`](#test-old-architecture).
1. To run the App on iOS, install the dependencies: `cd ios && pod install && cd ..`
1. `npx react-native start` (In another terminal, to run Metro)
1. Run the app:
    1. iOS: `npx react-native run-ios`
    1. Android `npx react-native run-android`
1. Click on the `Compute` button and see the app working

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
    +   # Includes the MK file for `example-library`
    +
    +   include $(NODE_MODULES_DIR)/example-library/android/build/generated/source/codegen/jni/Android.mk
        include $(CLEAR_VARS)
    ```
1. In the same file above, go to the `LOCAL_SHARED_LIBRARIES` setting and add the following line:
    ```diff
        libreact_codegen_rncore \
    +   libreact_codegen_calculator \
        libreact_debug \
    ```
1. Open the `NewArchitecture/android/app/src/main/jni/MainApplicationModuleProvider.cpp` file and update the file as it follows:
    1. Add the import for the calculator:
        ```diff
            #include <answersolver.h>
        +   #include <calculator.h>
        ```
    1. Add the following check in the `MainApplicationModuleProvider` constructor:
        ```diff
            // auto module = samplelibrary_ModuleProvider(moduleName, params);
            // if (module != nullptr) {
            //    return module;
            // }

        +    auto module = calculator_ModuleProvider(moduleName, params);
        +    if (module != nullptr) {
        +        return module;
        +    }

            return rncore_ModuleProvider(moduleName, params);
        }
        ```
