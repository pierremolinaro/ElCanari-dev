//
//  extension-BoardRestrictRectangle.swift.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/06/2019.
//
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_RESTRICT_RECT_BOTTOM = 1
let BOARD_RESTRICT_RECT_RIGHT  = 2
let BOARD_RESTRICT_RECT_TOP    = 3
let BOARD_RESTRICT_RECT_LEFT   = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolSolidRect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardRestrictRectangle {

  //····················································································································

  func cursorForKnob_BoardRestrictRectangle (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == BOARD_RESTRICT_RECT_RIGHT) && (inKnobIndex == BOARD_RESTRICT_RECT_LEFT) {
      return NSCursor.resizeLeftRight
    }else if (inKnobIndex == BOARD_RESTRICT_RECT_BOTTOM) && (inKnobIndex == BOARD_RESTRICT_RECT_TOP) {
      return NSCursor.resizeUpDown
    }else{
      return nil
    }
  }

  //····················································································································

  func acceptedTranslation_BoardRestrictRectangle (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    var acceptedX = inDx
    let newX = self.mX + acceptedX
    if newX < 0 {
      acceptedX = -self.mX
    }
    var acceptedY = inDy
    let newY = self.mY + acceptedY
    if newY < 0 {
      acceptedY = -self.mY
    }
    return CanariPoint (x: acceptedX, y: acceptedY)
  }

  //····················································································································

  func acceptToTranslate_BoardRestrictRectangle (xBy inDx: Int, yBy inDy: Int) -> Bool {
//    let newX = self.mX + inDx
//    let newY = self.mY + inDy
    return true
  }

  //····················································································································

  func translate_BoardRestrictRectangle (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_BoardRestrictRectangle (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == BOARD_RESTRICT_RECT_LEFT {
      if (self.mX + dx) < 0 {
        dx = -self.mX
      }
      if (self.mWidth - dx) < SYMBOL_GRID_IN_CANARI_UNIT {
        dx = SYMBOL_GRID_IN_CANARI_UNIT - self.mWidth
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_RIGHT {
      if (self.mWidth + dx) < SYMBOL_GRID_IN_CANARI_UNIT {
        dx = -(SYMBOL_GRID_IN_CANARI_UNIT - self.mWidth)
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_BOTTOM {
      if (self.mY + dy) < 0 {
        dy = -self.mY
      }
      if (self.mHeight - dy) < SYMBOL_GRID_IN_CANARI_UNIT {
        dy = SYMBOL_GRID_IN_CANARI_UNIT - self.mHeight
      }
    }else if inKnobIndex == BOARD_RESTRICT_RECT_TOP {
      if (self.mHeight + dy) < SYMBOL_GRID_IN_CANARI_UNIT {
        dy = -(SYMBOL_GRID_IN_CANARI_UNIT - self.mHeight)
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  //····················································································································

  func move_BoardRestrictRectangle (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
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

  //····················································································································
  //  COPY AND PASTE
  //····················································································································

  func canCopyAndPaste_BoardRestrictRectangle () -> Bool {
    return true
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

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

  //····················································································································

  func snapToGrid_BoardRestrictRectangle (_ inGrid : Int) {
    self.mX = ((self.mX + inGrid / 2) / inGrid) * inGrid
    self.mY = ((self.mY + inGrid / 2) / inGrid) * inGrid
    self.mWidth = ((self.mWidth + inGrid / 2) / inGrid) * inGrid
    self.mHeight = ((self.mHeight + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_BoardRestrictRectangle () -> ObjcCanariPointSet {
    let result = ObjcCanariPointSet ()
    result.insert (CanariPoint (x: self.mX, y: self.mY))
    result.insert (CanariPoint (x: self.mX + self.mWidth, y: self.mY + self.mHeight))
    return result
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_BoardRestrictRectangle (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    accumulatedPoints.insert (CanariPoint (x: self.mX + self.mWidth / 2, y: self.mY + self.mHeight / 2))
    return true
  }

  //····················································································································

  func rotate90Clockwise_BoardRestrictRectangle (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    swap (&self.mWidth, &self.mHeight)
    ioSet.insert (self)
  }

  //····················································································································

  func rotate90CounterClockwise_BoardRestrictRectangle (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
    swap (&self.mWidth, &self.mHeight)
    ioSet.insert (self)
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_BoardRestrictRectangle () {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
