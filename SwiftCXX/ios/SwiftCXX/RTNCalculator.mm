//
//  RNTCalculator.m
//  SwiftCXX
//
//  Created by Riccardo Cipolleschi on 07/06/2023.
//

#import "RTNCalculator.h"

@implementation RTNCalculator

RCT_EXPORT_MODULE()


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
}

- (void)add:(double)a b:(double)b resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  resolve(@(a + b));
}

@end
