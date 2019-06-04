//
//  extension-BoardLimit.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_LIMIT_P1_KNOB  = 0
let BOARD_LIMIT_P2_KNOB  = 1
let BOARD_LIMIT_CP1_KNOB = 2
let BOARD_LIMIT_CP2_KNOB = 3

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
        p1.mCurve2?.setControlPointsDefaultValuesForLine ()
      }
      if !ioSet.objects.contains (p2) {
        ioSet.objects.insert (p2)
        p2.mX += inDx
        p2.mY += inDy
        p2.mCurve1?.setControlPointsDefaultValuesForLine ()
      }
      self.setControlPointsDefaultValuesForLine ()
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
    }else if inKnobIndex == BOARD_LIMIT_CP1_KNOB {
      return OCCanariPoint (x: inDx, y: inDy)
    }else if inKnobIndex == BOARD_LIMIT_CP2_KNOB {
      return OCCanariPoint (x: inDx, y: inDy)
    }else{
      return OCCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == BOARD_LIMIT_P1_KNOB, let point = self.mP1 {
      point.mX += inDx
      point.mY += inDy
      self.setControlPointsDefaultValuesForLine ()
      point.mCurve2?.setControlPointsDefaultValuesForLine ()
    }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let point = self.mP2 {
      point.mX += inDx
      point.mY += inDy
      self.setControlPointsDefaultValuesForLine ()
      point.mCurve1?.setControlPointsDefaultValuesForLine ()
    }else if inKnobIndex == BOARD_LIMIT_CP1_KNOB {
      self.mCPX1 += inDx
      self.mCPY1 += inDy
    }else if inKnobIndex == BOARD_LIMIT_CP2_KNOB {
      self.mCPX2 += inDx
      self.mCPY2 += inDy
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    let grid = self.mRoot!.mBoardLimitsGridStep
    var isAligned = self.mCPX1.isAlignedOnGrid (grid)
    if isAligned {
      isAligned = self.mCPY1.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mCPX2.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mCPY2.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mP1!.mX.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mP1!.mY.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mP2!.mX.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mP2!.mY.isAlignedOnGrid (grid)
    }
    return !isAligned
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    let grid = self.mRoot!.mBoardLimitsGridStep
    self.mCPX1.align (onGrid: grid)
    self.mCPY1.align (onGrid: grid)
    self.mCPX2.align (onGrid: grid)
    self.mCPY2.align (onGrid: grid)
    self.mP1!.mX.align (onGrid: grid)
    self.mP1!.mY.align (onGrid: grid)
    self.mP2!.mX.align (onGrid: grid)
    self.mP2!.mY.align (onGrid: grid)
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func canBeDeleted () -> Bool {
    return false
  }

  //····················································································································

  func setControlPointsDefaultValuesForLine () {
    if self.mShape == .line, let p1 = self.mP1, let p2 = self.mP2 {
      self.mCPX1 = ((2 * p1.mX + 1 * p2.mX) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPY1 = ((2 * p1.mY + 1 * p2.mY) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPX2 = ((1 * p1.mX + 2 * p2.mX) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPY2 = ((1 * p1.mY + 2 * p2.mY) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
