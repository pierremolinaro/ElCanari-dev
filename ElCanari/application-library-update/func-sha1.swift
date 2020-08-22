//
//  sha1.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Foundation

//----------------------------------------------------------------------------------------------------------------------
//  Computing SHA1 of Data
//----------------------------------------------------------------------------------------------------------------------

func sha1 (_ inData : Data) -> String {
  let transform = SecDigestTransformCreate (kSecDigestSHA1, 0, nil)
  SecTransformSetAttribute (transform, kSecTransformInputAttributeName, inData as CFTypeRef, nil)
  let shaValue = SecTransformExecute (transform, nil) as! Data
  var s = ""
  for byte in shaValue {
    s += "\(String (byte, radix:16, uppercase: false))"
  }
  return s
}

//----------------------------------------------------------------------------------------------------------------------
//  Computing SHA1 of a library file
//----------------------------------------------------------------------------------------------------------------------

func computeFileSHA (_ filePath : String) -> String? {
  let absoluteFilePath = systemLibraryPath () + "/" + filePath
  var result : String? = nil
  do{
    let data = try Data (contentsOf: URL (fileURLWithPath: absoluteFilePath))
    result = sha1 (data)
  }catch _ {
  }
  return result
}

//----------------------------------------------------------------------------------------------------------------------
