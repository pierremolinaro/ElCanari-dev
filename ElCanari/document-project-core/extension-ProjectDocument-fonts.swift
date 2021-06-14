//
//  Created by Pierre Molinaro on 01/03/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension ProjectDocument {

  //····················································································································

  internal func addFont (postAction: Optional <() -> Void>) {
     var currentFontNames = Set <String> ()
     for font in self.rootObject.mFonts {
        currentFontNames.insert (font.mFontName)
     }
     gOpenFontInLibrary?.loadDocumentFromLibrary (
       windowForSheet: self.windowForSheet!,
       alreadyLoadedDocuments: currentFontNames,
       callBack: self.addFontFromLoadFontDialog,
       postAction: postAction
     )
  }

  //····················································································································

  internal func addFontFromLoadFontDialog (_ inData : Data, _ inName : String) -> Bool {
    var ok = false
    if let documentData : EBDocumentData = try? loadEasyBindingFile (fromData: inData, documentName: inName, undoManager: nil),
       let version = documentData.documentMetadataDictionary [PMFontVersion] as? Int {
      let propertyDictionary = NSMutableDictionary ()
      documentData.documentRootObject.saveIntoDictionary (propertyDictionary)
      if let descriptiveString = propertyDictionary [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String,
         let nominalSize = propertyDictionary ["nominalSize"] as? Int  {
        let addedFont = FontInProject (self.ebUndoManager)
        addedFont.mFontName = inName
        addedFont.mFontVersion = version
        addedFont.mNominalSize = nominalSize
        addedFont.mDescriptiveString = descriptiveString
        self.rootObject.mFonts.append (addedFont)
        ok = true
      }
    }
    if !ok, let window = self.windowForSheet {
      let alert = NSAlert ()
      alert.messageText = "Internal error: cannot add font."
      alert.addButton (withTitle: "Ok")
      alert.beginSheetModal (for: window) { inReturnCode in }
    }
    return ok
  }

  //····················································································································

  internal func updateFonts (_ inFonts : [FontInProject], _ ioMessages : inout [String]) {
    for font in inFonts {
      let pathes = fontFilePathInLibraries (font.mFontName)
      if pathes.count == 0 {
        ioMessages.append ("No file for \(font.mFontName) font in Library")
      }else if pathes.count == 1 {
        var ok = false
        if let data = try? Data (contentsOf: URL (fileURLWithPath: pathes [0])),
           let documentData : EBDocumentData = try? loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil),
           let version = documentData.documentMetadataDictionary [PMFontVersion] as? Int {
          let propertyDictionary = NSMutableDictionary ()
          documentData.documentRootObject.saveIntoDictionary (propertyDictionary)
          if let descriptiveString = propertyDictionary [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String,
            let nominalSize = propertyDictionary ["nominalSize"] as? Int  {
            ok = true
            if font.mFontVersion < version {
              font.mFontVersion = version
              font.mNominalSize = nominalSize
              font.mDescriptiveString = descriptiveString
            }
          }
        }
        if !ok {
          ioMessages.append ("Cannot read \(pathes [0]) file.")
        }
      }else{ // pathes.count > 1
        ioMessages.append ("Several files for \(font.mFontName) font in Library:")
        for path in pathes {
          ioMessages.append ("  - \(path)")
        }
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
