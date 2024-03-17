import React from 'react';

import { registerRootComponent } from 'expo';

import { App } from './App';

const AppProvider = () => {
  return <App />;
};

registerRootComponent(AppProvider);
