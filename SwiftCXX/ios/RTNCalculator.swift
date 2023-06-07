//
//  RTNCalculator.swift
//  SwiftCXX
//
//  Created by Riccardo Cipolleschi on 07/06/2023.
//

import Foundation
import ReactCommon
import React_Codegen

@objc
class RTNCalculator: NSObject/*, NativeCalculatorSpec*/ {
  
  static func moduleName() -> String {
    return "RTNCalculator"
  }
  
  func add(_ a: Double, b: Double, resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
    resolve(a+b)
  }
  
//  func getTurboModule(params: facebook.react.ObjCTurboModule.InitParams) -> std.shared_ptr<facebook.react.TurboModule> {
//    return std.make_shared<facebook.react.NativeCalculatorSpecJSI>(params);
//  }
}
