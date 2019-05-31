//
//  ProjectDocument-schematic-option-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func startWireCreationOnOptionMouseDown (at inUnalignedMousePoint : NSPoint) {
     if let selectedSheet = self.rootObject.mSelectedSheet {
//       self.mWireCreatedByOptionClick = selectedSheet.performAddWireDragOperation (
//         inUnalignedMousePoint,
//         newNetCreator:self.rootObject.createNetWithAutomaticName
//       )
     let p = inUnalignedMousePoint.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    //--- Find points at p1 and p2
      let pointsAtP = selectedSheet.pointsInSchematics (at: p)
    //---
      if pointsAtP.count == 1 { // Use point at p1, create a point at p2
        let wire = WireInSchematic (self.ebUndoManager)
        self.mWireCreatedByOptionClick = wire
        wire.mP1 = pointsAtP [0]
        let point = PointInSchematic (self.ebUndoManager)
        point.mX = p.x
        point.mY = p.y
        point.mNet = wire.mP1?.mNet
        wire.mP2 = point
        selectedSheet.mPoints.append (point)
      }else{ // Assign no net
        let wire = WireInSchematic (self.ebUndoManager)
        self.mWireCreatedByOptionClick = wire
        let point1 = PointInSchematic (self.ebUndoManager)
        point1.mX = p.x
        point1.mY = p.y
        wire.mP1 = point1
        selectedSheet.mPoints.append (point1)
        let point2 = PointInSchematic (self.ebUndoManager)
        point2.mX = p.x
        point2.mY = p.y
        wire.mP2 = point2
        selectedSheet.mPoints.append (point2)
      }
    //--- Enter wire and select it
      if let wire = self.mWireCreatedByOptionClick {
        selectedSheet.mObjects.append (wire)
      }
    }
  }

  //····················································································································

  internal func continueWireCreationOnOptionMouseDragged (at inUnalignedMousePoint : NSPoint) {
     if let p2 = self.mWireCreatedByOptionClick?.mP2 {
       let alignedMouseDownLocation = inUnalignedMousePoint.canariPoint.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
       p2.mX = alignedMouseDownLocation.x
       p2.mY = alignedMouseDownLocation.y
    }
  }

  //····················································································································

  internal func abortWireCreationOnOptionMouseUp () {
     if self.mWireCreatedByOptionClick != nil {
       self.ebUndoManager.undo ()
       self.mWireCreatedByOptionClick = nil
     }
  }

  //····················································································································

  internal func stopWireCreationOnOptionMouseUp () {
     if let wire = self.mWireCreatedByOptionClick {
       let p1 = wire.mP1!.location!
       let p2 = wire.mP2!.location!
       if (p1.x == p2.x) && (p1.y == p2.y) {
         wire.mP1 = nil
         wire.mP2 = nil
         wire.mSheet = nil
       }else{
         self.schematicObjectsController.setSelection ([wire])
       }
       self.mWireCreatedByOptionClick = nil
     }
  }


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

