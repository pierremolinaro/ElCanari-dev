//
//  extension-AutoLayoutProjectDocument-remove-components.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 12/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeSelectedComponents () {
    if self.componentController.selectedArray.count == 0 {
      NSSound.beep ()
    }else{
      var inSchematicsOrInBoard = false
      for component in self.componentController.selectedArray.values {
        for symbol in component.mSymbols.values {
          if symbol.mSheet != nil {
            inSchematicsOrInBoard = true
          }
        }
        if component.mRoot != nil {
          inSchematicsOrInBoard = true
        }
      }
      if !inSchematicsOrInBoard {
        self.performRemoveSelectedComponents ()
      }else{
        let alert = NSAlert ()
        if self.componentController.selectedArray.count > 1 {
          alert.messageText = "Removed components have symbols in schematic and/or package in board."
        }else{
          alert.messageText = "Removed component has symbols in schematic and/or package in board."
        }
        _ = alert.addButton (withTitle: "Remove")
        _ = alert.addButton (withTitle: "Cancel")
        alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
          if response == .alertFirstButtonReturn {
            DispatchQueue.main.async { self.performRemoveSelectedComponents () }
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performRemoveSelectedComponents () {
    self.registerUndoForTriggeringStandAlonePropertyComputationForProject ()
    for component in self.componentController.selectedArray.values {
      if let idx = self.rootObject.mComponents.firstIndex (of: component) {
      //--- Remove all symbols from schematics sheets
        for symbol in component.mSymbols.values {
          symbol.mSheet = nil
          symbol.operationBeforeRemoving ()
        }
        component.mSymbols = EBReferenceArray ()
     //--- Remove package from board
        component.operationBeforeRemoving ()
        component.mSelectedPackage = nil
        component.mRoot = nil
        component.mValueFont = nil
        component.mNameFont = nil
        component.mConnectors = EBReferenceArray ()
        component.mSymbols = EBReferenceArray ()
        component.componentAvailablePackagesController.unbind_model ()
      //--- Remove from component list
        self.rootObject.mComponents.remove (at: idx)
      //--- Adapt remaining component names
        component.mDevice = nil
        self.performNormalizeComponentNames ()
      }
    }
  //--- Remove unused components models from embedded library
    for device in self.rootObject.mDevices.values {
      if device.mComponents.count == 0 {
        self.rootObject.mDevices_property.remove (device)
      }
    }
    self.triggerStandAlonePropertyComputationForProject ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
