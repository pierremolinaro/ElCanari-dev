//
//  extension-BoardLine.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_LINE_P1  = 0
let BOARD_LINE_P2  = 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardLine
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardLine {

  //····················································································································

  func cursorForKnob_BoardLine (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································

  func acceptToTranslate_BoardLine (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_BoardLine (xBy inDx : Int, yBy inDy : Int, userSet ioSet : ObjcObjectSet) {
    self.mX1 += inDx
    self.mY1 += inDy
    self.mX2 += inDx
    self.mY2 += inDy
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_BoardLine () -> ObjcCanariPointSet {
    return ObjcCanariPointSet ()
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_BoardLine (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    if inKnobIndex == BOARD_LINE_P1 {
      return inProposedAlignedTranslation
    }else if inKnobIndex == BOARD_LINE_P2 {
      return inProposedAlignedTranslation
    }else{
      return CanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  func move_BoardLine (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == BOARD_LINE_P1 {
      self.mX1 += inDx
      self.mY1 += inDy
    }else if inKnobIndex == BOARD_LINE_P2 {
      self.mX2 += inDx
      self.mY2 += inDy
    }
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_BoardLine (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    accumulatedPoints.insert (CanariPoint (x: self.mX1, y: self.mY1))
    accumulatedPoints.insert (CanariPoint (x: self.mX2, y: self.mY2))
    return true
  }

  //····················································································································

  func rotate90Clockwise_BoardLine (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.mX1, y: self.mY1)
    self.mX1 = p1.x
    self.mY1 = p1.y
    let p2 = inRotationCenter.rotated90Clockwise (x: self.mX2, y: self.mY2)
    self.mX2 = p2.x
    self.mY2 = p2.y
    ioSet.insert (self)
  }

  //····················································································································

  func rotate90CounterClockwise_BoardLine (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.mX1, y: self.mY1)
    self.mX1 = p1.x
    self.mY1 = p1.y
    let p2 = inRotationCenter.rotated90CounterClockwise (x: self.mX2, y: self.mY2)
    self.mX2 = p2.x
    self.mY2 = p2.y
    ioSet.insert (self)
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  func canSnapToGrid_BoardLine (_ inGrid : Int) -> Bool {
    var isAligned = self.mX1.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mY1.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mX2.isAlignedOnGrid (inGrid)
    }
    if isAligned {
      isAligned = self.mY2.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  func snapToGrid_BoardLine (_ inGrid : Int) {
    self.mX1.align (onGrid: inGrid)
    self.mY1.align (onGrid: inGrid)
    self.mX2.align (onGrid: inGrid)
    self.mY2.align (onGrid: inGrid)
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_BoardLine () {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
