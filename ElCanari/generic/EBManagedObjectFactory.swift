//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  newInstanceOfEntityNamed
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func newInstanceOfEntityNamed (_ undoManager : EBUndoManager?, _ inEntityTypeName : String) throws -> EBManagedObject {
  var result : EBManagedObject
  if inEntityTypeName == "FontCharacter" {
    result = FontCharacter (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SegmentForFontCharacter" {
    result = SegmentForFontCharacter (undoManager, file: #file, #line)
  }else if inEntityTypeName == "FontRoot" {
    result = FontRoot (undoManager, file: #file, #line)
  }else if inEntityTypeName == "ArtworkRoot" {
    result = ArtworkRoot (undoManager, file: #file, #line)
  }else if inEntityTypeName == "ArtworkFileGenerationParameters" {
    result = ArtworkFileGenerationParameters (undoManager, file: #file, #line)
  }else if inEntityTypeName == "BoardModelPad" {
    result = BoardModelPad (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SegmentEntity" {
    result = SegmentEntity (undoManager, file: #file, #line)
  }else if inEntityTypeName == "BoardModelVia" {
    result = BoardModelVia (undoManager, file: #file, #line)
  }else if inEntityTypeName == "BoardModel" {
    result = BoardModel (undoManager, file: #file, #line)
  }else if inEntityTypeName == "MergerBoardInstance" {
    result = MergerBoardInstance (undoManager, file: #file, #line)
  }else if inEntityTypeName == "MergerRoot" {
    result = MergerRoot (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolObject" {
    result = SymbolObject (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolPin" {
    result = SymbolPin (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolText" {
    result = SymbolText (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolSolidRect" {
    result = SymbolSolidRect (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolOval" {
    result = SymbolOval (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolSolidOval" {
    result = SymbolSolidOval (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolBezierCurve" {
    result = SymbolBezierCurve (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolSegment" {
    result = SymbolSegment (undoManager, file: #file, #line)
  }else if inEntityTypeName == "SymbolRoot" {
    result = SymbolRoot (undoManager, file: #file, #line)
  }else{
       let dictionary : [String : Any] = [
      NSLocalizedDescriptionKey : "Cannot read document",
      NSLocalizedRecoverySuggestionErrorKey : "Cannot create object of \(inEntityTypeName) class",
    ]
    throw NSError (
      domain:Bundle.main.bundleIdentifier!,
      code:1,
      userInfo:dictionary
    )
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   makeManagedObjectFromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func makeManagedObjectFromDictionary (_ inUndoManager : EBUndoManager, _ inDictionary : NSDictionary) throws -> EBManagedObject {
  let entityName = inDictionary.value (forKey: kEntityKey) as! String
  let object = try newInstanceOfEntityNamed (inUndoManager, entityName)
  inUndoManager.disableUndoRegistration ()
  object.setUpAtomicPropertiesWithDictionary (inDictionary) 
  inUndoManager.enableUndoRegistration ()
  return object
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//     loadEasyBindingFile
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func loadEasyBindingFile (_ inUndoManager : EBUndoManager, from data: Data) throws -> (UInt8, NSDictionary, EBManagedObject?) {
//---- Define input data scanner
  var dataScanner = EBDataScanner (data:data)
//--- Check Signature
  for c in kFormatSignature.utf8 {
    dataScanner.acceptRequired (byte: c)
  }
//--- Read Status
  let metadataStatus = dataScanner.parseByte ()
//--- if ok, check byte is 1
  dataScanner.acceptRequired (byte: 1)
//--- Read metadata dictionary
  let dictionaryData = dataScanner.parseAutosizedData ()
  let metadataDictionary = try PropertyListSerialization.propertyList (from: dictionaryData as Data,
    options:[],
    format:nil
  ) as! NSDictionary
//  let metadataDictionary = metadataDictionary.mutableCopy () as! NSMutableDictionary
//--- Read data
  let dataFormat = dataScanner.parseByte ()
  let fileData = dataScanner.parseAutosizedData ()
//--- if ok, check final byte (0)
  dataScanner.acceptRequired (byte: 0)
//--- Scanner error ?
  if !dataScanner.ok () {
    let dictionary = [
      "Cannot Open Document" :  NSLocalizedDescriptionKey,
      "The file has an invalid format" :  NSLocalizedRecoverySuggestionErrorKey
    ]
    throw NSError (
      domain:Bundle.main.bundleIdentifier!,
      code:1,
      userInfo:dictionary
    )
  }
//--- Analyze read data
  var rootObject : EBManagedObject? = nil
  if dataFormat == 0x06 {
    rootObject = try readManagedObjectsFromData (inUndoManager, inData: fileData)
  }else{
    try raiseInvalidDataFormatArror (dataFormat: dataFormat)
  }
//---
  if rootObject == nil {
    let dictionary = [
      "Cannot Open Document" :  NSLocalizedDescriptionKey,
      "Root object cannot be read" :  NSLocalizedRecoverySuggestionErrorKey
    ]
    throw NSError (
      domain:Bundle.main.bundleIdentifier!,
      code:1,
      userInfo:dictionary
    )
  }
//---
  return (metadataStatus, metadataDictionary, rootObject)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func readManagedObjectsFromData (_ inUndoManager : EBUndoManager, inData : Data) throws -> EBManagedObject? {
  var resultRootObject : EBManagedObject? = nil
  let v : Any = try PropertyListSerialization.propertyList (from: inData as Data,
    options:[],
    format:nil
  )
  let dictionaryArray : [NSDictionary] = v as! [NSDictionary]
  let semaphore : DispatchSemaphore = DispatchSemaphore (value: 0)
  let queue = DispatchQueue (label: "readObjectFromData")
  var possibleError : NSError? = nil
  queue.asyncAfter (deadline: .now (), execute: {
    do{
      var objectArray = [EBManagedObject] ()
      for d in dictionaryArray {
        let className = d.object (forKey: kEntityKey) as! String
        let object = try newInstanceOfEntityNamed (inUndoManager, className)
        objectArray.append (object)
      }
      var idx = 0
      for d in dictionaryArray {
        let object : EBManagedObject = objectArray [idx]
        object.setUpWithDictionary (d, managedObjectArray: &objectArray)
        idx += 1
      }
    //--- Set root object
      resultRootObject = objectArray [0]
      semaphore.signal()
    }catch let error as NSError {
      possibleError = error
      semaphore.signal()
   }
  })
  semaphore.wait()
  if let error = possibleError {
    throw error
  }
  return resultRootObject
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func raiseInvalidDataFormatArror (dataFormat : UInt8) throws {
  let dictionary = [
    "Cannot Open Document" :  NSLocalizedDescriptionKey,
    "Unkown data format: \(dataFormat)" :  NSLocalizedRecoverySuggestionErrorKey
  ]
  throw NSError (
    domain:Bundle.main.bundleIdentifier!,
    code:1,
    userInfo:dictionary
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
