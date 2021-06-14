//
//  extension-MergerDocument-importArtworkAction.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension MergerDocument {

  //····················································································································

  func importArtwork () {
    if let window = self.windowForSheet {
      gOpenArtworkInLibrary?.loadDocumentFromLibrary (
        windowForSheet: window,
        alreadyLoadedDocuments: [],
        callBack: { (_ inData : Data, _ inName : String) -> Bool in
          var ok = false
          if let documentData = try? loadEasyBindingFile (fromData: inData, documentName: inName, undoManager: self.ebUndoManager),
             let artworkRoot = documentData.documentRootObject as? ArtworkRoot {
            ok = true
            self.rootObject.mArtwork = artworkRoot
            self.rootObject.mArtworkName = inName
            if let version = documentData.documentMetadataDictionary [PMArtworkVersion] as? Int {
              self.rootObject.mArtworkVersion = version
            }
          }
          return ok
        },
        postAction: {}
      )
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
