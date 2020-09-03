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

  internal func addFontFromLoadFontDialog (_ inData : Data, _ inName : String) {
    if let documentRootObjectDictionary = try? loadEasyRootObjectDictionary (from: inData),
       let version = documentRootObjectDictionary [PMFontVersion] as? Int,
       let nominalSize = documentRootObjectDictionary ["nominalSize"] as? Int,
       let descriptiveString = documentRootObjectDictionary [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String {
      let addedFont = FontInProject (self.ebUndoManager)
      addedFont.mFontName = inName
      addedFont.mFontVersion = version
      addedFont.mNominalSize = nominalSize
      addedFont.mDescriptiveString = descriptiveString
      self.rootObject.mFonts.append (addedFont)
    }
  }

  //····················································································································

  internal func updateFonts (_ inFonts : [FontInProject], _ ioMessages : inout [String]) {
    for font in inFonts {
      let pathes = fontFilePathInLibraries (font.mFontName)
      if pathes.count == 0 {
        ioMessages.append ("No file for \(font.mFontName) font in Library")
      }else if pathes.count == 1 {
        if let data = try? Data (contentsOf: URL (fileURLWithPath: pathes [0])),
           let documentRootObjectDictionary = try? loadEasyRootObjectDictionary (from: data),
           let version = documentRootObjectDictionary [PMFontVersion] as? Int,
           let nominalSize = documentRootObjectDictionary ["nominalSize"] as? Int,
           let descriptiveString = documentRootObjectDictionary [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String {
          if font.mFontVersion < version {
            font.mFontVersion = version
            font.mNominalSize = nominalSize
            font.mDescriptiveString = descriptiveString
          }
         }else{
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
