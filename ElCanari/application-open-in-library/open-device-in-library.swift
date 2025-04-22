//
//  open-device-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/04/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor let gOpenDeviceInLibrary = OpenDeviceInLibrary ()

//--------------------------------------------------------------------------------------------------

final class OpenDeviceInLibrary : OpenInLibrary {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Dialog
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func openDeviceInLibrary (_ inSender : Any?) {
    super.openDocumentInLibrary (windowTitle: "Open Device in Library")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) {
    super.buildTableViewDataSource (extension: ElCanariDevice_EXTENSION,
                                    alreadyLoadedDocuments: inNames) { (_ inRootObject : EBManagedObject?) -> NSImage? in
      var image : NSImage? = nil
      if let deviceRoot = inRootObject as? DeviceRoot {
        let imageData = deviceRoot.mImageData
        image = NSImage (data: imageData)
      }
      return image
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func noPartMessage () -> String {
    return "No selected device"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var categoryKey : String? { DEVICE_CATEGORY_KEY }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func partLibraryPathForPath (_ inPath : String) -> String {
    return deviceLibraryPathForPath (inPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
