//
//  extension-PackageInDevice.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageInDevice {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_PackageInDevice (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_PackageInDevice (additionalDictionary inDictionary : NSDictionary,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_PackageInDevice (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_PackageInDevice  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_PackageInDevice (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return ((self.mX + inDx) >= 0) && ((self.mY + inDy) >= 0)
  }

  //····················································································································

  func translate_PackageInDevice (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································

  func operationBeforeRemoving_PackageInDevice () {
    for masterPad in self.mMasterPads.values {
      for slavePad in masterPad.mSlavePads.values {
        slavePad.mMasterPad = nil
      }
    }
    super.operationBeforeRemoving ()
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_PackageInDevice () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_PackageInDevice () {
  }

  //····················································································································

  func canFlipHorizontally_PackageInDevice () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_PackageInDevice () {
  }

  //····················································································································

  func canFlipVertically_PackageInDevice () -> Bool {
    return false
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_PackageInDevice (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_PackageInDevice (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_PackageInDevice (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  Snap to grid
  //····················································································································

  func snapToGrid_PackageInDevice (_ inGrid : Int) {
  }

  //····················································································································

  func canSnapToGrid_PackageInDevice (_ inGrid : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_PackageInDevice (knob inKnobIndex : Int,
                proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_PackageInDevice (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
