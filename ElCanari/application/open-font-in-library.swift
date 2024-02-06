//
//  open-symbol-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————


final class OpenFontInLibrary : OpenInLibrary {

  //····················································································································
  //   Dialog
  //····················································································································

  @objc func openFontInLibrary (_ inSender : Any?) {
    super.openDocumentInLibrary (windowTitle: "Open Font in Library")
  }

  //····················································································································

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    self.buildTableViewDataSource (extension: ElCanariFont_EXTENSION, alreadyLoadedDocuments: inNames, {
      (_ inRootObject : EBManagedObject?) -> NSImage? in
      return nil // NSImage (named: okStatusImageName)
    })
  }

  //····················································································································

  override func noPartMessage () -> String {
    return "No selected font"
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return fontLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
