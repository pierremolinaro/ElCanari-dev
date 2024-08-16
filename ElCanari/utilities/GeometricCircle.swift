//
//  GeometricCircle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/11/2016.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//  Struct GeometricCircle
//--------------------------------------------------------------------------------------------------

struct GeometricCircle {
  let center : NSPoint
  let radius : CGFloat

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Intersection
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func intersects (circle : GeometricCircle) -> Bool {
    let d = NSPoint.distance (self.center, circle.center)
    return d <= (self.radius + circle.radius)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func intersects (rect inRect : GeometricRect) -> Bool {
    return inRect.intersects (circle: self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func intersects (segmentFrom inP1 : NSPoint, to inP2 : NSPoint) -> Bool {
  //--- We translate P1, P2, C (center of circle) so that P1 is at (0, 0)
    let p2x = inP2.x - inP1.x
    let p2y = inP2.y - inP1.y
    let Cx = self.center.x - inP1.x
    let Cy = self.center.y - inP1.y
  //--- Then we compute the relative abscisse µ of P, the projection of C on P1P2
    let µ = (p2x * Cx + p2y * Cy) / (p2x * p2x + p2y * p2y)
    if µ < 0.0 { // Outside
      return NSPoint.distance (self.center, inP1) <= self.radius
    }else if µ > 1.0 { // Outside
      return NSPoint.distance (self.center, inP2) <= self.radius
    }else{ // Inside: we compute the distance between P and C
      let dx = µ * p2x - Cx
      let dy = µ * p2y - Cy
      let d = (dx * dx + dy * dy).squareRoot ()
      return d <= self.radius
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bezierPath : EBBezierPath {
    return EBBezierPath (ovalIn: self.bounds)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bounds : NSRect {
    let s = NSSize (width: self.radius * 2.0, height: self.radius * 2.0)
    return NSRect (center: self.center, size: s)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

