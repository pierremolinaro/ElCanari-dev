//
//  CanariRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct CanariRect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariRect {
  let center : CGPoint
  let angle : CGFloat // In radians
  let size : CGSize

  //····················································································································
  //   init
  //····················································································································

  init (cgrect : CGRect) {
    center = CGPoint (x: NSMidX (cgrect), y: NSMidY (cgrect))
    size = cgrect.size
    angle = 0.0
  }

  //····················································································································

  init (from p1 : CGPoint, to p2 : CGPoint, height : CGFloat) {
    center = CGPoint (x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    size = CGSize (width: CGPoint.distance (p1, p2), height: height)
    angle = CGPoint.angleInRadian (p1, p2)
  }

  //····················································································································

  init (center : CGPoint, size : CGSize, angle : CGFloat) {
    self.center = center
    self.size = size
    self.angle = angle
  }

  //····················································································································
  //   CircumCircle
  //····················································································································

  func circumCircle () -> CanariCircle {
    let radius = sqrt (size.width * size.width + size.height * size.height) / 2.0
    return CanariCircle (center: self.center, radius: radius)
  }

  //····················································································································
  //   inscribedCircle
  //····················································································································

  func inscribedCircle () -> CanariCircle {
    let radius = min (size.width, size.height) / 2.0
    return CanariCircle (center: self.center, radius: radius)
  }

  //····················································································································
  //   Contains point
  //····················································································································

  func contains (point p : CGPoint) -> Bool {
    let tr = CGAffineTransform (rotationAngle: -angle).translatedBy (x:-center.x, y:-center.y)
    let point = p.applying (tr)
    return (abs (point.x) <= (size.width * 0.5)) && (abs (point.y) <= (size.height * 0.5))
  }

  //····················································································································
  //   vertices
  //····················································································································

  func vertices () -> [CGPoint] { // Returns the four vertices in counterclock order
    let cosSlash2 = cos (angle) / 2.0
    let sinSlash2 = sin (angle) / 2.0
    let widthCos  = size.width  * cosSlash2
    let widthSin  = size.width  * sinSlash2
    let heightCos = size.height * cosSlash2
    let heightSin = size.height * sinSlash2
    return [
      CGPoint (x: center.x + widthCos - heightSin, y: center.y + widthSin + heightCos),
      CGPoint (x: center.x - widthCos - heightSin, y: center.y - widthSin + heightCos),
      CGPoint (x: center.x - widthCos + heightSin, y: center.y - widthSin - heightCos),
      CGPoint (x: center.x + widthCos + heightSin, y: center.y + widthSin - heightCos)
    ]
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersects (circle : CanariCircle) -> Bool {
  //--- Intersection if circle contains rectangle center
    var intersects = CGPoint.distance (self.center, circle.center) <= circle.radius
  //--- Intersection if rectangle contains circle center
    if !intersects {
      intersects = self.contains (point: circle.center)
    }
  //--- Test intersection between circle and rectangle edge
    if !intersects {
      let vertices = self.vertices ()
      var i = 0
      while !intersects && (i < vertices.count) {
        intersects = circle.intersects (segmentFrom: vertices [i], to: vertices [(i+1) % vertices.count])
        i += 1
      }
    }
    return intersects
  }
  
  //····················································································································

  func intersects (rect : CanariRect) -> Bool {
  //--- Method of separating axes (https://www.youtube.com/watch?v=WBy6AveIRRs)
    var intersects = true
    let vertices1 = self.vertices ()
    let vertices2 = rect.vertices ()
    do{
      var i = 0
      while intersects && (i < vertices1.count) {
        let ref = CGPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices1 [(i+2) % vertices1.count])
        var outside = true
        var j = 0
        while outside && (j < vertices2.count) {
          let test = CGPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices2 [j])
          outside = (ref * test) < 0.0
          j += 1
        }
        intersects = !outside
        i += 1
      }
    }
  //---
    if intersects {
      var i = 0
      while intersects && (i < vertices2.count) {
        let ref = CGPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices2 [(i+2) % vertices2.count])
        var outside = true
        var j = 0
        while outside && (j < vertices1.count) {
          let test = CGPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices1 [j])
          outside = (ref * test) < 0.0
          j += 1
        }
        intersects = !outside
        i += 1
      }
    }
  //---
    return intersects
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
