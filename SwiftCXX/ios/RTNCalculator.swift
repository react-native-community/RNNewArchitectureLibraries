//
//  RTNCalculator.swift
//  SwiftCXX
//
//  Created by Riccardo Cipolleschi on 07/06/2023.
//

import Foundation
import React

//import ReactCommon
//import React_Codegen

@objc
public class RTNCalculatorSwift: NSObject/*, NativeCalculatorSpec*/ {
  
  static func moduleName() -> String {
    return "RTNCalculator"
  }
  
  func add(_ a: Double, b: Double, resolve: RCTPromiseResolveBlock!, reject: RCTPromiseRejectBlock!) {
    resolve(a+b)
  }
  
  @objc
  public func giveMeAString() -> String {
    var p = facebook.react.Person(35)
    return "\(p.doubleAge())"
  }
  
//  func getTurboModule(params: facebook.react.ObjCTurboModule.InitParams) -> std.shared_ptr<facebook.react.TurboModule> {
//    return std.make_shared<facebook.react.NativeCalculatorSpecJSI>(params);
//  }
}
