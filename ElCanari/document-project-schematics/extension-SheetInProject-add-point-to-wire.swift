//
//  extension-SheetInProject-add-wire.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  func addPointToWire (at inLocation : CanariPoint) {
    let wires = self.wiresStrictlyContaining (point: inLocation)
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
      let newPoint = PointInSchematic (self.ebUndoManager)
      let alignedLocation = inLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      newPoint.mX = alignedLocation.x
      newPoint.mY = alignedLocation.y
      newPoint.mNet = net
      self.mPoints.append (newPoint)
    //--- Create first wire
      let firstWire = WireInSchematics (self.ebUndoManager)
      firstWire.mP1 = p1
      firstWire.mP2 = newPoint
      self.mObjects.append (firstWire)
    //--- Create second wire
      let secondWire = WireInSchematics (self.ebUndoManager)
      secondWire.mP1 = newPoint
      secondWire.mP2 = p2
      self.mObjects.append (secondWire)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
