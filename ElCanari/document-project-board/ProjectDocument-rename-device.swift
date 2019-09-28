//
//  ProjectDocument-rename-component.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/08/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func renameDeviceDialog () {
    if self.projectDeviceController.selectedArray.count == 1, let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      let selectedDeviceName = selectedDevice.mDeviceName
      var deviceNameSet = Set <String> ()
      for device in self.rootObject.mDevices {
        deviceNameSet.insert (device.mDeviceName)
      }
      deviceNameSet.remove (selectedDeviceName)
      self.mRenameDeviceNameTextField?.stringValue = selectedDeviceName
      self.mRenameDeviceNameTextField?.mControlTextDidChangeCallBack = self.proposedDeviceNameDidChange
      self.mRenameDeviceNameTextField?.isContinuous = true
      self.mRenameDeviceNameTextField?.mUserInfo = (selectedDeviceName, deviceNameSet)
      self.mRenameDeviceErrorMessageTextField?.stringValue = ""
      self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedDeviceName)\" name"
      self.mRenameDeviceValidationButton?.isEnabled = true
      self.windowForSheet?.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop, let newName = self.mRenameDeviceNameTextField?.stringValue {
          selectedDevice.mDeviceName = newName
        }
      }
    }
  }

  //····················································································································

  @objc private func proposedDeviceNameDidChange () {
    if let proposedName = self.mRenameDeviceNameTextField?.stringValue,
       let (selectedDeviceName, deviceNameSet) = self.mRenameDeviceNameTextField?.mUserInfo as? (String, Set <String>) {
      if proposedName == "" {
        self.mRenameDeviceErrorMessageTextField?.stringValue = "Proposed Name is empty"
        self.mRenameDeviceValidationButton?.title = "Cannot rename"
        self.mRenameDeviceValidationButton?.isEnabled = false
      }else if proposedName == selectedDeviceName {
        self.mRenameDeviceErrorMessageTextField?.stringValue = ""
        self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedDeviceName)\" name"
        self.mRenameDeviceValidationButton?.isEnabled = true
      }else if deviceNameSet.contains (proposedName) {
        self.mRenameDeviceErrorMessageTextField?.stringValue = "This name is already used by an other device"
        self.mRenameDeviceValidationButton?.title = "Cannot rename to \"\(selectedDeviceName)\""
        self.mRenameDeviceValidationButton?.isEnabled = false
      }else{
        self.mRenameDeviceErrorMessageTextField?.stringValue = ""
        self.mRenameDeviceValidationButton?.title = "Rename as \"\(proposedName)\""
        self.mRenameDeviceValidationButton?.isEnabled = true
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
