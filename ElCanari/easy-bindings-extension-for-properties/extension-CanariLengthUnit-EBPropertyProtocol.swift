//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry
//--------------------------------------------------------------------------------------------------
//  extension CanariLengthUnit : EBStoredPropertyProtocol
//--------------------------------------------------------------------------------------------------

extension CanariLengthUnit : EBStoredPropertyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func ebHashValue () -> UInt32 {
    var value = self.length.cuValue.bigEndian
    let array = withUnsafeBytes (of: &value) { unsafe Array ($0) }
    return array.ebHashValue ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func convertToNSObject () -> NSObject {
    return NSNumber (value: self.length.cuValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func convertFromNSObject (object : NSObject) -> CanariLengthUnit {
    let number = object as! NSNumber
    return CanariLengthUnit (fromNearestLength: number.intValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendPropertyValueTo (_ ioData : inout Data) {
    ioData.append (base62Encoded: self.length.cuValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> CanariLengthUnit? {
    if let v = inData.base62EncodedInt (range: inRange) {
      return CanariLengthUnit (fromNearestLength: v)
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
