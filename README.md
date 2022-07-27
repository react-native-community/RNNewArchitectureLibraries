# Run

This doc contains the logs of the steps done to achieve the final result.

## Table of Contents

* [[Setup] Create the colored-view folder and the package.json](#setup)
* [[Native Component] Create the JS import](#js-import)

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
