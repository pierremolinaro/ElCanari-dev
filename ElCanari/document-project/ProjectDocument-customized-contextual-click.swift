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
  //---
    return menu
  }

  //····················································································································

  @objc internal func addNCToPin (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematics {
      let nc = NCInSchematics (self.ebUndoManager)
      nc.mPoint = point
      nc.mOrientation = self.findPreferredNCOrientation (for: point)
      self.rootObject.mSelectedSheet?.mObjects.append (nc)
      self.mSchematicsObjectsController.setSelection ([nc])
    }
  }

  //····················································································································

  private func findPreferredNCOrientation (for inPoint : PointInSchematics) -> QuadrantRotation {
  //--- Find the rectangle of all pins of current symbol
    let symbol = inPoint.mSymbol!
    let symbolInfo = symbol.symbolInfo!
    var xMin = Int.max
    var yMin = Int.max
    var xMax = Int.min
    var yMax = Int.min
    for pin in symbolInfo.pins {
      if pin.pinName == inPoint.mSymbolPinName {
        if xMin > pin.pinLocation.x {
          xMin = pin.pinLocation.x
        }
        if yMin > pin.pinLocation.y {
          yMin = pin.pinLocation.y
        }
        if xMax < pin.pinLocation.x {
          xMax = pin.pinLocation.x
        }
        if yMax < pin.pinLocation.y {
          yMax = pin.pinLocation.y
        }
      }
    }
  //---
    let pinLocation = inPoint.location!
    if pinLocation.x == xMin {
      return .rotation180
    }else if pinLocation.x == xMax {
      return .rotation0
    }else if pinLocation.y == yMin {
      return .rotation270
    }else if pinLocation.y == yMax {
      return .rotation90
    }else{
      return .rotation0
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
