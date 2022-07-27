#import <Foundation/Foundation.h>

#ifdef RCT_NEW_ARCH_ENABLED

#import <RNCalculatorSpec/RNCalculatorSpec.h>
@interface RNCalculator: NSObject <NativeCalculatorSpec>

#else

#import <React/RCTBridgeModule.h>
@interface RNCalculator : NSObject <RCTBridgeModule>

#endif

@end
