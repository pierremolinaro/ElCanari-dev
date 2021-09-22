//
//  GeometricRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   GeometricRect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class GeometricRect {
  let p1 : NSPoint
  let p2 : NSPoint
  let width : CGFloat

  //····················································································································
  //   init
  //····················································································································

  init (rect inRect : NSRect) {
    self.p1 = NSPoint (x: NSMinX (inRect), y: NSMidY (inRect))
    self.p2 = NSPoint (x: NSMaxX (inRect), y: NSMidY (inRect))
    self.width = inRect.size.height
  }

  //····················································································································

  init (_ inP1 : NSPoint, _ inP2 : NSPoint, _ inWidth : CGFloat) {
    self.p1 = inP1
    self.p2 = inP2
    self.width = inWidth
  }

  //····················································································································
  //   Center
  //····················································································································

  var center : NSPoint {
    return NSPoint.center (self.p1, self.p2)
  }

  //····················································································································
  //   length
  //····················································································································

  var length : CGFloat {
    return NSPoint.distance (self.p1, self.p2)
  }

  //····················································································································
  //   CircumCircle
  //····················································································································

  private var mCircumRadius : CGFloat? = nil
  var circumRadius : CGFloat {
    if let r = self.mCircumRadius {
      return r
    }else{
      let d = NSPoint.distance (self.p1, self.p2)
      let r = (d * d + self.width * self.width).squareRoot () / 2.0
      self.mCircumRadius = r
      return r
    }
  }

  //····················································································································

  func circumCircle () -> GeometricCircle {
    return GeometricCircle (center: self.center, radius: self.circumRadius)
  }

  //····················································································································
  //   inscribedCircle
  //····················································································································

  private var mInnerRadius : CGFloat? = nil
  var innerRadius : CGFloat {
    if let r = self.mInnerRadius {
      return r
    }else{
      let d = NSPoint.distance (self.p1, self.p2)
      let r = min (d, self.width) / 2.0
      self.mInnerRadius = r
      return r
    }
  }

  //····················································································································

  func inscribedCircle () -> GeometricCircle {
    return GeometricCircle (center: self.center, radius: self.innerRadius)
  }

  //····················································································································
  //   Contains point
  //····················································································································

  func contains (point p : NSPoint) -> Bool {
    return self.bezierPath.contains (p)
  }

  //····················································································································
  //   vertices
  //····················································································································

  private var mVerticesCache : [NSPoint]? = nil
  var vertices : [NSPoint] {
    if let v = self.mVerticesCache {
      return v
    }else{
      let angle = NSPoint.angleInRadian (self.p1, self.p2)
      let dx = self.width * 0.5 * sin (angle)
      let dy = self.width * 0.5 * cos (angle)
      var v = [NSPoint] ()
      v.append (NSPoint (x: self.p1.x - dx, y: self.p1.y + dy))
      v.append (NSPoint (x: self.p1.x + dx, y: self.p1.y - dy))
      v.append (NSPoint (x: self.p2.x + dx, y: self.p2.y - dy))
      v.append (NSPoint (x: self.p2.x - dx, y: self.p2.y + dy))
      self.mVerticesCache = v
      return v
    }
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersects (circle inCircle : GeometricCircle) -> Bool {
    if !self.bounds.intersects (inCircle.bounds) {
      return false
    }else{
      let centerDistance = NSPoint.distance (self.center, inCircle.center)
      if centerDistance > (self.circumRadius + inCircle.radius) {
        return false
      }else if self.bezierPath.contains (inCircle.center) {
        return true
      }else{
      //--- Test intersection between circle and rectangle edge
        let v = self.vertices
        for i in 0 ..< v.count {
          let j = (i+1) % v.count
          let intersects = inCircle.intersects (segmentFrom: v [i], to: v [j])
          if intersects {
            return true
          }
        }
        return false
      }
    }
  }

  //····················································································································

  func intersects (rect inRect : GeometricRect) -> Bool {
    if !self.bounds.intersects (inRect.bounds) {
      return false
    }else{
    //--- Method of separating axes (https://www.youtube.com/watch?v=WBy6AveIRRs)
      var intersects = true
      let vertices1 = self.vertices
      let vertices2 = inRect.vertices
      do{
        var i = 0
        while intersects && (i < vertices1.count) {
          let ref = NSPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices1 [(i+2) % vertices1.count])
          var outside = true
          var j = 0
          while outside && (j < vertices2.count) {
            let test = NSPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices2 [j])
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
          let ref = NSPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices2 [(i+2) % vertices2.count])
          var outside = true
          var j = 0
          while outside && (j < vertices1.count) {
            let test = NSPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices1 [j])
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
  }

  //····················································································································

  var bounds : NSRect {
    return NSRect (points: self.vertices)
  }

  //····················································································································

  var bezierPath : EBBezierPath {
    var bp = EBBezierPath ()
    let v = self.vertices
    bp.move (to: v [0])
    for idx in 1 ..< v.count {
      bp.line (to: v [idx])
    }
    bp.close ()
    return bp
  }

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> GeometricRect {
    return GeometricRect (inAffineTransform.transform (self.p1), inAffineTransform.transform (self.p2), self.width)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
