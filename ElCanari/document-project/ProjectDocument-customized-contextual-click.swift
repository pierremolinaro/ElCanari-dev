//
//  ProjectDocument-customized-contextual-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func populateContextualClickOnSchematics (_ inMouseDownPoint : CanariPoint) -> NSMenu {
    let menu = NSMenu ()
  //--- Add NC ?
     for object in self.rootObject.mSelectedSheet?.mObjects ?? [] {
       if let point = object as? PointInSchematics {
         if point.mNC == nil,
            point.mWiresP1s.count == 0,
            point.mWiresP2s.count == 0,
            let location = point.location,
            inMouseDownPoint == location {
           let menuItem = NSMenuItem (title: "Add NC", action: #selector (CustomizedProjectDocument.addNCToPin (_:)), keyEquivalent: "")
           menuItem.target = self
           menuItem.representedObject = point
           menu.addItem (menuItem)
         }
       }
     }
     menu.addItem (withTitle: "Nada", action: nil, keyEquivalent: "")
  //---
    return menu
  }

  //····················································································································

  @objc func addNCToPin (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematics {
      let nc = NCInSchematics (self.ebUndoManager)
      nc.mPoint = point
      self.rootObject.mSelectedSheet?.mObjects.append (nc)
      self.mSchematicsObjectsController.setSelection ([nc])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
