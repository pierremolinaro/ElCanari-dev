//
//  extension-SegmentForFontCharacter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SegmentForFontCharacter {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_SegmentForFontCharacter (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_SegmentForFontCharacter (additionalDictionary inDictionary : NSDictionary,
                                             optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_SegmentForFontCharacter (_ ioDictionary : NSMutableDictionary) {
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

  func canRotate90_SegmentForFontCharacter (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_SegmentForFontCharacter (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_SegmentForFontCharacter (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  func snapToGrid_SegmentForFontCharacter (_ inGrid : Int) {
  }

  //····················································································································

  func canSnapToGrid_SegmentForFontCharacter (_ inGrid : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_SegmentForFontCharacter (knob inKnobIndex : Int,
                proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_SegmentForFontCharacter (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_SegmentForFontCharacter (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_SegmentForFontCharacter (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return false
  }

  //····················································································································

  func translate_SegmentForFontCharacter (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
