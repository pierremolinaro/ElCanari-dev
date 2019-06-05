//
//  extension-BorderCurve.swift
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
//   EXTENSION BorderCurve
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BorderCurve {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    var accept = false
    if let next = self.mNext {
      accept = true
      if (self.mX + inDx) < 0 {
        accept = false
      }else if (self.mY + inDy) < 0 {
        accept = false
      }
      if (next.mX + inDx) < 0 {
        accept = false
      }else if (next.mY + inDy) < 0 {
        accept = false
      }
    }
    return accept
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    if let next = self.mNext, let previous = self.mPrevious {
      let dx = max (inDx, -self.mX, -next.mX)
      let dy = max (inDy, -self.mY, -next.mY)
      if !ioSet.objects.contains (self) {
        ioSet.objects.insert (self)
        self.mX += dx
        self.mY += dy
        self.setControlPointsDefaultValuesForLine ()
        previous.setControlPointsDefaultValuesForLine ()
      }
      if !ioSet.objects.contains (next) {
        ioSet.objects.insert (next)
        next.mX += dx
        next.mY += dy
        self.setControlPointsDefaultValuesForLine ()
        next.setControlPointsDefaultValuesForLine ()
      }
      self.setControlPointsDefaultValuesForLine ()
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    if inKnobIndex == BOARD_LIMIT_P1_KNOB, let next = self.mNext {
      let dx = max (inDx, -self.mX)
      let dy = max (inDy, -self.mY)
      if ((self.mX + dx) == next.mX) && ((self.mY + dy) == next.mY) {
        return OCCanariPoint (x: 0, y: 0)
      }else{
        return OCCanariPoint (x: dx, y: dy)
      }
    }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let next = self.mNext {
      let dx = max (inDx, -next.mX)
      let dy = max (inDy, -next.mY)
      if ((next.mX + dx) == self.mX) && ((next.mY + dy) == self.mY) {
        return OCCanariPoint (x: 0, y: 0)
      }else{
        return OCCanariPoint (x: dx, y: dy)
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
    if inKnobIndex == BOARD_LIMIT_P1_KNOB {
      self.mX += inDx
      self.mY += inDy
      self.setControlPointsDefaultValuesForLine ()
      self.mPrevious?.setControlPointsDefaultValuesForLine ()
    }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let next = self.mNext{
      next.mX += inDx
      next.mY += inDy
      self.setControlPointsDefaultValuesForLine ()
      next.setControlPointsDefaultValuesForLine ()
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
      isAligned = self.mX.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mY.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mNext!.mX.isAlignedOnGrid (grid)
    }
    if isAligned {
      isAligned = self.mNext!.mY.isAlignedOnGrid (grid)
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
    self.mX.align (onGrid: grid)
    self.mY.align (onGrid: grid)
    self.mNext!.mX.align (onGrid: grid)
    self.mNext!.mY.align (onGrid: grid)
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func canBeDeleted () -> Bool {
    return false
  }

  //····················································································································

  func setControlPointsDefaultValuesForLine () {
    if self.mShape == .line, let x2 = self.mNext?.mX, let y2 = self.mNext?.mY {
      self.mCPX1 = ((2 * self.mX + 1 * x2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPY1 = ((2 * self.mY + 1 * y2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPX2 = ((1 * self.mX + 2 * x2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPY2 = ((1 * self.mY + 2 * y2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
