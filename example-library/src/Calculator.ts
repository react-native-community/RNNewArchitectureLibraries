import { NativeModules } from 'react-native';

const nativeCalculator = NativeModules.Calculator;

class Calculator {
  add(a: number, b: number): Promise<number> {
    return nativeCalculator.add(a, b);
  }
}
const calc = new Calculator();
export default calc;
