//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    extension Data : EBStoredPropertyProtocol
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Data : EBStoredPropertyProtocol {

  //····················································································································

  func ebHashValue () -> UInt32 {
    var crc : UInt32 = 0
    for i in 0 ..< self.count {
      crc.accumulate (u8: self [i])
    }
    return crc
  }

  //····················································································································

  func convertToNSObject () -> NSObject {
    return self as NSObject
  }

  //····················································································································

  static func convertFromNSObject (object : NSObject) -> Data {
    return object as! Data
  }

  //····················································································································

  func appendPropertyValueTo (_ ioData : inout Data) {
    ioData.append (self.base64EncodedData ())
  }

  //····················································································································

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> Data? {
    let dataSlice = inData [inRange.location ..< inRange.location + inRange.length]
    return Data (base64Encoded: dataSlice)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————