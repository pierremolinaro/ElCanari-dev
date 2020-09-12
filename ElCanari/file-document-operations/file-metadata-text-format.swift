//----------------------------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

func getTextFileMetadata (forFileHandle inFileHandle : FileHandle) -> EBFileMetadata? {
//--- Rewind
  inFileHandle.seek (toFileOffset: 0)
//--- Read format string
  let formatStringData : Data = inFileHandle.readData (ofLength: PM_TEXTUAL_FORMAT_SIGNATURE.utf8.count)
  if formatStringData.count != PM_TEXTUAL_FORMAT_SIGNATURE.utf8.count {
    return nil
  }else{
    let signatureData = PM_TEXTUAL_FORMAT_SIGNATURE.data (using: String.Encoding.utf8)
    if signatureData! != formatStringData {
      return nil
    }
  }
//--- Pass new line
  if inFileHandle.readByte () != ASCII.lineFeed.rawValue {
    return nil
  }
//--- Read status
  let status : MetadataStatus
  if let s = MetadataStatus (rawValue: inFileHandle.readBase62IntAndLineFeed ()) {
    status = s
  }else{
    return nil
  }
//--- Read metadata dictionary
  let dictionaryData : Data = inFileHandle.readLine ()
  if let possibleDictionary : Any = try? JSONSerialization.jsonObject (with: dictionaryData),
     let dict = possibleDictionary as? [String : Any] {
    return EBFileMetadata (metadataStatus: status, metadataDictionary: dict)
  }else{
    return nil
  }
}

//----------------------------------------------------------------------------------------------------------------------

extension FileHandle {

  //····················································································································

  fileprivate func readBase62IntAndLineFeed () -> Int {
    var sign = 1
    var c = self.readByte ()
    if c == ASCII.minus.rawValue {
      sign = -1
      c = self.readByte ()
    }
    var r = 0
    var loop = true
    while loop && (c != ASCII.lineFeed.rawValue) {
      if (c >= ASCII.zero.rawValue) && (c <= ASCII.nine.rawValue) {
        r *= 62
        r += Int (c - ASCII.zero.rawValue)
        c = self.readByte ()
      }else if (c >= ASCII.A.rawValue) && (c <= ASCII.Z.rawValue) {
        r *= 62
        r += Int (c - ASCII.A.rawValue) + 10
        c = self.readByte ()
      }else if (c >= ASCII.a.rawValue) && (c <= ASCII.z.rawValue) {
        r *= 62
        r += Int (c - ASCII.a.rawValue) + 10 + 26
        c = self.readByte ()
      }else{
        loop = false
      }
    }
    return sign * r
  }

  //····················································································································

  fileprivate func readLine () -> Data {
    var data = Data ()
    var loop = true
    while loop {
      let c = self.readByte ()
      loop = c != ASCII.lineFeed.rawValue
      if loop {
        data.append (c)
      }
    }
    return data
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------