//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum GridStyle : Int, EnumPropertyProtocol, Hashable, CaseIterable {
  case noGrid = 0
  case cross = 1
  case line = 2

  //····················································································································
  // Function popupTitles
  //····················································································································

  static func popupTitles () -> [String] {
    return ["No Grid", "Cross Grid", "Line Grid"]
  }

  //····················································································································
  //  Enum generic bindings utility functions
  //····················································································································

  static func buildfromRawValue (rawValue : Int) -> GridStyle? {
    if let v = GridStyle (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  //····················································································································

  func enumfromRawValue (rawValue : Int) -> GridStyle {
    var result = self
    let v : GridStyle? = GridStyle (rawValue:rawValue) ;
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

  static func convertFromNSObject (object : NSObject) -> GridStyle {
    var result = GridStyle.noGrid
    if let number = object as? NSNumber, let v = GridStyle (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  //····················································································································

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> GridStyle? {
    if let rawValue = inData.base62EncodedInt (range: inRange), let enumValue = GridStyle (rawValue: rawValue) {
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

typealias EBReadOnlyProperty_GridStyle = EBReadOnlyEnumProperty <GridStyle>
typealias EBTransientProperty_GridStyle = EBTransientEnumProperty <GridStyle>
typealias EBReadWriteProperty_GridStyle = EBReadWriteEnumProperty <GridStyle>
typealias EBStoredProperty_GridStyle = EBStoredEnumProperty <GridStyle>
typealias EBPropertyProxy_GridStyle = EBPropertyEnumProxy <GridStyle>
typealias EBPreferencesProperty_GridStyle = EBStoredEnumProperty <GridStyle>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————