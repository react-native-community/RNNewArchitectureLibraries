# RUN

This run starts from the [feat/back-turbomodule-070](https://github.com/react-native-community/RNNewArchitectureLibraries/tree/feat/back-turbomodule-070) branch.
Start from there up to the `[TurboModule] Test the Turbomodule` section. Then, follow the steps below to move your logic to a Swift implementation file.

## Table of contents

* [[Setup] Update to 0.71-RC.3](#update)
* [[Setup] Update podspec](#update-podspec)
* [[Swift] Add Swift files](#swift)
* [[iOS] Update Calculator file](#update-calculator)

## Steps

### <a name="update" />[[Setup] Update to 0.71-RC.3]()

1. `cd NewArchitecture` - It has been created in this [step](https://github.com/react-native-community/RNNewArchitectureLibraries/tree/feat/back-turbomodule-070#tm-test).
2. `yarn add react-native@0.71.0-rc.3`

### <a name="update-podspec" />[[Setup] Update podspec]()

1. Open the `calculator/calculator.podspec` file
2. Update it as it follows:
```diff
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

-folly_version = '2021.07.22.00'
-folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name            = "calculator"
  s.version         = package["version"]
  s.summary         = package["description"]
  s.description     = package["description"]
  s.homepage        = package["homepage"]
  s.license         = package["license"]
  s.platforms       = { :ios => "11.0" }
  s.author          = package["author"]
  s.source          = { :git => package["repository"], :tag => "#{s.version}" }

  s.source_files    = "ios/**/*.{h,m,mm,swift}"

+  s.pod_target_xcconfig    = {
+    "DEFINES_MODULE" => "YES",
+    "OTHER_CPLUSPLUSFLAGS" => "-DRCT_NEW_ARCH_ENABLED=1"
+  }

+  install_modules_dependencies(s)
-  # This guard prevent to install the dependencies when we run `pod install` in the old architecture.
-  if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
-      s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
-      s.pod_target_xcconfig    = {
-          "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
-          "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
-      }
-
-      s.dependency "React-Codegen"
-      s.dependency "RCT-Folly", folly_version
-      s.dependency "RCTRequired"
-      s.dependency "RCTTypeSafety"
-      s.dependency "ReactCommon/turbomodule/core"
-  end
end
```

### <a name="swift" />[[Swift] Add Swift files]()

1. Create a new file `calculator/ios/Calculator.swift` with the implementation of the logic:
    ```swift
    import Foundation

    @objc
    class Calculator: NSObject {

      @objc
      static func add(a: Int, b: Int) -> Int {
        return a+b;
      }
    }
    ```

### <a name="upadet-calculator" />[[iOS] Update Calculator file]()

1. Open the `calculator/ios/RNCalculator.mm` file and update the logic to invoke the Swift one
    ```diff
    // This are not needed
    - #ifdef RCT_NEW_ARCH_ENABLED
    - #import "RNCalculatorSpec.h"
    - #endif

    + #import <calculator-Swift.h>

    @implementation RNCalculator

    RCT_EXPORT_MODULE(Calculator)

    RCT_REMAP_METHOD(add, addA:(NSInteger)a
                            andB:(NSInteger)b
                    withResolver:(RCTPromiseResolveBlock) resolve
                    withRejecter:(RCTPromiseRejectBlock) reject)
    {
    -    NSNumber *result = [[NSNumber alloc] initWithInteger:a+b];
    +    NSNumber *result = @([Calculator addWithA:a b:b]);
        resolve(result);
    }
    ```
