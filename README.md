# Run

This doc contains the logs of the steps done to achieve the final result.

## Table of Contents

* [[Setup] Create the colored-view folder and the package.json](#setup)
* [[Native Component] Create the JS import](#js-import)
* [[Native Component] Create the iOS implementation](#native-ios)

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
