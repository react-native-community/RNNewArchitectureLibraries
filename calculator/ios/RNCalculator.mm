#import "RNCalculator.h"
// Thanks to this guard, we won't import this header when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNCalculatorSpec.h"
#endif

#import "calculator-Swift.h"

// Options 2.A - Conform to the protocol
@interface RNCalculator () <CalculatorDelegate>
@end

@implementation RNCalculator {
  Calculator *calculator;
}

- (instancetype)init {
  self = [super init];
  if(self) {
    // Option 2.B - Instantiate the Calculator and set the delegate
    calculator = [Calculator new];
    calculator.delegate = self;
  }
  return self;
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

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
  NSNumber *result = @([calculator addWithA:a b:b]);
  resolve(result);
}

// Event Emitter

- (NSArray<NSString *> *)supportedEvents {
  return [Calculator supportedEvents];
}

// Options 2.D - Implement the Specs
RCT_EXPORT_METHOD(eventfulSqrt:(double)a)
{
  [calculator eventfulSqrtWithValue:a];
}


// Option 2.C - Implement the protocol
- (void)sendEventWithName:(NSString * _Nonnull)name result:(double)result {
  [self sendEventWithName:name body:@(result)];
}

@end
