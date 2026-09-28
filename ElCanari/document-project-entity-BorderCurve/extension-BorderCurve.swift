//
//  extension-BorderCurve.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/06/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let BOARD_LIMIT_P1_KNOB  = 0
let BOARD_LIMIT_P2_KNOB  = 1
let BOARD_LIMIT_CP1_KNOB = 2
let BOARD_LIMIT_CP2_KNOB = 3

let BOARD_LIMITS_KNOB_SIZE = CGFloat (8.0)

//--------------------------------------------------------------------------------------------------
//   EXTENSION BorderCurve
//--------------------------------------------------------------------------------------------------

extension BorderCurve {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_BorderCurve (knob _ : Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_BorderCurve (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_BorderCurve (xBy inDx: CanariLength, yBy inDy: CanariLength) -> Bool {
    var accept = false
    if let next = self.mNext, let boardShape = self.mRoot?.mBoardShape, boardShape == .bezierPathes {
      accept = true
      if (self.mX + inDx.cuValue) < 0 {
        accept = false
      }else if (self.mY + inDy.cuValue) < 0 {
        accept = false
      }
      if (next.mX + inDx.cuValue) < 0 {
        accept = false
      }else if (next.mY + inDy.cuValue) < 0 {
        accept = false
      }
    }
    return accept
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_BorderCurve (additionalDictionary _ : [String : Any],
                                          optionalDocument _ : EBAutoLayoutManagedDocument?,
                                          objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_BorderCurve (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_BorderCurve () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_BorderCurve () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_BorderCurve () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_BorderCurve () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_BorderCurve (xBy inDx: CanariLength,
                              yBy inDy: CanariLength,
                              userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    if let next = self.mNext, let previous = self.mPrevious, let boardShape = self.mRoot?.mBoardShape, boardShape == .bezierPathes {
      let dx = max (inDx, -.cu (self.mX), -.cu (next.mX))
      let dy = max (inDy, -.cu (self.mY), -.cu (next.mY))
      if !ioSet.contains (self) {
        ioSet.insert (self)
        self.mX += dx.cuValue
        self.mY += dy.cuValue
        self.setControlPointsDefaultValuesForLine ()
        previous.setControlPointsDefaultValuesForLine ()
      }
      if !ioSet.contains (next) {
        ioSet.insert (next)
        next.mX += dx.cuValue
        next.mY += dy.cuValue
        self.setControlPointsDefaultValuesForLine ()
        next.setControlPointsDefaultValuesForLine ()
      }
      self.setControlPointsDefaultValuesForLine ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_BorderCurve (knob inKnobIndex : Int,
                            proposedUnalignedAlignedTranslation _ : CanariPoint,
                            proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                            unalignedMouseDraggedLocation _ : CanariPoint,
                            shift _ : Bool) -> CanariPoint {
    if let boardShape = self.mRoot?.mBoardShape, boardShape == .bezierPathes {
      if inKnobIndex == BOARD_LIMIT_P1_KNOB, let next = self.mNext {
        let dx = max (inProposedAlignedTranslation.x.cuValue, -self.mX)
        let dy = max (inProposedAlignedTranslation.y.cuValue, -self.mY)
        if ((self.mX + dx) == next.mX) && ((self.mY + dy) == next.mY) {
          return .zero
        }else{
          return CanariPoint (x: .cu (dx), y: .cu (dy))
        }
      }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let next = self.mNext {
        let dx = max (inProposedAlignedTranslation.x.cuValue, -next.mX)
        let dy = max (inProposedAlignedTranslation.y.cuValue, -next.mY)
        if ((next.mX + dx) == self.mX) && ((next.mY + dy) == self.mY) {
          return .zero
        }else{
          return CanariPoint (x: .cu (dx), y: .cu (dy))
        }
      }else if inKnobIndex == BOARD_LIMIT_CP1_KNOB {
        return inProposedAlignedTranslation
      }else if inKnobIndex == BOARD_LIMIT_CP2_KNOB {
        return inProposedAlignedTranslation
      }else{
        return .zero
      }
    }else{
      return .zero
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_BorderCurve (knob inKnobIndex: Int,
                         proposedDx inDx: CanariLength,
                         proposedDy inDy: CanariLength,
                         unalignedMouseLocationX _ : CanariLength,
                         unalignedMouseLocationY _ : CanariLength,
                         alignedMouseLocationX _ : CanariLength,
                         alignedMouseLocationY _ : CanariLength,
                         shift _ : Bool) {
    if inKnobIndex == BOARD_LIMIT_P1_KNOB {
      self.mX += inDx.cuValue
      self.mY += inDy.cuValue
      self.setControlPointsDefaultValuesForLine ()
      self.mPrevious?.setControlPointsDefaultValuesForLine ()
    }else if inKnobIndex == BOARD_LIMIT_P2_KNOB, let next = self.mNext{
      next.mX += inDx.cuValue
      next.mY += inDy.cuValue
      self.setControlPointsDefaultValuesForLine ()
      next.setControlPointsDefaultValuesForLine ()
    }else if inKnobIndex == BOARD_LIMIT_CP1_KNOB {
      self.mCPX1 += inDx.cuValue
      self.mCPY1 += inDy.cuValue
    }else if inKnobIndex == BOARD_LIMIT_CP2_KNOB {
      self.mCPX2 += inDx.cuValue
      self.mCPY2 += inDy.cuValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_BorderCurve (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_BorderCurve (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BorderCurve (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_BorderCurve () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_BorderCurve (_ _ : Int) -> Bool {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BorderCurve (_ _ : Int) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_BorderCurve () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setControlPointsDefaultValuesForLine () {
    if self.mShape == .line, let x2 = self.mNext?.mX, let y2 = self.mNext?.mY {
      self.mCPX1 = ((2 * self.mX + 1 * x2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPY1 = ((2 * self.mY + 1 * y2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPX2 = ((1 * self.mX + 2 * x2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
      self.mCPY2 = ((1 * self.mY + 2 * y2) / 3).value (alignedOnGrid: self.mRoot!.mBoardLimitsGridStep)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
