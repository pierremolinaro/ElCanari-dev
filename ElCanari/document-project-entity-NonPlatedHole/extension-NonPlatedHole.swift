//
//  extension-NonPlatedHole.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 11/01/2025.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let NON_PLATED_HOLE_ORIGIN_KNOB  = 0
let NON_PLATED_HOLE_ROTATION_KNOB  = 1

let NON_PLATED_HOLE_ROTATION_KNOB_DISTANCE = CanariLength.pt (30.0)

//--------------------------------------------------------------------------------------------------
//   EXTENSION NonPlatedHole
//--------------------------------------------------------------------------------------------------

extension NonPlatedHole {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_NonPlatedHole (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == NON_PLATED_HOLE_ORIGIN_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == NON_PLATED_HOLE_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_NonPlatedHole (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_NonPlatedHole (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_NonPlatedHole (xBy inDx : CanariLength, yBy inDy : CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_NonPlatedHole (additionalDictionary inDictionary : [String : Any],
                                        optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                        objectArray _ : [EBGraphicManagedObject]) -> String {
    return "" // Ok, no error
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_NonPlatedHole (_ ioDictionary : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_NonPlatedHole (knob inKnobIndex : Int,
                          proposedUnalignedAlignedTranslation _ : CanariPoint,
                          proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                          unalignedMouseDraggedLocation _ : CanariPoint,
                          shift _ : Bool) -> CanariPoint {
    if inKnobIndex == NON_PLATED_HOLE_ORIGIN_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == NON_PLATED_HOLE_ROTATION_KNOB {
      return inProposedAlignedTranslation
    }else{
      return .zero
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_NonPlatedHole (knob inKnobIndex: Int,
                      proposedDx inDx: CanariLength,
                      proposedDy inDy: CanariLength,
                      unalignedMouseLocationX _ : CanariLength,
                      unalignedMouseLocationY _ : CanariLength,
                      alignedMouseLocationX inAlignedMouseLocationX : CanariLength,
                      alignedMouseLocationY inAlignedMouseLocationY : CanariLength,
                      shift _ : Bool) {
    if inKnobIndex == NON_PLATED_HOLE_ORIGIN_KNOB {
      self.mX += inDx
      self.mY += inDy
    }else if inKnobIndex == NON_PLATED_HOLE_ROTATION_KNOB {
      let origin = NSPoint (x: self.mX, y: self.mY)
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY).ptValue
//      let newAngleInDegrees = NSPoint.angleInDegrees (origin, newRotationKnobLocation)
//      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
      self.mRotation_property.setProp (origin.angle (to: newRotationKnobLocation))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_NonPlatedHole (_ inGrid : CanariLength) -> Bool {
    var isAligned = self.mX.isAligned (on: inGrid)
    if isAligned {
      isAligned = self.mY.isAligned (on: inGrid)
    }
    return !isAligned
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_NonPlatedHole (_ inGrid : CanariLength) {
    self.mX.align (on: inGrid)
    self.mY.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_NonPlatedHole (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.mX, y: self.mY)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_NonPlatedHole (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
//    self.mRotation = (self.mRotation + degreesToCanariRotation (270.0)) % degreesToCanariRotation (360.0)
    self.mRotation += .degrees270
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_NonPlatedHole (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
//    self.mRotation = (self.mRotation + degreesToCanariRotation (90.0)) % degreesToCanariRotation (360.0)
    self.mRotation += .degrees90
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_NonPlatedHole () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  REMOVING
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_NonPlatedHole () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_NonPlatedHole () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_NonPlatedHole () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_NonPlatedHole () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_NonPlatedHole () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
