# RUN

This doc contains the logs of the steps done to achieve the final result.

## Steps

### [[Setup] Create the example-library folder and the package.json]()

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

### [[Native Module] Create the JS import]()

1. `mkdir example-library/src`
1. `touch example-library/src/index.js`
1. Paste the following content into the `index.js`
```js
// @flow
import { NativeModules } from 'react-native'

export default NativeModules.Calculator;
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
