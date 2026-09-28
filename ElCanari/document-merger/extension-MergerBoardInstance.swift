//
//  extension-MergerBoardInstance-graphic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2018.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//   EXTENSION MergerBoardInstance
//--------------------------------------------------------------------------------------------------

extension MergerBoardInstance {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Cursor
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_MergerBoardInstance (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_MergerBoardInstance (additionalDictionary _ : [String : Any],
                                                  optionalDocument _ : EBAutoLayoutManagedDocument?,
                                                  objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_MergerBoardInstance (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_MergerBoardInstance (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    var acceptedX = inDx
    let newX = .cu (self.x) + acceptedX
    if newX < .zero {
      acceptedX = -.cu (self.x)
    }
    var acceptedY = inDy
    let newY = .cu (self.y) + acceptedY
    if newY < .zero {
      acceptedY = -.cu (self.y)
    }
    return CanariPoint (x: acceptedX, y: acceptedY)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_MergerBoardInstance (xBy inDx: CanariLength, yBy inDy: CanariLength) -> Bool {
    let newX = self.x + inDx.cuValue
    let newY = self.y + inDy.cuValue
    return (newX >= 0) && (newY >= 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_MergerBoardInstance (xBy inDx: CanariLength, yBy inDy: CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x += inDx.cuValue
    self.y += inDy.cuValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_MergerBoardInstance () {
    super.operationBeforeRemoving ()
    self.myRoot_property.setProp (nil)
    self.myModel_property.setProp (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_MergerBoardInstance () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_MergerBoardInstance (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  func rotate90Clockwise_MergerBoardInstance (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  func rotate90CounterClockwise_MergerBoardInstance (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_MergerBoardInstance () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_MergerBoardInstance () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_MergerBoardInstance () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_MergerBoardInstance () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Snap to grid
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_MergerBoardInstance (_ _ : Int) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_MergerBoardInstance (_ _ : Int) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Move
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_MergerBoardInstance (knob _ : Int,
                                    proposedUnalignedAlignedTranslation _ : CanariPoint,
                                    proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                    unalignedMouseDraggedLocation _ : CanariPoint,
                                    shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_MergerBoardInstance (knob _ : Int,
                                 proposedDx _ : Int,
                                 proposedDy _ : Int,
                                 unalignedMouseLocationX _ : Int,
                                 unalignedMouseLocationY _ : Int,
                                 alignedMouseLocationX _ : Int,
                                 alignedMouseLocationY _ : Int,
                                 shift _ : Bool) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
