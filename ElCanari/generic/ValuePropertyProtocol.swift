//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Protocol ValuePropertyProtocol
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

protocol ValuePropertyProtocol : Equatable {
  func ebHashValue () -> UInt32
  func convertToNSObject () -> NSObject
  static func convertFromNSObject (object : NSObject) -> Self
  func stringPropertyValue () -> String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————