const isTurboModuleEnabled = global.__turboModuleProxy != null;

const calculator = isTurboModuleEnabled ?
    require("./NativeCalculator").default :
    require("./Calculator").default;

export default calculator;
