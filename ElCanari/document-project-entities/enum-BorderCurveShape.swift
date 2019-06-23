//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum BorderCurveShape : Int, EnumPropertyProtocol {
  case line = 0
  case bezier = 1


  //····················································································································

  init? (string : String) {
    switch string {
      case "line" : self = .line // 0
      case "bezier" : self = .bezier // 1
      case _ : return nil
    }
  }

  //····················································································································

  func descriptionForExplorer () -> String {
    switch self {
      case .line : return "line" // 0
      case .bezier : return "bezier" // 1
    }
  }

  //····················································································································
  //  Enum generic bindings utility functions
  //····················································································································

  static func buildfromRawValue (rawValue : Int) -> BorderCurveShape? {
    if let v = BorderCurveShape (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  //····················································································································

  func enumfromRawValue (rawValue : Int) -> BorderCurveShape {
    var result = self
    let v : BorderCurveShape? = BorderCurveShape (rawValue:rawValue) ;
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

  static func convertFromNSObject (object : NSObject) -> BorderCurveShape {
    var result = BorderCurveShape.line
    if let number = object as? NSNumber, let v = BorderCurveShape (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias EBReadOnlyProperty_BorderCurveShape = EBReadOnlyEnumProperty <BorderCurveShape>
typealias EBTransientProperty_BorderCurveShape = EBTransientEnumProperty <BorderCurveShape>
typealias EBReadWriteProperty_BorderCurveShape = EBReadWriteEnumProperty <BorderCurveShape>
typealias EBStoredProperty_BorderCurveShape = EBStoredEnumProperty <BorderCurveShape>
typealias EBPropertyProxy_BorderCurveShape = EBPropertyEnumProxy <BorderCurveShape>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————