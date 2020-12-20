//
//  extension-BorderCurve.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/06/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let BOARD_LIMIT_P1_KNOB  = 0
let BOARD_LIMIT_P2_KNOB  = 1
let BOARD_LIMIT_CP1_KNOB = 2
let BOARD_LIMIT_CP2_KNOB = 3

let BOARD_LIMITS_KNOB_SIZE = CGFloat (8.0)

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION BorderCurve
//----------------------------------------------------------------------------------------------------------------------

extension BorderCurve {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    var accept = false
    if let next = self.mNext, let boardShape = self.mRoot?.mBoardShape, boardShape == .bezierPathes {
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

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    if let next = self.mNext, let previous = self.mPrevious, let boardShape = self.mRoot?.mBoardShape, boardShape == .bezierPathes {
      let dx = max (inDx, -self.mX, -next.mX)
      let dy = max (inDy, -self.mY, -next.mY)
      if !ioSet.contains (self) {
        ioSet.insert (self)
        self.mX += dx
        self.mY += dy
        self.setControlPointsDefaultValuesForLine ()
        previous.setControlPointsDefaultValuesForLine ()
      }
      if !ioSet.contains (next) {
        ioSet.insert (next)
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

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : ObjcCanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : ObjcCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : ObjcCanariPoint,
                         shift inShift : Bool) -> ObjcCanariPoint {
    if let boardShape = self.mRoot?.mBoardShape, boardShape == .bezierPathes {
      if inKnobIndex == BOARD_LIMIT_P1_KNOB, let next = self.mNext {
        let dx = max (inProposedAlignedTranslation.x, -self.mX)
        let dy = max (inProposedAlignedTranslation.y, -self.mY)
        if ((self.mX + dx) == next.mX) && ((self.mY + dy) == next.mY) {
          return ObjcCanariPoint (x: 0, y: 0)
        }else{
          return ObjcCanariPoint (x: dx, y: dy)
        }
      }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let next = self.mNext {
        let dx = max (inProposedAlignedTranslation.x, -next.mX)
        let dy = max (inProposedAlignedTranslation.y, -next.mY)
        if ((next.mX + dx) == self.mX) && ((next.mY + dy) == self.mY) {
          return ObjcCanariPoint (x: 0, y: 0)
        }else{
          return ObjcCanariPoint (x: dx, y: dy)
        }
      }else if inKnobIndex == BOARD_LIMIT_CP1_KNOB {
        return inProposedAlignedTranslation
      }else if inKnobIndex == BOARD_LIMIT_CP2_KNOB {
        return inProposedAlignedTranslation
      }else{
        return ObjcCanariPoint (x: 0, y: 0)
      }
    }else{
      return ObjcCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
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
    if let boardShape = self.mRoot?.mBoardShape, boardShape == .bezierPathes {
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
    }else{
      return false
    }
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

//----------------------------------------------------------------------------------------------------------------------
