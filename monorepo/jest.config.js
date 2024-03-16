module.exports = {
  "testEnvironment": "node",
  "testRegex": "/__tests__/.*\\.(test|spec)\\.(js|tsx?)$",
  "setupFiles": [],
  "transformIgnorePatterns": [
    "node_modules/(?!(@react-native|react-native|react-native-reanimated)/)"
  ],
  "moduleNameMapper": {
    "([^/]+)": "<rootDir>/packages/$1/src"
  },
  "prettierPath": null,
  "preset": "react-native"
};
