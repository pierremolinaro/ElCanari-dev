//
//  extension-MergerDocument-importArtworkAction.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  func importArtwork () {
    if let window = self.windowForSheet {
      openArtworkPanelInLibrary (
        windowForSheet: window,
        validationButtonTitle: "Import",
        callBack: { (_ inURL : URL, _ inName : String) -> Void in
          if let data = try? Data (contentsOf: inURL),
             let documentData = try? loadEasyBindingFile (fromData: data, documentName: inName, undoManager: self.ebUndoManager),
             let artworkRoot = documentData.documentRootObject as? ArtworkRoot {
            self.rootObject.mArtwork = artworkRoot
            self.rootObject.mArtworkName = inName
            if let version = documentData.documentMetadataDictionary [PMArtworkVersion] as? Int {
              self.rootObject.mArtworkVersion = version
            }
          }
        }
      )
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
