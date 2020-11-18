//
//  ProjectDocument-schematic-move-selected.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/06/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction func moveSelectedToSheetInSchematicsAction (_ inSender : Any?) {
    let (selectedObjects, selectedPoints) = self.selectAllConnectedElementsInSchematics ()
  //--- Display dialog for selecting destination sheet
    if let selectedSheet = self.rootObject.mSelectedSheet,
       let window = self.windowForSheet,
       let panel = self.mMoveSelectedObjectsToSheetPanel,
       let popup = self.mMoveSelectedObjectsToSheetPopUpButton {
    //--- Populate pop up button
      popup.removeAllItems ()
      var idx = 0
      for sheet in self.rootObject.mSheets {
        popup.addItem (withTitle: "\(sheet.mSheetTitle) — \(idx + 1)/\(self.rootObject.mSheets.count)")
        popup.lastItem?.representedObject = sheet
        if selectedSheet === sheet {
          popup.selectItem (at: idx)
        }
        idx += 1
      }
      window.beginSheet (panel) { (inModalResponse) in
        if inModalResponse == .stop, let sheet = popup.selectedItem?.representedObject as? SheetInProject {
          for point in selectedPoints {
            point.mSheet = sheet
          }
          for object in selectedObjects {
            object.mSheet = sheet
          }
          self.rootObject.mSelectedSheet = sheet
          self.schematicObjectsController.setSelection (Array (selectedObjects))
        }
      }
    }
  }

  //····················································································································


}

//----------------------------------------------------------------------------------------------------------------------
