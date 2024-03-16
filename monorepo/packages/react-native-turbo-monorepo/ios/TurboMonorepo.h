
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTurboMonorepoSpec.h"

@interface TurboMonorepo : NSObject <NativeTurboMonorepoSpec>
#else
#import <React/RCTBridgeModule.h>

@interface TurboMonorepo : NSObject <RCTBridgeModule>
#endif

@end
