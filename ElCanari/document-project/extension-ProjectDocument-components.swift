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
  //--- Append component
    if let newDeviceInProject = possibleNewDeviceInProject {
      let newComponent = ComponentInProject (self.ebUndoManager)
      newComponent.mDevice = newDeviceInProject
      newComponent.mSelectedPackage = newDeviceInProject.mPackages [0]
    //--- Fix index for component name
      var idx = 1
      for component in self.rootObject.mComponents {
        if newComponent.mDevice!.mPrefix == component.mDevice!.mPrefix {
          idx = component.mNameIndex + 1
        }
      }
      newComponent.mNameIndex = idx
      self.rootObject.mComponents.append (newComponent)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
