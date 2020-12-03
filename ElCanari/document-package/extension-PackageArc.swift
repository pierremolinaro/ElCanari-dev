//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let PACKAGE_ARC_CENTER = 1
let PACKAGE_ARC_RADIUS = 2
let PACKAGE_ARC_START_ANGLE = 3
let PACKAGE_ARC_END_ANGLE = 4

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION PackageArc
//----------------------------------------------------------------------------------------------------------------------

extension PackageArc {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
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

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : ObjcCanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : ObjcCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : ObjcCanariPoint) -> ObjcCanariPoint {
    return inProposedAlignedTranslation
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
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
        x: canariUnitToCocoa (inNewX),
        y: canariUnitToCocoa (inNewY)
      )
      let newStartAngle = NSPoint.angleInDegrees (center, newStartAngleKnob)
      let newCanariStartAngle = Int ((newStartAngle * 1000.0).rounded (.toNearestOrEven))
      self.startAngle = newCanariStartAngle
    }else if inKnobIndex == PACKAGE_ARC_END_ANGLE {
      let newEndAngleKnob = NSPoint (
        x: canariUnitToCocoa (inNewX),
        y: canariUnitToCocoa (inNewY)
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
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    return false
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
  }

  //····················································································································

  override func alignmentPoints () -> ObjcCanariPointSet {
    let result = ObjcCanariPointSet ()
//    result.points.append (CanariPoint (x: self.x, y: self.y))
//    result.points.append (CanariPoint (x: self.x + self.width, y: self.y + self.height))
    return result
  }

  //····················································································································

  override func program () -> String {
    var s = "arc "
    s += stringFrom (valueInCanariUnit: self.xCenter, displayUnit : self.xCenterUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.yCenter, displayUnit : self.yCenterUnit)
    s += " radius "
    s += stringFrom (valueInCanariUnit: self.radius, displayUnit : self.radiusUnit)
    s += " start "
    s += "\(self.startAngle)"
    s += " angle "
    s += "\(self.arcAngle)"
    s += " leading "
    s += stringFrom (valueInCanariUnit: self.startTangent, displayUnit : self.startTangentUnit)
    s += " training "
    s += stringFrom (valueInCanariUnit: self.endTangent, displayUnit : self.endTangentUnit)
    if self.pathIsClosed {
      s += " closed"
    }
    s += ";\n"
    return s
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
