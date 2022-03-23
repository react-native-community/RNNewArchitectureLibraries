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
