// @flow

import { requireNativeComponent } from 'react-native'

const isFabricEnabled = global.nativeFabricUIManager != null;

const coloredView = isFabricEnabled ?
    require("./ColoredViewNativeComponent").default :
    requireNativeComponent("ColoredView")

export default coloredView;
