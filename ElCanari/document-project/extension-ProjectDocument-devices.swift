//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func addFont (postAction: Optional <() -> Void>) {
     var currentFontNames = Set <String> ()
     for font in self.rootObject.mFonts_property.propval {
        currentFontNames.insert (font.mFontName)
     }
     gOpenFontInLibrary?.loadDocumentFromLibrary (
       windowForSheet: self.windowForSheet!,
       alreadyLoadedDocuments: currentFontNames,
       callBack: self.addFontFromLoadFontDialog,
       postAction: postAction
     )
  }

  //····················································································································

  internal func addFontFromLoadFontDialog (_ inData : Data, _ inName : String) {
    if let (_, metadataDictionary, rootObjectDictionary) = try? loadEasyRootObjectDictionary (from: inData),
       let version = metadataDictionary [PMFontVersion] as? Int,
       let rod = rootObjectDictionary,
       let descriptiveString = rod [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String {
      let addedFont = FontInProject (self.ebUndoManager)
      addedFont.mFontName = inName
      addedFont.mFontVersion = version
      addedFont.mDescriptiveString = descriptiveString
      var fonts = self.rootObject.mFonts_property.propval
      fonts.append (addedFont)
      self.rootObject.mFonts_property.setProp (fonts)
    }
  }

  //····················································································································

  internal func addComponentDialog () {
    var currentDeviceNames = Set <String> ()
    for device in self.rootObject.mDevices_property.propval {
      currentDeviceNames.insert (device.mDeviceName)
    }
     gOpenDeviceInLibrary?.loadDocumentFromLibrary (
       windowForSheet: self.windowForSheet!,
       alreadyLoadedDocuments: currentDeviceNames,
       callBack: self.addComponent,
       postAction: nil
     )
  }

  //····················································································································

  internal func addComponent (_ inData : Data, _ inName : String) {
    // Swift.print ("inName \(inName), inData \(inData.count)")
  //--- Append device
    _ = self.appendDevice (inData, inName)
  //--- Append component
  }

  //····················································································································

  internal func appendDevice (_ inData : Data, _ inName : String) -> DeviceInProject? {
    var device : DeviceInProject? = nil
    if let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: inData),
      let deviceRoot = rootObject as? DeviceRoot,
      let version = metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int {
    //--- Create device
      let newDevice = DeviceInProject (self.ebUndoManager)
      device = newDevice
      newDevice.mDeviceName = inName
      newDevice.mDeviceVersion = version
      newDevice.mDeviceFileData = inData
    //--- Append packages
      for packageInDevice in deviceRoot.mPackages {
        let packageInProject = DevicePackageInProject (self.ebUndoManager)
        newDevice.mPackages.append (packageInProject)
        packageInProject.mPackageName = packageInDevice.mName
        for masterPadInDevice in packageInDevice.mMasterPads {
          let masterPadInProject = DeviceMasterPadInProject (self.ebUndoManager)
          packageInProject.mMasterPads.append (masterPadInProject)
          masterPadInProject.mCenterX = masterPadInDevice.mCenterX
          masterPadInProject.mCenterY = masterPadInDevice.mCenterY
          masterPadInProject.mHeight = masterPadInDevice.mHeight
          masterPadInProject.mHoleDiameter = masterPadInDevice.mHoleDiameter
          masterPadInProject.mName = masterPadInDevice.mName
          masterPadInProject.mShape = masterPadInDevice.mShape
          masterPadInProject.mStyle = masterPadInDevice.mStyle
          masterPadInProject.mWidth = masterPadInDevice.mWidth
          for slavePadInDevice in masterPadInDevice.mSlavePads {
            let slavePadInProject = DeviceSlavePadInProject (self.ebUndoManager)
            masterPadInProject.mSlavePads.append (slavePadInProject)
            slavePadInProject.mCenterX = slavePadInDevice.mCenterX
            slavePadInProject.mCenterY = slavePadInDevice.mCenterY
            slavePadInProject.mHeight = slavePadInDevice.mHeight
            slavePadInProject.mHoleDiameter = slavePadInDevice.mHoleDiameter
            slavePadInProject.mShape = slavePadInDevice.mShape
            slavePadInProject.mStyle = slavePadInDevice.mStyle
            slavePadInProject.mWidth = slavePadInDevice.mWidth
          }
        }
      }
    //--- Add to device list
      self.rootObject.mDevices.append (newDevice)
    //--- Free imported root object
      deviceRoot.removeRecursivelyAllRelationsShips ()
    }
    return device
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
