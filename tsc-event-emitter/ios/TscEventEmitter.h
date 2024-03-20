
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTscEventEmitterSpec.h"

@interface TscEventEmitter : NSObject <NativeTscEventEmitterSpec>
#else
#import <React/RCTBridgeModule.h>

@interface TscEventEmitter : NSObject <RCTBridgeModule>
#endif

@end
