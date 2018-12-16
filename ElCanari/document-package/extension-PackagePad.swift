//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//let PACKAGE_ARC_CENTER = 1
//let PACKAGE_ARC_RADIUS = 2
//let PACKAGE_ARC_START_ANGLE = 3
//let PACKAGE_ARC_END_ANGLE = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackagePad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackagePad {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    return OCCanariPoint (x: inDx, y: inDy)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) {
//    let center = CanariPoint (x: self.xCenter, y: self.yCenter).cocoaPoint ()
//    let radius = canariUnitToCocoa (self.radius)
//    let startAngle = packageArcAngleToCocoaDegrees (self.startAngle)
//    let arcAngle = CGFloat (self.arcAngle) / 1000.0
//    if inKnobIndex == PACKAGE_ARC_CENTER {
//      self.xCenter += inDx
//      self.yCenter += inDy
//    }else if inKnobIndex == PACKAGE_ARC_RADIUS {
//      let t = NSAffineTransform ()
//      t.translateX (by: center.x, yBy: center.y)
//      t.rotate (byDegrees: startAngle - arcAngle / 2.0)
//      let currentRadiusKnob = t.transform (NSPoint (x: radius, y: 0.0))
//      let newRadiusKnob = NSPoint (
//        x: currentRadiusKnob.x + canariUnitToCocoa (inDx),
//        y: currentRadiusKnob.y + canariUnitToCocoa (inDy)
//      )
//      let deltaX = center.x - newRadiusKnob.x
//      let deltaY = center.y - newRadiusKnob.y
//      let newRadius = sqrt (deltaX * deltaX + deltaY * deltaY)
//      self.radius = cocoaToCanariUnit (newRadius)
//    }else if inKnobIndex == PACKAGE_ARC_START_ANGLE {
//      let t = NSAffineTransform ()
//      t.translateX (by: center.x, yBy: center.y)
//      t.rotate (byDegrees: startAngle)
//      let currentRadiusKnob = t.transform (NSPoint (x: radius, y: 0.0))
//      let newStartAngleKnob = NSPoint (
//        x: currentRadiusKnob.x + canariUnitToCocoa (inDx),
//        y: currentRadiusKnob.y + canariUnitToCocoa (inDy)
//      )
//      let newStartAngle = CGPoint.angleInDegrees (center, newStartAngleKnob)
//      let newCanariStartAngle = cocoaDegreesToPackageArcAngle (newStartAngle)
////      Swift.print ("\(startAngle)° -> \(newStartAngle)°")
////      Swift.print ("\(self.startAngle) -> \(newCanariStartAngle)")
//      self.startAngle = newCanariStartAngle
//    }else if inKnobIndex == PACKAGE_ARC_END_ANGLE {
//      let t = NSAffineTransform ()
//      t.translateX (by: center.x, yBy: center.y)
//      t.rotate (byDegrees: startAngle - arcAngle)
//      let currentEndAngleKnob = t.transform (NSPoint (x: radius, y: 0.0))
//      let newEndAngleKnob = NSPoint (
//        x: currentEndAngleKnob.x + canariUnitToCocoa (inDx),
//        y: currentEndAngleKnob.y + canariUnitToCocoa (inDy)
//      )
//      var newArcAngle = startAngle - CGPoint.angleInDegrees (center, newEndAngleKnob)
//      if newArcAngle < 0.0 {
//        newArcAngle += 360.0
//      }
//      // Swift.print ("\(arcAngle)° -> \(newArcAngle)°")
//      self.arcAngle = Int ((newArcAngle * 1000.0).rounded (.toNearestOrEven))
//    }
  }

  //····················································································································
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································

  override func operationAfterPasting () {
    self.padNumber = 0 // So it will be numbered by model observer CustomizedPackageDocument:handlePadNumbering
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
//    var result = (self.x % inGrid) != 0
//    if !result {
//      result = (self.y % inGrid) != 0
//    }
//    if !result {
//      result = (self.width % inGrid) != 0
//    }
//    if !result {
//      result = (self.height % inGrid) != 0
//    }
//    return result
    return false
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
//    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
//    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
//    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
//    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  override func alignmentPoints () -> OCCanariPointArray {
    let result = OCCanariPointArray ()
//    result.points.append (CanariPoint (x: self.x, y: self.y))
//    result.points.append (CanariPoint (x: self.x + self.width, y: self.y + self.height))
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSBezierPath {

  //····················································································································

  convenience init (octogonInRect inRect : NSRect) {
    self.init ()
    let s2 : CGFloat = sqrt (2.0)
    let w = inRect.size.width
    let h = inRect.size.height
    let x = inRect.origin.x // center x
    let y = inRect.origin.y // center y
    let lg = min (w, h) / (1.0 + s2)
    self.move (to: NSPoint (x: x + lg / s2,     y: y + h))
    self.line (to: NSPoint (x: x + w - lg / s2, y: y + h))
    self.line (to: NSPoint (x: x + w,           y: y + h - lg / s2))
    self.line (to: NSPoint (x: x + w,           y: y + lg / s2))
    self.line (to: NSPoint (x: x + w - lg / s2, y: y))
    self.line (to: NSPoint (x: x + lg / s2,     y: y))
    self.line (to: NSPoint (x: x,               y: y + lg / s2))
    self.line (to: NSPoint (x: x,               y: y + h - lg / s2))
    self.close ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
