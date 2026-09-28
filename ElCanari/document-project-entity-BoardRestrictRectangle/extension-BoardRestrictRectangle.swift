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
    let newX = .cu (self.mX) + acceptedX
    if newX < .zero {
      acceptedX = -.cu (self.mX)
    }
    var acceptedY = inDy
    let newY = .cu (self.mY) + acceptedY
    if newY < .zero {
      acceptedY = -.cu (self.mY)
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
    self.mX += inDx.cuValue
    self.mY += inDy.cuValue
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
    var dx = inProposedAlignedTranslation.x.cuValue
    var dy = inProposedAlignedTranslation.y.cuValue
    if inKnobIndex == BOARD_RESTRICT_RECT_LEFT {
      if (self.mX + dx) < 0 {
        dx = -self.mX
      }
      if (self.mWidth - dx) < SYMBOL_GRID_LENGTH.cuValue {
        dx = SYMBOL_GRID_LENGTH.cuValue - self.mWidth
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_RIGHT {
      if (self.mWidth + dx) < SYMBOL_GRID_LENGTH.cuValue {
        dx = -(SYMBOL_GRID_LENGTH.cuValue - self.mWidth)
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_BOTTOM {
      if (self.mY + dy) < 0 {
        dy = -self.mY
      }
      if (self.mHeight - dy) < SYMBOL_GRID_LENGTH.cuValue {
        dy = SYMBOL_GRID_LENGTH.cuValue - self.mHeight
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_TOP {
      if (self.mHeight + dy) < SYMBOL_GRID_LENGTH.cuValue {
        dy = -(SYMBOL_GRID_LENGTH.cuValue - self.mHeight)
      }
    }
    return CanariPoint (x: .cu (dx), y: .cu (dy))
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
      self.mWidth += inDx.cuValue
    }else if inKnobIndex == BOARD_RESTRICT_RECT_LEFT {
      self.mX += inDx.cuValue
      self.mWidth -= inDx.cuValue
    }else if inKnobIndex == BOARD_RESTRICT_RECT_TOP {
      self.mHeight += inDy.cuValue
    }else if inKnobIndex == BOARD_RESTRICT_RECT_BOTTOM {
      self.mY += inDy.cuValue
      self.mHeight -= inDy.cuValue
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

  func canSnapToGrid_BoardRestrictRectangle (_ inGrid : Int) -> Bool {
    var result = (self.mX % inGrid) != 0
    if !result {
      result = (self.mY % inGrid) != 0
    }
    if !result {
      result = (self.mWidth % inGrid) != 0
    }
    if !result {
      result = (self.mHeight % inGrid) != 0
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BoardRestrictRectangle (_ inGrid : Int) {
    self.mX = ((self.mX + inGrid / 2) / inGrid) * inGrid
    self.mY = ((self.mY + inGrid / 2) / inGrid) * inGrid
    self.mWidth = ((self.mWidth + inGrid / 2) / inGrid) * inGrid
    self.mHeight = ((self.mHeight + inGrid / 2) / inGrid) * inGrid
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
    self.mX = p.x.cuValue
    self.mY = p.y.cuValue
    swap (&self.mWidth, &self.mHeight)
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BoardRestrictRectangle (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mX, y: self.mY)
    self.mX = p.x.cuValue
    self.mY = p.y.cuValue
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
