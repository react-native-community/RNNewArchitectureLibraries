## Table of contents

* [[Setup] Create the calculator folder and the package.json](#setup)
* [[Native Module] Create the JS import](#js-import)

## Steps

### <a name="setup" />[[Setup] Create the calculator folder and the package.json](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. `mkdir calculator`
1. `touch calculator/package.json`
1. Paste the following code into the `package.json` file
```json
{
    "name": "calculator",
    "version": "0.0.1",
    "description": "Showcase Turbomodule with backward compatibility",
    "react-native": "src/index",
    "source": "src/index",
    "files": [
        "src",
        "android",
        "ios",
        "calculator.podspec",
        "!android/build",
        "!ios/build",
        "!**/__tests__",
        "!**/__fixtures__",
        "!**/__mocks__"
    ],
    "keywords": ["react-native", "ios", "android"],
    "repository": "https://github.com/<your_github_handle>/calculator",
    "author": "<Your Name> <your_email@your_provider.com> (https://github.com/<your_github_handle>)",
    "license": "MIT",
    "bugs": {
        "url": "https://github.com/<your_github_handle>/calculator/issues"
    },
    "homepage": "https://github.com/<your_github_handle>/calculator#readme",
    "devDependencies": {},
    "peerDependencies": {
        "react": "*",
        "react-native": "*"
    }
}
```

### <a name="js-import" />[[Native Module] Create the JS import](https://github.com/cipolleschi/RNNewArchitectureLibraries/commit/)

1. `mkdir calculator/src`
1. `touch calculator/src/index.js`
1. Paste the following content into the `index.js`
```js
// @flow
import { NativeModules } from 'react-native'

export default NativeModules.Calculator;
```
