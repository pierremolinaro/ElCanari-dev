//
//  Created by Pierre Molinaro on 01/03/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendDevice (_ inData : Data, _ inName : String) -> DeviceInProject? {
    var device : DeviceInProject? = nil
    let documentReadData = loadEasyBindingFile (fromData: inData, documentName: inName, undoManager: nil)
    switch documentReadData {
    case .ok (let documentData) :
      if let deviceRoot = documentData.documentRootObject as? DeviceRoot,
        let version = documentData.documentMetadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int {
      //--- Create device
        let newDevice = DeviceInProject (self.undoManager)
        device = newDevice
        newDevice.mDeviceName = inName
        if let categoryName = documentData.documentMetadataDictionary [DEVICE_CATEGORY_KEY] as? String {
          newDevice.mCategory = categoryName
        }
        self.performUpdateDevice (
          newDevice,
          from: deviceRoot,
          version: version,
          category: newDevice.mCategory,
          pinNameSusbstitution: nil,
          data: inData
        )
      //--- Add to device list
        self.rootObject.mDevices.append (newDevice)
      }
    case .readError (_) :
      ()
    }
    return device
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func checkDevices (_ ioMessages : inout [String]) {
    for deviceInProject in self.rootObject.mDevices.values {
      deviceInProject.mFileSystemStatusMessageForDeviceInProject = "Ok"
      deviceInProject.mFileSystemStatusRequiresAttentionForDeviceInProject = false
      let pathes = deviceFilePathInLibraries (deviceInProject.mDeviceName)
      if pathes.count == 0 {
        ioMessages.append ("No file for \(deviceInProject.mDeviceName) device in Library")
        deviceInProject.mFileSystemStatusMessageForDeviceInProject = "No device file in Library"
        deviceInProject.mFileSystemStatusRequiresAttentionForDeviceInProject = true
      }else if pathes.count == 1 {
        if let data = try? Data (contentsOf: URL (fileURLWithPath: pathes [0])) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let version = documentData.documentMetadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int,
               let candidateDeviceRoot = documentData.documentRootObject as? DeviceRoot {
              if deviceInProject.mDeviceVersion < version {
                var pinNameSusbstitution : PinNameSusbstitution? = nil
                var errorMessage = self.checkCandidateDevicePads (deviceInProject, candidateDeviceRoot)
                errorMessage += self.checkCandidateDeviceSymbolTypes (deviceInProject, candidateDeviceRoot, pinNameSusbstitution: &pinNameSusbstitution)
                errorMessage += self.checkCandidateDeviceSymbolInstances (deviceInProject, candidateDeviceRoot)
                deviceInProject.mFileSystemStatusRequiresAttentionForDeviceInProject = true
                if errorMessage == "" {
                  if pinNameSusbstitution != nil {
                    deviceInProject.mFileSystemStatusMessageForDeviceInProject = "One symbol pin name differs, device is updatable"
                  }else{
                    deviceInProject.mFileSystemStatusMessageForDeviceInProject = "Device is updatable"
                  }
                }else{
                 deviceInProject.mFileSystemStatusMessageForDeviceInProject = "Cannot update: new device is incompatible"
                 ioMessages.append ("Cannot update '\(deviceInProject.mDeviceName)'; new device is incompatible: \(errorMessage)\n")
                 Swift.print (errorMessage)
                }
              }
            }else{
              deviceInProject.mFileSystemStatusMessageForDeviceInProject = "Cannot read device file"
              deviceInProject.mFileSystemStatusRequiresAttentionForDeviceInProject = true
              ioMessages.append ("Cannot read \(pathes [0]) file.")
            }
          case .readError (_) :
            deviceInProject.mFileSystemStatusMessageForDeviceInProject = "Cannot read device file"
            deviceInProject.mFileSystemStatusRequiresAttentionForDeviceInProject = true
            ioMessages.append ("Cannot read \(pathes [0]) file.")
          }
        }else{
          deviceInProject.mFileSystemStatusMessageForDeviceInProject = "Cannot read device file"
          deviceInProject.mFileSystemStatusRequiresAttentionForDeviceInProject = true
          ioMessages.append ("Cannot read \(pathes [0]) file.")
        }
      }else{ // pathes.count > 1
        deviceInProject.mFileSystemStatusMessageForDeviceInProject = "Several device files in library"
        deviceInProject.mFileSystemStatusRequiresAttentionForDeviceInProject = true
        ioMessages.append ("Several files for \(deviceInProject.mDeviceName) font in Library:")
        for path in pathes {
          ioMessages.append ("  - \(path)")
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateDevices (_ inDevices : EBReferenceArray <DeviceInProject>, _ ioMessages : inout [String]) {
    for deviceInProject in inDevices.values {
      let pathes = deviceFilePathInLibraries (deviceInProject.mDeviceName)
      if pathes.count == 0 {
        ioMessages.append ("No file for \(deviceInProject.mDeviceName) device in Library")
      }else if pathes.count == 1 {
        if let data = try? Data (contentsOf: URL (fileURLWithPath: pathes [0])) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let version = documentData.documentMetadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int,
               let deviceRoot = documentData.documentRootObject as? DeviceRoot {
              if deviceInProject.mDeviceVersion < version {
                let category = documentData.documentMetadataDictionary [DEVICE_CATEGORY_KEY] as? String ?? ""
                let errorMessage = self.testAndUpdateDevice (
                  deviceInProject,
                  from: deviceRoot,
                  version: version,
                  category: category,
                  data: data
                )
                if errorMessage != "" {
                  ioMessages.append ("Cannot update '\(deviceInProject.mDeviceName)'; new device is incompatible: \(errorMessage)\n")
                }
              }
            }else{
              ioMessages.append ("Cannot read \(pathes [0]) file.")
            }
          case .readError (_) :
            ioMessages.append ("Cannot read \(pathes [0]) file.")
          }
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func testAndUpdateDevice (_ inCurrentDeviceInProject : DeviceInProject,
                            from inCandidateDeviceRoot : DeviceRoot,
                            version inVersion : Int,
                            category inCategory : String,
                            data inData : Data) -> String { // Return "" if new device is compatible
   var errorMessage = self.checkCandidateDevicePads (inCurrentDeviceInProject, inCandidateDeviceRoot)
   var pinNameSusbstitution : PinNameSusbstitution? = nil
   errorMessage += self.checkCandidateDeviceSymbolTypes (inCurrentDeviceInProject, inCandidateDeviceRoot, pinNameSusbstitution: &pinNameSusbstitution)
   errorMessage += self.checkCandidateDeviceSymbolInstances (inCurrentDeviceInProject, inCandidateDeviceRoot)
   if errorMessage.isEmpty {
      self.performUpdateDevice (
        inCurrentDeviceInProject,
        from: inCandidateDeviceRoot,
        version: inVersion,
        category: inCategory,
        pinNameSusbstitution: pinNameSusbstitution,
        data: inData
      )
    }
    return errorMessage
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func checkCandidateDevicePads (_ inCurrentDeviceInProject : DeviceInProject,
                                         _ inCandidateDeviceRoot : DeviceRoot) -> String {
    var errorMessage = ""
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
      errorMessage += "\n  - the candidate device has no '\(p)' pad"
    }
    for p in unknownPads {
      errorMessage += "\n  - the candidate device has unknown '\(p)' pad"
    }
  //---
    return errorMessage
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func checkCandidateDeviceSymbolTypes (_ inCurrentDeviceInProject : DeviceInProject,
                                                _ inCandidateDeviceRoot : DeviceRoot,
                                                pinNameSusbstitution ioPinNameSusbstitution : inout PinNameSusbstitution?) -> String {
    var errorMessage = ""
    ioPinNameSusbstitution = nil
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
      errorMessage += "\n  - the candidate device has no '\(p)' symbol type"
    }
    for p in unknownSymbols {
      errorMessage += "\n  - the candidate device has unknown '\(p)' symbol type (available: "
      var first = true
      for symbol in candidateSymbolTypeSet {
        if first {
          first = false
        }else{
          errorMessage += ", "
        }
        errorMessage += "'\(symbol)'"
      }
      errorMessage += ")"
    }
    if errorMessage.isEmpty {
      for symbolTypeName in currentSymbolTypeSet {
        let currentPinSet = currentSymbolTypeDictionary [symbolTypeName]!
        let candidatePinSet = candidateSymbolTypeDictionary [symbolTypeName]!
        let missingPins = currentPinSet.subtracting (candidatePinSet)
        let unknownPins = candidatePinSet.subtracting (currentPinSet)
        if (missingPins.count == 1) && (unknownPins.count == 1) {
          ioPinNameSusbstitution = PinNameSusbstitution (
            symbolTypeName: symbolTypeName,
            oldPinName: missingPins.first!,
            newPinName: unknownPins.first!
          )
        }else{
          for p in missingPins {
            errorMessage += "\n  - the '\(symbolTypeName)' symbol type of the candidate device has no '\(p)' pin"
          }
          for p in unknownPins {
            errorMessage += "\n  - the '\(symbolTypeName)' symbol type of the candidate device has a new '\(p)' pin"
          }
        }
      }
    }
  //---
    return errorMessage
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct PinNameSusbstitution {
    let symbolTypeName : String
    let oldPinName : String
    let newPinName : String
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func performUpdateDevice (_ inCurrentDeviceInProject : DeviceInProject,
                            from inCandidateDeviceRoot : DeviceRoot,
                            version inVersion : Int,
                            category inCategory : String,
                            pinNameSusbstitution inPinNameSusbstitution : PinNameSusbstitution?,
                            data inData : Data) {
    inCurrentDeviceInProject.mDeviceVersion = inVersion
    inCurrentDeviceInProject.mCategory = inCategory
    inCurrentDeviceInProject.mDeviceFileData = inData
    inCurrentDeviceInProject.mPrefix = inCandidateDeviceRoot.mPrefix
  //--- Remove current packages
    inCurrentDeviceInProject.mPackages = EBReferenceArray ()
  //--- Build package dictionary
    var packageDictionary = [String : DevicePackageInProject] ()
  //--- Append packages
    for packageInDevice in inCandidateDeviceRoot.mPackages.values {
      let packageInProject = DevicePackageInProject (self.undoManager)
      inCurrentDeviceInProject.mPackages.append (packageInProject)
      packageInProject.mPackageName = packageInDevice.mName
      packageInProject.mStrokeBezierPath = packageInDevice.mStrokeBezierPath
      packageDictionary [packageInProject.mPackageName] = packageInProject
      for masterPadInDevice in packageInDevice.mMasterPads.values {
        let masterPadInProject = DeviceMasterPadInProject (self.undoManager)
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
          let slavePadInProject = DeviceSlavePadInProject (self.undoManager)
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
    inCurrentDeviceInProject.mSymbols = EBReferenceArray ()
  //--- Append symbols
    var newDevicePinDictionary = [PinQualifiedNameStruct : DevicePinInProject] ()
    for candidateSymbolTypeInDevice in inCandidateDeviceRoot.mSymbolTypes.values {
      let newSymbolTypeInProject = DeviceSymbolTypeInProject (self.undoManager)
      newSymbolTypeInProject.mFilledBezierPath = candidateSymbolTypeInDevice.mFilledBezierPath
      newSymbolTypeInProject.mStrokeBezierPath = candidateSymbolTypeInDevice.mStrokeBezierPath
      newSymbolTypeInProject.mSymbolTypeName = candidateSymbolTypeInDevice.mTypeName
      for candidateSymbolInstanceInDevice in candidateSymbolTypeInDevice.mInstances.values {
        let newSymbolInstanceInProject = DeviceSymbolInstanceInProject (self.undoManager)
        newSymbolInstanceInProject.mSymbolInstanceName = candidateSymbolInstanceInDevice.mInstanceName
        newSymbolInstanceInProject.mSymbolType = newSymbolTypeInProject
        inCurrentDeviceInProject.mSymbols.append (newSymbolInstanceInProject)
        for candidatePinInDevice in candidateSymbolTypeInDevice.mPinTypes.values {
          let newPinInProject = DevicePinInProject (self.undoManager)
          newPinInProject.mPinName = candidatePinInDevice.mName
          newPinInProject.mSymbolInstanceName = candidateSymbolInstanceInDevice.mInstanceName
          newPinInProject.mSymbolTypeName = newSymbolTypeInProject.mSymbolTypeName
          newPinInProject.mNameHorizontalAlignment = candidatePinInDevice.mNameHorizontalAlignment
          newPinInProject.mNumberHorizontalAlignment = candidatePinInDevice.mNumberHorizontalAlignment
          newPinInProject.mPinNameIsDisplayedInSchematic = candidatePinInDevice.mPinNameIsDisplayedInSchematics
          newPinInProject.mPinX = candidatePinInDevice.mPinX
          newPinInProject.mPinY = candidatePinInDevice.mPinY
          newPinInProject.mXName = candidatePinInDevice.mXName
          newPinInProject.mYName = candidatePinInDevice.mYName
          newPinInProject.mXNumber = candidatePinInDevice.mXNumber
          newPinInProject.mYNumber = candidatePinInDevice.mYNumber
          let pinQualifiedName : PinQualifiedNameStruct = newPinInProject.pinQualifiedName!
          newDevicePinDictionary [pinQualifiedName] = newPinInProject
        }
      }
    }
  //--- Append pin/pad assignments
    inCurrentDeviceInProject.mPadAssignments = EBReferenceArray ()
    for candidatePinPadAssignmentInDevice in inCandidateDeviceRoot.mPadProxies.values {
      let newPadAssignment = DevicePadAssignmentInProject (self.undoManager)
      let padName = candidatePinPadAssignmentInDevice.mPadName
      newPadAssignment.mPadName = padName
      if let candidatePinInstanceInDevice = candidatePinPadAssignmentInDevice.mPinInstance { // If nil, pad is NC
        let qualifiedPinName = candidatePinInstanceInDevice.pinQualifiedName!
        let newPinInProject = newDevicePinDictionary [qualifiedPinName]!
        // Swift.print ("qualifiedPinName [\(qualifiedPinName)] pinInProject [\(newPinInProject.mPinName)]")
        newPadAssignment.mPin = newPinInProject
      }
      inCurrentDeviceInProject.mPadAssignments.append (newPadAssignment)
    }
  //--- Handle one pin name change ?
    if let pinNameSusbstitution = inPinNameSusbstitution {
      for componentInProject : ComponentInProject in inCurrentDeviceInProject.mComponents.values {
        for symbolInProject : ComponentSymbolInProject in componentInProject.mSymbols.values {
          if symbolInProject.mSymbolTypeName == pinNameSusbstitution.symbolTypeName {
            for point : PointInSchematic in symbolInProject.mPoints.values {
              if point.mSymbolPinName == pinNameSusbstitution.oldPinName {
                point.mSymbolPinName = pinNameSusbstitution.newPinName
              }
            }
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
