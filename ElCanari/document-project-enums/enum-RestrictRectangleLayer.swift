//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum RestrictRectangleLayer : Int, EnumPropertyProtocol, Hashable, CaseIterable {
  case frontSide = 0
  case backSide = 1
  case bothSides = 2

  //····················································································································
  //  Enum generic bindings utility functions
  //····················································································································

  static func buildfromRawValue (rawValue : Int) -> RestrictRectangleLayer? {
    if let v = RestrictRectangleLayer (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  //····················································································································

  func enumfromRawValue (rawValue : Int) -> RestrictRectangleLayer {
    var result = self
    let v : RestrictRectangleLayer? = RestrictRectangleLayer (rawValue:rawValue) ;
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

  static func convertFromNSObject (object : NSObject) -> RestrictRectangleLayer {
    var result = RestrictRectangleLayer.frontSide
    if let number = object as? NSNumber, let v = RestrictRectangleLayer (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  //····················································································································

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> RestrictRectangleLayer? {
    if let rawValue = inData.base62EncodedInt (range: inRange), let enumValue = RestrictRectangleLayer (rawValue: rawValue) {
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

typealias EBReadOnlyProperty_RestrictRectangleLayer = EBReadOnlyEnumProperty <RestrictRectangleLayer>
typealias EBTransientProperty_RestrictRectangleLayer = EBTransientEnumProperty <RestrictRectangleLayer>
typealias EBReadWriteProperty_RestrictRectangleLayer = EBReadWriteEnumProperty <RestrictRectangleLayer>
typealias EBStoredProperty_RestrictRectangleLayer = EBStoredEnumProperty <RestrictRectangleLayer>
typealias EBPropertyProxy_RestrictRectangleLayer = EBPropertyEnumProxy <RestrictRectangleLayer>
typealias EBPreferencesProperty_RestrictRectangleLayer = EBStoredEnumProperty <RestrictRectangleLayer>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————