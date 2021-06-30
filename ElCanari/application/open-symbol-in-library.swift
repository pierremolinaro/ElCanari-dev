//
//  open-symbol-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var gOpenSymbolInLibrary : OpenSymbolInLibrary? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// This class is instancied as object in MainMenu.xib
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class OpenSymbolInLibrary : OpenInLibrary {

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
    gOpenSymbolInLibrary = self
  }


  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openSymbolInLibrary (_ inSender : Any?) {
    super.openDocumentInLibrary (windowTitle: "Open Symbol in Library")
  }

  //····················································································································

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    self.buildTableViewDataSource (extension: "ElCanariSymbol", alreadyLoadedDocuments: inNames) { (_ inRootObject : EBManagedObject?) -> NSImage? in
      var partShape = EBShape ()
      if let symbolRoot = inRootObject as? SymbolRoot {
        for object in symbolRoot.symbolObjects {
          if let shape = object.objectDisplay {
            partShape.add (shape)
          }
        }
      }
      inRootObject?.removeRecursivelyAllRelationsShips ()
      let box = partShape.boundingBox
      return box.isEmpty ? nil : buildPDFimage (frame: box, shape: partShape, backgroundColor: preferences_symbolBackgroundColor)
    }
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return symbolLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
