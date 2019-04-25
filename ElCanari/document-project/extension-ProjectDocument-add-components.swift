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
  //--- Append device
    let possibleNewDeviceInProject = self.appendDevice (inData, inName)
    self.addComponent (fromPossibleDevice: possibleNewDeviceInProject)
  }

  //····················································································································

  internal func addComponent (fromPossibleDevice inPossibleDevice : DeviceInProject?) {
  //--- Append component
    if let newDeviceInProject = inPossibleDevice {
      let newComponent = ComponentInProject (self.ebUndoManager)
      newComponent.mDevice = newDeviceInProject
      newComponent.mSelectedPackage = newDeviceInProject.mPackages [0]
    //--- Fix index for component name
      newComponent.mNamePrefix = newDeviceInProject.mPrefix
      var idx = 1
      for component in self.rootObject.mComponents {
        if newComponent.mNamePrefix == component.mNamePrefix {
          idx = max (idx, component.mNameIndex + 1)
        }
      }
      newComponent.mNameIndex = idx
      self.rootObject.mComponents.append (newComponent)
      self.mComponentController.setSelection ([newComponent])
    }
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
    self.addComponent (fromPossibleDevice: possibleDevice)
  }

  //····················································································································

  internal func duplicate (component inComponent : ComponentInProject) -> ComponentInProject {
    let newComponent = ComponentInProject (self.ebUndoManager)
    newComponent.mDevice = inComponent.mDevice
    newComponent.mSelectedPackage = inComponent.mSelectedPackage
    newComponent.mComponentValue = inComponent.mComponentValue
  //--- Fix index for component name
    newComponent.mNamePrefix = inComponent.mNamePrefix
    var idx = 1
    for component in self.rootObject.mComponents {
      if newComponent.mNamePrefix == component.mNamePrefix {
        idx = max (idx, component.mNameIndex + 1)
      }
    }
    newComponent.mNameIndex = idx
    self.rootObject.mComponents.append (newComponent)
    return newComponent
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
