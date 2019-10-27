//
//  ProjectDocument-rename-in-library.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/08/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func renameDevicePackageNameDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
    let selectedPackageName = self.mDevicePackageTableView?.selectedItemTitle,
    let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var devicePackageNameSet = Set <String> ()
      for package in selectedDevice.mPackages {
        devicePackageNameSet.insert (package.mPackageName)
      }
      devicePackageNameSet.remove (selectedPackageName)
      self.mRenameDeviceTitleTextField?.stringValue = "Rename Package With A New Name"
      self.mRenameDeviceNameTextField?.stringValue = selectedPackageName
      self.mRenameDeviceNameTextField?.mControlTextDidChangeCallBack = self.proposedDeviceNameDidChange
      self.mRenameDeviceNameTextField?.isContinuous = true
      self.mRenameDeviceNameTextField?.mUserInfo = (selectedPackageName, devicePackageNameSet)
      self.mRenameDeviceErrorMessageTextField?.stringValue = ""
      self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedPackageName)\" name"
      self.mRenameDeviceValidationButton?.isEnabled = true
      self.windowForSheet?.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop, let newName = self.mRenameDeviceNameTextField?.stringValue {
          for package in selectedDevice.mPackages {
            if package.mPackageName == selectedPackageName {
              package.mPackageName = newName
            }
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDeviceNameDialog () {
    if self.projectDeviceController.selectedArray.count == 1, let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      let selectedDeviceName = selectedDevice.mDeviceName
      var deviceNameSet = Set <String> ()
      for device in self.rootObject.mDevices {
        deviceNameSet.insert (device.mDeviceName)
      }
      deviceNameSet.remove (selectedDeviceName)
      self.mRenameDeviceTitleTextField?.stringValue = "Rename Device With A New Name"
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
       let (selectedName, nameSet) = self.mRenameDeviceNameTextField?.mUserInfo as? (String, Set <String>) {
      if proposedName == "" {
        self.mRenameDeviceErrorMessageTextField?.stringValue = "Proposed Name is empty"
        self.mRenameDeviceValidationButton?.title = "Cannot rename"
        self.mRenameDeviceValidationButton?.isEnabled = false
      }else if proposedName == selectedName {
        self.mRenameDeviceErrorMessageTextField?.stringValue = ""
        self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedName)\" name"
        self.mRenameDeviceValidationButton?.isEnabled = true
      }else if nameSet.contains (proposedName) {
        self.mRenameDeviceErrorMessageTextField?.stringValue = "This name is already used"
        self.mRenameDeviceValidationButton?.title = "Cannot rename to \"\(selectedName)\""
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
