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

  internal func renameDeviceSymbolTypePinDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
    let selectedSymbolTypeName = self.mDeviceSymbolTableView?.selectedItemRightTitle,
    let selectedPinName = self.mDeviceSymbolTypePinsTableView?.selectedItemTitle,
    let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var deviceSymbolPinNameSet = Set <String> ()
      let deviceSymbolDictionary = selectedDevice.deviceSymbolDictionary!
      for (symbolIdentifier, info) in deviceSymbolDictionary {
        if symbolIdentifier.symbolTypeName == selectedSymbolTypeName  {
          for assignment in info.assignments {
            if let pin = assignment.pin, pin.symbol == symbolIdentifier {
              deviceSymbolPinNameSet.insert (pin.pinName)
            }
          }
        }
      }
      deviceSymbolPinNameSet.remove (selectedPinName)
      self.mRenameDeviceTitleTextField?.stringValue = "Rename Symbol Type Pin"
      self.mRenameDeviceNameTextField?.stringValue = selectedPinName
      self.mRenameDeviceNameTextField?.mControlTextDidChangeCallBack = self.proposedNameDidChange
      self.mRenameDeviceNameTextField?.isContinuous = true
      self.mRenameDeviceNameTextField?.mTextFieldUserInfo = (selectedPinName, deviceSymbolPinNameSet, false)
      self.mRenameDeviceErrorMessageTextField?.stringValue = ""
      self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedPinName)\" name"
      self.mRenameDeviceValidationButton?.isEnabled = true
      self.windowForSheet?.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop, let newName = self.mRenameDeviceNameTextField?.stringValue {
          for padAssignment in selectedDevice.mPadAssignments.values {
            if let pin = padAssignment.mPin,
            pin.mSymbolTypeName == selectedSymbolTypeName,
            pin.mPinName == selectedPinName {
              pin.mPinName = newName
            }
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDeviceSymbolInstanceDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
    let selectedSymbolInstanceName = self.mDeviceSymbolTableView?.selectedItemLeftTitle,
    let selectedSymbolTypeName = self.mDeviceSymbolTableView?.selectedItemRightTitle,
    let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var deviceSymbolInstanceNameSet = Set <String> ()
      let deviceSymbolDictionary = selectedDevice.deviceSymbolDictionary!
      for (symbolIdentifier, _) in deviceSymbolDictionary {
        if symbolIdentifier.symbolTypeName == selectedSymbolTypeName {
          deviceSymbolInstanceNameSet.insert (symbolIdentifier.symbolInstanceName)
        }
      }
      deviceSymbolInstanceNameSet.remove (selectedSymbolInstanceName)
      self.mRenameDeviceTitleTextField?.stringValue = "Rename Symbol Instance"
      self.mRenameDeviceNameTextField?.stringValue = selectedSymbolInstanceName
      self.mRenameDeviceNameTextField?.mControlTextDidChangeCallBack = self.proposedNameDidChange
      self.mRenameDeviceNameTextField?.isContinuous = true
      self.mRenameDeviceNameTextField?.mTextFieldUserInfo = (selectedSymbolInstanceName, deviceSymbolInstanceNameSet, true)
      self.mRenameDeviceErrorMessageTextField?.stringValue = ""
      self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedSymbolInstanceName)\" name"
      self.mRenameDeviceValidationButton?.isEnabled = true
      self.windowForSheet?.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop, let newName = self.mRenameDeviceNameTextField?.stringValue {
          for symbolInstance in selectedDevice.mSymbols.values {
            if let symbolType = symbolInstance.mSymbolType,
            symbolType.mSymbolTypeName == selectedSymbolTypeName,
            symbolInstance.mSymbolInstanceName == selectedSymbolInstanceName {
              symbolInstance.mSymbolInstanceName = newName
            }
          }
          for padAssignment in selectedDevice.mPadAssignments.values {
            if let pin = padAssignment.mPin,
            pin.mSymbolTypeName == selectedSymbolTypeName,
            pin.mSymbolInstanceName == selectedSymbolInstanceName {
              pin.mSymbolInstanceName = newName
            }
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDeviceSymbolTypeDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
    let selectedSymbolTypeName = self.mDeviceSymbolTypeTableView?.selectedItemTitle,
    let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var deviceSymbolTypeNameSet = Set <String> ()
      let deviceSymbolDictionary = selectedDevice.deviceSymbolDictionary!
      for (symbolIdentifier, _) in deviceSymbolDictionary {
        deviceSymbolTypeNameSet.insert (symbolIdentifier.symbolTypeName)
      }
      deviceSymbolTypeNameSet.remove (selectedSymbolTypeName)
      self.mRenameDeviceTitleTextField?.stringValue = "Rename Symbol Type"
      self.mRenameDeviceNameTextField?.stringValue = selectedSymbolTypeName
      self.mRenameDeviceNameTextField?.mControlTextDidChangeCallBack = self.proposedNameDidChange
      self.mRenameDeviceNameTextField?.isContinuous = true
      self.mRenameDeviceNameTextField?.mTextFieldUserInfo = (selectedSymbolTypeName, deviceSymbolTypeNameSet, false)
      self.mRenameDeviceErrorMessageTextField?.stringValue = ""
      self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedSymbolTypeName)\" name"
      self.mRenameDeviceValidationButton?.isEnabled = true
      self.windowForSheet?.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop, let newName = self.mRenameDeviceNameTextField?.stringValue {
          for symbolInstance in selectedDevice.mSymbols.values {
            if let symbolType = symbolInstance.mSymbolType, symbolType.mSymbolTypeName == selectedSymbolTypeName {
              symbolType.mSymbolTypeName = newName
            }
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDevicePackageDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
    let selectedPackageName = self.mDevicePackageTableView?.selectedItemTitle,
    let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var devicePackageNameSet = Set <String> ()
      for package in selectedDevice.mPackages.values {
        devicePackageNameSet.insert (package.mPackageName)
      }
      devicePackageNameSet.remove (selectedPackageName)
      self.mRenameDeviceTitleTextField?.stringValue = "Rename Package"
      self.mRenameDeviceNameTextField?.stringValue = selectedPackageName
      self.mRenameDeviceNameTextField?.mControlTextDidChangeCallBack = self.proposedNameDidChange
      self.mRenameDeviceNameTextField?.isContinuous = true
      self.mRenameDeviceNameTextField?.mTextFieldUserInfo = (selectedPackageName, devicePackageNameSet, false)
      self.mRenameDeviceErrorMessageTextField?.stringValue = ""
      self.mRenameDeviceValidationButton?.title = "Keep \"\(selectedPackageName)\" name"
      self.mRenameDeviceValidationButton?.isEnabled = true
      self.windowForSheet?.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop, let newName = self.mRenameDeviceNameTextField?.stringValue {
          for package in selectedDevice.mPackages.values {
            if package.mPackageName == selectedPackageName {
              package.mPackageName = newName
            }
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDeviceDialog () {
    if self.projectDeviceController.selectedArray.count == 1, let panel = self.mRenameDevicePanel {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      let selectedDeviceName = selectedDevice.mDeviceName
      var deviceNameSet = Set <String> ()
      for device in self.rootObject.mDevices.values {
        deviceNameSet.insert (device.mDeviceName)
      }
      deviceNameSet.remove (selectedDeviceName)
      self.mRenameDeviceTitleTextField?.stringValue = "Rename Device"
      self.mRenameDeviceNameTextField?.stringValue = selectedDeviceName
      self.mRenameDeviceNameTextField?.mControlTextDidChangeCallBack = self.proposedNameDidChange
      self.mRenameDeviceNameTextField?.isContinuous = true
      self.mRenameDeviceNameTextField?.mTextFieldUserInfo = (selectedDeviceName, deviceNameSet, false)
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

  @objc private func proposedNameDidChange () {
    if let proposedName = self.mRenameDeviceNameTextField?.stringValue,
       let (selectedName, nameSet, allowEmptyName) = self.mRenameDeviceNameTextField?.mTextFieldUserInfo as? (String, Set <String>, Bool) {
      if (proposedName == "") && !allowEmptyName {
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
