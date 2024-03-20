#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTscEventEmitterSpec.h"

@interface TscEventEmitter : RCTEventEmitter <NativeTscEventEmitterSpec> {
    bool hasListeners;
}
#else
#import <React/RCTBridgeModule.h>

@interface TscEventEmitter : RCTEventEmitter <RCTBridgeModule> {
    bool hasListeners;
}

- (void)multiply:(double)a
            b:(double)b
            resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject);
#endif

@end
