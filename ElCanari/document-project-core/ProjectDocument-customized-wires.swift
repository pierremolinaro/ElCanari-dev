//
//  ProjectDocument-customized-wires.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func wiresAt (point inPoint : CanariPoint) -> [WireInSchematics] {
    let width = cocoaToCanariUnit (CGFloat (g_Preferences!.symbolDrawingWidthMultipliedByTen) / 5.0)
    var result = [WireInSchematics]  ()
    for object in self.rootObject.mSelectedSheet?.mObjects ?? [] {
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

  @objc func addPointToWire (_ inSender : NSMenuItem) {
    if let location = inSender.representedObject as? CanariPoint, let selectedSheet = self.rootObject.mSelectedSheet {
      let wires = self.wiresAt (point: location)
      if wires.count == 1 {
        let wire = wires [0]
        let p1 = wire.mP1!
        let p2 = wire.mP2!
        let net = p1.mNet
      //--- Remove current wire
        wire.mP1 = nil
        wire.mP2 = nil
        wire.mSheet = nil
      //--- Create a new point
        let newPoint = PointInSchematics (self.ebUndoManager)
        let alignedLocation = location.point (alignedOnGrid: SCHEMATICS_GRID_IN_CANARI_UNIT)
        newPoint.mX = alignedLocation.x
        newPoint.mY = alignedLocation.y
        newPoint.mNet = net
        selectedSheet.mPoints.append (newPoint)
      //--- Create first wire
        let firstWire = WireInSchematics (self.ebUndoManager)
        firstWire.mP1 = p1
        firstWire.mP2 = newPoint
        selectedSheet.mObjects.append (firstWire)
      //--- Create second wire
        let secondWire = WireInSchematics (self.ebUndoManager)
        secondWire.mP1 = newPoint
        secondWire.mP2 = p2
        selectedSheet.mObjects.append (secondWire)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
