//
//  extension-PackageSlavePad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY = "MASTER_PAD_ID_KEY"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackagePad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageSlavePad {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_PackageSlavePad (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_PackageSlavePad (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_PackageSlavePad (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageSlavePad (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_PackageSlavePad (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.xCenter, y: self.yCenter)
    return true
  }

  //····················································································································

  func rotate90Clockwise_PackageSlavePad (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90Clockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  //····················································································································

  func rotate90CounterClockwise_PackageSlavePad (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90CounterClockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_PackageSlavePad (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_PackageSlavePad (knob inKnobIndex: Int,
             proposedDx inDx: Int,
             proposedDy inDy: Int,
             unalignedMouseLocationX inUnlignedMouseLocationX : Int,
             unalignedMouseLocationY inUnlignedMouseLocationY : Int,
             alignedMouseLocationX inAlignedMouseLocationX : Int,
             alignedMouseLocationY inAlignedMouseLocationY : Int,
             shift inShift : Bool) {
  }


  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_PackageSlavePad () {
  }

  //····················································································································

  func canFlipHorizontally_PackageSlavePad () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_PackageSlavePad () {
  }

  //····················································································································

  func canFlipVertically_PackageSlavePad () -> Bool {
    return false
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_PackageSlavePad (_ inGrid : Int) -> Bool {
    var result = (self.xCenter % inGrid) != 0
    if !result {
      result = (self.yCenter % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_PackageSlavePad (_ inGrid : Int) {
    self.xCenter = ((self.xCenter + inGrid / 2) / inGrid) * inGrid
    self.yCenter = ((self.yCenter + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_PackageSlavePad () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.xCenter, y: self.yCenter)
    return result
  }

  //····················································································································

  func operationBeforeRemoving_PackageSlavePad () {
    super.operationBeforeRemoving ()
    self.master = nil
  }

  //····················································································································

  func saveIntoAdditionalDictionary_PackageSlavePad (_ ioDictionary : inout [String : Any]) {
    if let masterPadObjectIndex = self.master?.objectIndex {
      ioDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPadObjectIndex
    }
  }

  //····················································································································

  func operationAfterPasting_PackageSlavePad (additionalDictionary inDictionary : NSDictionary,
                                              optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                              objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    if let masterPadIndex = inDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] as? Int {
      for object in inObjectArray {
        if object.objectIndex == masterPadIndex, let masterPad = object as? PackagePad {
          self.master = masterPad
        }
      }
    }
    return (self.master != nil)
      ? "" // Ok, no error
      : "Cannot perform operation, the master pad does not exist any more." // Error message
  }

  //····················································································································
  //
  //····················································································································

  func angle (from inCanariPoint : CanariPoint) -> CGFloat {
    return CanariPoint.angleInRadian (CanariPoint (x: self.xCenter, y: self.yCenter), inCanariPoint)
  }

  //····················································································································

  override func program () -> String {
    var s = "slave "
    s += stringFrom (valueInCanariUnit: self.xCenter, displayUnit : self.xCenterUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.yCenter, displayUnit : self.yCenterUnit)
    s += " size "
    s += stringFrom (valueInCanariUnit: self.width, displayUnit : self.widthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.height, displayUnit : self.heightUnit)
    s += " shape "
    s += self.padShape.string
    s += " style "
    s += self.padStyle.string
    s += " hole "
    s += stringFrom (valueInCanariUnit: self.holeWidth, displayUnit : self.holeWidthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.holeHeight, displayUnit : self.holeHeightUnit)
    s += " id "
    s += "\(self.master_property.propval!.objectIndex)"
    s += ";\n"
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
