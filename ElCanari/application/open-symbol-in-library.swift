//
//  open-symbol-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// This class is instancied as object in MainMenu.xib
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenSymbolInLibrary : OpenInLibrary {

  //····················································································································

  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openSymbolInLibrary (_ inSender : Any?) {
    super.openDocumentInLibrary (windowTitle: "Open Symbol in Library")
  }

  //····················································································································

  override func buildDataSource () {
    self.buildOutlineViewDataSource (extension: "ElCanariSymbol", { (_ inRootObject : EBManagedObject?) -> NSImage? in
      let partShape = EBShape ()
      if let root = inRootObject as? SymbolRoot {
        for object in root.symbolObjects_property.propval {
          if let shape = object.objectDisplay {
            partShape.append (shape)
          }
        }
      }
      let box = partShape.boundingBox
      return box.isEmpty ? nil : buildPDFimage (frame: box, shape: partShape, backgroundColor: g_Preferences?.symbolBackgroundColor)
    })
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return symbolLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
