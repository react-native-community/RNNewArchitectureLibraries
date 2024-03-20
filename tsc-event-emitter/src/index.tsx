import { NativeModules, Platform, NativeEventEmitter } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-tsc-event-emitter' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const TscEventEmitterModule = isTurboModuleEnabled
  ? require('./NativeTscEventEmitter').default
  : NativeModules.TscEventEmitter;

const TscEventEmitter = TscEventEmitterModule
  ? TscEventEmitterModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function multiply(a: number, b: number): Promise<number> {
  return TscEventEmitter.multiply(a, b);
}

export function startListening(listener: (event: any) => void) {
  const eventEmitter = new NativeEventEmitter(TscEventEmitter);
  return eventEmitter.addListener(`multiplyEvent`, listener);
}
