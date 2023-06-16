//
//  extension-SegmentForFontCharacter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SegmentForFontCharacter {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_SegmentForFontCharacter (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_SegmentForFontCharacter (additionalDictionary _ : [String : Any],
                                             optionalDocument _ : EBAutoLayoutManagedDocument?,
                                             objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_SegmentForFontCharacter (_ _ : inout [String : Any]) {
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_SegmentForFontCharacter () {
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_SegmentForFontCharacter () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_SegmentForFontCharacter (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_SegmentForFontCharacter (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_SegmentForFontCharacter (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_SegmentForFontCharacter () {
  }

  //····················································································································

  func canFlipHorizontally_SegmentForFontCharacter () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_SegmentForFontCharacter () {
  }

  //····················································································································

  func canFlipVertically_SegmentForFontCharacter () -> Bool {
    return false
  }

  //····················································································································
  //  Snap to grid
  //····················································································································

  func snapToGrid_SegmentForFontCharacter (_ _ : Int) {
  }

  //····················································································································

  func canSnapToGrid_SegmentForFontCharacter (_ _ : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_SegmentForFontCharacter (knob _ : Int,
                                        proposedUnalignedAlignedTranslation _ : CanariPoint,
                                        proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                        unalignedMouseDraggedLocation _ : CanariPoint,
                                        shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_SegmentForFontCharacter (knob _ : Int,
                                     proposedDx _ : Int,
                                     proposedDy _ : Int,
                                     unalignedMouseLocationX _ : Int,
                                     unalignedMouseLocationY _ : Int,
                                     alignedMouseLocationX _ : Int,
                                     alignedMouseLocationY _ : Int,
                                     shift _ : Bool) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_SegmentForFontCharacter (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_SegmentForFontCharacter (xBy _ : Int, yBy _ : Int) -> Bool {
    return false
  }

  //····················································································································

  func translate_SegmentForFontCharacter (xBy _ : Int, yBy _ : Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
