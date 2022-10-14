//
//  ProjectDocument-schematic-option-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func startWireCreationOnOptionMouseDown (at inUnalignedMousePoint : NSPoint) -> Bool {
     if let selectedSheet = self.rootObject.mSelectedSheet {
       _ = selectedSheet.addPointToWire (at: inUnalignedMousePoint.canariPoint)
       let p = inUnalignedMousePoint.canariPointAligned (onCanariGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    //--- Find points at p
      let pointsAtP = selectedSheet.pointsInSchematics (at: p)
    //--- Check all points are not "nc"
      var allPointsAreNC = true
      for p in pointsAtP {
        if p.mNC != nil {
          allPointsAreNC = false
          break
        }
      }
    //---
      if !allPointsAreNC {
        let alert = NSAlert ()
        alert.messageText = "Cannot create a wire from a NC point"
        _ = alert.runModal ()
      }else if pointsAtP.count == 1 { // Use point at p1, create a point at p2
        let wire = WireInSchematic (self.undoManager)
        self.mWireCreatedByOptionClick = wire
        wire.mP1 = pointsAtP [0]
        let point = PointInSchematic (self.undoManager)
        point.mX = p.x
        point.mY = p.y
        point.mNet = wire.mP1?.mNet
        wire.mP2 = point
        selectedSheet.mPoints.append (point)
      }else{ // Assign no net
        let wire = WireInSchematic (self.undoManager)
        self.mWireCreatedByOptionClick = wire
        let point1 = PointInSchematic (self.undoManager)
        point1.mX = p.x
        point1.mY = p.y
        wire.mP1 = point1
        selectedSheet.mPoints.append (point1)
        let point2 = PointInSchematic (self.undoManager)
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
    return self.mWireCreatedByOptionClick != nil
  }

  //····················································································································

  func continueWireCreationOnOptionMouseDragged (at inUnalignedMousePoint : NSPoint,
                                                 _ inModifierFlags : NSEvent.ModifierFlags) {
    if let p2 = self.mWireCreatedByOptionClick?.mP2 {
      var alignedMouseLocation = inUnalignedMousePoint.canariPoint.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      if inModifierFlags.contains (.shift), let p1 = self.mWireCreatedByOptionClick?.mP1 {
        alignedMouseLocation.constraintToOctolinearDirection (from: CanariPoint (x: p1.mX, y: p1.mY))
      }
      p2.mX = alignedMouseLocation.x
      p2.mY = alignedMouseLocation.y
    }
  }

  //····················································································································

  func helperStringForWireCreation (_ inModifierFlags : NSEvent.ModifierFlags) -> String {
    return "Dragging defines new wire; SHIFT constraints octolinear direction"
  }

  //····················································································································

  func abortWireCreationOnOptionMouseUp () {
    self.mWireCreatedByOptionClick = nil
  }

  //····················································································································

  func stopWireCreationOnOptionMouseUp (at inUnalignedMousePoint : NSPoint) -> Bool {
     if let wire = self.mWireCreatedByOptionClick, let selectedSheet = self.rootObject.mSelectedSheet {
       let p1 = wire.mP1!.location!
       let p2 = wire.mP2!.location!
       if (p1.x == p2.x) && (p1.y == p2.y) { // Zero length wire: remove it
         wire.mP1 = nil
         wire.mP2 = nil
         wire.mSheet = nil
         self.updateSchematicPointsAndNets ()
       }else{
         let points = selectedSheet.pointsInSchematics (at: p2)
         self.connectInSchematic (points: points)
         self.schematicObjectsController.setSelection ([wire])
       }
       self.mWireCreatedByOptionClick = nil
     }
     return true // Accepts wire creation
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

