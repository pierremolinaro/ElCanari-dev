//
//  analyze-document.swift
//  eb-document-analyzer
//
//  Created by Pierre Molinaro on 08/07/2015.
//  Copyright © 2015 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let kFormatSignature = "PM-BINARY-FORMAT"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func analyze (_ inFilePath : String, textView : NSTextView) throws {
//--- Read data
  let fileData = try Data (contentsOf: URL(fileURLWithPath: inFilePath), options: NSData.ReadingOptions.mappedIfSafe)
//---- Show window
  textView.window?.title = (inFilePath as NSString).lastPathComponent
  textView.window?.makeKeyAndOrderFront (nil)
//---- Clear result
  textView.string = ""
  textView.appendMessageString ("File: \(inFilePath)\n")
  textView.appendMessageString ("Size: \(fileData.count) bytes\n")
  textView.appendMessageString ("------------------------------ File contents\n")
//---- Define input data scanner
  var dataScanner = DataScanner (data:fileData, textView:textView)
//--- Check Signature
  for c in kFormatSignature.utf8 {
    dataScanner.acceptRequiredByte (c, comment:"Magic tag")
  }
//--- Read Status
  dataScanner.printAddress ()
  let meadMetadataStatus = dataScanner.parseByte ()
  textView.appendByte (meadMetadataStatus)
  textView.appendMessageString (" | Status\n")
//--- if ok, check byte is 1
  dataScanner.acceptRequiredByte (1, comment:"Required byte")
//--- Read metadata dictionary
  let dictionaryData = dataScanner.parseAutosizedData ("Metadata dictionary length", dataComment:"Metadata dictionary")
//--- Read data format
  dataScanner.printAddress ()
  let dataFormat = dataScanner.parseByte ()
  textView.appendByte (dataFormat)
  switch dataFormat {
  case 2 :
    textView.appendMessageString (" | Legacy BZ2-compressed format\n")
  case 6 :
    textView.appendMessageString (" | Array of dictionaries format\n")
  default:
    textView.appendErrorString (" | Unknown data format\n")
  }
//--- Read data
  let data = dataScanner.parseAutosizedData ("Encoded data length", dataComment:"Encoded data")
//--- if ok, check final byte (0)
  dataScanner.acceptRequiredByte (0, comment:"End of file")
//--- Display metadata dictionary
  textView.appendMessageString ("------------------------------ Metadata dictionary\n")
  let metadataDictionary = try PropertyListSerialization.propertyList (from: dictionaryData,
    options:PropertyListSerialization.MutabilityOptions(),
    format:nil
  ) as! NSDictionary
  textView.appendMessageString (String (format:"%@\n", metadataDictionary))
//--- Display data
  switch dataFormat {
  case 6 :
    textView.appendMessageString ("------------------------------ Data in array of dictionaries format\n")
    let dataArray = try PropertyListSerialization.propertyList (from: data,
      options:PropertyListSerialization.MutabilityOptions(),
      format:nil
    ) as! NSArray
    textView.appendMessageString (String (format:"%@\n", dataArray))
  default:
    analyzeLegacyBZ2Data (data, textView:textView)
    break
  }
//--- END
  textView.appendMessageString ("------------------------------ Analysis completed\n")
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
