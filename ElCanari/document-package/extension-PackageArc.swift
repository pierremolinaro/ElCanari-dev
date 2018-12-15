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
    var dx = inDx
    var dy = inDy
    if inKnobIndex == PACKAGE_ARC_CENTER {
//      if (self.width - dx) < 0 {
//        dx = self.width
//      }
    }else if inKnobIndex == PACKAGE_ARC_RADIUS {
//      shape.append (EBKnobShape (at: radiusKnob, index: PACKAGE_ARC_RADIUS, .circ))
//      if (self.width + dx) < 0 {
//        dx = -self.width
//      }
//    }else if inKnobIndex == PACKAGE_OVAL_BOTTOM {
//      if (self.height - dy) < 0 {
//        dy = self.height
//      }
//    }else if inKnobIndex == PACKAGE_OVAL_TOP {
//      if (self.height + dy) < 0 {
//        dy = -self.height
//      }
    }
    return OCCanariPoint (x: dx, y: dy)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) {
    let center = CanariPoint (x: self.xCenter, y: self.yCenter).cocoaPoint ()
    let radius = canariUnitToCocoa (self.radius)
    let startAngle = CGFloat (self.startAngle) / 1000.0
    let arcAngle = CGFloat (self.arcAngle) / 1000.0
    if inKnobIndex == PACKAGE_ARC_CENTER {
      self.xCenter += inDx
      self.yCenter += inDy
    }else if inKnobIndex == PACKAGE_ARC_RADIUS {
      let t = NSAffineTransform ()
      t.rotate (byDegrees: startAngle + arcAngle / 2.0)
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
      // let oldStartAngle = CGPoint.angleInDegrees (center, currentRadiusKnob)
      let newStartAngleKnob = NSPoint (
        x: currentRadiusKnob.x + canariUnitToCocoa (inDx),
        y: currentRadiusKnob.y + canariUnitToCocoa (inDy)
      )
      let newStartAngle = CGPoint.angleInDegrees (center, newStartAngleKnob)
      self.startAngle = Int ((newStartAngle * 1000.0).rounded (.toNearestOrEven))
    }else if inKnobIndex == PACKAGE_ARC_END_ANGLE {
      let t = NSAffineTransform ()
      t.translateX (by: center.x, yBy: center.y)
      t.rotate (byDegrees: startAngle + arcAngle)
      let currentEndAngleKnob = t.transform (NSPoint (x: radius, y: 0.0))
      let newEndAngleKnob = NSPoint (
        x: currentEndAngleKnob.x + canariUnitToCocoa (inDx),
        y: currentEndAngleKnob.y + canariUnitToCocoa (inDy)
      )
      var newArcAngle = CGPoint.angleInDegrees (center, newEndAngleKnob) - startAngle
      if newArcAngle < 0.0 {
        newArcAngle += 360.0
      }
      self.arcAngle = Int ((newArcAngle * 1000.0).rounded (.toNearestOrEven))
 //     Swift.print ("\(arcAngle), \(newArcAngle)")
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
    self.appendArc (
      withCenter: inCenter,
      radius: inRadius,
      startAngle: inStartAngleInDegrees,
      endAngle: inStartAngleInDegrees + inArcAngleInDegrees
    )
  //--- First point
    var t = NSAffineTransform ()
    t.translateX (by: inCenter.x, yBy: inCenter.y)
    t.rotate (byDegrees: inStartAngleInDegrees)
    var firstPoint = t.transform (NSPoint (x: inRadius, y: 0.0))
    if inStartTangentLength > 0.0 {
      self.move (to: firstPoint)
      t = NSAffineTransform ()
      t.rotate (byDegrees: inStartAngleInDegrees - 90.0)
      let p = t.transform (NSPoint (x: inStartTangentLength, y: 0.0))
      self.relativeLine (to: p)
      firstPoint.x += p.x
      firstPoint.y += p.y
    }
  //--- Last Point
    t = NSAffineTransform ()
    t.translateX (by: inCenter.x, yBy: inCenter.y)
    t.rotate (byDegrees: inStartAngleInDegrees + inArcAngleInDegrees)
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
