#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>

#if RCT_NEW_ARCH_ENABLED

#import <RNCalculatorSpec/RNCalculatorSpec.h>
@interface RNCalculator: RCTEventEmitter <NativeCalculatorSpec>

#else

#import <React/RCTBridgeModule.h>
@interface RNCalculator : RCTEventEmitter <RCTBridgeModule>

#endif

@end
