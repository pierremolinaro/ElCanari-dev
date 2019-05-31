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

  func addPointToWire (at inUnalignedLocation : CanariPoint) -> PointInSchematic? {
    var optionalNewPoint : PointInSchematic? = nil
    let wires = self.wiresStrictlyContaining (point: inUnalignedLocation)
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
      optionalNewPoint = newPoint
      let alignedLocation = inUnalignedLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      newPoint.mX = alignedLocation.x
      newPoint.mY = alignedLocation.y
      newPoint.mNet = net
      self.mPoints.append (newPoint)
    //--- Create first wire
      let firstWire = WireInSchematic (self.ebUndoManager)
      firstWire.mP1 = p1
      firstWire.mP2 = newPoint
      self.mObjects.append (firstWire)
    //--- Create second wire
      let secondWire = WireInSchematic (self.ebUndoManager)
      secondWire.mP1 = newPoint
      secondWire.mP2 = p2
      self.mObjects.append (secondWire)
    }
    return optionalNewPoint
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
