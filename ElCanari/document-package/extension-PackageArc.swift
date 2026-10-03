//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let PACKAGE_ARC_CENTER = 1
let PACKAGE_ARC_RADIUS = 2
let PACKAGE_ARC_START_ANGLE = 3
let PACKAGE_ARC_END_ANGLE = 4

//--------------------------------------------------------------------------------------------------
//   EXTENSION PackageArc
//--------------------------------------------------------------------------------------------------

extension PackageArc {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_PackageArc (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == PACKAGE_ARC_RADIUS) {
      return NSCursor.upDownRightLeftCursor
    }else if (inKnobIndex == PACKAGE_ARC_RADIUS) {
      return NSCursor.rotationCursor
    }else if (inKnobIndex == PACKAGE_ARC_END_ANGLE) {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_PackageArc  (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_PackageArc (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_PackageArc (xBy inDx: CanariLength, yBy inDy: CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_PackageArc (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_PackageArc (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_PackageArc (knob _ : Int,
                           proposedUnalignedAlignedTranslation _ : CanariPoint,
                           proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                           unalignedMouseDraggedLocation _ : CanariPoint,
                           shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_PackageArc (knob inKnobIndex: Int,
                      proposedDx inDx: CanariLength,
                      proposedDy inDy: CanariLength,
                      unalignedMouseLocationX _ : CanariLength,
                      unalignedMouseLocationY _ : CanariLength,
                      alignedMouseLocationX inAlignedMouseLocationX : CanariLength,
                      alignedMouseLocationY inAlignedMouseLocationY : CanariLength,
                      shift _ : Bool) {
//    let center = NSPoint (x: self.xCenter, y: self.yCenter)
    let center = CanariPoint (x: self.xCenter, y: self.yCenter)
//    let radius = self.radius.ptValue
    let startAngle = self.startAngle
    let arcAngle = self.arcAngle
    if inKnobIndex == PACKAGE_ARC_CENTER {
      self.xCenter += inDx
      self.yCenter += inDy
    }else if inKnobIndex == PACKAGE_ARC_RADIUS {
      let tr = CanariAffinity
        .translating (x: self.xCenter, y: self.yCenter)
        .rotating (by: startAngle - arcAngle / 2.0)
      let currentRadiusKnob = tr.transforming (x: self.radius)
      let newRadiusKnob = CanariPoint (
        x: currentRadiusKnob.x + inDx,
        y: currentRadiusKnob.y + inDy
      )
      let deltaX = self.xCenter - newRadiusKnob.x
      let deltaY = self.yCenter - newRadiusKnob.y
      self.radius = sqrt (deltaX * deltaX + deltaY * deltaY)
    }else if inKnobIndex == PACKAGE_ARC_START_ANGLE {
      let newStartAngleKnob = CanariPoint (
        x: inAlignedMouseLocationX,
        y: inAlignedMouseLocationY
      )
      let newStartAngle = center.angle (to: newStartAngleKnob)
      self.startAngle = newStartAngle
    }else if inKnobIndex == PACKAGE_ARC_END_ANGLE {
      let newEndAngleKnob = CanariPoint (
        x: inAlignedMouseLocationX,
        y: inAlignedMouseLocationY
      )
      let newArcAngle = center.angle (to: newEndAngleKnob) - startAngle
      self.arcAngle = newArcAngle
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_PackageArc () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_PackageArc () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_PackageArc () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_PackageArc () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_PackageArc (_ _ : CanariLength) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_PackageArc (_ _ : CanariLength) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_PackageArc () -> Set <CanariPoint> {
    let result = Set <CanariPoint> ()
//    result.points.append (CanariPoint (x: self.x, y: self.y))
//    result.points.append (CanariPoint (x: self.x + self.width, y: self.y + self.height))
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_PackageArc () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func program () -> String {
    var s = "arc "
    s += self.xCenter.string (in: self.xCenterUnit, fractionDigits: 2)
    s += " : "
    s += self.yCenter.string (in: self.yCenterUnit, fractionDigits: 2)
    s += " radius "
    s += self.radius.string (in: self.radiusUnit, fractionDigits: 2)
    s += " start "
    s += "\(self.startAngle)"
    s += " angle "
    s += "\(self.arcAngle)"
    s += " leading "
    s += self.startTangent.string (in: self.startTangentUnit, fractionDigits: 2)
    s += " training "
    s += self.endTangent.string (in: self.endTangentUnit, fractionDigits: 2)
    if self.pathIsClosed {
      s += " closed"
    }
    s += ";\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_PackageArc (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  func rotate90Clockwise_PackageArc (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  func rotate90CounterClockwise_PackageArc (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
