//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

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
