#import "TurboMonorepo.h"

@implementation TurboMonorepo
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
    return @[@"multiplyEvent"];
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    // Remove upstream listeners, stop unnecessary background tasks
    hasListeners = NO;
    // If we no longer have listeners registered we should also probably also stop the sensor since the sensor events are essentially being dropped.
}

- (void)sendEvent:(NSString *)eventName body:(id)body {
    [self sendEventWithName:eventName body:body];
}

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_EXPORT_METHOD(multiply:(double)a
                  b:(double)b
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSNumber *result = @(a * b);
    [self sendEvent:@"multiplyEvent" body:@{
                                             @"result" : [NSNumber numberWithDouble:result]
                                           }];

    resolve(result);
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeTurboMonorepoSpecJSI>(params);
}
#endif

@end
