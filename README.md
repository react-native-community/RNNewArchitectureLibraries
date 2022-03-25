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
