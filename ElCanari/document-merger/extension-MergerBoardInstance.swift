//
//  extension-MergerBoardInstance-graphic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION MergerBoardInstance
//——————————————————————————————————————————————————————————————————————————————————————————————————

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

  func acceptedTranslation_MergerBoardInstance (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    var acceptedX = inDx
    let newX = self.x + acceptedX
    if newX < 0 {
      acceptedX = -self.x
    }
    var acceptedY = inDy
    let newY = self.y + acceptedY
    if newY < 0 {
      acceptedY = -self.y
    }
    return CanariPoint (x: acceptedX, y: acceptedY)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_MergerBoardInstance (xBy inDx: Int, yBy inDy: Int) -> Bool {
    let newX = self.x + inDx
    let newY = self.y + inDy
    return (newX >= 0) && (newY >= 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_MergerBoardInstance (xBy inDx: Int, yBy inDy: Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x += inDx
    self.y += inDy
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

//——————————————————————————————————————————————————————————————————————————————————————————————————
