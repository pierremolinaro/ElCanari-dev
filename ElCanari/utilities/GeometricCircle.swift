//
//  GeometricCircle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct GeometricCircle
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct GeometricCircle {
  let center : CGPoint
  let radius : CGFloat

  //····················································································································
  //   init
  //····················································································································

  init (center : CGPoint, radius : CGFloat) {
    self.center = center
    self.radius = radius
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersects (circle : GeometricCircle) -> Bool {
    let d = CGPoint.distance (self.center, circle.center)
    return d <= (self.radius + circle.radius)
  }

  //····················································································································

  func intersects (segmentFrom p1 : CGPoint, to p2 : CGPoint) -> Bool {
    var intersects = CGPoint.distance (p1, self.center) <= self.radius
    if !intersects {
      intersects = CGPoint.distance (p2, self.center) <= self.radius
    }
    if !intersects {
      let segmentAngle = CGPoint.angleInRadian (p1, p2)
      let segmentCenter = CGPoint (x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
      let tr = CGAffineTransform (rotationAngle: -segmentAngle).translatedBy (x:-segmentCenter.x, y:-segmentCenter.y)
      let point = self.center.applying (tr)
      intersects = abs (point.y) <= self.radius
      if intersects {
        let segmentLength = CGPoint.distance (p1, p2)
        intersects = abs (point.x) <= (segmentLength * 0.5)
      }
    }
    return intersects
  }

  //····················································································································

  func path () -> CGPath {
    let r = CGRect (x: center.x - radius, y: center.y - radius, width: radius  * 2.0, height: radius * 2.0)
    return CGPath (ellipseIn: r, transform: nil)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

