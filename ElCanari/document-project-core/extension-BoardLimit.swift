//
//  extension-BoardLimit.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_LIMIT_P1_KNOB = 0
let BOARD_LIMIT_P2_KNOB = 1

let BOARD_LIMITS_KNOB_SIZE = CGFloat (8.0)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardLimit
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardLimit {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    if let p1 = self.mP1, let p2 = self.mP2 {
      if !ioSet.objects.contains (p1) {
        ioSet.objects.insert (p1)
        p1.mX += inDx
        p1.mY += inDy
      }
      if !ioSet.objects.contains (p2) {
        ioSet.objects.insert (p2)
        p2.mX += inDx
        p2.mY += inDy
      }
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    if inKnobIndex == BOARD_LIMIT_P1_KNOB, let point = self.mP1, let other = self.mP2 {
      if ((point.mX + inDx) == other.mX) && ((point.mY + inDy) == other.mY) {
        return OCCanariPoint (x: 0, y: 0)
      }else{
        return OCCanariPoint (x: inDx, y: inDy)
      }
    }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let point = self.mP2, let other = self.mP1 {
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
    if inKnobIndex == BOARD_LIMIT_P1_KNOB, let point = self.mP1 {
      point.mX += inDx
      point.mY += inDy
    }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let point = self.mP2 {
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func canBeDeleted () -> Bool {
    return false
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
