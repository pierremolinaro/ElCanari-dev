//
//  GeometricRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/11/2016.
//
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//   GeometricRect
//--------------------------------------------------------------------------------------------------

final class GeometricRect {
  let p1 : CanariPoint
  let p2 : CanariPoint
  let width : CanariLength

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRect : CanariRect) {
    self.p1 = CanariPoint (x: inRect.minX, y: inRect.midY)
    self.p2 = CanariPoint (x: inRect.maxX, y: inRect.midY)
    self.width = inRect.size.height
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inP1 : CanariPoint, _ inP2 : CanariPoint, _ inWidth : CanariLength) {
    self.p1 = inP1
    self.p2 = inP2
    self.width = inWidth
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Center
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var center : CanariPoint {
    return self.p1.mid (with: self.p2)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   CircumCircle
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mCircumRadius : CanariLength? = nil
    var circumRadius : CanariLength {
    if let r = self.mCircumRadius {
      return r
    }else{
      let d = self.p1.distance (to: self.p2)
      let r = sqrt (d * d + self.width * self.width) / 2.0
      self.mCircumRadius = r
      return r
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Contains point
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func contains (point p : CanariPoint) -> Bool {
    return self.bezierPath.contains (p)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   vertices
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mVerticesCache : [CanariPoint]? = nil
  var vertices : [CanariPoint] {
    if let v = self.mVerticesCache {
      return v
    }else{
      let angle = self.p1.angle (to: self.p2)
      let dx = self.width * 0.5 * sin (angle)
      let dy = self.width * 0.5 * cos (angle)
      var v = [CanariPoint] ()
      v.append (CanariPoint (x: self.p1.x - dx, y: self.p1.y + dy))
      v.append (CanariPoint (x: self.p1.x + dx, y: self.p1.y - dy))
      v.append (CanariPoint (x: self.p2.x + dx, y: self.p2.y - dy))
      v.append (CanariPoint (x: self.p2.x - dx, y: self.p2.y + dy))
      self.mVerticesCache = v
      return v
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Intersection
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func intersects (circle inCircle : GeometricCircle) -> Bool {
    if !self.bounds.intersects (inCircle.bounds) {
      return false
    }else{
      let centerDistance = self.center.distance (to: inCircle.center)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
          let ref = CanariPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices1 [(i+2) % vertices1.count])
          var outside = true
          var j = 0
          while outside && (j < vertices2.count) {
            let test = CanariPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices2 [j])
            outside = ref.isNegative != test.isNegative
//            outside = (ref * test) < 0.0
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
          let ref = CanariPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices2 [(i+2) % vertices2.count])
          var outside = true
          var j = 0
          while outside && (j < vertices1.count) {
            let test = CanariPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices1 [j])
            outside = ref.isNegative != test.isNegative
//            outside = (ref * test) < 0.0
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bounds : CanariRect {
    return CanariRect (self.vertices)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bezierPath : BezierPath {
    var bp = BezierPath ()
    let v = self.vertices
    bp.move (to: v [0].ptValue)
    for idx in 1 ..< v.count {
      bp.line (to: v [idx].ptValue)
    }
    bp.close ()
    return bp
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
