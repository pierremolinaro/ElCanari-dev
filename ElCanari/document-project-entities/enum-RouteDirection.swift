//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum RouteDirection : Int, EnumPropertyProtocol {
  case from = 0
  case to = 1


  //····················································································································

  init? (string : String) {
    switch string {
      case "from" : self = .from // 0
      case "to" : self = .to // 1
      case _ : return nil
    }
  }

  //····················································································································

  func descriptionForExplorer () -> String {
    switch self {
      case .from : return "from" // 0
      case .to : return "to" // 1
    }
  }

  //····················································································································
  //  Enum generic bindings utility functions
  //····················································································································

  static func buildfromRawValue (rawValue : Int) -> RouteDirection? {
    if let v = RouteDirection (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  //····················································································································

  func enumfromRawValue (rawValue : Int) -> RouteDirection {
    var result = self
    let v : RouteDirection? = RouteDirection (rawValue:rawValue) ;
    if let unwrappedV = v {
      result = unwrappedV
    }
    return result
  }

  //····················································································································
  //  ValuePropertyProtocol
  //····················································································································

  func ebHashValue () -> UInt32 {
    return UInt32 (self.rawValue)
  }

  func convertToNSObject () -> NSObject {
    return NSNumber (value: self.rawValue)
  }

  static func convertFromNSObject (object : NSObject) -> RouteDirection {
    var result = RouteDirection.from
    if let number = object as? NSNumber, let v = RouteDirection (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  //····················································································································

  func stringPropertyValue () -> String {
    return "\(self.rawValue)\n"
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias EBReadOnlyProperty_RouteDirection = EBReadOnlyEnumProperty <RouteDirection>
typealias EBTransientProperty_RouteDirection = EBTransientEnumProperty <RouteDirection>
typealias EBReadWriteProperty_RouteDirection = EBReadWriteEnumProperty <RouteDirection>
typealias EBStoredProperty_RouteDirection = EBStoredEnumProperty <RouteDirection>
typealias EBPropertyProxy_RouteDirection = EBPropertyEnumProxy <RouteDirection>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————