//
//  open-package-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var gOpenPackageInLibrary : OpenPackageInLibrary? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// This class is instancied as object in MainMenu.xib
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenPackageInLibrary : OpenInLibrary {

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
    gOpenPackageInLibrary = self
  }

  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openPackageInLibrary (_ inSender : Any?) {
    self.openDocumentInLibrary (windowTitle: "Open Package in Library")
  }

  //····················································································································

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    super.buildOutlineViewDataSource (extension: "ElCanariPackage", alreadyLoadedDocuments: inNames) { (_ inRootObject : EBManagedObject?) -> NSImage? in
      var partShape = EBShape ()
      if let packageRoot = inRootObject as? PackageRoot {
        for object in packageRoot.packageObjects_property.propval {
          if !(object is PackageGuide), !(object is PackageDimension), let shape = object.objectDisplay {
            partShape.add (shape)
          }
        }
      }
      inRootObject?.removeRecursivelyAllRelationsShips ()
      let box = partShape.boundingBox
      return box.isEmpty ? nil : buildPDFimage (frame: box, shape: partShape, backgroundColor: g_Preferences?.packageBackgroundColor)
    }
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return packageLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
