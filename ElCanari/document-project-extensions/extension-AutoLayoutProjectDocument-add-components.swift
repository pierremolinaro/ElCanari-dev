//
//  Created by Pierre Molinaro on 01/03/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addComponentDialog () {
    var currentDeviceNames = Set <String> ()
    for device in self.rootObject.mDevices_property.propval.values {
      currentDeviceNames.insert (device.mDeviceName)
    }
    gOpenDeviceInLibrary.loadDocumentFromLibrary (
      windowForSheet: self.windowForSheet!,
      alreadyLoadedDocuments: [], // currentDeviceNames,
      callBack: self.addComponent,
      postAction: nil
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addComponent (_ inData : Data, _ inDeviceName : String) -> Bool {
    self.registerUndoForTriggeringStandAlonePropertyComputationForProject ()
    var added = self.addComponent (fromEmbeddedLibraryDeviceName: inDeviceName)
    if !added {
      let possibleNewDeviceInProject = self.appendDevice (inData, inDeviceName)
      let optionalAddedComponent = self.addComponent (
        fromPossibleDevice: possibleNewDeviceInProject,
        prefix: nil
      )
      added = optionalAddedComponent != nil
    }
    self.triggerStandAlonePropertyComputationForProject ()
    return added
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addComponent (fromEmbeddedLibraryDeviceName inDeviceName : String) -> Bool {
  //--- find device
    var possibleDevice : DeviceInProject? = nil
    for device in self.rootObject.mDevices.values {
      if device.mDeviceName == inDeviceName {
        possibleDevice = device
      }
    }
  //--- Add Component
    let embeddedDevice = self.addComponent (fromPossibleDevice: possibleDevice, prefix: nil)
    return embeddedDevice != nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func duplicate (component inComponent : ComponentInProject) -> ComponentInProject? {
    let optionalNewComponent = self.addComponent (fromPossibleDevice: inComponent.mDevice, prefix: inComponent.mNamePrefix)
    if let newComponent = optionalNewComponent {
      newComponent.mComponentValue = inComponent.mComponentValue
      newComponent.mDisplayLegend = inComponent.mDisplayLegend
      newComponent.mNameFontSize = inComponent.mNameFontSize
      newComponent.mNameIsVisibleInBoard = inComponent.mNameIsVisibleInBoard
      newComponent.mNameRotation = inComponent.mNameRotation
      newComponent.mRotation = inComponent.mRotation
      newComponent.mSide = inComponent.mSide
      newComponent.mSlavePadsShouldBeRouted = inComponent.mSlavePadsShouldBeRouted
      newComponent.mValueFontSize = inComponent.mValueFontSize
      newComponent.mValueIsVisibleInBoard = inComponent.mValueIsVisibleInBoard
      newComponent.mValueRotation = inComponent.mValueRotation
      newComponent.mSelectedPackage = inComponent.mSelectedPackage
      newComponent.mXName = inComponent.mXName
      newComponent.mXUnit = inComponent.mXUnit
      newComponent.mYUnit = inComponent.mYUnit
      newComponent.mYName = inComponent.mYName
      newComponent.mXValue = inComponent.mXValue
      newComponent.mYValue = inComponent.mYValue
    }
    return optionalNewComponent
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addComponent (fromPossibleDevice inPossibleDevice : DeviceInProject?,
                     prefix inPossiblePrefix : String?) -> ComponentInProject? {
    var optionalNewComponent : ComponentInProject? = nil
  //--- Append component
    if let deviceInProject = inPossibleDevice {
      self.registerUndoForTriggeringStandAlonePropertyComputationForProject ()
      let newComponent = ComponentInProject (self.undoManager)
    //--- Set device
      newComponent.mDevice = deviceInProject
    //--- Set package
      newComponent.mSelectedPackage = deviceInProject.mPackages [0]
    //--- Set font for name and value in board
      newComponent.mNameFont = self.rootObject.mFonts [0]
      newComponent.mValueFont = self.rootObject.mFonts [0]
    //--- Set symbols
      var componentSymbols = EBReferenceArray <ComponentSymbolInProject> ()
      for symbolInDevice in deviceInProject.mSymbols.values {
        let newSymbolInProject = ComponentSymbolInProject (self.undoManager)
        newSymbolInProject.mSymbolTypeName = symbolInDevice.mSymbolType!.mSymbolTypeName
        newSymbolInProject.mSymbolInstanceName = symbolInDevice.mSymbolInstanceName
        componentSymbols.append (newSymbolInProject)
      }
      newComponent.mSymbols = componentSymbols
    //--- Fix index for component name
      if let prefix = inPossiblePrefix {
        newComponent.mNamePrefix = prefix
      }else{
        newComponent.mNamePrefix = deviceInProject.mPrefix
      }
      var idx = 1
      for component in self.rootObject.mComponents.values {
        if newComponent.mNamePrefix == component.mNamePrefix {
          idx = max (idx, component.mNameIndex + 1)
        }
      }
      newComponent.mNameIndex = idx
      self.rootObject.mComponents.append (newComponent)
      self.componentController.setSelection ([newComponent])
      optionalNewComponent = newComponent
      self.triggerStandAlonePropertyComputationForProject ()
    }
    return optionalNewComponent
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
