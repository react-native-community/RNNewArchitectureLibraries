import { TurboMonorepo } from './TurboMonorepo';
import { NativeEventEmitter } from 'react-native';

export function multiply(a: number, b: number): Promise<number> {
  return TurboMonorepo.multiply(a, b);
}

export function startListening(listener: (event: any) => void) {
  const eventEmitter = new NativeEventEmitter(TurboMonorepo);
  return eventEmitter.addListener(`multiplyEvent`, listener);
}
