//
//  extension-PackageSlavePad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY = "MASTER_PAD_ID_KEY"

//--------------------------------------------------------------------------------------------------
//   EXTENSION PackagePad
//--------------------------------------------------------------------------------------------------

extension PackageSlavePad {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Cursor
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_PackageSlavePad (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_PackageSlavePad (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_PackageSlavePad (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_PackageSlavePad (xBy inDx: CanariLength,
                                  yBy inDy: CanariLength,
                                  userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_PackageSlavePad (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.xCenter, y: self.yCenter)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_PackageSlavePad (from inRotationCenter : CanariPoint,
                                          userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90Clockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_PackageSlavePad (from inRotationCenter : CanariPoint,
                                                 userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90CounterClockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Move
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_PackageSlavePad (knob _ : Int,
                                proposedUnalignedAlignedTranslation _ : CanariPoint,
                                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                unalignedMouseDraggedLocation _ : CanariPoint,
                                shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_PackageSlavePad (knob _ : Int,
                             proposedDx _ : CanariLength,
                             proposedDy _ : CanariLength,
                             unalignedMouseLocationX _ : CanariLength,
                             unalignedMouseLocationY _ : CanariLength,
                             alignedMouseLocationX _ : CanariLength,
                             alignedMouseLocationY _ : CanariLength,
                             shift _ : Bool) {
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_PackageSlavePad () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_PackageSlavePad () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_PackageSlavePad () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_PackageSlavePad () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_PackageSlavePad (_ inGrid : CanariLength) -> Bool {
    var result = self.xCenter.isAligned (on: inGrid)
    if !result {
      result = self.yCenter.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_PackageSlavePad (_ inGrid : CanariLength) {
    self.xCenter.align (on: inGrid)
    self.yCenter.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_PackageSlavePad () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.xCenter, y: self.yCenter)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_PackageSlavePad () {
    super.operationBeforeRemoving ()
    self.master = nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_PackageSlavePad (_ ioDictionary : inout [String : Any]) {
    if let masterPadObjectIndex = self.master?.objectIndex {
      ioDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPadObjectIndex
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_PackageSlavePad (additionalDictionary inDictionary : [String : Any],
                                              optionalDocument _ : EBAutoLayoutManagedDocument?,
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func angle (from inCanariPoint : CanariPoint) -> CGFloat {
//    return CanariPoint.angleInRadian (CanariPoint (x: self.xCenter, y: self.yCenter), inCanariPoint)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func program () -> String {
    var s = "slave "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.xCenter, displayUnit : self.xCenterUnit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.yCenter, displayUnit : self.yCenterUnit)
    s += " size "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.width, displayUnit : self.widthUnit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.height, displayUnit : self.heightUnit)
    s += " shape "
    s += self.padShape.string
    s += " style "
    s += self.padStyle.string
    s += " hole "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.holeWidth, displayUnit : self.holeWidthUnit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.holeHeight, displayUnit : self.holeHeightUnit)
    s += " id "
    s += "\(self.master_property.propval!.objectIndex)"
    s += ";\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
