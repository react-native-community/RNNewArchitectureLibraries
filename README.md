# Create a TurboModule in Swift and C++ inside a RNApp

## Requirements:
- Xcode 15
- macOS 14.0


## Steps:

### Create a new app

```
npx init SwiftCxx --version next
cd SwiftCxx
```

### Create TS Specs

1. Create a `js/NativeCalculator.ts` file
```
mkdir js
touch NativeCalculator.ts
```

2. Populate the file with the following code
```ts
import type {TurboModule} from 'react-native/Libraries/TurboModule/RCTExport';
import {TurboModuleRegistry} from 'react-native';

export interface Spec extends TurboModule {
  add(a: number, b: number): Promise<number>;
}

export default TurboModuleRegistry.get<Spec>('RTNCalculator') as Spec | null;
```

### Configure Codegen

1. Update the `package.json` with the following object:
```diff
  "jest": {
    "preset": "react-native"
-  }
+  },
+  "codegenConfig": {
+    "name": "AppSpecs",
+    "type": "all",
+    "jsSrcsDir": "js"
+  }
}
```

2. Rerun Codegen by

```
cd ios
RCT_NEW_ARCH_ENABLED=1 bundle exec pod install
cd ..
```

3. Verify that the specs are there. If you have `tree` installed, you can run `tree SwiftCXX/ios/build/generated/ios/AppSpecs ` and the output would be:
```
SwiftCXX/ios/build/generated/ios/AppSpecs
├── AppSpecs-generated.mm
└── AppSpecs.h
```

### Create the ObjectiveC++ TM

1. open the project with Xcode 14 to make it work in a known situation:
  ```
  cd ios
  open SwiftCxx.xcworkspace
  ```
2. Create a new file `RNTCalculator.h` with the content:
    ```objc
    #import <Foundation/Foundation.h>
    #import <AppSpecs/AppSpecs.h>

    @interface RNCalculator: NSObject <NativeCalculatorSpec>
    @end
    ```

3. Create a new file `RNTCalculator.mm` with the content
   ```objc
   #import "RNTCalculator.h"

    @implementation RNCalculator

    RCT_EXPORT_MODULE()


    - (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
        (const facebook::react::ObjCTurboModule::InitParams &)params
    {
        return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
    }

    - (void)add:(double)a b:(double)b resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    resolve(@(a + b));
    }

    @end
    ```

4. Click on Build and Run and verify that it works.

### Connect the TurboModule to your app

1. Open the `App.tsx` file and replace its content with:
   ```ts
    /**
     * Sample React Native App
    * https://github.com/facebook/react-native
    *
    * @format
    */

    import React from 'react';
    import {
    Button,
    SafeAreaView,
    ScrollView,
    StatusBar,
    Text,
    useColorScheme,
    View,
    } from 'react-native';

    import {Colors, Header} from 'react-native/Libraries/NewAppScreen';
    import NativeCalculator from './js/NativeCalculator';

    function App(): JSX.Element {
    const isDarkMode = useColorScheme() === 'dark';
    const [result, setResult] = React.useState<number | undefined>(undefined);

    const compute = async () => {
        const newRes = await NativeCalculator?.add(5, 2);
        setResult(newRes);
    };

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
            <Header />
        </ScrollView>
        <View>
            <Text>5 + 2 = {result ? `${result}` : '???'}</Text>
            <Button title="Compute" onPress={compute} />
        </View>
        </SafeAreaView>
    );
    }
    export default App;
   ```

2. Tap on `"Compute"` and see that the computation is updated.

### Temporary - fix the project for Xcode 15

1. Open the `ios/Podfile` file
2. Add the following code in the `post_install` section:
    ```diff
    post_install do |installer|
    react_native_post_install(
        installer,
        # Set `mac_catalyst_enabled` to `true` in order to apply patches
        # necessary for Mac Catalyst builds
        :mac_catalyst_enabled => false
    )
    __apply_Xcode_12_5_M1_post_install_workaround(installer)

    +  installer.pods_project.targets.each do |target|
    +   target.build_configurations.each do |config|
    +     config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', '_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION']
    +   end
    + end
    end
    ```
3. Run `RCT_NEW_ARCH_ENABLED=1 bundle exec pod install` from the iOS folder
4. Build and run from Xcode 15 to verify that we have a working project

### Enable Swift-CXX interop

1. Select the project and look for `OTHER_SWIFT_FLAGS` in the build settings
2. Add the `-cxx-interoperability-mode=default` flag to the one already set up by cocoapods

### Create the Swift file

1. Create a new Swift file, called `RTNCalculator.swift`
    - when asked, choose to create a `Bridging Header` for your app
2. Fill the `RTNCalculator.swift` with the content
   ```swift
    import Foundation
    import ReactCommon
    import React_Codegen

    @objc
    class RTNCalculator: NSObject, NativeCalculatorSpec {

        static func moduleName() -> String {
            return "RTNCalculator"
        }

        func add(_ a: Double, b: Double, resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
            resolve(a+b)
        }

        func getTurboModule(params: facebook.react.ObjCTurboModule.InitParams) -> std.shared_ptr<facebook.react.TurboModule> {
            return std.make_shared<facebook.react.NativeCalculatorSpecJSI>(params);
        }
    }
   ```

:::Note

And here we hit some issue related to the layout of our framework:
1. React_Codegen module can't be built by Swift as it uses the RCTTypeSafety module which fails to build. My hypothesis is that we need proper Clang modules and no submodule of React native is a proper Clang module right now.
2. facebook.react.ObjCTurboModule can't be accessed.
3. facebook.react.ObjCTurboModule.InitParams can't be accessed, following up the previous issue
4. facebook.react.NativeCalculatorSpecJSI can't be accessed (follows 1)

Looking at [here](https://www.swift.org/documentation/cxx-interop/status/) it seems like that types within Namespaces are not supported yet, only functions.

:::
