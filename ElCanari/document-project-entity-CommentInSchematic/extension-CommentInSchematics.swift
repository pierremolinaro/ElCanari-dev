//
//  extension-CommentInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION CommentInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CommentInSchematic {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_CommentInSchematic (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_CommentInSchematic (additionalDictionary inDictionary : NSDictionary,
                                                 objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_CommentInSchematic () {
  }

  //····················································································································

  func canFlipHorizontally_CommentInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_CommentInSchematic () {
  }

  //····················································································································

  func canFlipVertically_CommentInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_CommentInSchematic (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_CommentInSchematic (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_CommentInSchematic (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_CommentInSchematic (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_CommentInSchematic (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

  //····················································································································

  func rotate90Clockwise_CommentInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································

  func rotate90CounterClockwise_CommentInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_CommentInSchematic (knob inKnobIndex : Int,
                proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_CommentInSchematic (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_CommentInSchematic () {
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_CommentInSchematic (_ inGrid : Int) -> Bool {
    var result = (self.mX % inGrid) != 0
    if !result {
      result = (self.mY % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_CommentInSchematic (_ inGrid : Int) {
    self.mX = ((self.mX + inGrid / 2) / inGrid) * inGrid
    self.mY = ((self.mY + inGrid / 2) / inGrid) * inGrid
   }

  //····················································································································

  func alignmentPoints_CommentInSchematic () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.mX, y: self.mY)
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
