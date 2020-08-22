//
//  open-device-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/04/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

var gOpenDeviceInLibrary : OpenDeviceInLibrary? = nil

//----------------------------------------------------------------------------------------------------------------------
// This class is instancied as object in MainMenu.xib
//----------------------------------------------------------------------------------------------------------------------

class OpenDeviceInLibrary : OpenInLibrary {

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
    gOpenDeviceInLibrary = self
  }

  //····················································································································
  //   Dialog
  //····················································································································

  @objc @IBAction func openDeviceInLibrary (_ inSender : Any?) {
    self.openDocumentInLibrary (windowTitle: "Open Device in Library")
  }

  //····················································································································

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    super.buildTableViewDataSource (extension: "ElCanariDevice", alreadyLoadedDocuments: inNames) { (_ inRootObject : EBManagedObject?) -> NSImage? in
      var image : NSImage? = nil
      if let deviceRoot = inRootObject as? DeviceRoot {
        let imageData = deviceRoot.mImageData
        image = NSImage (data: imageData)
      }
      inRootObject?.removeRecursivelyAllRelationsShips ()
      return image
    }
  }

  //····················································································································

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return deviceLibraryPathForPath (inPath)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
