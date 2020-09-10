//
//  Created by Pierre Molinaro on 01/03/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

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

  internal func addComponent (_ inData : Data, _ inName : String) -> Bool {
  //--- Append device
    let possibleNewDeviceInProject = self.appendDevice (inData, inName)
    let optionalAddedComponent = self.addComponent (fromPossibleDevice: possibleNewDeviceInProject, prefix: nil)
    return optionalAddedComponent != nil
  }

  //····················································································································

  func addComponent (fromEmbeddedLibraryDeviceName inDeviceName : String) {
  //--- find device
    var possibleDevice : DeviceInProject? = nil
    for device in self.rootObject.mDevices {
      if device.mDeviceName == inDeviceName {
        possibleDevice = device
      }
    }
  //--- Add Component
    _ = self.addComponent (fromPossibleDevice: possibleDevice, prefix: nil)
  }

  //····················································································································

  internal func duplicate (component inComponent : ComponentInProject) -> ComponentInProject? {
    let optionalNewComponent = self.addComponent (fromPossibleDevice: inComponent.mDevice, prefix: inComponent.mNamePrefix)
    optionalNewComponent?.mComponentValue = inComponent.mComponentValue
    optionalNewComponent?.mNameIsVisibleInBoard = inComponent.mNameIsVisibleInBoard
    optionalNewComponent?.mValueIsVisibleInBoard = inComponent.mValueIsVisibleInBoard
    optionalNewComponent?.mSelectedPackage = inComponent.mSelectedPackage
    return optionalNewComponent
  }

  //····················································································································

  internal func addComponent (fromPossibleDevice inPossibleDevice : DeviceInProject?,
                              prefix inPossiblePrefix : String?) -> ComponentInProject? {
    var optionalNewComponent : ComponentInProject? = nil
  //--- Append component
    if let deviceInProject = inPossibleDevice {
      let newComponent = ComponentInProject (self.ebUndoManager)
    //--- Set device
      newComponent.mDevice = deviceInProject
    //--- Set package
      newComponent.mSelectedPackage = deviceInProject.mPackages [0]
    //--- Set font for name and value in board
      newComponent.mNameFont = self.rootObject.mFonts [0]
      newComponent.mValueFont = self.rootObject.mFonts [0]
    //--- Set symbols
      var componentSymbols = [ComponentSymbolInProject] ()
      for symbolInDevice in deviceInProject.mSymbols {
        let newSymbolInProject = ComponentSymbolInProject (self.ebUndoManager)
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
      for component in self.rootObject.mComponents {
        if newComponent.mNamePrefix == component.mNamePrefix {
          idx = max (idx, component.mNameIndex + 1)
        }
      }
      newComponent.mNameIndex = idx
      self.rootObject.mComponents.append (newComponent)
      self.componentController.setSelection ([newComponent])
      optionalNewComponent = newComponent
    }
    return optionalNewComponent
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
