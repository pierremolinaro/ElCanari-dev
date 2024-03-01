//
//  extension-SymbolInstanceInDevice.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolInstanceInDevice
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolInstanceInDevice {

  //································································································
  //  Cursor
  //································································································

  func cursorForKnob_SymbolInstanceInDevice (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //································································································
  //  operationAfterPasting
  //································································································

  func operationAfterPasting_SymbolInstanceInDevice (additionalDictionary _ : [String : Any],
                                             optionalDocument _ : EBAutoLayoutManagedDocument?,
                                             objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //································································································
  //  Save into additional dictionary
  //································································································

  func saveIntoAdditionalDictionary_SymbolInstanceInDevice (_ _ : inout [String : Any]) {
  }

  //································································································

  func acceptToTranslate_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return ((self.mX + inDx) >= 0) && ((self.mY + inDy) >= 0)
  }

  //································································································

  func translate_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  //································································································

  func operationBeforeRemoving_SymbolInstanceInDevice () {
    for pinInstance in self.mPinInstances.values {
      pinInstance.mSymbolInstance = nil
      pinInstance.mType = nil
      pinInstance.mPadProxy = nil
    }
  //--- Remove symbol type if no more symbol instances
    if let symbolType = self.mType, symbolType.instanceCount == 1 {
      for symbolPinType in symbolType.mPinTypes.values {
        symbolPinType.mInstances = EBReferenceArray ()
      }
      symbolType.mPinTypes = EBReferenceArray ()
      self.mDeviceRoot?.mSymbolTypes_property.remove (symbolType)
    }
  //---
    self.mDeviceRoot = nil
    self.mType = nil
    super.operationBeforeRemoving ()
  }

  //································································································
  //  Alignment Points
  //································································································

  func alignmentPoints_SymbolInstanceInDevice () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //································································································
  //  HORIZONTAL FLIP
  //································································································

  func flipHorizontally_SymbolInstanceInDevice () {
  }

  //································································································

  func canFlipHorizontally_SymbolInstanceInDevice () -> Bool {
    return false
  }

  //································································································
  //  VERTICAL FLIP
  //································································································

  func flipVertically_SymbolInstanceInDevice () {
  }

  //································································································

  func canFlipVertically_SymbolInstanceInDevice () -> Bool {
    return false
  }

  //································································································
  //  ROTATE 90
  //································································································

  func canRotate90_SymbolInstanceInDevice (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_SymbolInstanceInDevice (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_SymbolInstanceInDevice (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //································································································
  //  Snap to grid
  //································································································

  func snapToGrid_SymbolInstanceInDevice (_ _ : Int) {
  }

  //································································································
  //  Translation
  //································································································

  func acceptedTranslation_SymbolInstanceInDevice (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }
  
  //································································································

  func canSnapToGrid_SymbolInstanceInDevice (_ _ : Int) -> Bool {
    return false
  }

  //································································································
  //  Move
  //································································································

  func canMove_SymbolInstanceInDevice (knob _ : Int,
                                       proposedUnalignedAlignedTranslation _ : CanariPoint,
                                       proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                       unalignedMouseDraggedLocation _ : CanariPoint,
                                       shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //································································································

  func move_SymbolInstanceInDevice (knob _ : Int,
                                    proposedDx _ : Int,
                                    proposedDy _ : Int,
                                    unalignedMouseLocationX _ : Int,
                                    unalignedMouseLocationY _ : Int,
                                    alignedMouseLocationX _ : Int,
                                    alignedMouseLocationY _ : Int,
                                    shift _ : Bool) {
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
