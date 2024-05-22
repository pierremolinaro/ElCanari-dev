//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func loadEasyBindingTextFile (_ inUndoManager : UndoManager?,
                                         documentName inDocumentName : String,
                                         from ioDataScanner: inout EBDataScanner) -> EBDocumentReadData {
  setStartOperationDateToNow ("Read Text Document file: \(inDocumentName)")
  do{
  //--- Check header ends with line feed
    ioDataScanner.acceptRequired (byte: ASCII.lineFeed.rawValue)
  //--- Read Status
    let metadataStatus = UInt8 (ioDataScanner.parseBase62EncodedInt ())
  //--- Read metadata dictionary
    let metadataDictionary : [String : Any] = try ioDataScanner.parseJSON ()
  //--- Read classes
    var classDefinition = [(String, [String])] ()
    while ioDataScanner.testAccept (byte: ASCII.dollar.rawValue) {
      let className = try ioDataScanner.parseString ()
      var readPropertyNames = true
      var propertyNameArray = [String] ()
      while readPropertyNames, ioDataScanner.ok () {
        if ioDataScanner.test (byte: ASCII.dollar.rawValue) {
          readPropertyNames = false
        }else if ioDataScanner.test (byte: ASCII.at.rawValue) {
          readPropertyNames = false
        }else{
          let propertyName = try ioDataScanner.parseString ()
          propertyNameArray.append (propertyName)
        }
      }
      classDefinition.append ((className, propertyNameArray))
    }
    appendDocumentFileOperationInfo ("read \(classDefinition.count) classes done")
  //--- Read objects
    var rawObjectArray = [RawObject] ()
    let scannerData = ioDataScanner.data
    while !ioDataScanner.eof (), ioDataScanner.testAccept (byte: ASCII.at.rawValue) {
      let classIndex = ioDataScanner.parseBase62EncodedInt ()
      let propertyNameArray = classDefinition [classIndex].1
      let className = classDefinition [classIndex].0
      var propertyValueDictionary = [String : NSRange] ()
      for propertyName in propertyNameArray {
        let propertyRange = ioDataScanner.getLineRangeAndAdvance ()
        propertyValueDictionary [propertyName] = propertyRange
      }
      let managedObject = newInstanceOfEntityNamed (inUndoManager, className)
      let rawObject = RawObject (object: managedObject, propertyDictionary: propertyValueDictionary)
      rawObjectArray.append (rawObject)
    }
    appendDocumentFileOperationInfo ("parsed \(rawObjectArray.count) objects done")
  //--- Setup atomic properties, relationships
    for rawObject in rawObjectArray.reversed () {
      let valueDictionary = rawObject.propertyDictionary
      let managedObject = rawObject.object
      managedObject.setUpPropertiesWithTextDictionary (valueDictionary, rawObjectArray, scannerData)
    }
    appendDocumentFileOperationInfo ("setup done")
  //--- Scanner error ?
    if !ioDataScanner.ok () {
      let dictionary = [
        "Cannot Open Document" : NSLocalizedDescriptionKey,
        "The file has an invalid format" : NSLocalizedRecoverySuggestionErrorKey
      ]
      throw NSError (domain: Bundle.main.bundleIdentifier!, code: 1, userInfo: dictionary)
    }
  //--- Analyze read data
    if ioDataScanner.ok (), rawObjectArray.count > 0 {
      let rootObject = rawObjectArray [0].object
      let documentData = EBDocumentData (
        documentMetadataStatus: metadataStatus,
        documentMetadataDictionary: metadataDictionary,
        documentRootObject: rootObject,
        documentFileFormat: .textual
      )
      return .ok (documentData: documentData)
    }else{
      let dictionary = [
        "Cannot Open Document" :  NSLocalizedDescriptionKey,
        "Root object cannot be read" :  NSLocalizedRecoverySuggestionErrorKey
      ]
      throw NSError (domain: Bundle.main.bundleIdentifier!, code: 1, userInfo: dictionary)
    }
  }catch{
    return .readError (error: error)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func dataForTextualSaveOperation (from inDocumentData : EBDocumentData) throws -> Data {
//--- First line: PM-TEXT-FORMAT
  var fileStringData = Data ()
  fileStringData.append (ascii: .P)
  fileStringData.append (ascii: .M)
  fileStringData.append (ascii: .minus)
  fileStringData.append (ascii: .T)
  fileStringData.append (ascii: .E)
  fileStringData.append (ascii: .X)
  fileStringData.append (ascii: .T)
  fileStringData.append (ascii: .minus)
  fileStringData.append (ascii: .F)
  fileStringData.append (ascii: .O)
  fileStringData.append (ascii: .R)
  fileStringData.append (ascii: .M)
  fileStringData.append (ascii: .A)
  fileStringData.append (ascii: .T)
  fileStringData.append (ascii: .lineFeed)
//--- Append status
  fileStringData.append (base62Encoded: Int (inDocumentData.documentMetadataStatus))
  fileStringData.append (ascii: .lineFeed)
//--- Append metadata dictionary
  let textMetaData = try JSONSerialization.data (withJSONObject: inDocumentData.documentMetadataDictionary, options: .sortedKeys)
  fileStringData += textMetaData
  fileStringData.append (ascii: .lineFeed)
//--- Build class index dictionary
  let objectArray = collectAndPrepareObjectsForSaveOperation (fromRoot: inDocumentData.documentRootObject)
  var classDictionary = [String : Int] ()
  var classDescriptionString = ""
  for object in objectArray {
    let key = String (describing: type (of: object))
    if classDictionary [key] == nil {
      classDictionary [key] = classDictionary.count
      classDescriptionString += "$" + key + "\n"
      object.appendPropertyNamesTo (string: &classDescriptionString)
    }
  }
  fileStringData += classDescriptionString.data (using: .utf8)!
//--- Save data
  for object in objectArray {
    let key = String (describing: type (of: object as Any))
    let classIndex = classDictionary [key]!
  //  Swift.print ("\(classIndex)")
    fileStringData.append (ascii: .at)
    fileStringData.append (base62Encoded: classIndex)
    fileStringData.append (ascii: .lineFeed)
    object.appendPropertyValuesTo (data: &fileStringData)
  }
//---
//   Swift.print ("Text Saving \(Int (Date ().timeIntervalSince (start) * 1000.0)) ms")
  return fileStringData
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
