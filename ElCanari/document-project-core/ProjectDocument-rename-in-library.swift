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
         let selectedPinName = self.mDeviceSymbolTypePinsTableView?.selectedItemTitle {
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
      self.renameDialog (title: "Rename Symbol Type Pin",
                         initialName: selectedPinName,
                         referenceNameSet: deviceSymbolPinNameSet,
                         allowsEmptyName: false) { (inNewName) in
        for padAssignment in selectedDevice.mPadAssignments.values {
          if let pin = padAssignment.mPin,
          pin.mSymbolTypeName == selectedSymbolTypeName,
          pin.mPinName == selectedPinName {
            pin.mPinName = inNewName
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDeviceSymbolInstanceDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
          let selectedSymbolInstanceName = self.mDeviceSymbolTableView?.selectedItemLeftTitle,
          let selectedSymbolTypeName = self.mDeviceSymbolTableView?.selectedItemRightTitle {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var deviceSymbolInstanceNameSet = Set <String> ()
      let deviceSymbolDictionary = selectedDevice.deviceSymbolDictionary!
      for (symbolIdentifier, _) in deviceSymbolDictionary {
        if symbolIdentifier.symbolTypeName == selectedSymbolTypeName {
          deviceSymbolInstanceNameSet.insert (symbolIdentifier.symbolInstanceName)
        }
      }
      deviceSymbolInstanceNameSet.remove (selectedSymbolInstanceName)

      self.renameDialog (title: "Rename Symbol Instance",
                         initialName: selectedSymbolInstanceName,
                         referenceNameSet: deviceSymbolInstanceNameSet,
                         allowsEmptyName: true) { (inNewName) in
        for symbolInstance in selectedDevice.mSymbols.values {
          if let symbolType = symbolInstance.mSymbolType,
          symbolType.mSymbolTypeName == selectedSymbolTypeName,
          symbolInstance.mSymbolInstanceName == selectedSymbolInstanceName {
            symbolInstance.mSymbolInstanceName = inNewName
          }
        }
        for padAssignment in selectedDevice.mPadAssignments.values {
          if let pin = padAssignment.mPin,
          pin.mSymbolTypeName == selectedSymbolTypeName,
          pin.mSymbolInstanceName == selectedSymbolInstanceName {
            pin.mSymbolInstanceName = inNewName
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDeviceSymbolTypeDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
    let selectedSymbolTypeName = self.mDeviceSymbolTypeTableView?.selectedItemTitle {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var deviceSymbolTypeNameSet = Set <String> ()
      let deviceSymbolDictionary = selectedDevice.deviceSymbolDictionary!
      for (symbolIdentifier, _) in deviceSymbolDictionary {
        deviceSymbolTypeNameSet.insert (symbolIdentifier.symbolTypeName)
      }
      deviceSymbolTypeNameSet.remove (selectedSymbolTypeName)

      self.renameDialog (title: "Rename Symbol Type",
                         initialName: selectedSymbolTypeName,
                         referenceNameSet: deviceSymbolTypeNameSet,
                         allowsEmptyName: false) { (inNewName) in
        for symbolInstance in selectedDevice.mSymbols.values {
          if let symbolType = symbolInstance.mSymbolType, symbolType.mSymbolTypeName == selectedSymbolTypeName {
            symbolType.mSymbolTypeName = inNewName
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDevicePackageDialog () {
    if self.projectDeviceController.selectedArray.count == 1,
           let selectedPackageName = self.mDevicePackageTableView?.selectedItemTitle  {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      var devicePackageNameSet = Set <String> ()
      for package in selectedDevice.mPackages.values {
        devicePackageNameSet.insert (package.mPackageName)
      }
      devicePackageNameSet.remove (selectedPackageName)

      self.renameDialog (title: "Rename Package",
                         initialName: selectedPackageName,
                         referenceNameSet: devicePackageNameSet,
                         allowsEmptyName: false) { (inNewName) in
        for package in selectedDevice.mPackages.values {
          if package.mPackageName == selectedPackageName {
            package.mPackageName = inNewName
          }
        }
      }
    }
  }

  //····················································································································

  internal func renameDeviceDialog () {
    if self.projectDeviceController.selectedArray.count == 1 {
      let selectedDevice = self.projectDeviceController.selectedArray [0]
      let selectedDeviceName = selectedDevice.mDeviceName
      var deviceNameSet = Set <String> ()
      for device in self.rootObject.mDevices.values {
        deviceNameSet.insert (device.mDeviceName)
      }
      deviceNameSet.remove (selectedDeviceName)

      self.renameDialog (title: "Rename Device",
                         initialName: selectedDeviceName,
                         referenceNameSet: deviceNameSet,
                         allowsEmptyName: false) { (inNewName) in
        selectedDevice.mDeviceName = inNewName
      }
    }
  }

  //····················································································································

  fileprivate func renameDialog (title inTitle : String,
                                 initialName inInitialName : String,
                                 referenceNameSet inRefNameSet : Set <String>,
                                 allowsEmptyName inAllowsEmptyName : Bool,
                                 _ inAcceptedCallBack : @escaping (_ inNewName : String) -> Void) {
    let panel = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 550, height: 200),
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
  //---
    let leftColumn = AutoLayoutVerticalStackView ()
  //--- Title
    leftColumn.appendView (AutoLayoutStaticLabel (title: inTitle, bold: true, size: .regular).set (alignment: .center).expandableWidth ())
    leftColumn.appendFlexibleSpace ()
  //--- New Name
    let newNameTextField = AutoLayoutTextField (width: 100, size: .regular).expandableWidth ()
    newNameTextField.stringValue = inInitialName
    do {
      let hStack = AutoLayoutHorizontalStackView ()
      hStack.appendView (AutoLayoutStaticLabel (title: "New Name", bold: false, size: .regular))
      hStack.appendView (newNameTextField)
      leftColumn.appendView (hStack)
    }
  //--- Error Label
    let errorLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .regular).expandableWidth ().setRedTextColor ()
    leftColumn.appendView (errorLabel)
    leftColumn.appendFlexibleSpace ()
  //--- Right Column
    let rightColumn = AutoLayoutVerticalStackView ()
    rightColumn.appendView (AutoLayoutStaticLabel (title: "Danger Zone", bold: true, size: .regular).set (alignment: .center).setRedTextColor().expandableWidth ())
    rightColumn.appendFlexibleSpace ()
    rightColumn.appendView (AutoLayoutStaticImageView (name: "danger"))
    rightColumn.appendFlexibleSpace ()
  //---
    let columnsView = AutoLayoutHorizontalStackView ()
    columnsView.appendView (leftColumn)
    columnsView.appendFlexibleSpace ()
    columnsView.appendView (rightColumn)
    let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
    layoutView.appendView (columnsView)
  //--- Validation
    let okButton = AutoLayoutSheetDefaultOkButton (title: "Ok", size: .regular, sheet: panel, isInitialFirstResponder: true)
    do{
      let hStack = AutoLayoutHorizontalStackView ()
      hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false))
      hStack.appendFlexibleSpace ()
      hStack.appendView (okButton)
      layoutView.appendView (hStack)
    }
  //---
    newNameTextField.mTextDidChange = { [weak self] in
      self?.proposedNameDidChange (
        initialName: inInitialName,
        proposedName: newNameTextField.stringValue,
        referenceNameSet: inRefNameSet,
        allowsEmptyName: inAllowsEmptyName,
        okButton: okButton,
        errorLabel: errorLabel
      )
    }
  //---
    panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
    self.windowForSheet?.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
      if inResponse == .stop {
        let newName = newNameTextField.stringValue
        inAcceptedCallBack (newName)
      }
    }
  }

  //····················································································································

  fileprivate func proposedNameDidChange (initialName inInitialName : String,
                                          proposedName inProposedName : String,
                                          referenceNameSet inRefNameSet : Set <String>,
                                          allowsEmptyName inAllowsEmptyName : Bool,
                                          okButton inOkButton : AutoLayoutSheetDefaultOkButton,
                                          errorLabel inErrorLabel : AutoLayoutStaticLabel) {
    if (inProposedName.isEmpty) && !inAllowsEmptyName {
      inErrorLabel.stringValue = "New Name is empty"
      inOkButton.title = "Cannot rename"
      inOkButton.isEnabled = false
    }else if inProposedName == inInitialName {
      inErrorLabel.stringValue = ""
      inOkButton.title = "Keep '\(inInitialName)' name"
      inOkButton.isEnabled = true
    }else if inRefNameSet.contains (inProposedName) {
      inErrorLabel.stringValue = "This name is already used"
      inOkButton.title = "Cannot rename to '\(inProposedName)'"
      inOkButton.isEnabled = false
    }else{
      inErrorLabel.stringValue = ""
      inOkButton.title = "Rename as '\(inProposedName)'"
      inOkButton.isEnabled = true
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
