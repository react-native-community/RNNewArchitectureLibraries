# RUN: Create a Fabric Component Without Codegen

This Run lets you create a Fabric Component without using Codegen.

To avoid to manually write a lot of boilerplate, you will still use the Codegen to get the code you need.

Then, you will move that code to the Fabric Component and you will disable the Codegen for the component.

## TOC

* [[Setup] Use the colored-view from other branch](#colored-view)
* [[App] Create an app using the latest template](#create-app)
* [[App] Add the Fabric Component to the app and generate the code](#codegen)
* [[Fabric Component] Move the Codegen'd code from app to library](#move-codegen)
* [[Fabric Component] Remove the codegenConfig from the package.json](#remove-codegen)
* [[App] Cleanup App Build](#cleanup-build)
* [[App] Make it work for iOS](#ios)
* [[App] Make it work for Android](#android)

## Steps

### [[Setup] Use the colored-view from other branch]()

To avoid excessive boilerplate, you will use a Fabric Component we already created in other branches of this same repository.

1. Go to [RNNewArchitectureLibraries](https://github.com/react-native-community/RNNewArchitectureLibraries/tree/feat/back-fabric-component-070)
2. Download the colored-view folder into the workspace

### [[App] Create an app using the latest template]()

1. `npx react-native init NewArchitecture --version next`

**Note:** The app is not committed to the repo not to pollute it

### [[App] Add the Fabric Component to the app and generate the code]()

1. `cd NewArchitecture`
2. `yarn add ../colored-view`
3. `cd ios && bundle install && RCT_NEW_ARCH_ENABLED=1 bundle exec pod install && cd ..`
4. `npx react-native run-ios`
5. Open the `android/gradle.properties` file and turn the `newArchEnabled` flag to true.
6. `npx react-native run-android`
7. Update the `NewArchitecture/App.js` file with the following code, to make sure that the component is actually working.

```ts
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

### [[Fabric Component] Move the Codegen'd code from app to library]()

1. Go to the `NewArchitecture/ios/build/generated/ios` folder.
2. Copy the `react/renderer/components/RNColoredViewSpec` folder.
3. Paste it in the `colored-view/ios` folder.
4. Go to the `NewArchitecture/node_modules/colored-view/android/build/generated/source/codegen`
5. Copy the content of `java/com` folder and paste it into the `colored-view/android/src/newarch/java/com`
6. Copy the content of `jni` folder and paste it intp the `colored-view/android/src/newarch/jni`

### [[Fabric Component] Remove the codegenConfig from the package.json]()

1. Open the `colored-view/package.json`
2. Remove the `codegenConfig` field from the file

### [[App] Cleanup App Build](#cleanup-build)

1. `rm -rf NewArchitecture/ios/build`
2. `cd NewArchitecture && yarn add ../colored-view`
3. `cd ios && rm -rf build`

### [[App] Make it work for iOS](#ios)

1. Update the `colored-view.podspec` to include also the cpp files
  ```diff
  - s.source_files    = "ios/**/*.{h,m,mm,swift}"
  + s.source_files    = "ios/**/*.{h,m,mm,cpp,swift}"
  ```
2. Open the files in the `react/renderer/components/RNColoredViewSpec`
3. Remove the `react/renderer/components/RNColoredViewSpec/` from the various `#include` directive. **Note:** Just remove the prefix from the `RNColoredViewSpec` only!
4. Open the `RNColoredView.mm` and remove the `react/renderer/components/RNColoredViewSpec/` from the 4 `#imports`
5. `cd NewArchitecture`
6. `yarn add ../colored-view`
7. `cd ios`
8. `RCT_NEW_ARCH_ENABLED=1 bundle exec pod install`
9. Open the `NewArchitecture/ios/AppDelegate.mm`
10. Add the following statements:
    ```diff
    #import <React/RCTSurfacePresenterBridgeAdapter.h>
    #import <ReactCommon/RCTTurboModuleManager.h>
    + #import <React/RCTComponentViewFactory.h>
    + #import <RNColoredView.h>

    // ...

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
      //...

    +  [RCTComponentViewFactory.currentComponentViewFactory registerComponentViewClass:RNColoredView.class];
      return YES;
    }
    ```
11. Build and run the app

* [[App] Make it work for Android]()

1. Open the `colored-view/android/build.gradle` file
1. Remove the following lines:
  ```diff
  apply plugin: 'com.android.library'

  - if (isNewArchitectureEnabled()) {
  -    apply plugin: 'com.facebook.react'
  - }
  ```
1. `cd ../../NewArchitecture`
1. `yarn install ../colored-view`
1. `npx react-native run-android`
1. Once it fails, go to `node_modules/colored-view/android` and delete the build folder
1. From the `NewArchitecture` root folder, run `cd android`
1. `./gradlew :app:installDebug -PreactNativeArcitectures=arm64-v8a -x generateCodegenArtifactsFromSchema`

**NOTE:** Due to a bug in the Codegen, you currently need to tell to Gradle not to run the Codegen
