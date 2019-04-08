//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

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
      self.performUpdateDevice (newDevice, from: deviceRoot, version, inData)
    //--- Add to device list
      self.rootObject.mDevices.append (newDevice)
    //--- Free imported root object
      deviceRoot.removeRecursivelyAllRelationsShips ()
    }
    return device
  }

  //····················································································································

  internal func updateDeviceAction () {
    let selectedDevices = self.mProjectDeviceController.selectedArray_property.propval
    var messages = [String] ()
    for deviceInProject in selectedDevices {
      let pathes = deviceFilePathInLibraries (deviceInProject.mDeviceName)
      if pathes.count == 0 {
        messages.append ("No file for \(deviceInProject.mDeviceName) device in Library")
      }else if pathes.count == 1 {
        if let data = try? Data (contentsOf: URL (fileURLWithPath: pathes [0])),
           let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: data),
           let version = metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int,
           let deviceRoot = rootObject as? DeviceRoot {
          if deviceInProject.mDeviceVersion < version {
            let ok = self.testAndUpdateDevice (deviceInProject, from: deviceRoot, version, data)
            if !ok {
              messages.append ("Cannot update '\(deviceInProject.mDeviceName)': new device is incompatible.")
            }
          }
          deviceRoot.removeRecursivelyAllRelationsShips ()
         }else{
          messages.append ("Cannot read \(pathes [0]) file.")
        }
      }else{ // pathes.count > 1
        messages.append ("Several files for \(deviceInProject.mDeviceName) font in Library:")
        for path in pathes {
          messages.append ("  - \(path)")
        }
      }
    }
    if messages.count > 0 {
      let alert = NSAlert ()
      alert.messageText = "Error updating device"
      alert.informativeText = messages.joined (separator: "\n")
      alert.beginSheetModal (for: self.windowForSheet!, completionHandler: nil)
    }
  }

  //····················································································································

  internal func testAndUpdateDevice (_ inDeviceInProject : DeviceInProject,
                                     from inDeviceRoot : DeviceRoot,
                                     _ inVersion : Int,
                                     _ inData : Data) -> Bool { // Return true if new device is compatible
  //--- Compute current master pad set
    var currentMasterPadSet = Set <String> ()
    for masterPad in inDeviceInProject.mPackages [0].mMasterPads {
      currentMasterPadSet.insert (masterPad.mName)
    }
  //--- Compute new master pad set
    var newMasterPadSet = Set <String> ()
    for masterPad in inDeviceRoot.mPackages [0].mMasterPads {
      newMasterPadSet.insert (masterPad.mName)
    }
  //--- Perform update ?
    let ok = currentMasterPadSet == newMasterPadSet
    if ok {
      self.performUpdateDevice (inDeviceInProject, from: inDeviceRoot, inVersion, inData)
    }
    return ok
  }

  //····················································································································

  internal func performUpdateDevice (_ inDeviceInProject : DeviceInProject,
                                     from inDeviceRoot : DeviceRoot,
                                     _ inVersion : Int,
                                     _ inData : Data) {
    inDeviceInProject.mDeviceVersion = inVersion
    inDeviceInProject.mDeviceFileData = inData
    inDeviceInProject.mPrefix = inDeviceRoot.mPrefix
  //--- Remove current packages
    let currentPackages = inDeviceInProject.mPackages
    inDeviceInProject.mPackages = []
    for p in currentPackages {
      p.removeRecursivelyAllRelationsShips ()
    }
  //--- Build package dictionary
    var packageDictionary = [String : DevicePackageInProject] ()
  //--- Append packages
    for packageInDevice in inDeviceRoot.mPackages {
      let packageInProject = DevicePackageInProject (self.ebUndoManager)
      inDeviceInProject.mPackages.append (packageInProject)
      packageInProject.mPackageName = packageInDevice.mName
      packageDictionary [packageInProject.mPackageName] = packageInProject
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
  //--- For all components, update selected package
    for component in inDeviceInProject.mComponents {
      if let newPackage = packageDictionary [component.mSelectedPackage!.mPackageName] {
        component.mSelectedPackage = newPackage
      }else{
        component.mSelectedPackage = inDeviceInProject.mPackages [0]
      }
    }
  //--- Remove current symbols
    let currentSymbols = inDeviceInProject.mSymbols
    inDeviceInProject.mSymbols = []
    for s in currentSymbols {
      s.removeRecursivelyAllRelationsShips ()
    }
  //--- Append symbols
    for symbolTypeInDevice in inDeviceRoot.mSymbolTypes {
      let symbolTypeInProject = DeviceSymbolTypeInProject (self.ebUndoManager)
      symbolTypeInProject.mFilledBezierPath = symbolTypeInDevice.mFilledBezierPath
      symbolTypeInProject.mStrokeBezierPath = symbolTypeInDevice.mStrokeBezierPath
      symbolTypeInProject.mTypeName = symbolTypeInDevice.mTypeName
      for pinInDevice in symbolTypeInDevice.mPinTypes {
        let pinInProject = DevicePinInProject (self.ebUndoManager)
        pinInProject.mPinName = pinInDevice.mName
        pinInProject.mNameHorizontalAlignment = pinInDevice.mNameHorizontalAlignment
        pinInProject.mNumberHorizontalAlignment = pinInDevice.mNumberHorizontalAlignment
        pinInProject.mPinNameIsDisplayedInSchematics = pinInDevice.mPinNameIsDisplayedInSchematics
        pinInProject.mPinX = pinInDevice.mPinX
        pinInProject.mPinY = pinInDevice.mPinY
        pinInProject.mXName = pinInDevice.mXName
        pinInProject.mYName = pinInDevice.mYName
        pinInProject.mXNumber = pinInDevice.mXNumber
        pinInProject.mYNumber = pinInDevice.mYNumber
        symbolTypeInProject.mPins.append (pinInProject)
      }
      for symbolInstanceInDevice in symbolTypeInDevice.mInstances {
        let symbolInstanceInProject = DeviceSymbolInstanceInProject (self.ebUndoManager)
        symbolInstanceInProject.mSymbolType = symbolTypeInProject
        symbolInstanceInProject.mInstanceName = symbolInstanceInDevice.mInstanceName
        inDeviceInProject.mSymbols.append (symbolInstanceInProject)
      }
    }
  }

  //····················································································································


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
