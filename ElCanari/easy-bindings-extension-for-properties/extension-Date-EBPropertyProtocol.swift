//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    extension Date : EBStoredPropertyProtocol
//--------------------------------------------------------------------------------------------------

extension Date : EBStoredPropertyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func ebHashValue () -> UInt32 {
    let archiver = NSKeyedArchiver (requiringSecureCoding: true)
    archiver.encode (self, forKey: NSKeyedArchiveRootObjectKey)
    archiver.finishEncoding ()
    return archiver.encodedData.ebHashValue ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func convertToNSObject () -> NSObject {
    return self as NSObject
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func convertFromNSObject (object : NSObject) -> Date {
    return (object as? Date) ?? Date ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendPropertyValueTo (_ ioData : inout Data) {
    self.timeIntervalSince1970.appendPropertyValueTo (&ioData)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> Date? {
    var result : Date? = nil
    if let timeIntervalSince1970 = Double.unarchiveFromDataRange (inData, inRange) {
      result = Date (timeIntervalSince1970: timeIntervalSince1970)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
