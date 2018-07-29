//
//  legacy-artwork.swift
//  canari
//
//  Created by Pierre Molinaro on 09/07/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Ce dictionnaire désigne pour chaque ancienne extension, le type du nouveau document

private let LEGACY_EXTENSION_TO_ELCANARI_TYPE_DICTIONARY : [String : String] = [
  "CanariArtwork" : "El Canari Artwork",
  "CanariFont" : "El Canari Font"
]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Ce dictionnaire désigne pour chaque ancienne extension, le dictonnaire de traduction des objets

private let DICTIONARY_LEGACY_EXTENSION_CLASS_DICTIONARY : [String : [String : String]] = [
  "CanariArtwork" : ARTWORK_LEGACY_ENTITY_NAME_DICTIONARY,
  "CanariFont" : FONT_LEGACY_ENTITY_NAME_DICTIONARY
]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    extension EBManagedObject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBManagedObject {

  //····················································································································
  //   additionalSetUpOnLegacyImport
  //····················································································································

  @objc func additionalSetUpOnLegacyImport (_ objectPropertyDictionary : NSDictionary,
                                      _ legacyImportContext : LegacyImportContext) throws {
    let className = String (describing: type(of: self))
    let dictionary = [
      NSLocalizedDescriptionKey : "Cannot Configure El Canari Document" ,
      NSLocalizedRecoverySuggestionErrorKey : "Class '\(className)' does not override '\(#function)'"
    ]
    throw NSError (
      domain:Bundle.main.bundleIdentifier!,
      code:1,
      userInfo:dictionary
    )
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   extension ApplicationDelegate
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func actionImportLegacyDocument (_ : AnyObject) {
    let openPanel = NSOpenPanel ()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = true
    openPanel.allowedFileTypes = Array (LEGACY_EXTENSION_TO_ELCANARI_TYPE_DICTIONARY.keys)
    openPanel.allowsOtherFileTypes = false
    openPanel.message = "Select legacy documents to convert into ElCanari documents:"
    openPanel.accessoryView = mSaveAccessoryView
    openPanel.begin (completionHandler: { (response : SW34_ApplicationModalResponse) in
      if response == sw34_FileHandlingPanelOKButton {
        let legacyDocumentURLs = openPanel.urls
        self.mConvertLegacyDocumentTextView?.clear()
        self.mConvertLegacyDocumentLogWindow?.makeKeyAndOrderFront (nil)
        do{
          for url in legacyDocumentURLs {
            let legacyDocumentPath = url.path
            try self.convertLegacyDocumentAtPath (legacyDocumentPath)
          }
        }catch let error {
          let alert = NSAlert (error:error)
          alert.beginSheetModal (
            for: self.mConvertLegacyDocumentLogWindow!,
            completionHandler: { (response: SW34_ApplicationModalResponse) in }
          )
        }
      }
    })
  }

  //····················································································································

  func convertLegacyDocumentAtPath (_ path : String) throws {
    self.mConvertLegacyDocumentTextView?.appendMessageString ("Document \(path)\n", color:NSColor.blue)
  //--- Read
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Read...")
    let fileData = try Data (contentsOf: URL(fileURLWithPath: path))
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Ok\n")
  //--- Parse
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Parse...")
    let contents = try parseLegacyFileContents (fileData)
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Ok\n")
  //--- Build object array
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Build dictionary array...")
    var objectDictionaryArray = [NSMutableDictionary] ()
    analyzeLegacyUncompressedData (contents.mUncompressedData, objectArray : &objectDictionaryArray)
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Ok\n")
  //--- Convert
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Convert...")
    let document = try convertLegacyDocumentAtPath (path, legacyFileContents: contents, objectDictionaryArray: objectDictionaryArray)
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Ok\n")
  //--- Save in place
    if mSaveConvertedDocumentInPlaceSwitch?.state != 0 {
      let pathExtension = (path as NSString).pathExtension
      let documentType : String = LEGACY_EXTENSION_TO_ELCANARI_TYPE_DICTIONARY [pathExtension]!
      let elCanariExtension = try extensionFor (documentType)
      let documentFile = (path as NSString).deletingPathExtension + "." + elCanariExtension // ".ElCanariArtwork"
      self.mConvertLegacyDocumentTextView?.appendMessageString ("  Save...")
      RunLoop.main.run (mode: RunLoopMode.defaultRunLoopMode, before: Date ())
      document.save (
        to: URL (fileURLWithPath: documentFile),
        ofType: documentType,
        for: .saveOperation,
        delegate: nil,
        didSave: nil,
        contextInfo: nil
      )
      self.mConvertLegacyDocumentTextView?.appendMessageString ("  Ok\n")
    }
  //--- Done
    self.mConvertLegacyDocumentTextView?.appendMessageString ("  Done\n", color:NSColor.green)
  }

  //····················································································································

  func parseLegacyFileContents (_ fileData : Data) throws -> PMLegacyDocumentContents {
 //---- Define input data scanner
    var dataScanner = EBDataScanner (data:fileData)
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
      options:PropertyListSerialization.MutabilityOptions(),
      format:nil
    ) as! NSDictionary
  //--- Read data
    let dataFormat = dataScanner.parseByte ()
    let compressedData = dataScanner.parseAutosizedData ()
  //--- if ok, check final byte (0)
    dataScanner.acceptRequired (byte: 0)
  //--- Scanner error ?
    if !dataScanner.ok () {
      let dictionary = [
        NSLocalizedDescriptionKey : "Cannot Open Document",
        NSLocalizedRecoverySuggestionErrorKey : "The file has an invalid format"
      ]
      throw NSError (
        domain:Bundle.main.bundleIdentifier!,
        code:1,
        userInfo:dictionary
      )
    }
  //--- Analyze read data
    let uncompressedData : Data
    switch dataFormat {
    case 0x02 :
      uncompressedData = bz2DecompressedData (compressedData as Data?)
    default:
      let dictionary = [
        NSLocalizedDescriptionKey : "Cannot Open Document",
        NSLocalizedRecoverySuggestionErrorKey : "The file has an invalid data format \(dataFormat)"
      ]
      throw NSError (
        domain:Bundle.main.bundleIdentifier!,
        code:1,
        userInfo:dictionary
      )
    }
  //---
    return PMLegacyDocumentContents (
      metadataStatus: metadataStatus,
      metadataDictionary: metadataDictionary,
      uncompressedData: uncompressedData
    )
  }

  //····················································································································

  func convertLegacyDocumentAtPath (_ path : String,
                                    legacyFileContents : PMLegacyDocumentContents,
                                    objectDictionaryArray inObjectDictionaryArray : [NSMutableDictionary]) throws -> EBManagedDocument {
    let document : EBManagedDocument
    #if swift(>=4)
      let dc = NSDocumentController.shared
    #else
      let dc = NSDocumentController.shared ()
    #endif
    let pathExtension = (path as NSString).pathExtension
    let possibleElCanariType = LEGACY_EXTENSION_TO_ELCANARI_TYPE_DICTIONARY [pathExtension]
    let legacyClassDictionary = DICTIONARY_LEGACY_EXTENSION_CLASS_DICTIONARY [pathExtension]!
    if let elCanariType = possibleElCanariType {
      let possibleNewDocument : AnyObject = try dc.makeUntitledDocument (ofType: elCanariType)
      if let elCanariDocument = possibleNewDocument as? EBManagedDocument {
        document = elCanariDocument
        dc.addDocument (elCanariDocument)
        elCanariDocument.incrementVersionNumber ()
        try elCanariDocument.configureFromLegacyData (
          legacyFileContents,
          legacyClassDictionary : legacyClassDictionary,
          managedObjectContext: document.managedObjectContext (),
          objectDictionaryArray: inObjectDictionaryArray
        )
        elCanariDocument.makeWindowControllers ()
        elCanariDocument.showWindows ()
      }else{
        let dictionary = [
          NSLocalizedDescriptionKey : "Cannot Create El Canari Document",
          NSLocalizedRecoverySuggestionErrorKey : "New document is not an instance of EBManagedDocument class"
        ]
        throw NSError (
          domain:Bundle.main.bundleIdentifier!,
          code:1,
          userInfo:dictionary
        )
      }
    }else{
      let dictionary = [
        NSLocalizedDescriptionKey : "Cannot Create El Canari Document",
        NSLocalizedRecoverySuggestionErrorKey : "Unhandled legacy '\(pathExtension)' extension"
      ]
      throw NSError (
        domain:Bundle.main.bundleIdentifier!,
        code:1,
        userInfo:dictionary
      )
    }
    return document
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PMLegacyDocumentContents {
  let mMetadataStatus : UInt8
  let mMetadataDictionary : NSDictionary
  var mUncompressedData : Data
  
  //····················································································································

  init (metadataStatus : UInt8, metadataDictionary : NSDictionary, uncompressedData : Data) {
    mMetadataStatus = metadataStatus
    mMetadataDictionary = metadataDictionary
    mUncompressedData = uncompressedData
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CONFIGURE
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(LegacyImportContext) class LegacyImportContext : NSObject, EBUserClassNameProtocol {
  let mObjectArray : [EBManagedObject]
  let mLegacyObjectDictionaryArray : [NSDictionary]
  let mManagedObjectContext : EBManagedObjectContext

  //····················································································································

  init (objectArray : [EBManagedObject], legacyObjectDictionaryArray : [NSDictionary], managedObjectContext : EBManagedObjectContext) {
    mObjectArray = objectArray
    mLegacyObjectDictionaryArray = legacyObjectDictionaryArray
    mManagedObjectContext = managedObjectContext
    super.init ()
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBManagedDocument {

  //····················································································································

  func configureFromLegacyData (_ legacyFileContents : PMLegacyDocumentContents,
                                legacyClassDictionary : [String : String],
                                managedObjectContext : EBManagedObjectContext,
                                objectDictionaryArray inObjectDictionaryArray : [NSMutableDictionary]) throws {
    undoManager?.disableUndoRegistration ()
  //--- Create objects
    var objectArray = [EBManagedObject] ()
    var obsoleteObjectArray = [EBManagedObject] ()
    try buildNewObjectArray (
      objectDictionaryArray: inObjectDictionaryArray,
      legacyClassDictionary : legacyClassDictionary,
      objectArray : &objectArray,
      obsoleteObjectArray : &obsoleteObjectArray
    )
 //--- Set up objects
    let legacyImportContext = LegacyImportContext (
      objectArray: objectArray,
      legacyObjectDictionaryArray: inObjectDictionaryArray,
      managedObjectContext: managedObjectContext
    )
    var idx = 0
    for d in inObjectDictionaryArray {
      let object : EBManagedObject = objectArray [idx]
      //Swift.print ("\(object.className)")
      object.setUpWithDictionary (d, managedObjectArray:&objectArray)
      if object.className != EBManagedObject.className () {
        try object.additionalSetUpOnLegacyImport (d, legacyImportContext)
      }
      idx += 1
    }
  //--- Remove obsolete objects
    for obsoleteObject in obsoleteObjectArray {
      self.managedObjectContext ().removeManagedObject (obsoleteObject)
    }
  //--- Find root object
    var rootObjectCandidateArray = [EBManagedObject] ()
    for object : EBManagedObject in objectArray {
      let className = String (describing: type(of: object))
      if className == self.rootEntityClassName () {
        rootObjectCandidateArray.append (object)
      }
    }
    if rootObjectCandidateArray.count == 1 { // Ok
    //--- Remove old root object
      if let rootObject = self.mRootObject {
        self.managedObjectContext ().removeManagedObject (rootObject)
      }
    //--- Set root object
      self.mRootObject = rootObjectCandidateArray [0]
    }else{ // Error
      let dictionary = [
        NSLocalizedDescriptionKey : "Cannot Configure El Canari Document" ,
        NSLocalizedRecoverySuggestionErrorKey : "\(rootObjectCandidateArray.count)' root object(s), instead of 1"
      ]
      throw NSError (
        domain:Bundle.main.bundleIdentifier!,
        code:1,
        userInfo:dictionary
      )
    }
    undoManager?.enableUndoRegistration ()
  }

  //····················································································································

  private func buildNewObjectArray (objectDictionaryArray inObjectDictionaryArray : [NSMutableDictionary],
                                    legacyClassDictionary : [String : String],
                                    objectArray : inout [EBManagedObject],
                                    obsoleteObjectArray : inout [EBManagedObject]) throws {
    objectArray = [EBManagedObject] ()
    obsoleteObjectArray = [EBManagedObject] ()
    for d in inObjectDictionaryArray {
      let legacyClassName = d.object (forKey: kEntityKey) as! String
//      NSLog ("legacyClassName [\(legacyClassName)]")
//      NSLog ("\(legacyClassDictionary)")
      let elCanariPossibleClassName : String? = legacyClassDictionary [legacyClassName]
      if let elCanariClassName = elCanariPossibleClassName {
        if elCanariClassName != "" {
          let newObject = try self.managedObjectContext ().newInstanceOfEntityNamed (inEntityTypeName: elCanariClassName)
          objectArray.append (newObject)
        }else{
          //    NSLog ("unhandled className \(className)")
          let object = EBManagedObject (managedObjectContext: self.managedObjectContext ())
          obsoleteObjectArray.append (object)
          objectArray.append (object)
        }
      }else{
        let dictionary = [
          NSLocalizedDescriptionKey : "Cannot Configure El Canari Document" ,
          NSLocalizedRecoverySuggestionErrorKey : "Legacy class '\(legacyClassName)' unknown"
        ]
        throw NSError (
          domain:Bundle.main.bundleIdentifier!,
          code:1,
          userInfo:dictionary
        )
      }
    }
  }
  

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func extensionFor (_ documentType : String) throws -> String {
  let possibleInfoPLIST : [String : Any]? = Bundle.main.infoDictionary
  if let infoPLIST = possibleInfoPLIST {
    let possibleDocumentDescriptionArray =  infoPLIST ["CFBundleDocumentTypes"]
    if let documentDescriptionArray = possibleDocumentDescriptionArray as? [NSDictionary] {
      for doc : NSDictionary in documentDescriptionArray {
        if let documentType = doc ["CFBundleTypeName"] as? String, documentType == documentType {
          if let extensionArray = doc ["CFBundleTypeExtensions"] as? [String], extensionArray.count > 0 {
            return extensionArray [0]
          }
        }
      }
    }
  }
  let dictionary = [
    NSLocalizedDescriptionKey : "Cannot Save El Canari Document" ,
    NSLocalizedRecoverySuggestionErrorKey : "Cannot find a file extension for type '\(documentType)'"
  ]
  throw NSError (
    domain:Bundle.main.bundleIdentifier!,
    code:1,
    userInfo:dictionary
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

