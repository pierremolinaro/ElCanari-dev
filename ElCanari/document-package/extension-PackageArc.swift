//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_ARC_CENTER = 1
let PACKAGE_ARC_RADIUS = 2
let PACKAGE_ARC_START_ANGLE = 3
let PACKAGE_ARC_END_ANGLE = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageArc
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageArc {

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
    let center = CanariPoint (x: self.xCenter, y: self.yCenter).cocoaPoint ()
    let radius = canariUnitToCocoa (self.radius)
    let startAngle = packageArcAngleToCocoaDegrees (self.startAngle)
    let arcAngle = CGFloat (self.arcAngle) / 1000.0
    if inKnobIndex == PACKAGE_ARC_CENTER {
      self.xCenter += inDx
      self.yCenter += inDy
    }else if inKnobIndex == PACKAGE_ARC_RADIUS {
      let t = NSAffineTransform ()
      t.rotate (byDegrees: startAngle - arcAngle / 2.0)
      t.translateX (by: center.x, yBy: center.y)
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
      let t = NSAffineTransform ()
      t.translateX (by: center.x, yBy: center.y)
      t.rotate (byDegrees: startAngle)
      let currentRadiusKnob = t.transform (NSPoint (x: radius, y: 0.0))
      let newStartAngleKnob = NSPoint (
        x: currentRadiusKnob.x + canariUnitToCocoa (inDx),
        y: currentRadiusKnob.y + canariUnitToCocoa (inDy)
      )
      let newStartAngle = CGPoint.angleInDegrees (center, newStartAngleKnob)
      let newCanariStartAngle = cocoaDegreesToPackageArcAngle (newStartAngle)
//      Swift.print ("\(startAngle)° -> \(newStartAngle)°")
//      Swift.print ("\(self.startAngle) -> \(newCanariStartAngle)")
      self.startAngle = newCanariStartAngle
    }else if inKnobIndex == PACKAGE_ARC_END_ANGLE {
      let t = NSAffineTransform ()
      t.translateX (by: center.x, yBy: center.y)
      t.rotate (byDegrees: startAngle - arcAngle)
      let currentEndAngleKnob = t.transform (NSPoint (x: radius, y: 0.0))
      let newEndAngleKnob = NSPoint (
        x: currentEndAngleKnob.x + canariUnitToCocoa (inDx),
        y: currentEndAngleKnob.y + canariUnitToCocoa (inDy)
      )
      var newArcAngle = startAngle - CGPoint.angleInDegrees (center, newEndAngleKnob)
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

  convenience init (arcWithTangentFromCenter inCenter : NSPoint,
        radius inRadius : CGFloat,
        startAngleInDegrees inStartAngleInDegrees : CGFloat,
        arcAngleInDegrees inArcAngleInDegrees : CGFloat,
        startTangentLength inStartTangentLength : CGFloat,
        endTangentLength inEndTangentLength : CGFloat,
        pathIsClosed inPathIsClosed : Bool) {
    self.init ()
    var endAngle = inStartAngleInDegrees - inArcAngleInDegrees
    if endAngle >= 360.0 {
      endAngle -= 360.0
    }else if endAngle < 0.0 {
      endAngle += 360.0
    }
    self.appendArc (
      withCenter: inCenter,
      radius: inRadius,
      startAngle: inStartAngleInDegrees,
      endAngle: endAngle,
      clockwise: true
    )
  //--- First point
    var t = NSAffineTransform ()
    t.translateX (by: inCenter.x, yBy: inCenter.y)
    t.rotate (byDegrees: inStartAngleInDegrees)
    var firstPoint = t.transform (NSPoint (x: inRadius, y: 0.0))
    if inStartTangentLength > 0.0 {
      self.move (to: firstPoint)
      t = NSAffineTransform ()
      t.rotate (byDegrees: inStartAngleInDegrees + 90.0)
      let p = t.transform (NSPoint (x: inStartTangentLength, y: 0.0))
      self.relativeLine (to: p)
      firstPoint.x += p.x
      firstPoint.y += p.y
    }
  //--- Last Point
    t = NSAffineTransform ()
    t.translateX (by: inCenter.x, yBy: inCenter.y)
    t.rotate (byDegrees: inStartAngleInDegrees - inArcAngleInDegrees)
    var lastPoint = t.transform (NSPoint (x: inRadius, y: 0.0))
    if inEndTangentLength > 0.0 {
      self.move (to: lastPoint)
      t = NSAffineTransform ()
      t.rotate (byDegrees: inStartAngleInDegrees + inArcAngleInDegrees + 90.0)
      let p = t.transform (NSPoint (x: inEndTangentLength, y: 0.0))
      self.relativeLine (to: p)
      lastPoint.x += p.x
      lastPoint.y += p.y
    }
  //--- Closed ?
    if inPathIsClosed {
      self.move (to: firstPoint)
      self.line (to: lastPoint)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Angles in Cocoa are CGFloat, counterclockwise, in degrees (or radians)
// Package arc angle are integer, in degrees * 1000; clockwise

func packageArcAngleToCocoaDegrees (_ inCanariAngle : Int) -> CGFloat {
  var angle = 180.0 - CGFloat (inCanariAngle) / 1000.0
  if angle < 0.0 {
    angle += 360.0
  }
  return angle
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaDegreesToPackageArcAngle (_ inCocoaAngle : CGFloat) -> Int {
  var angle = 180_000 - Int ((inCocoaAngle * 1000.0).rounded (.toNearestOrEven))
  if angle < 0 {
    angle += 360_000
  }
  return angle
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
