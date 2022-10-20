# Run

This run is used to show an advanced use of a component which use the state to load images on **iOS**.

Loading images on **Android** is done with Fresco, so the android component won't actually use the state. The example is still helpful to show how to configure auto-linking properly when there is some custom C++ state.

## Table of Content

* [[Setup] Create the image-component folder and the package.json](#setup)
* [[Fabric Component] Create the TS specs](#ts-specs)
* [[Fabric Component] Setup Codegen](#codegen)

## Steps

### <a name="setup">[[Setup] Create the image-component folder and the package.json]()

1. `mkdir image-component`
2. `touch image-component/package.json`
3. Paste the following code into the `package.json` file
```json
{
    "name": "image-component",
    "version": "0.0.1",
    "description": "Showcase Fabric component with state",
    "react-native": "src/index",
    "source": "src/index",
    "files": [
        "src",
        "android",
        "ios",
        "example-component.podspec",
        "!android/build",
        "!ios/build",
        "!**/__tests__",
        "!**/__fixtures__",
        "!**/__mocks__"
    ],
    "keywords": ["react-native", "ios", "android"],
    "repository": "https://github.com/<your_github_handle>/image-component",
    "author": "<Your Name> <your_email@your_provider.com> (https://github.com/<your_github_handle>)",
    "license": "MIT",
    "bugs": {
        "url": "https://github.com/<your_github_handle>/image-component/issues"
    },
    "homepage": "https://github.com/<your_github_handle>/image-component#readme",
    "devDependencies": {},
    "peerDependencies": {
        "react": "*",
        "react-native": "*"
    }
}
```

### <a name="ts-import" />[[Fabric Component] Create the TS specs]()

1. `mkdir image-component/src`
1. `touch image-component/src/ImageComponentNativeComponent.ts`
1. Paste the following content into the `ImageComponentNativeComponent.ts`
```ts
import type { ViewProps } from 'ViewPropTypes';
import type { HostComponent } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type {ImageSource} from 'react-native/Libraries/Image';

export interface NativeProps extends ViewProps {
  image?: ImageSource;
  // add other props here
}

export default codegenNativeComponent<NativeProps>(
  'RTNImageComponent'
) as HostComponent<NativeProps>;
```

### <a name="codegen">[[Fabric Component] Setup Codegen]()

1. Open the `image-component/package.json`
2. Add the following snippet at the end of it:
```json
"codegenConfig": {
    "name": "RTNImageViewSpec",
    "type": "all",
    "jsSrcsDir": "src"
}
```
