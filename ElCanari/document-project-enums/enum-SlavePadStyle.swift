//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum SlavePadStyle : Int, EnumPropertyProtocol, Hashable, CaseIterable {
  case traversing = 0
  case componentSide = 1
  case oppositeSide = 2

  //····················································································································
  // Function popupTitles
  //····················································································································

  static func popupTitles () -> [String] {
    return ["Traversing", "Component Side", "Opposite Side"]
  }

  //····················································································································
  //  Enum generic bindings utility functions
  //····················································································································

  static func buildfromRawValue (rawValue : Int) -> SlavePadStyle? {
    if let v = SlavePadStyle (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  //····················································································································

  func enumfromRawValue (rawValue : Int) -> SlavePadStyle {
    var result = self
    let v : SlavePadStyle? = SlavePadStyle (rawValue:rawValue) ;
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

  static func convertFromNSObject (object : NSObject) -> SlavePadStyle {
    var result = SlavePadStyle.traversing
    if let number = object as? NSNumber, let v = SlavePadStyle (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  //····················································································································

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> SlavePadStyle? {
    if let rawValue = inData.base62EncodedInt (range: inRange), let enumValue = SlavePadStyle (rawValue: rawValue) {
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

typealias EBReadOnlyProperty_SlavePadStyle = EBReadOnlyEnumProperty <SlavePadStyle>
typealias EBTransientProperty_SlavePadStyle = EBTransientEnumProperty <SlavePadStyle>
typealias EBReadWriteProperty_SlavePadStyle = EBReadWriteEnumProperty <SlavePadStyle>
typealias EBStoredProperty_SlavePadStyle = EBStoredEnumProperty <SlavePadStyle>
typealias EBPropertyProxy_SlavePadStyle = EBPropertyEnumProxy <SlavePadStyle>
typealias EBPreferencesProperty_SlavePadStyle = EBStoredEnumProperty <SlavePadStyle>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————