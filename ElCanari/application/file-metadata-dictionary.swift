//
//  check-libraries.swift
//  canari
//
//  Created by Pierre Molinaro on 30/06/2015.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func canariError (_ message : String, informativeText: String) -> Error {
  let dictionary : [String : String] = [
    NSLocalizedDescriptionKey : message,
    NSLocalizedRecoverySuggestionErrorKey : informativeText,
  ]
  return NSError (
    domain: Bundle.main.bundleIdentifier!,
    code: 1,
    userInfo: dictionary
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func badFormatErrorForFileAtPath (_ inFilePath : String, code : Int) -> Error {
  return canariError (
    "Cannot read '\(inFilePath)' file",
    informativeText: "File does not have the required format (code: \(code))."
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func readByte (_ inFileHandle : FileHandle) -> UInt8 {
  let statusData : Data = inFileHandle.readData (ofLength: 1)
  return statusData [0]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func readAutosizedUnsignedInteger (_ inFileHandle : FileHandle) -> UInt {
  var result : UInt = 0
  var shift : UInt = 0
  var done = false
  repeat{
    let byte : UInt = UInt (readByte (inFileHandle))
    let w = byte & 0x7F
    result |= w << shift
    shift += 7
    done = (byte & 0x80) == 0
  }while !done
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func readAutosizedData (_ inFileHandle : FileHandle) -> Data {
  let dataLength = readAutosizedUnsignedInteger (inFileHandle)
  return inFileHandle.readData (ofLength: Int (dataLength))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func metadataForFileAtPath (_ inFilePath : String) throws -> (MetadataStatus, NSDictionary) {
//--- Open file
  let f = try FileHandle (forReadingFrom: (URL (fileURLWithPath: inFilePath)))
//--- Read format string
  let formatStringData : Data = f.readData (ofLength: kFormatSignature.utf8.count)
  if formatStringData.count != kFormatSignature.utf8.count {
    f.closeFile ()
    throw badFormatErrorForFileAtPath (inFilePath, code:#line)
  }else{
    let signatureData = kFormatSignature.data (using: String.Encoding.utf8)
    if signatureData! != formatStringData {
      f.closeFile ()
      throw badFormatErrorForFileAtPath (inFilePath, code:#line)
    }
  }
//--- Read status
  let status : MetadataStatus
  if let s = MetadataStatus (rawValue: Int (readByte (f))) {
    status = s
  }else{
    status = .unknown
    f.closeFile ()
    throw badFormatErrorForFileAtPath (inFilePath, code:#line)
  }
//--- Check byte is 1
  let byte : UInt8 = readByte (f)
  if byte != 1 {
    f.closeFile ()
    throw badFormatErrorForFileAtPath (inFilePath, code:#line)
  }
//--- Read metadata dictionary
  let dictionaryData : Data = readAutosizedData (f)
  let possibleDictionary : Any = try PropertyListSerialization.propertyList (
    from: dictionaryData,
    options:PropertyListSerialization.MutabilityOptions(),
    format:nil
  )
  let metadataDictionary : NSDictionary
  if let dict = possibleDictionary as? NSDictionary {
    metadataDictionary = dict
  }else{
    f.closeFile ()
    throw badFormatErrorForFileAtPath (inFilePath, code:#line)
  }
//---
  f.closeFile ()
//---
  return (status, metadataDictionary)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
