# Create a TurboModule with Typescript

TypeScript support for the new architecture is still in Beta. However, we would like to provide some examples and a walkthrough guide about how to write a TurboModule using TypeScript.

**WARNING:** TypeScript support is still in beta and some things may change in the next future.

## Steps

### [[Setup] Create the example-library folder and the config files]()

1. `mkdir example-library`
1. `touch example-library/package.json`
1. Paste the following code into the `package.json` file
```json
{
  "name": "example-library",
  "version": "0.1.0",
  "description": "Showcase Turbomodule with backward compatibility in TypeScript",
  "types": "lib/typescript/index.d.ts",
  "react-native": "src/index",
  "source": "src/index",
  "files": [
    "src",
    "lib",
    "android",
    "ios",
    "example-library.podspec",
    "!lib/typescript/example",
    "!android/build",
    "!ios/build",
    "!**/__tests__",
    "!**/__fixtures__",
    "!**/__mocks__"
  ],
  "scripts": {
    "typescript": "tsc --noEmit",
  },
  "keywords": [
    "react-native",
    "ios",
    "android"
  ],
  "repository": "https://github.com/<your_github_handle/example-library",
  "author": "<Your Name> <your_email@your_provider.com> (https://github.com/<your_github_handle)",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/<your_github_handle/example-library/issues"
  },
  "homepage": "https://github.com/<your_github_handle/example-library#readme",

  "devDependencies": {
    "@react-native-community/eslint-config": "^2.0.0",
    "@types/jest": "^26.0.0",
    "@types/react": "^16.9.19",
    "@types/react-native": "0.62.13",
    "typescript": "^4.1.3"
  },
  "peerDependencies": {
    "react": "*",
    "react-native": "*"
  }
}
```
1. `touch babel.config.js`
1. Paste this code into the `babel.config.js` file:
```js
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
};
```
1. `touch tsconfig.build.json`
1. Paste this code into the `tsconfig.build.json` file:
```json
{
  "extends": "./tsconfig",
  "exclude": ["example"]
}
```
1. `touch tsconfig.json`
1. Paste this code into the `tsconfig.json` file:
```json
{
  "compilerOptions": {
    "baseUrl": "./",
    "paths": {
      "example-library": ["./src/index"]
    },
    "allowUnreachableCode": false,
    "allowUnusedLabels": false,
    "esModuleInterop": true,
    "importsNotUsedAsValues": "error",
    "forceConsistentCasingInFileNames": true,
    "jsx": "react",
    "lib": ["esnext"],
    "module": "esnext",
    "moduleResolution": "node",
    "noFallthroughCasesInSwitch": true,
    "noImplicitReturns": true,
    "noImplicitUseStrict": false,
    "noStrictGenericChecks": false,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "strict": true,
    "target": "esnext"
  }
}
```

### [[Native Module] Create the TS Specs]()

1. `mkdir example-library/src`
1. `touch example-library/src/index.ts`
1. Paste the following content into the `index.ts`:

```ts
import { NativeModules } from 'react-native';

const nativeCalculator = NativeModules.Calculator;

class Calculator {
  add(a: number, b: number): Promise<number> {
    return nativeCalculator.add(a, b);
  }
}
const calc = new Calculator();
export default calc;
```

### [[Native Module] Create the iOS implementation]()

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

### <a name="test-old-architecture" />[[Native Module] Test The Native Module]()

1. At the same level of example-library run `npx react-native init OldArchitecture --template react-native-template-typescript`
1. `cd OldArchitecture && yarn add ../example-library`
1. `cd ios && pod install && cd ..`
1. `npx react-native start` (In another terminal, to run Metro)
1. `npx react-native run-ios`
1. Open `OldArchitecture/App.tsx` file and replace the content with:
    ```ts
    /**
     * Sample React Native App
    * https://github.com/facebook/react-native
    *
    * Generated with the TypeScript template
    * https://github.com/react-native-community/react-native-template-typescript
    *
    * @format
    */
    import React, { useState } from 'react';
    import {
    SafeAreaView,
    StatusBar,
    Text,
    Button,
    } from 'react-native';
    import Calculator from 'example-library/src/index';

    const App = () => {
    const [result, setResult] = useState<number | null>(null);

    return (
        <SafeAreaView>
        <StatusBar barStyle={'dark-content'} />
        <Text style={{marginLeft:20, marginTop:20}}>3+7={result ?? "Unknown"}</Text>
        <Button title="Compute" onPress={async () => {
            const newRes = await Calculator.add(5, 4);
            setResult(newRes);
        }} />
        </SafeAreaView>
    );
    };

    export default App;
    ```
1. Click on the `Compute` button and see the app working

**Note:** OldArchitecture app has not been committed not to pollute the repository.

### [[TurboModule] Add the JavaScript specs](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/54aedba81461301f4e2bc602ebc8df78e0df2639)

1. `touch example-library/src/NativeCalculator.ts`
1. Paste the following code:
    ```ts
    import type { TurboModule } from 'react-native';
    import { TurboModuleRegistry } from 'react-native';

    export interface Spec extends TurboModule {
      // your module methods go here, for example:
      add(a: number, b: number): Promise<number>;
    }

    export default TurboModuleRegistry.get<Spec>('Calculator');
    ```
