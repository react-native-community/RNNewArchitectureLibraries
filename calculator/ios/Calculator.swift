import Foundation

@objc
class Calculator: NSObject {

  @objc
  static func add(a: Int, b: Int) -> Int {
    return a+b;
  }
}
