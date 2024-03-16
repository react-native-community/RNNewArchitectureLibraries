const fs = require('fs');
const path = require('path');

const alias = {};
const PACKAGES_DIR = path.join(__dirname, '..', '..', 'packages');
fs.readdirSync(PACKAGES_DIR).forEach((name) => {
  if (typeof name === 'string') {
    alias[`${name}`] = path.join(PACKAGES_DIR, name, 'src');
  }
});

module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    [
      'module-resolver',
      {
        extensions: ['.tsx', '.ts', '.js', '.json'],
        alias,
      },
    ],
  ],
};
