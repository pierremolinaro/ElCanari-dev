//
//  open-package-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenPackageInLibrary : OpenInLibrary {

  //····················································································································

  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openPackageInLibrary (_ inSender : Any?) {
    self.openInLibrary ()
  }

  //····················································································································

  override func buildDataSource () {
    self.buildOutlineViewDataSource (extension: "ElCanariPackage", { (_ inRootObject : EBManagedObject?) -> NSImage? in
      let partShape = EBShape ()
      if let root = inRootObject as? PackageRoot {
        for object in root.packageObjects_property.propval {
          if !(object is PackageGuide), !(object is PackageDimension), let shape = object.objectDisplay {
            partShape.append (shape)
          }
        }
      }
      let box = partShape.boundingBox
      return box.isEmpty ? nil : buildPDFimage (frame: box, shape: partShape, backgroundColor: g_Preferences?.packageBackgroundColor)
    })
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return packageLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
