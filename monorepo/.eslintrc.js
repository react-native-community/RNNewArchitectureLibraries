module.exports = {
  root: true,
  env: {
    'browser': true,
    'es2021': true,
    'node': true,
    'commonjs': true,
    'react-native/react-native': true,
  },
  plugins: [
    'react',
    'react-native',
    'react-hooks',
    '@typescript-eslint',
    'prettier',
  ],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/recommended',
    'plugin:react/recommended',
    'plugin:react-native/all',
    'plugin:react-hooks/recommended',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  settings: {
    'import/resolver': {
      node: {
        extensions: ['.js', '.jsx', '.ts', '.tsx'],
      },
    },
    'react': {
      version: 'detect',
    },
  },
  rules: {
    'import/no-unresolved': 'off',
    'import/named': 'off',
    'import/namespace': 'off',
    'react/display-name': 'off',
    'react/prop-types': 'off',
    'no-unsafe-optional-chaining': 'off',
    'react-native/no-inline-styles': 'off',
    'react-native/sort-styles': 'off',
    'react-native/no-color-literals': 'off',
    'react-native/no-raw-text': 'off',
    'react/no-unescaped-entities': 'off',
    'react-hooks/exhaustive-deps': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-var-requires': 'off',
    '@typescript-eslint/ban-ts-comment': 'off',
  },
};
