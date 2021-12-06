//
//  extension-NCInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION NCInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NCInSchematic {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_NCInSchematic (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_NCInSchematic (additionalDictionary inDictionary : NSDictionary,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_NCInSchematic (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_NCInSchematic () {
  }

  //····················································································································

  func canFlipHorizontally_NCInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_NCInSchematic () {
  }

  //····················································································································

  func canFlipVertically_NCInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_NCInSchematic (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_NCInSchematic (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_NCInSchematic (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_NCInSchematic () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_NCInSchematic (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    let p = self.mPoint!.location!
    accumulatedPoints.insert (p)
    return true
  }

  //····················································································································

  func rotate90Clockwise_NCInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    switch self.mOrientation {
    case .rotation0 :
      self.mOrientation = .rotation270
    case .rotation90 :
      self.mOrientation = .rotation0
    case .rotation180 :
      self.mOrientation = .rotation90
    case .rotation270 :
      self.mOrientation = .rotation180
    }
  }

  //····················································································································

  func rotate90CounterClockwise_NCInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  switch self.mOrientation {
    case .rotation0 :
      self.mOrientation = .rotation90
    case .rotation90 :
      self.mOrientation = .rotation180
    case .rotation180 :
      self.mOrientation = .rotation270
    case .rotation270 :
      self.mOrientation = .rotation0
    }
  }

  //····················································································································

  func operationBeforeRemoving_NCInSchematic () {
    self.mPoint = nil // Detach from point
  }

  //····················································································································
  //  Snap to grid
  //····················································································································

  func snapToGrid_NCInSchematic (_ inGrid : Int) {
  }

  //····················································································································

  func canSnapToGrid_NCInSchematic (_ inGrid : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_NCInSchematic (knob inKnobIndex : Int,
                proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_NCInSchematic (knob inKnobIndex: Int,
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
