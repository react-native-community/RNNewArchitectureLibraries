#import "RNCalculator.h"

#import "calculator-Swift.h"

@implementation RNCalculator

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(add, addA:(NSInteger)a
                        andB:(NSInteger)b
                withResolver:(RCTPromiseResolveBlock) resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
  return [self add:a b:b resolve:resolve reject:reject];
}

// Thanks to this guard, we won't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
}
#endif

- (void)add:(double)a b:(double)b resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  NSNumber *result = @([Calculator addWithA:a b:b]);
  resolve(result);
}

@end
