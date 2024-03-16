const fs = require('fs');
const path = require('path');

const dependencies = {};
const PACKAGES_DIR = path.join(__dirname, '..', '..', 'packages');
fs.readdirSync(PACKAGES_DIR).forEach((name) => {
  if (typeof name === 'string') {
    dependencies[`${name}`] = {
      root: path.join(PACKAGES_DIR, name),
    };
  }
});

module.exports = {
  dependencies,
};
