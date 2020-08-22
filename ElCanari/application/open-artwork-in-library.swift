//
//  open-artwork-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/07/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

var gOpenArtworkInLibrary : OpenArtworkInLibrary? = nil

//----------------------------------------------------------------------------------------------------------------------
// This class is instancied as object in MainMenu.xib
//----------------------------------------------------------------------------------------------------------------------

class OpenArtworkInLibrary : OpenInLibrary {

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
    gOpenArtworkInLibrary = self
  }


  //····················································································································
  //   Dialog
  //····················································································································

  @IBAction func openArtworkInLibrary (_ inSender : Any?) {
    super.openDocumentInLibrary (windowTitle: "Open Artwork in Library")
  }

  //····················································································································

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    self.buildTableViewDataSource (extension: "ElCanariArtwork", alreadyLoadedDocuments: inNames, {
      (_ inRootObject : EBManagedObject?) -> NSImage? in
      return nil // NSImage (named: okStatusImageName)
    })
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return artworkLibraryPathForPath (inPath)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
