import Foundation

// Define a protocol for the Calculator Delegate
@objc protocol CalculatorDelegate {
  func sendEvent(name: String, result: Double)
}

@objc class Calculator: NSObject {
  @objc weak var delegate: CalculatorDelegate? = nil

  @objc func add(a: Int, b: Int) -> Int {
    return a+b
  }

  @objc func eventfulSqrt(value: Double) {
    delegate?.sendEvent(name: Event.sqrt.rawValue, result: sqrt(value));
  }
}


extension Calculator {
  // List of emittable events
  enum Event: String, CaseIterable {
    case sqrt
  }

  @objc
  static var supportedEvents: [String] {
    return Event.allCases.map(\.rawValue);
  }
}
