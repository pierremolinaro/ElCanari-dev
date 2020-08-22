//
//  GeometricOblong.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/11/2016.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//  Struct GeometricOblong
//----------------------------------------------------------------------------------------------------------------------

struct GeometricOblong {
  let p1 : NSPoint
  let p2 : NSPoint
  let width : CGFloat

  //····················································································································
  //   init
  //····················································································································

  init (from p1 : NSPoint, to p2 : NSPoint, width : CGFloat) {
    self.p1 = p1
    self.p2 = p2
    self.width = width
  }

  //····················································································································
  //   Contains point
  //····················································································································

  func contains (point p : NSPoint) -> Bool {
  //--- p inside P1 circle
    var inside = NSPoint.distance (self.p1, p) <= (self.width / 2.0)
  //--- p inside P2 circle
    if !inside {
      inside = NSPoint.distance (self.p2, p) <= (self.width / 2.0)
    }
  //--- p inside rectangle
    if !inside {
      let r = GeometricRect (self.p1, self.p2, self.width)
      inside = r.contains (point: p)
    }
    return inside
  }

  //····················································································································

  var bezierPath : EBBezierPath {
    var bp = EBBezierPath ()
    bp.lineWidth = self.width
    bp.move (to: self.p1)
    bp.line (to: self.p2)
    bp.lineCapStyle = .round
    return bp.pathByStroking
  }

  //····················································································································

  var bounds : NSRect {
    let w = self.width / 2.0
    let left   = min (self.p1.x, self.p2.x) - w
    let right  = max (self.p1.x, self.p2.x) + w
    let bottom = min (self.p1.y, self.p2.y) - w
    let top    = max (self.p1.y, self.p2.y) + w
    return NSRect (x: left, y: bottom, width: right - left, height: top - bottom)
   }

  //····················································································································

  private var circle1 : GeometricCircle {
    return GeometricCircle (center: self.p1, radius: self.width / 2.0)
  }

  //····················································································································

  private var circle2 : GeometricCircle {
    return GeometricCircle (center: self.p2, radius: self.width / 2.0)
  }

  //····················································································································

  private var geometricRect : GeometricRect {
    return GeometricRect (self.p1, self.p2, self.width)
  }

  //····················································································································

  func intersects (circle inCircle : GeometricCircle) -> Bool {
    if !self.bounds.intersects (inCircle.bounds) {
      return false
    }else if self.circle1.intersects (circle: inCircle) {
      return true
    }else if self.circle2.intersects (circle: inCircle) {
      return true
    }else if self.geometricRect.intersects (circle: inCircle) {
      return true
    }else{
      return false
    }
  }

  //····················································································································

  func intersects (rect inRect : GeometricRect) -> Bool {
    if !self.bounds.intersects (inRect.bounds) {
      return false
    }else if inRect.intersects (circle: self.circle1) {
      return true
    }else if inRect.intersects (circle: self.circle2) {
      return true
    }else if inRect.intersects (rect: self.geometricRect) {
      return true
    }else{
      return false
    }
  }

  //····················································································································

  func intersects (oblong inOther : GeometricOblong) -> Bool {
    if !self.bounds.intersects (inOther.bounds) {
      return false
    }else if self.circle1.intersects (circle: inOther.circle1) {
      return true
    }else if self.circle1.intersects (circle: inOther.circle2) {
      return true
    }else if self.circle1.intersects (rect: inOther.geometricRect) {
      return true
    }else if self.circle2.intersects (circle: inOther.circle1) {
      return true
    }else if self.circle2.intersects (circle: inOther.circle2) {
      return true
    }else if self.circle2.intersects (rect: inOther.geometricRect) {
      return true
    }else if self.geometricRect.intersects (circle: inOther.circle1) {
      return true
    }else if self.geometricRect.intersects (circle: inOther.circle2) {
      return true
    }else if self.geometricRect.intersects (rect: inOther.geometricRect) {
      return true
    }else{
      return false
    }
  }

  //····················································································································

  func transformed (by inAffineTransfrom : AffineTransform) -> GeometricOblong {
    return GeometricOblong (from: inAffineTransfrom.transform (self.p1), to: inAffineTransfrom.transform (self.p2), width: self.width)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
