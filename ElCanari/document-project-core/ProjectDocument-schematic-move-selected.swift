//
//  ProjectDocument-schematic-move-selected.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @IBAction func moveSelectedToSheetInSchematicsAction (_ inSender : Any?) {
    let (selectedObjects, selectedPoints) = self.selectAllConnectedElementsInSchematics ()
  //--- Display dialog for selecting destination sheet
    if let selectedSheet = self.rootObject.mSelectedSheet,
       let window = self.windowForSheet {
    //---
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
    //---
      layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Move Selected Element to Sheet", bold: true, size: .regular))
      layoutView.appendFlexibleSpace ()
    //--- Populate pop up button
      let popUpButton = AutoLayoutBase_NSPopUpButton (pullsDown: false, size: .regular).expandableWidth ()
      layoutView.appendView (popUpButton)
      layoutView.appendFlexibleSpace ()
      var idx = 0
      for sheet in self.rootObject.mSheets.values {
        popUpButton.addItem (withTitle: "\(sheet.mSheetTitle) — \(idx + 1)/\(self.rootObject.mSheets.count)")
        popUpButton.lastItem?.representedObject = sheet
        if selectedSheet === sheet {
          popUpButton.selectItem (at: idx)
        }
        idx += 1
      }
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false))
        hStack.appendFlexibleSpace ()
        let okButton = AutoLayoutSheetDefaultOkButton (title: "Mode Selected Elements", size: .regular, sheet: panel, isInitialFirstResponder: true)
        hStack.appendView (okButton)
        layoutView.appendView (hStack)
      }
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      window.beginSheet (panel) { inResponse in
        if inResponse == .stop,
            let sheet = popUpButton.selectedItem?.representedObject as? SheetInProject {
          for point in selectedPoints.values {
            point.mSheet = sheet
          }
          for object in selectedObjects.values {
            object.mSheet = sheet
          }
          self.rootObject.mSelectedSheet = sheet
          self.schematicObjectsController.setSelection (Array (selectedObjects.values))
        }
      }
    }
  }





//    //--- Populate pop up button
//      popup.removeAllItems ()
//      var idx = 0
//      for sheet in self.rootObject.mSheets.values {
//        popup.addItem (withTitle: "\(sheet.mSheetTitle) — \(idx + 1)/\(self.rootObject.mSheets.count)")
//        popup.lastItem?.representedObject = sheet
//        if selectedSheet === sheet {
//          popup.selectItem (at: idx)
//        }
//        idx += 1
//      }
//      window.beginSheet (panel) { (inModalResponse) in
//        if inModalResponse == .stop, let sheet = popup.selectedItem?.representedObject as? SheetInProject {
//          for point in selectedPoints.values {
//            point.mSheet = sheet
//          }
//          for object in selectedObjects.values {
//            object.mSheet = sheet
//          }
//          self.rootObject.mSelectedSheet = sheet
//          self.schematicObjectsController.setSelection (Array (selectedObjects.values))
//        }
//      }
//    }
//  }

  //····················································································································


}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
