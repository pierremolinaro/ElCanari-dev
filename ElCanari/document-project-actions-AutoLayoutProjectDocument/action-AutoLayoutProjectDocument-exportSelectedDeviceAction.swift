//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {
  @objc func exportSelectedDeviceAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
        let selectedDevices = self.projectDeviceController.selectedArray_property.propval
        var messages = [String] ()
        for device in selectedDevices.values {
          if device.mDeviceFileData.count > 0 {
            let savePanel = NSSavePanel ()
            savePanel.allowedFileTypes = [ElCanariDevice_EXTENSION]
            savePanel.allowsOtherFileTypes = false
            savePanel.nameFieldStringValue = device.mDeviceName + "." + ElCanariDevice_EXTENSION
            savePanel.beginSheetModal (for: self.windowForSheet!) { (_ inResponse : NSApplication.ModalResponse) in
              DispatchQueue.main.async {
                if inResponse == .OK, let url = savePanel.url {
                  try? device.mDeviceFileData.write (to: url)
                }
              }
            }
          }else{
            messages.append ("Cannot export \(device.mDeviceName) device: no embedded data")
          }
        }
        if messages.count > 0 {
          let alert = NSAlert ()
          alert.messageText = "Error"
          alert.informativeText = messages.joined (separator: "\n")
          alert.beginSheetModal (for: self.windowForSheet!, completionHandler: nil)
        }
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
