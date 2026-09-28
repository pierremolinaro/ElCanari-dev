//
//  extension-CommentInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/05/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let COMMENT_IN_SCHEMATIC_DRAG_KNOB     = 0
let COMMENT_IN_SCHEMATIC_ROTATION_KNOB = 1

//--------------------------------------------------------------------------------------------------
//   EXTENSION CommentInSchematic
//--------------------------------------------------------------------------------------------------

extension CommentInSchematic {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Cursor
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_CommentInSchematic (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == COMMENT_IN_SCHEMATIC_DRAG_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil  // Uses default cursor
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_CommentInSchematic (additionalDictionary _ : [String : Any],
                                                 optionalDocument _ : EBAutoLayoutManagedDocument?,
                                                 objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_CommentInSchematic () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_CommentInSchematic () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_CommentInSchematic () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_CommentInSchematic () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_CommentInSchematic (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_CommentInSchematic (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_CommentInSchematic (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_CommentInSchematic (xBy inDx: CanariLength, yBy inDy: CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mX += inDx.cuValue
    self.mY += inDy.cuValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_CommentInSchematic (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_CommentInSchematic (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_CommentInSchematic (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Move
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_CommentInSchematic (knob _ : Int,
                                   proposedUnalignedAlignedTranslation _ : CanariPoint,
                                   proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                   unalignedMouseDraggedLocation _ : CanariPoint,
                                   shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_CommentInSchematic (knob inKnobIndex : Int,
                                proposedDx inDx: CanariLength,
                                proposedDy inDy: CanariLength,
                                unalignedMouseLocationX _ : CanariLength,
                                unalignedMouseLocationY _ : CanariLength,
                                alignedMouseLocationX inAlignedMouseLocationX : CanariLength,
                                alignedMouseLocationY inAlignedMouseLocationY : CanariLength,
                                shift _ : Bool) {
    if inKnobIndex == COMMENT_IN_SCHEMATIC_DRAG_KNOB {
      self.mX += inDx.cuValue
      self.mY += inDy.cuValue
    }else if inKnobIndex == COMMENT_IN_SCHEMATIC_ROTATION_KNOB {
      let absoluteCenter = CanariPoint (x: .cu (self.mX), y: .cu (self.mY)).ptValue
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).ptValue
      let newAngleInDegrees = NSPoint.angleInDegrees (absoluteCenter, newRotationKnobLocation)
      self.mRotation_property.setProp (degreesToCanariRotation (newAngleInDegrees))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_CommentInSchematic () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_CommentInSchematic (_ inGrid : Int) -> Bool {
    var result = (self.mX % inGrid) != 0
    if !result {
      result = (self.mY % inGrid) != 0
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_CommentInSchematic (_ inGrid : Int) {
    self.mX = ((self.mX + inGrid / 2) / inGrid) * inGrid
    self.mY = ((self.mY + inGrid / 2) / inGrid) * inGrid
   }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_CommentInSchematic () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.mX, y: self.mY)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
