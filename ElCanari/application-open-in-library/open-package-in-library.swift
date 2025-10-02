//
//  open-package-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor let gOpenPackageInLibrary = OpenPackageInLibrary ()

//--------------------------------------------------------------------------------------------------

final class OpenPackageInLibrary : OpenInLibrary {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Dialog
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func openPackageInLibrary (_ /* inUnusedSender */ : Any?) {
    super.openDocumentInLibrary (
      windowTitle: "Open Package in Library",
      openButtonTitle: "Open Package",
      closeButtonTitle: "Close"
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    super.buildTableViewDataSource (extension: ElCanariPackage_EXTENSION, alreadyLoadedDocuments: inNames) { (_ inRootObject : EBManagedObject?) -> NSImage? in
      var partShape = EBShape ()
      if let packageRoot = inRootObject as? PackageRoot {
        for object in packageRoot.packageObjects_property.propval.values {
          if !(object is PackageGuide), !(object is PackageDimension), let shape = object.objectDisplay {
            partShape.add (shape)
          }
        }
      }
      let box = partShape.boundingBox
      return box.isEmpty ? nil : buildPDFimage (frame: box, shape: partShape, backgroundColor: preferences_packageBackgroundColor_property.propval)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func noPartMessage () -> String {
    return "No selected package"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return packageLibraryPathForPath (inPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
