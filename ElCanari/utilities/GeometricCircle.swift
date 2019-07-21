//
//  GeometricCircle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct GeometricCircle
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct GeometricCircle {
  let center : NSPoint
  let radius : CGFloat

  //····················································································································
  //   init
  //····················································································································

  init (center inCenter : NSPoint, radius inRadius : CGFloat) {
    self.center = inCenter
    self.radius = inRadius
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersects (circle : GeometricCircle) -> Bool {
    let d = NSPoint.distance (self.center, circle.center)
    return d <= (self.radius + circle.radius)
  }

  //····················································································································

  func intersects (rect inRect : GeometricRect) -> Bool {
    return inRect.intersects (circle: self)
  }

  //····················································································································

  func intersects (segmentFrom p1 : NSPoint, to p2 : NSPoint) -> Bool {
    if NSPoint.distance (p1, self.center) <= self.radius {
      Swift.print ("    p1 inside")
      return true // P1 is inside circle
    }else if NSPoint.distance (p2, self.center) <= self.radius {
      Swift.print ("    p2 inside")
      return true // P2 is inside circle
    }else if let (pp1, pp2) = self.bounds.clippedSegment (p1: p1, p2: p2), pp1 != pp2 {
      let P = NSPoint.distance (pp1, self.center)
      let Q = NSPoint.distance (pp2, self.center)
      let D = NSPoint.distance (pp1, pp2)
      let X = (P * P - Q * Q) / D
      let H = (2.0 * P * P + 2.0 * Q * Q - D * D - X * X).squareRoot () / 2.0
      Swift.print ("    H \(H), radius \(self.radius)")
      return H <= self.radius
    }else{
      return false
    }
  }

  //····················································································································

  var bezierPath : EBBezierPath {
    return EBBezierPath (ovalIn: self.bounds)
  }

  //····················································································································

  var bounds : NSRect {
    let s = NSSize (width: self.radius * 2.0, height: self.radius * 2.0)
    return NSRect (center: self.center, size: s)
  }

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> GeometricCircle {
    return GeometricCircle (center: inAffineTransform.transform (self.center), radius: self.radius)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

