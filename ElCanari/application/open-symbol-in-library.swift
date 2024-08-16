//
//  open-symbol-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class OpenSymbolInLibrary : OpenInLibrary {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Dialog
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func openSymbolInLibrary (_ inSender : Any?) {
    super.openDocumentInLibrary (windowTitle: "Open Symbol in Library")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    self.buildTableViewDataSource (extension: ElCanariSymbol_EXTENSION, alreadyLoadedDocuments: inNames) { (_ inRootObject : EBManagedObject?) -> NSImage? in
      var partShape = EBShape ()
      if let symbolRoot = inRootObject as? SymbolRoot {
        for object in symbolRoot.symbolObjects.values {
          if let shape = object.objectDisplay {
            partShape.add (shape)
          }
        }
      }
      let box = partShape.boundingBox
      return box.isEmpty
        ? nil
        : buildPDFimage (frame: box, shape: partShape, backgroundColor: preferences_symbolBackgroundColor_property.propval)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func noPartMessage () -> String {
    return "No selected symbol"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return symbolLibraryPathForPath (inPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
