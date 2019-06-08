//
//  extension-WireInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let WIRE_P1_KNOB = 0
let WIRE_P2_KNOB = 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION WireInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension WireInSchematic {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    if let p1 = self.mP1, !ioSet.objects.contains (p1) {
      ioSet.objects.insert (p1)
      p1.mX += inDx
      p1.mY += inDy
    }
    if let p2 = self.mP2, !ioSet.objects.contains (p2) {
      ioSet.objects.insert (p2)
      p2.mX += inDx
      p2.mY += inDy
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    if inKnobIndex == WIRE_P1_KNOB, let point = self.mP1, point.mSymbol == nil, let other = self.mP2 {
      if ((point.mX + inDx) == other.mX) && ((point.mY + inDy) == other.mY) {
        return OCCanariPoint (x: 0, y: 0)
      }else{
        return OCCanariPoint (x: inDx, y: inDy)
      }
    }else if inKnobIndex == WIRE_P2_KNOB, let point = self.mP2, point.mSymbol == nil, let other = self.mP1 {
      if ((point.mX + inDx) == other.mX) && ((point.mY + inDy) == other.mY) {
        return OCCanariPoint (x: 0, y: 0)
      }else{
        return OCCanariPoint (x: inDx, y: inDy)
      }
    }else{
      return OCCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == WIRE_P1_KNOB, let point = self.mP1, point.mSymbol == nil {
      point.mX += inDx
      point.mY += inDy
    }else if inKnobIndex == WIRE_P2_KNOB, let point = self.mP2, point.mSymbol == nil {
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func operationBeforeRemoving () {
    var pointSet = Set <PointInSchematic> ()
    pointSet.insert (self.mP1!)
    pointSet.insert (self.mP2!)
    self.mP1 = nil // Detach from point
    self.mP2 = nil // Detach from point
    self.mSheet?.updateConnections (pointSet : pointSet)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
