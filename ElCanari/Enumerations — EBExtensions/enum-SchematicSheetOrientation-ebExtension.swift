//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension SchematicSheetOrientation : EBEnumPropertyProtocol, Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Function popupTitles
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func popupTitles () -> [String] {
    return ["A4 V", "A4 H", "Custom"]
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Enum generic bindings utility functions
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func buildfromRawValue (rawValue : Int) -> SchematicSheetOrientation? {
    if let v = SchematicSheetOrientation (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 /* func enumfromRawValue (rawValue : Int) -> SchematicSheetOrientation {
    var result = self
    let v : SchematicSheetOrientation? = SchematicSheetOrientation (rawValue:rawValue) ;
    if let unwrappedV = v {
      result = unwrappedV
    }
    return result
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  EBStoredPropertyProtocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func ebHashValue () -> UInt32 {
    return UInt32 (self.rawValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func convertToNSObject () -> NSObject {
    return NSNumber (value: self.rawValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func convertFromNSObject (object : NSObject) -> SchematicSheetOrientation {
    var result = SchematicSheetOrientation.a4Vertical
    if let number = object as? NSNumber, let v = SchematicSheetOrientation (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> SchematicSheetOrientation? {
    if let rawValue = inData.base62EncodedInt (range: inRange), let enumValue = SchematicSheetOrientation (rawValue: rawValue) {
      return enumValue
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendPropertyValueTo (_ ioData : inout Data) {
    ioData.append (base62Encoded: self.rawValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

typealias EBReadWriteProperty_SchematicSheetOrientation  = EBEnumReadWriteProperty <SchematicSheetOrientation>
typealias EBStoredProperty_SchematicSheetOrientation     = EBEnumStoredProperty <SchematicSheetOrientation>
typealias EBStandAloneProperty_SchematicSheetOrientation = EBEnumStandAloneProperty <SchematicSheetOrientation>
typealias EBComputedProperty_SchematicSheetOrientation   = EBEnumGenericComputedProperty <SchematicSheetOrientation>
typealias EBPreferenceProperty_SchematicSheetOrientation = EBEnumPreferenceProperty <SchematicSheetOrientation>

//--------------------------------------------------------------------------------------------------
