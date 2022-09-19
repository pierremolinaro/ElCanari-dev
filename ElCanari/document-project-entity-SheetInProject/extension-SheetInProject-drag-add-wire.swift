//
//  extension-SheetInProject-drag-add-wire.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  func performAddWireDragOperation (_ inUnalignedDraggingLocation : NSPoint,
                                    newNetCreator inNewNetCreator : @MainActor () -> NetInProject) -> WireInSchematic? {
    let p = inUnalignedDraggingLocation.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let possibleWire : WireInSchematic?
    let p1 = CanariPoint (x: p.x, y: p.y)
    let p2 = CanariPoint (x: p.x + WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP, y: p.y + WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP)
  //--- Find points at p1 and p2
    let pointsAtP1 = self.pointsInSchematics (at: p1)
    let pointsAtP2 = self.pointsInSchematics (at: p2)
  //---
    if (pointsAtP1.count == 1) && (pointsAtP2.count == 1) && (pointsAtP1 [0].mNet === pointsAtP2 [0].mNet) {
      let wire = WireInSchematic (self.undoManager)
      possibleWire = wire
      wire.mP1 = pointsAtP1 [0]
      wire.mP2 = pointsAtP2 [0]
    }else if (pointsAtP1.count == 1) && (pointsAtP2.count == 0) { // Use point at p1, create a point at p2
      let wire = WireInSchematic (self.undoManager)
      possibleWire = wire
      wire.mP1 = pointsAtP1 [0]
      let point = PointInSchematic (self.undoManager)
      point.mX = p2.x
      point.mY = p2.y
      point.mNet = wire.mP1?.mNet
      wire.mP2 = point
      self.mPoints.append (point)
      if (pointsAtP1 [0].mNet == nil) && (pointsAtP1 [0].mSymbol != nil) {
        point.mNet = inNewNetCreator ()
        point.propagateNetToAccessiblePointsThroughtWires ()
      }
    }else if (pointsAtP1.count == 0) && (pointsAtP2.count == 1) { // Use point at p2, create a point at p1
      let wire = WireInSchematic (self.undoManager)
      possibleWire = wire
      wire.mP2 = pointsAtP2 [0]
      let point = PointInSchematic (self.undoManager)
      point.mX = p1.x
      point.mY = p1.y
      point.mNet = wire.mP2?.mNet
      wire.mP1 = point
      self.mPoints.append (point)
      if (pointsAtP2 [0].mNet == nil) && (pointsAtP2 [0].mSymbol != nil) {
        point.mNet = inNewNetCreator ()
        point.propagateNetToAccessiblePointsThroughtWires ()
      }
    }else{ // Assign no net
      let wire = WireInSchematic (self.undoManager)
      possibleWire = wire
      let point1 = PointInSchematic (self.undoManager)
      point1.mX = p1.x
      point1.mY = p1.y
      wire.mP1 = point1
      self.mPoints.append (point1)
      let point2 = PointInSchematic (self.undoManager)
      point2.mX = p2.x
      point2.mY = p2.y
      wire.mP2 = point2
      self.mPoints.append (point2)
      point1.mNet = inNewNetCreator ()
      point1.propagateNetToAccessiblePointsThroughtWires ()
    }
  //--- Enter wire and select it
    if let wire = possibleWire {
      self.mObjects.append (wire)
    }
  //---
    return possibleWire
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

