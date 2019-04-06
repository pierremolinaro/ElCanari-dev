//
//  open-symbol-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var gOpenFontInLibrary : OpenFontInLibrary? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// This class is instancied as object in MainMenu.xib
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenFontInLibrary : OpenInLibrary {

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
    gOpenFontInLibrary = self
  }


  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openFontInLibrary (_ inSender : Any?) {
    super.openDocumentInLibrary (windowTitle: "Open Font in Library")
  }

  //····················································································································

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    self.buildOutlineViewDataSource (extension: "ElCanariFont", alreadyLoadedDocuments: inNames, {
      (_ inRootObject : EBManagedObject?) -> NSImage? in
      return nil // NSImage (named: okStatusImageName)
//      let partShape = EBShape ()
//      if let fontRoot = inRootObject as? FontRoot {
//        for object in fontRoot.symbolObjects_property.propval {
//          if let shape = object.objectDisplay {
//            partShape.append (shape)
//          }
//        }
//      }
//      inRootObject?.removeRecursivelyAllRelationsShips ()
//      let box = partShape.boundingBox
//      return box.isEmpty ? nil : buildPDFimage (frame: box, shape: partShape, backgroundColor: g_Preferences?.symbolBackgroundColor)
    })
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return fontLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
