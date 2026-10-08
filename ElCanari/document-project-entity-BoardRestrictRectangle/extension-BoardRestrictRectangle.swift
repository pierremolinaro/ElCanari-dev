//
//  extension-BoardRestrictRectangle.swift.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/06/2019.
//

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let BOARD_RESTRICT_RECT_BOTTOM = 1
let BOARD_RESTRICT_RECT_RIGHT  = 2
let BOARD_RESTRICT_RECT_TOP    = 3
let BOARD_RESTRICT_RECT_LEFT   = 4

//--------------------------------------------------------------------------------------------------
//   EXTENSION SymbolSolidRect
//--------------------------------------------------------------------------------------------------

extension BoardRestrictRectangle {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_BoardRestrictRectangle (knob inKnobIndex : Int) -> NSCursor? {
    if (inKnobIndex == BOARD_RESTRICT_RECT_RIGHT) && (inKnobIndex == BOARD_RESTRICT_RECT_LEFT) {
      return NSCursor.resizeLeftRight
    }else if (inKnobIndex == BOARD_RESTRICT_RECT_BOTTOM) && (inKnobIndex == BOARD_RESTRICT_RECT_TOP) {
      return NSCursor.resizeUpDown
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_BoardRestrictRectangle (xBy inDx : CanariLength, yBy inDy : CanariLength) -> CanariPoint {
    var acceptedX = inDx
    let newX = self.mX + acceptedX
    if newX.isNegative {
      acceptedX = -self.mX
    }
    var acceptedY = inDy
    let newY = self.mY + acceptedY
    if newY .isNegative {
      acceptedY = -self.mY
    }
    return CanariPoint (x: acceptedX, y: acceptedY)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_BoardRestrictRectangle (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_BoardRestrictRectangle (xBy inDx : CanariLength,
                                         yBy inDy : CanariLength,
                                         userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_BoardRestrictRectangle (additionalDictionary _ : [String : Any],
                                                     optionalDocument _ : EBAutoLayoutManagedDocument?,
                                                     objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_BoardRestrictRectangle (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_BoardRestrictRectangle (knob inKnobIndex : Int,
                                       proposedUnalignedAlignedTranslation _ : CanariPoint,
                                       proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                       unalignedMouseDraggedLocation _ : CanariPoint,
                                       shift _ : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == BOARD_RESTRICT_RECT_LEFT {
      if (self.mX + dx).isNegative {
        dx = -self.mX
      }
      if (self.mWidth - dx) < SYMBOL_GRID_LENGTH {
        dx = SYMBOL_GRID_LENGTH - self.mWidth
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_RIGHT {
      if (self.mWidth + dx) < SYMBOL_GRID_LENGTH {
        dx = -(SYMBOL_GRID_LENGTH - self.mWidth)
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_BOTTOM {
      if (self.mY + dy).isNegative {
        dy = -self.mY
      }
      if (self.mHeight - dy) < SYMBOL_GRID_LENGTH {
        dy = SYMBOL_GRID_LENGTH - self.mHeight
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_TOP {
      if (self.mHeight + dy) < SYMBOL_GRID_LENGTH {
        dy = -(SYMBOL_GRID_LENGTH - self.mHeight)
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_BoardRestrictRectangle (knob inKnobIndex: Int,
                      proposedDx inDx: CanariLength,
                      proposedDy inDy: CanariLength,
                      unalignedMouseLocationX _ : CanariLength,
                      unalignedMouseLocationY _ : CanariLength,
                      alignedMouseLocationX _ : CanariLength,
                      alignedMouseLocationY _ : CanariLength,
                      shift _ : Bool) {
    if inKnobIndex == BOARD_RESTRICT_RECT_RIGHT {
      self.mWidth += inDx
    }else if inKnobIndex == BOARD_RESTRICT_RECT_LEFT {
      self.mX += inDx
      self.mWidth -= inDx
    }else if inKnobIndex == BOARD_RESTRICT_RECT_TOP {
      self.mHeight += inDy
    }else if inKnobIndex == BOARD_RESTRICT_RECT_BOTTOM {
      self.mY += inDy
      self.mHeight -= inDy
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  COPY AND PASTE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func canCopyAndPaste_BoardRestrictRectangle () -> Bool {
//    return true
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_BoardRestrictRectangle (_ inGrid : CanariLength) -> Bool {
    var result = self.mX.isAligned (on: inGrid)
    if !result {
      result = self.mY.isAligned (on: inGrid)
    }
    if !result {
      result = self.mWidth.isAligned (on: inGrid)
    }
    if !result {
      result = self.mHeight.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BoardRestrictRectangle (_ inGrid : CanariLength) {
    self.mX.align (on: inGrid)
    self.mY.align (on: inGrid)
    self.mWidth.align (on: inGrid)
    self.mHeight.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_BoardRestrictRectangle () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.mX, y: self.mY)
    result.insert (x: self.mX + self.mWidth, y: self.mY + self.mHeight)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_BoardRestrictRectangle (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.mX + self.mWidth / 2, y: self.mY + self.mHeight / 2)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_BoardRestrictRectangle (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    swap (&self.mWidth, &self.mHeight)
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BoardRestrictRectangle (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    swap (&self.mWidth, &self.mHeight)
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_BoardRestrictRectangle () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_BoardRestrictRectangle () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_BoardRestrictRectangle () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_BoardRestrictRectangle () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_BoardRestrictRectangle () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var layers : Set <TrackSide> {
    var result = Set <TrackSide> ()
    if self.mIsInBackLayer {
      result.insert (.back)
    }
    if self.mIsInFrontLayer {
      result.insert (.front)
    }
    if self.mIsInInner1Layer {
      result.insert (.inner1)
    }
    if self.mIsInInner2Layer {
      result.insert (.inner2)
    }
    if self.mIsInInner3Layer {
      result.insert (.inner3)
    }
    if self.mIsInInner4Layer {
      result.insert (.inner4)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var hasInnerLayer : Bool {
    return self.mIsInInner1Layer || self.mIsInInner2Layer || self.mIsInInner3Layer || self.mIsInInner4Layer
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
