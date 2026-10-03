//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry
//--------------------------------------------------------------------------------------------------
//    extension CanariAngle : EBStoredPropertyProtocol
//--------------------------------------------------------------------------------------------------

extension CanariAngle : EBStoredPropertyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func ebHashValue () -> UInt32 {
    var value = Int ((self.unsignedDegreeValue * 1000.0).rounded ()).bigEndian
    let array = withUnsafeBytes (of: &value) { unsafe Array ($0) }
    return array.ebHashValue ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func convertToNSObject () -> NSObject {
    let value = Int ((self.unsignedDegreeValue * 1000.0).rounded ())
    return NSNumber (value: value)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func convertFromNSObject (object : NSObject) -> CanariAngle {
    let v = (object as! NSNumber).intValue
    let degrees = Double (v) / 1000.0
    return .degree (degrees)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendPropertyValueTo (_ ioData : inout Data) {
    let value = Int ((self.unsignedDegreeValue * 1000.0).rounded ())
    ioData.append (base62Encoded: value)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> CanariAngle? {
    if let v = inData.base62EncodedInt (range: inRange) {
      return CanariAngle.degree (Double (v) / 1000.0)
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
