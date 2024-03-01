//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //································································································

  final func addFont (postAction inPostAction : Optional <@MainActor () -> Void>) {
     var currentFontNames = Set <String> ()
     for font in self.rootObject.mFonts.values {
        currentFontNames.insert (font.mFontName)
     }
     gApplicationDelegate?.mOpenFontInLibrary.loadDocumentFromLibrary (
       windowForSheet: self.windowForSheet!,
       alreadyLoadedDocuments: currentFontNames,
       callBack: self.addFontFromLoadFontDialog,
       postAction: inPostAction
     )
  }

  //································································································

  final func addFontFromLoadFontDialog (_ inData : Data, _ inName : String) -> Bool {
    var ok = false
    let documentReadData = loadEasyBindingFile (fromData: inData, documentName: inName, undoManager: nil)
    switch documentReadData {
    case .ok (let documentData) :
      if let version = documentData.documentMetadataDictionary [PMFontVersion] as? Int {
        var propertyDictionary = [String : Any] ()
        documentData.documentRootObject.savePropertiesAndRelationshipsIntoDictionary (&propertyDictionary)
        if let descriptiveString = propertyDictionary [KEY_FOR_FontCharacter_characters] as? String,
           let nominalSize = propertyDictionary ["nominalSize"] as? Int  {
          let addedFont = FontInProject (self.undoManager)
          addedFont.mFontName = inName
          addedFont.mFontVersion = version
          addedFont.mNominalSize = nominalSize
          addedFont.mDescriptiveString = descriptiveString
          self.rootObject.mFonts.append (addedFont)
          ok = true
        }
      }
    case .readError (_) :
      ()
    }
  //---
    if !ok, let window = self.windowForSheet {
      let alert = NSAlert ()
      alert.messageText = "Internal error: cannot add font."
      _ = alert.addButton (withTitle: "Ok")
      alert.beginSheetModal (for: window) { inReturnCode in }
    }
    return ok
  }

  //································································································

  final func updateFonts (_ inFonts : EBReferenceArray <FontInProject>, _ ioMessages : inout [String]) {
    for font in inFonts.values {
      let pathes = fontFilePathInLibraries (font.mFontName)
      if pathes.count == 0 {
        ioMessages.append ("No file for \(font.mFontName) font in Library")
      }else if pathes.count == 1 {
        var ok = false
        if let data = try? Data (contentsOf: URL (fileURLWithPath: pathes [0])) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let version = documentData.documentMetadataDictionary [PMFontVersion] as? Int {
              var propertyDictionary = [String : Any] ()
              documentData.documentRootObject.savePropertiesAndRelationshipsIntoDictionary (&propertyDictionary)
              if let descriptiveString = propertyDictionary [KEY_FOR_FontCharacter_characters] as? String,
                let nominalSize = propertyDictionary ["nominalSize"] as? Int {
                ok = true
                if font.mFontVersion < version {
                  font.mFontVersion = version
                  font.mNominalSize = nominalSize
                  font.mDescriptiveString = descriptiveString
                }
              }
            }
          case .readError (_) :
            ()
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

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
