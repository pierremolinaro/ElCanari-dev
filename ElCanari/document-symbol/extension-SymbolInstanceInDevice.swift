//
//  extension-SymbolInstanceInDevice.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolInstanceInDevice {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_SymbolInstanceInDevice (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_SymbolInstanceInDevice (additionalDictionary inDictionary : NSDictionary,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_SymbolInstanceInDevice (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································

  func acceptToTranslate_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return ((self.mX + inDx) >= 0) && ((self.mY + inDy) >= 0)
  }

  //····················································································································

  func translate_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································

  func operationBeforeRemoving_SymbolInstanceInDevice () {
    for pinInstance in self.mPinInstances.values {
      pinInstance.mSymbolInstance = nil
      pinInstance.mType = nil
      pinInstance.mPadProxy = nil
    }
    self.mType = nil
    super.operationBeforeRemoving ()
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_SymbolInstanceInDevice () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_SymbolInstanceInDevice () {
  }

  //····················································································································

  func canFlipHorizontally_SymbolInstanceInDevice () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_SymbolInstanceInDevice () {
  }

  //····················································································································

  func canFlipVertically_SymbolInstanceInDevice () -> Bool {
    return false
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_SymbolInstanceInDevice (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_SymbolInstanceInDevice (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_SymbolInstanceInDevice (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  Snap to grid
  //····················································································································

  func snapToGrid_SymbolInstanceInDevice (_ inGrid : Int) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }
  
  //····················································································································

  func canSnapToGrid_SymbolInstanceInDevice (_ inGrid : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_SymbolInstanceInDevice (knob inKnobIndex : Int,
                proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_SymbolInstanceInDevice (knob inKnobIndex: Int,
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