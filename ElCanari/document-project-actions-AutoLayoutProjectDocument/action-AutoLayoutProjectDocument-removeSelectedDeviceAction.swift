//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {
  @objc func removeSelectedDeviceAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
        let selectedDevices = self.projectDeviceController.selectedArray_property.propval
        var allDevices = self.rootObject.mDevices_property.propval
        for device in selectedDevices.values {
          if let idx = allDevices.firstIndex(of: device) {
            allDevices.remove(at: idx)
          }
        }
        self.rootObject.mDevices_property.setProp (allDevices)
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————