//
//  extension-AutoLayoutProjectDocument-remove-components.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 12/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

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
        alert.addButton (withTitle: "Remove")
        alert.addButton (withTitle: "Cancel")
        alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
          if response == .alertFirstButtonReturn {
            self.performRemoveSelectedComponents ()
          }
        }
      }
    }
  }

  //····················································································································

  private func performRemoveSelectedComponents () {
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
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————