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

  init (center : NSPoint, radius : CGFloat) {
    self.center = center
    self.radius = radius
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersects (circle : GeometricCircle) -> Bool {
    let d = NSPoint.distance (self.center, circle.center)
    return d <= (self.radius + circle.radius)
  }

  //····················································································································

  func intersects (segmentFrom p1 : NSPoint, to p2 : NSPoint) -> Bool {
    var intersects = NSPoint.distance (p1, self.center) <= self.radius
    if !intersects {
      intersects = NSPoint.distance (p2, self.center) <= self.radius
    }
    if !intersects {
      let segmentAngle = NSPoint.angleInRadian (p1, p2)
      let segmentCenter = NSPoint (x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
      let tr = CGAffineTransform (rotationAngle: -segmentAngle).translatedBy (x:-segmentCenter.x, y:-segmentCenter.y)
      let point = self.center.applying (tr)
      intersects = abs (point.y) <= self.radius
      if intersects {
        let segmentLength = NSPoint.distance (p1, p2)
        intersects = abs (point.x) <= (segmentLength * 0.5)
      }
    }
    return intersects
  }

  //····················································································································

  func path () -> NSBezierPath {
    let r = NSRect (x: center.x - radius, y: center.y - radius, width: radius  * 2.0, height: radius * 2.0)
    return NSBezierPath (ovalIn: r)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
