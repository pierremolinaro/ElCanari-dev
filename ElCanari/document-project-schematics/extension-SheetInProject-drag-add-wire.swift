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

  func performAddWireDragOperation (_ inDraggingLocationInDestinationView : NSPoint,
                                    newNetCreator inNewNetCreator : () -> NetInProject) -> WireInSchematics {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: SCHEMATICS_GRID_IN_CANARI_UNIT)
    let wire = WireInSchematics (self.ebUndoManager)
    let p1 = CanariPoint (x: p.x, y: p.y)
    let p2 = CanariPoint (x: p.x + WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP, y: p.y + WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP)
  //--- Find points at p1 and p2
    let pointsAtP1 = self.pointsInSchematics (at: p1)
    let pointsAtP2 = self.pointsInSchematics (at: p2)
  //---
    if (pointsAtP1.count == 1) && (pointsAtP2.count == 1) && (pointsAtP1 [0].mNet === pointsAtP2 [0].mNet) {
      wire.mP1 = pointsAtP1 [0]
      wire.mP2 = pointsAtP2 [0]
      if pointsAtP1 [0].mNet == nil {
        let newNet = inNewNetCreator ()
        wire.mP1?.mNet = newNet
        wire.mP2?.mNet = newNet
      }
    }else if pointsAtP1.count == 1 { // Use point at p1, create a point at p2
      wire.mP1 = pointsAtP1 [0]
      if pointsAtP1 [0].mNet == nil {
        let newNet = inNewNetCreator ()
        wire.mP1?.mNet = newNet
      }
      let point = PointInSchematics (self.ebUndoManager)
      point.mX = p2.x
      point.mY = p2.y
      point.mNet = wire.mP1?.mNet
      wire.mP2 = point
      self.mPoints.append (point)
    }else if pointsAtP2.count == 1 { // Use point at p2, create a point at p1
      wire.mP2 = pointsAtP2 [0]
      if pointsAtP2 [0].mNet == nil {
        let newNet = inNewNetCreator ()
        wire.mP2?.mNet = newNet
      }
      let point = PointInSchematics (self.ebUndoManager)
      point.mX = p1.x
      point.mY = p1.y
      point.mNet = wire.mP2?.mNet
      wire.mP1 = point
      self.mPoints.append (point)
    }else{ // Assign no net
      let point1 = PointInSchematics (self.ebUndoManager)
      point1.mX = p1.x
      point1.mY = p1.y
      wire.mP1 = point1
      self.mPoints.append (point1)
      let point2 = PointInSchematics (self.ebUndoManager)
      point2.mX = p2.x
      point2.mY = p2.y
      wire.mP2 = point2
      self.mPoints.append (point2)
    }
  //--- Enter wire and select it
    self.mObjects.append (wire)
  //---
    return wire
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

