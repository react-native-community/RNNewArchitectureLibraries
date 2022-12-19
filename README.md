# RUN

This run starts from the [feat/turbomodule-swift](https://github.com/react-native-community/RNNewArchitectureLibraries/tree/feat/turbomodule-swift) branch.
Start from there up to the `[TurboModule] Test the swift Turbomodule` section. Then, follow the steps below to move your logic to a Swift implementation file.

## Table of contents

* [[Codegen] Update Codegen Specs](#codegen)


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


