//
//  extension-SheetInProject.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  internal func wiresAt (point inPoint : CanariPoint) -> [WireInSchematics] {
    let width = cocoaToCanariUnit (CGFloat (g_Preferences!.symbolDrawingWidthMultipliedByTen) / 5.0)
    var result = [WireInSchematics]  ()
    for object in self.mObjects {
      if let wire = object as? WireInSchematics {
        let p1 = wire.mP1!.location!
        let p2 = wire.mP2!.location!
        let segment = CanariSegment (x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, width: width)
        if segment.strictlyContains (point: inPoint) {
          result.append (wire)
        }
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
