#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTurboMonorepoSpec.h"

@interface TurboMonorepo : RCTEventEmitter <NativeTurboMonorepoSpec> {
    bool hasListeners;
}
#else
#import <React/RCTBridgeModule.h>

@interface TurboMonorepo : RCTEventEmitter <RCTBridgeModule> {
    bool hasListeners;
}

- (void)multiply:(double)a
            b:(double)b
            resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject);
#endif

@end
