# RUN

This run starts from the [feat/turbomodule-swift](https://github.com/react-native-community/RNNewArchitectureLibraries/tree/feat/turbomodule-swift) branch.
Start from there up to the `[TurboModule] Test the swift Turbomodule` section. Then, follow the steps below to move your logic to a Swift implementation file.

## Table of contents

* [[Codegen] Update Codegen Specs](#codegen)
* [[Swift] Implement the Swift logic](#swift-logic)
* [[Obj-C++] Implement the Objective-C++ logic](#objc-logic)

## Steps

### <a name="codegen" />* [[Codegen] Update Codegen Specs](#codegen)

1. Open the `calculator/src/NativeCalculator.js` file and add the following lines
```diff
export interface Spec extends TurboModule {
    // your module methods go here, for example:
    add(a: number, b: number): Promise<number>;

+    // eventful Sqrt
+    eventfulSqrt(a: number): void;

+    addListener: (eventType: string) => void;
+    removeListeners: (count: number) => void;
}
```

**Note:** The `addListener` and `removeListeners` implementations will be provided by React Native.

### <a name="swift-logic" />[[Swift] Implement the Swift logic]()

1. Open the `calculator/ios/Calculator.swift` file
2. Add the following `CalculatorDelegate` protocol in it. This protocol will be implemented by the Objective-C++ class to provide the send event method to the Swift implementation
```swift
@objc protocol CalculatorDelegate {
    func sendEvent(name: String, result: Double)
}
```
3. In the Calculator class, add a property to store the delegate (remember the `weak` keyword):
```diff
@objc class Calculator: NSObject {
+   @objc weak var delegate: CalculatorDelegate? = nil
// rest of the class
}
```
4. Transform the static method into instance method
```diff
@objc class Calculator: NSObject {
    @objc weak var delegate: CalculatorDelegate? = nil

-    @objc static func add(a: Int, b: Int) -> Int {
+    @objc func add(a: Int, b: Int) -> Int {
        return a+b
    }
}
```
5. Add the new method implementation:
```diff
@objc class Calculator: NSObject {
    @objc weak var delegate: CalculatorDelegate? = nil

    @objc func add(a: Int, b: Int) -> Int {
        return a+b
    }

+    @objc func eventfulSqrt(value: Double) {
+        delegate?.sendEvent(name: Event.sqrt.rawValue, result: sqrt(value));
+    }
}
```
6. Add an extension for the supporting logic:
```swift
extension Calculator {
  // List of emittable events
  enum Event: String, CaseIterable {
    case sqrt
  }

  @objc
  static var supportedEvents: [String] {
    return Event.allCases.map(\.rawValue);
  }
}
```

### <a name="objc-logic" />[[Obj-C++] Implement the Objective-C++ logic]()

1. Open the header file `calculator/ios/RNCalculator.h` and make it extend `RCTEventEmitter`
```diff
#import <Foundation/Foundation.h>
+ #import <React/RCTEventEmitter.h>

#if RCT_NEW_ARCH_ENABLED

#import <RNCalculatorSpec/RNCalculatorSpec.h>
-@interface RNCalculator: NSObject <NativeCalculatorSpec>
+@interface RNCalculator: RCTEventEmitter <NativeCalculatorSpec>

#else

#import <React/RCTBridgeModule.h>
-@interface RNCalculator : NSObject <RCTBridgeModule>
+@interface RNCalculator : RCTEventEmitter <RCTBridgeModule>

#endif

@end
```
2. Open the implementation file `calculator/ios/RNCalculator.mm` and:
    1. Make it conform to the protocol
    ```objc
    // Options 2.A - Conform to the protocol
    @interface RNCalculator () <CalculatorDelegate>
    @end
    ```
    2. Add a property to store the Calculator:
    ```objc
    @implementation RNCalculator {
        Calculator *calculator;
    }
    ```
    3. Implement the initializer, passing self as a delegate
    ```c++
    - (instancetype)init {
        self = [super init];
        if(self) {
            // Option 2.B - Instantiate the Calculator and set the delegate
            calculator = [Calculator new];
            calculator.delegate = self;
        }
        return self;
    }
    ```
    4. Given that we implemented a custom init, we need to implement the `requiresMainQueueSetup` method:
    ```c++
    + (BOOL)requiresMainQueueSetup {
        return NO;
    }
    ```
    5. Implement the `RCTEventEmitter` required fields. Notice that we leverage the Swift implementation
    ```c++
    - (NSArray<NSString *> *)supportedEvents {
        return [Calculator supportedEvents];
    }
    ```
    6. Implement the `CalculatorDelegate` requirements. Here we emit the event to the JS side of React Native. The `sendEventWithName:body` is provided by React Native itself.
    ```c++
    - (void)sendEventWithName:(NSString * _Nonnull)name result:(double)result {
        [self sendEventWithName:name body:@(result)];
    }
    ```
    7. Implement the Specs by calling the Swift code:
    ```c++
    RCT_EXPORT_METHOD(eventfulSqrt:(double)a)
    {
        [calculator eventfulSqrtWithValue:a];
    }
    ```
