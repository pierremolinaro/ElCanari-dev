//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum ComponentSide : Int, EnumPropertyProtocol, Hashable, CaseIterable {
  case front = 0
  case back = 1


  //····················································································································

  init? (string : String) {
    switch string {
      case "front" : self = .front // 0
      case "back" : self = .back // 1
      case _ : return nil
    }
  }

  //····················································································································

  func descriptionForExplorer () -> String {
    switch self {
      case .front : return "front" // 0
      case .back : return "back" // 1
    }
  }

  //····················································································································
  //  Enum generic bindings utility functions
  //····················································································································

  static func buildfromRawValue (rawValue : Int) -> ComponentSide? {
    if let v = ComponentSide (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  //····················································································································

  func enumfromRawValue (rawValue : Int) -> ComponentSide {
    var result = self
    let v : ComponentSide? = ComponentSide (rawValue:rawValue) ;
    if let unwrappedV = v {
      result = unwrappedV
    }
    return result
  }

  //····················································································································
  //  EBStoredPropertyProtocol
  //····················································································································

  func ebHashValue () -> UInt32 {
    return UInt32 (self.rawValue)
  }

  //····················································································································

  func convertToNSObject () -> NSObject {
    return NSNumber (value: self.rawValue)
  }

  //····················································································································

  static func convertFromNSObject (object : NSObject) -> ComponentSide {
    var result = ComponentSide.front
    if let number = object as? NSNumber, let v = ComponentSide (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  //····················································································································

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> ComponentSide? {
    if let rawValue = inData.base62EncodedInt (range: inRange), let enumValue = ComponentSide (rawValue: rawValue) {
      return enumValue
    }else{
      return nil
    }
  }

  //····················································································································

  func appendPropertyValueTo (_ ioData : inout Data) {
    ioData.append (base62Encoded: self.rawValue)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias EBReadOnlyProperty_ComponentSide = EBReadOnlyEnumProperty <ComponentSide>
typealias EBTransientProperty_ComponentSide = EBTransientEnumProperty <ComponentSide>
typealias EBReadWriteProperty_ComponentSide = EBReadWriteEnumProperty <ComponentSide>
typealias EBStoredProperty_ComponentSide = EBStoredEnumProperty <ComponentSide>
typealias EBPropertyProxy_ComponentSide = EBPropertyEnumProxy <ComponentSide>
typealias EBPreferencesProperty_ComponentSide = EBStoredEnumProperty <ComponentSide>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
