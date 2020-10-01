//
//  extension-SheetInProject.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension SheetInProject {

  //····················································································································

  internal func wiresStrictlyContaining (point inPoint : CanariPoint) -> [WireInSchematic] {
    let canariAlignedPoint = inPoint.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let width = cocoaToCanariUnit (CGFloat (prefs_symbolDrawingWidthMultipliedByTen) / 2.5)
    var result = [WireInSchematic]  ()
    for object in self.mObjects {
      if let wire = object as? WireInSchematic {
        let p1 = wire.mP1!.location!
        let alignedP1 = p1.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
        if canariAlignedPoint != alignedP1 {
          let p2 = wire.mP2!.location!
          let alignedP2 = p2.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
          if canariAlignedPoint != alignedP2 {
            let segment = CanariSegment (x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, width: width)
            if segment.strictlyContains (point: inPoint) {
              result.append (wire)
            }
          }
        }
      }
    }
    return result
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
