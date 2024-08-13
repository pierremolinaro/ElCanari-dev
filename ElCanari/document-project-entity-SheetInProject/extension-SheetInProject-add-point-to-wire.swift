//
//  extension-SheetInProject-add-wire.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addPointToWire (at inUnalignedLocation : CanariPoint) -> PointInSchematic? {
    var optionalNewPoint : PointInSchematic? = nil
    let wires = self.wiresStrictlyContaining (point: inUnalignedLocation)
    if wires.count == 1 {
      optionalNewPoint = self.addPoint (toWire: wires [0], at: inUnalignedLocation)
    }
    return optionalNewPoint
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addPoint (toWire inWire : WireInSchematic, at inUnalignedLocation : CanariPoint) -> PointInSchematic {
    let p1 = inWire.mP1!
    let p2 = inWire.mP2!
    let net = p1.mNet
  //--- Remove current wire
    inWire.mP1 = nil
    inWire.mP2 = nil
    inWire.mSheet = nil
  //--- Create a new point
    let newPoint = PointInSchematic (self.undoManager)
    let alignedLocation = inUnalignedLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    newPoint.mX = alignedLocation.x
    newPoint.mY = alignedLocation.y
    newPoint.mNet = net
    self.mPoints.append (newPoint)
  //--- Create first wire
    let firstWire = WireInSchematic (self.undoManager)
    firstWire.mP1 = p1
    firstWire.mP2 = newPoint
    self.mObjects.append (firstWire)
  //--- Create second wire
    let secondWire = WireInSchematic (self.undoManager)
    secondWire.mP1 = newPoint
    secondWire.mP2 = p2
    self.mObjects.append (secondWire)
    return newPoint
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
