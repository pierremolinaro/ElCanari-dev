//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_ARC_CENTER = 1
let PACKAGE_ARC_RADIUS = 2
let PACKAGE_ARC_START_ANGLE = 3
let PACKAGE_ARC_END_ANGLE = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageArc
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageArc {

  //····················································································································

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

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_PackageArc  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_PackageArc (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageArc (xBy inDx: Int, yBy inDy: Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_PackageArc (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_PackageArc (_ _ : inout [String : Any]) {
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_PackageArc (knob _ : Int,
                           proposedUnalignedAlignedTranslation _ : CanariPoint,
                           proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                           unalignedMouseDraggedLocation _ : CanariPoint,
                           shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  //····················································································································

  func move_PackageArc (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX _ : Int,
                      unalignedMouseLocationY _ : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift _ : Bool) {
    let center = CanariPoint (x: self.xCenter, y: self.yCenter).cocoaPoint
    let radius = canariUnitToCocoa (self.radius)
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
        x: currentRadiusKnob.x + canariUnitToCocoa (inDx),
        y: currentRadiusKnob.y + canariUnitToCocoa (inDy)
      )
      let deltaX = center.x - newRadiusKnob.x
      let deltaY = center.y - newRadiusKnob.y
      let newRadius = sqrt (deltaX * deltaX + deltaY * deltaY)
      self.radius = cocoaToCanariUnit (newRadius)
    }else if inKnobIndex == PACKAGE_ARC_START_ANGLE {
      let newStartAngleKnob = NSPoint (
        x: canariUnitToCocoa (inAlignedMouseLocationX),
        y: canariUnitToCocoa (inAlignedMouseLocationY)
      )
      let newStartAngle = NSPoint.angleInDegrees (center, newStartAngleKnob)
      let newCanariStartAngle = Int ((newStartAngle * 1000.0).rounded (.toNearestOrEven))
      self.startAngle = newCanariStartAngle
    }else if inKnobIndex == PACKAGE_ARC_END_ANGLE {
      let newEndAngleKnob = NSPoint (
        x: canariUnitToCocoa (inAlignedMouseLocationX),
        y: canariUnitToCocoa (inAlignedMouseLocationY)
      )
      var newArcAngle = NSPoint.angleInDegrees (center, newEndAngleKnob) - startAngle
      if newArcAngle < 0.0 {
        newArcAngle += 360.0
      }
      // Swift.print ("\(arcAngle)° -> \(newArcAngle)°")
      self.arcAngle = Int ((newArcAngle * 1000.0).rounded (.toNearestOrEven))
    }
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_PackageArc () {
  }

  //····················································································································

  func canFlipHorizontally_PackageArc () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_PackageArc () {
  }

  //····················································································································

  func canFlipVertically_PackageArc () -> Bool {
    return false
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_PackageArc (_ _ : Int) -> Bool {
    return false
  }

  //····················································································································

  func snapToGrid_PackageArc (_ _ : Int) {
  }

  //····················································································································

  func alignmentPoints_PackageArc () -> Set <CanariPoint> {
    let result = Set <CanariPoint> ()
//    result.points.append (CanariPoint (x: self.x, y: self.y))
//    result.points.append (CanariPoint (x: self.x + self.width, y: self.y + self.height))
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_PackageArc () {
  }

  //····················································································································

  override func program () -> String {
    var s = "arc "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.xCenter, displayUnit : self.xCenterUnit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.yCenter, displayUnit : self.yCenterUnit)
    s += " radius "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.radius, displayUnit : self.radiusUnit)
    s += " start "
    s += "\(self.startAngle)"
    s += " angle "
    s += "\(self.arcAngle)"
    s += " leading "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.startTangent, displayUnit : self.startTangentUnit)
    s += " training "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.endTangent, displayUnit : self.endTangentUnit)
    if self.pathIsClosed {
      s += " closed"
    }
    s += ";\n"
    return s
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_PackageArc (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_PackageArc (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_PackageArc (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
