//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PM_BINARY_FORMAT_SIGNATURE = "PM-BINARY-FORMAT"
let PM_TEXTUAL_FORMAT_SIGNATURE = "PM-TEXT-FORMAT"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//     Data
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Data {

  //····················································································································

  mutating func appendBinarySignature () {
    for c in PM_BINARY_FORMAT_SIGNATURE.utf8 {
      self.append (c)
    }
  }

  //····················································································································

  mutating func appendAutosizedData (_ inData : Data) {
    self.appendAutosizedUnsigned (UInt64 (inData.count))
    self.append (inData)
  }

  //····················································································································

  mutating func appendAutosizedUnsigned (_ inValue : UInt64) {
    var value = inValue
    repeat{
      var byte = UInt8 (value & 0x7F)
      value >>= 7
      if value != 0 {
        byte |= 0x80
      }
      self.append (byte)
    }while value != 0
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
