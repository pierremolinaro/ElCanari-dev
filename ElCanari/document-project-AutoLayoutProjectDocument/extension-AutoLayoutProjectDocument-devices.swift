//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  internal func appendDevice (_ inData : Data, _ inName : String) -> DeviceInProject? {
    var device : DeviceInProject? = nil
    if let documentData = try? loadEasyBindingFile (fromData: inData, documentName: inName, undoManager: nil),
      let deviceRoot = documentData.documentRootObject as? DeviceRoot,
      let version = documentData.documentMetadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int {
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

  internal func updateDevices (_ inDevices : EBReferenceArray <DeviceInProject>, _ ioMessages : inout [String]) {
    for deviceInProject in inDevices.values {
      let pathes = deviceFilePathInLibraries (deviceInProject.mDeviceName)
      if pathes.count == 0 {
        ioMessages.append ("No file for \(deviceInProject.mDeviceName) device in Library")
      }else if pathes.count == 1 {
        if let data = try? Data (contentsOf: URL (fileURLWithPath: pathes [0])),
           let documentData = try? loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil),
           let version = documentData.documentMetadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int,
           let deviceRoot = documentData.documentRootObject as? DeviceRoot {
          if deviceInProject.mDeviceVersion < version {
            let errorMessage = self.testAndUpdateDevice (deviceInProject, from: deviceRoot, version, data)
            if errorMessage != "" {
              ioMessages.append ("Cannot update '\(deviceInProject.mDeviceName)'; new device is incompatible: \(errorMessage)\n")
            }
          }
          deviceRoot.removeRecursivelyAllRelationsShips ()
         }else{
          ioMessages.append ("Cannot read \(pathes [0]) file.")
        }
      }else{ // pathes.count > 1
        ioMessages.append ("Several files for \(deviceInProject.mDeviceName) font in Library:")
        for path in pathes {
          ioMessages.append ("  - \(path)")
        }
      }
    }
  }

  //····················································································································

  internal func updateDeviceAction () {
    var messages = [String] ()
    let selectedDevices = self.projectDeviceController.selectedArray
    self.updateDevices (selectedDevices, &messages)
    if messages.count > 0 {
      let alert = NSAlert ()
      alert.messageText = "Error updating device"
      alert.informativeText = messages.joined (separator: "\n")
      alert.beginSheetModal (for: self.windowForSheet!, completionHandler: nil)
    }
  }

  //····················································································································

  internal func testAndUpdateDevice (_ inCurrentDeviceInProject : DeviceInProject,
                                     from inCandidateDeviceRoot : DeviceRoot,
                                     _ inVersion : Int,
                                     _ inData : Data) -> String { // Return "" if new device is compatible
   var errorMessage = self.checkCandidateDevicePads (inCurrentDeviceInProject, inCandidateDeviceRoot)
   errorMessage += self.checkCandidateDeviceSymbolTypes (inCurrentDeviceInProject, inCandidateDeviceRoot)
   errorMessage += self.checkCandidateDeviceSymbolInstances (inCurrentDeviceInProject, inCandidateDeviceRoot)
   if errorMessage.isEmpty {
      self.performUpdateDevice (inCurrentDeviceInProject, from: inCandidateDeviceRoot, inVersion, inData)
    }
    return errorMessage
  }

  //····················································································································

  private func checkCandidateDeviceSymbolInstances (_ inCurrentDeviceInProject : DeviceInProject,
                                                    _ inCandidateDeviceRoot : DeviceRoot) -> String {
    var result = ""
  //--- Compute current symbol instance set
    var currentSymbolInstanceDictionary = [String : String] () // Symbol name, symbol type
    var currentSymbolTypeNameSet = Set <String> ()
    for symbol in inCurrentDeviceInProject.mSymbols.values {
      currentSymbolInstanceDictionary [symbol.mSymbolInstanceName] = symbol.mSymbolType!.mSymbolTypeName
      currentSymbolTypeNameSet.insert (symbol.mSymbolType!.mSymbolTypeName)
    }
  //--- Compute new symbol instance set
    var candidateSymbolInstanceDictionary = [String : String] () // Symbol name, symbol type
    var candidateSymbolTypeNameSet = Set <String> ()
    for symbol in inCandidateDeviceRoot.mSymbolInstances.values {
      candidateSymbolInstanceDictionary [symbol.mInstanceName] = symbol.symbolTypeName!
      candidateSymbolTypeNameSet.insert (symbol.symbolTypeName!)
    }
  //---
    let missingSymbolTypes = currentSymbolTypeNameSet.subtracting (candidateSymbolTypeNameSet)
    let unknownSymbolTypes = candidateSymbolTypeNameSet.subtracting (currentSymbolTypeNameSet)
    for p in missingSymbolTypes {
      result += "\n  - the candidate device has no '\(p)' symbol type"
    }
    for p in unknownSymbolTypes {
      result += "\n  - the candidate device defines '\(p)' symbol type, but current device does not"
    }
  //---
    let currentSymbolSet = Set (currentSymbolInstanceDictionary.keys)
    let candidateSymbolSet = Set (candidateSymbolInstanceDictionary.keys)
    if result.isEmpty {
      let missingSymbols = currentSymbolSet.subtracting (candidateSymbolSet)
      let unknownSymbols = candidateSymbolSet.subtracting (currentSymbolSet)
      for p in missingSymbols {
        result += "\n  - the candidate device has no '\(p)' symbol instance"
      }
      for p in unknownSymbols {
        result += "\n  - the candidate device defines '\(p)' symbolinstance, but current device does not"
      }
    }
    if result.isEmpty {
      for symbolInstanceName in currentSymbolSet {
        let currentSymbolTypeName = currentSymbolInstanceDictionary [symbolInstanceName]!
        let candidateSymbolTypeName = candidateSymbolInstanceDictionary [symbolInstanceName]!
        if currentSymbolTypeName != candidateSymbolTypeName {
          result += "\n  - the '\(symbolInstanceName)' symbol has currently '\(currentSymbolTypeName) type, and \(candidateSymbolTypeName) type in candidate device"
        }
      }

    }
  //---
    return result
  }

  //····················································································································

  private func checkCandidateDevicePads (_ inCurrentDeviceInProject : DeviceInProject,
                                         _ inCandidateDeviceRoot : DeviceRoot) -> String {
    var result = ""
  //--- Compute current master pad set
    var currentMasterPadSet = Set <String> ()
    for masterPad in inCurrentDeviceInProject.mPackages [0].mMasterPads.values {
      currentMasterPadSet.insert (masterPad.mName)
    }
  //--- Compute new master pad set
    var newMasterPadSet = Set <String> ()
    for masterPad in inCandidateDeviceRoot.mPackages [0].mMasterPads.values {
      newMasterPadSet.insert (masterPad.mName)
    }
  //---
    let missingPads = currentMasterPadSet.subtracting (newMasterPadSet)
    let unknownPads = newMasterPadSet.subtracting (currentMasterPadSet)
    for p in missingPads {
      result += "\n  - the candidate device has no '\(p)' pad"
    }
    for p in unknownPads {
      result += "\n  - the candidate device has unknown '\(p)' pad"
    }
  //---
    return result
  }

  //····················································································································

  private func checkCandidateDeviceSymbolTypes (_ inCurrentDeviceInProject : DeviceInProject,
                                                _ inCandidateDeviceRoot : DeviceRoot) -> String {
    var result = ""
  //--- Compute current symbol type dictionary
    var currentSymbolTypeDictionary = [String : Set <String>] () // Symbol type name, set of pin names
    for padAssignment in inCurrentDeviceInProject.mPadAssignments.values {
      if let pin = padAssignment.mPin {
        let pinName = pin.mPinName
        let symbolTypeName = pin.mSymbolTypeName
        var pinNameSet = currentSymbolTypeDictionary [symbolTypeName] ?? Set ()
        pinNameSet.insert (pinName)
        currentSymbolTypeDictionary [symbolTypeName] = pinNameSet
      }
    }
  //--- Compute candidate symbol type dictionary
    var candidateSymbolTypeDictionary = [String : Set <String>] () // Symbol type name, set of pin names
    for symbolType in inCandidateDeviceRoot.mSymbolTypes.values {
      let symbolTypeName = symbolType.mTypeName
      var pinNameSet = Set <String> ()
      for pin in symbolType.mPinTypes.values {
        pinNameSet.insert (pin.mName)
      }
      candidateSymbolTypeDictionary [symbolTypeName] = pinNameSet
    }
  //---
    let currentSymbolTypeSet = Set (currentSymbolTypeDictionary.keys)
    let candidateSymbolTypeSet = Set (candidateSymbolTypeDictionary.keys)
    let missingSymbols = currentSymbolTypeSet.subtracting (candidateSymbolTypeSet)
    let unknownSymbols = candidateSymbolTypeSet.subtracting (currentSymbolTypeSet)
    for p in missingSymbols {
      result += "\n  - the candidate device has no '\(p)' symbol type"
    }
    for p in unknownSymbols {
      result += "\n  - the candidate device has unknown '\(p)' symbol type (available: "
      var first = true
      for symbol in candidateSymbolTypeSet {
        if first {
          first = false
        }else{
          result += ", "
        }
        result += "'\(symbol)'"
      }
      result += ")"
    }
    if result.isEmpty {
      for symbolTypeName in currentSymbolTypeSet {
        let currentPinSet = currentSymbolTypeDictionary [symbolTypeName]!
        let candidatePinSet = candidateSymbolTypeDictionary [symbolTypeName]!
        let missingPins = currentPinSet.subtracting (candidatePinSet)
        let unknownPins = candidatePinSet.subtracting (currentPinSet)
        for p in missingPins {
          result += "\n  - the '\(symbolTypeName)' symbol type of the candidate device has no '\(p)' pin"
        }
        for p in unknownPins {
          result += "\n  - the '\(symbolTypeName)' symbol type of the candidate device has a new '\(p)' pin"
        }
      }
    }
  //---
    return result
  }

  //····················································································································

  internal func performUpdateDevice (_ inCurrentDeviceInProject : DeviceInProject,
                                     from inCandidateDeviceRoot : DeviceRoot,
                                     _ inVersion : Int,
                                     _ inData : Data) {
    inCurrentDeviceInProject.mDeviceVersion = inVersion
    inCurrentDeviceInProject.mDeviceFileData = inData
    inCurrentDeviceInProject.mPrefix = inCandidateDeviceRoot.mPrefix
  //--- Remove current packages
    let currentPackages = inCurrentDeviceInProject.mPackages
    inCurrentDeviceInProject.mPackages = EBReferenceArray ()
    for p in currentPackages.values {
      p.removeRecursivelyAllRelationsShips ()
    }
  //--- Build package dictionary
    var packageDictionary = [String : DevicePackageInProject] ()
  //--- Append packages
    for packageInDevice in inCandidateDeviceRoot.mPackages.values {
      let packageInProject = DevicePackageInProject (self.ebUndoManager)
      inCurrentDeviceInProject.mPackages.append (packageInProject)
      packageInProject.mPackageName = packageInDevice.mName
      packageInProject.mStrokeBezierPath = packageInDevice.mStrokeBezierPath
      packageDictionary [packageInProject.mPackageName] = packageInProject
      for masterPadInDevice in packageInDevice.mMasterPads.values {
        let masterPadInProject = DeviceMasterPadInProject (self.ebUndoManager)
        packageInProject.mMasterPads.append (masterPadInProject)
        masterPadInProject.mCenterX = masterPadInDevice.mCenterX
        masterPadInProject.mCenterY = masterPadInDevice.mCenterY
        masterPadInProject.mHeight = masterPadInDevice.mHeight
        masterPadInProject.mHoleWidth = masterPadInDevice.mHoleWidth
        masterPadInProject.mHoleHeight = masterPadInDevice.mHoleHeight
        masterPadInProject.mName = masterPadInDevice.mName
        masterPadInProject.mShape = masterPadInDevice.mShape
        masterPadInProject.mStyle = masterPadInDevice.mStyle
        masterPadInProject.mWidth = masterPadInDevice.mWidth
        for slavePadInDevice in masterPadInDevice.mSlavePads.values {
          let slavePadInProject = DeviceSlavePadInProject (self.ebUndoManager)
          masterPadInProject.mSlavePads.append (slavePadInProject)
          slavePadInProject.mCenterX = slavePadInDevice.mCenterX
          slavePadInProject.mCenterY = slavePadInDevice.mCenterY
          slavePadInProject.mHeight = slavePadInDevice.mHeight
          slavePadInProject.mHoleWidth = slavePadInDevice.mHoleWidth
          slavePadInProject.mHoleHeight = slavePadInDevice.mHoleHeight
          slavePadInProject.mShape = slavePadInDevice.mShape
          slavePadInProject.mStyle = slavePadInDevice.mStyle
          slavePadInProject.mWidth = slavePadInDevice.mWidth
        }
      }
    }
  //--- For all components, update selected package
    for component in inCurrentDeviceInProject.mComponents.values {
      if let newPackage = packageDictionary [component.mSelectedPackage!.mPackageName] {
        component.mSelectedPackage = newPackage
      }else{
        component.mSelectedPackage = inCurrentDeviceInProject.mPackages [0]
      }
    }
  //--- Remove current symbols
    let currentSymbols = inCurrentDeviceInProject.mSymbols
    inCurrentDeviceInProject.mSymbols = EBReferenceArray ()
    for s in currentSymbols.values {
      s.removeRecursivelyAllRelationsShips ()
    }
  //--- Append symbols
    var devicePinDictionary = [PinQualifiedNameStruct : DevicePinInProject] ()
    for symbolTypeInDevice in inCandidateDeviceRoot.mSymbolTypes.values {
      let symbolTypeInProject = DeviceSymbolTypeInProject (self.ebUndoManager)
      symbolTypeInProject.mFilledBezierPath = symbolTypeInDevice.mFilledBezierPath
      symbolTypeInProject.mStrokeBezierPath = symbolTypeInDevice.mStrokeBezierPath
      symbolTypeInProject.mSymbolTypeName = symbolTypeInDevice.mTypeName
      for symbolInstanceInDevice in symbolTypeInDevice.mInstances.values {
        let symbolInstanceInProject = DeviceSymbolInstanceInProject (self.ebUndoManager)
        symbolInstanceInProject.mSymbolInstanceName = symbolInstanceInDevice.mInstanceName
        symbolInstanceInProject.mSymbolType = symbolTypeInProject
        inCurrentDeviceInProject.mSymbols.append (symbolInstanceInProject)
        for pinInDevice in symbolTypeInDevice.mPinTypes.values {
          let pinInProject = DevicePinInProject (self.ebUndoManager)
          pinInProject.mPinName = pinInDevice.mName
          pinInProject.mSymbolInstanceName = symbolInstanceInDevice.mInstanceName
          pinInProject.mSymbolTypeName = symbolTypeInProject.mSymbolTypeName
          pinInProject.mNameHorizontalAlignment = pinInDevice.mNameHorizontalAlignment
          pinInProject.mNumberHorizontalAlignment = pinInDevice.mNumberHorizontalAlignment
          pinInProject.mPinNameIsDisplayedInSchematic = pinInDevice.mPinNameIsDisplayedInSchematics
          pinInProject.mPinX = pinInDevice.mPinX
          pinInProject.mPinY = pinInDevice.mPinY
          pinInProject.mXName = pinInDevice.mXName
          pinInProject.mYName = pinInDevice.mYName
          pinInProject.mXNumber = pinInDevice.mXNumber
          pinInProject.mYNumber = pinInDevice.mYNumber
          let pinQualifiedName = pinInProject.pinQualifiedName!
          // Swift.print ("pinQualifiedName \(pinQualifiedName)")
          devicePinDictionary [pinQualifiedName] = pinInProject
        }
      }
    }
  //--- Append pin/pad assignments
    inCurrentDeviceInProject.mPadAssignments = EBReferenceArray ()
    for pinPadAssignmentInDevice in inCandidateDeviceRoot.mPadProxies.values {
      let assignment = DevicePadAssignmentInProject (self.ebUndoManager)
      let padName = pinPadAssignmentInDevice.mPadName
      assignment.mPadName = padName
      if let pinInstanceInDevice = pinPadAssignmentInDevice.mPinInstance { // If nil, pad is NC
        let qualifiedPinName = pinInstanceInDevice.pinQualifiedName!
        let pinInProject = devicePinDictionary [qualifiedPinName]!
        assignment.mPin = pinInProject
      }
      inCurrentDeviceInProject.mPadAssignments.append (assignment)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————