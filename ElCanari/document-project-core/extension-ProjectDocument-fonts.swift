//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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
    if let (_, metadataDictionary, rootObjectDictionary) = try? loadEasyRootObjectDictionary (from: inData),
       let version = metadataDictionary [PMFontVersion] as? Int,
       let rod = rootObjectDictionary,
       let nominalSize = rod ["nominalSize"] as? Int,
       let descriptiveString = rod [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String {
      let addedFont = FontInProject (self.ebUndoManager)
      addedFont.mFontName = inName
      addedFont.mFontVersion = version
      addedFont.mNominalSize = nominalSize
      addedFont.mDescriptiveString = descriptiveString
      self.rootObject.mFonts.append (addedFont)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
