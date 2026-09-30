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
    let center = NSPoint (x: self.xCenter, y: self.yCenter)
    let radius = self.radius.ptValue
    let startAngle = CGFloat (self.startAngle) / 1000.0
    let arcAngle = CGFloat (self.arcAngle) / 1000.0
    if inKnobIndex == PACKAGE_ARC_CENTER {
      self.xCenter += inDx
      self.yCenter += inDy
    }else if inKnobIndex == PACKAGE_ARC_RADIUS {
      let t = NSAffineTransform ()
      t.translateX (by: center.x, yBy: center.y)
      t.rotate (byDegrees: startAngle - arcAngle / 2.0)
      let currentRadiusKnob = t.transform (NSPoint (x: radius, y: 0.0))
      let newRadiusKnob = NSPoint (
        x: currentRadiusKnob.x + inDx.ptValue,
        y: currentRadiusKnob.y + inDy.ptValue
      )
      let deltaX = center.x - newRadiusKnob.x
      let deltaY = center.y - newRadiusKnob.y
      let newRadius = sqrt (deltaX * deltaX + deltaY * deltaY)
      self.radius = CanariLength.pt (newRadius)
    }else if inKnobIndex == PACKAGE_ARC_START_ANGLE {
      let newStartAngleKnob = NSPoint (
        x: inAlignedMouseLocationX.ptValue,
        y: inAlignedMouseLocationY.ptValue
      )
      let newStartAngle = NSPoint.angleInDegrees (center, newStartAngleKnob)
      let newCanariStartAngle = Int ((newStartAngle * 1000.0).rounded (.toNearestOrEven))
      self.startAngle = newCanariStartAngle
    }else if inKnobIndex == PACKAGE_ARC_END_ANGLE {
      let newEndAngleKnob = NSPoint (
        x: inAlignedMouseLocationX.ptValue,
        y: inAlignedMouseLocationY.ptValue
      )
      var newArcAngle = NSPoint.angleInDegrees (center, newEndAngleKnob) - startAngle
      if newArcAngle < 0.0 {
        newArcAngle += 360.0
      }
      // Swift.print ("\(arcAngle)° -> \(newArcAngle)°")
      self.arcAngle = Int ((newArcAngle * 1000.0).rounded (.toNearestOrEven))
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
