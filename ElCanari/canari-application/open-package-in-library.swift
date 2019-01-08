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
    self.openInLibrary (backColor: g_Preferences!.packageBackgroundColor)
  }

  //····················································································································

  override func buildDataSource () {
    self.buildOutlineViewDataSource (extension: "ElCanariPackage", { (_ inRootObject : EBManagedObject?) -> [EBShape] in
      if let symbolRoot = inRootObject as? PackageRoot {
        var symbolShape = [EBShape] ()
        for object in symbolRoot.packageObjects_property.propval {
          if !(object is PackageGuide), !(object is PackageDimension), let shape = object.objectDisplay {
            symbolShape.append (shape)
          }
        }
        return symbolShape
      }else{
        return []
      }
    })
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return packageLibraryPathForPath (inPath)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
