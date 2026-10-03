//
//  GeometricOblong.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/11/2016.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//  Struct GeometricOblong
//--------------------------------------------------------------------------------------------------

struct GeometricOblong {

  let p1 : CanariPoint
  let p2 : CanariPoint
  let width : CanariLength
  let capStyle : TrackEndStyle

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Initializers
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (p1 inP1 : CanariPoint,
        p2 inP2 : CanariPoint,
        width inWidth : CanariLength,
        capStyle inCapStyle : TrackEndStyle) {
    self.p1 = inP1
    self.p2 = inP2
    self.width = inWidth
    self.capStyle = inCapStyle
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (center inCenter : CanariPoint,
        width inWidth : CanariLength,
        height inHeight : CanariLength,
        angle inAngle : CanariAngle) {
    if inWidth < inHeight {
      let af = CanariAffinity.translating (inCenter).rotating (by: inAngle)
      let dh = (inHeight - inWidth) / 2.0
      self.p1 = af.transforming (y: -dh)
      self.p2 = af.transforming (y: +dh)
      self.width = inWidth
    }else if inWidth > inHeight {
      let af = CanariAffinity.translating (inCenter).rotating (by: inAngle)
      let dw = (inWidth - inHeight) / 2.0
      self.p1 = af.transforming (x: -dw)
      self.p2 = af.transforming (x: +dw)
      self.width = inHeight
    }else{
      self.p1 = inCenter
      self.p2 = inCenter
      self.width = inWidth
    }
    self.capStyle = .round
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Contains point
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func contains (point p : NSPoint) -> Bool {
    switch self.capStyle {
    case .round :
    //--- p inside P1 circle
      var inside = self.p1.distance (to: p.canariPoint) <= (self.width / 2.0)
    //--- p inside P2 circle
      if !inside {
        inside = self.p2.distance (to: p.canariPoint) <= (self.width / 2.0)
      }
    //--- p inside rectangle
      if !inside {
        let r = GeometricRect (self.p1, self.p2, self.width)
        inside = r.contains (point: p)
      }
      return inside
    case .square :
      return self.geometricRect.contains (point: p)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bezierPath : BezierPath {
    var bp = BezierPath ()
    bp.lineWidth = self.width.ptValue
    bp.move (to: self.p1.ptValue)
    bp.line (to: self.p2.ptValue)
    switch self.capStyle {
    case .round :
      bp.lineCapStyle = .round
    case .square :
      bp.lineCapStyle = .square
    }
    return bp.pathToFillByStroking
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bounds : CanariRect {
    switch self.capStyle {
    case .round :
      let w = self.width / 2.0
      let left   = min (self.p1.x, self.p2.x) - w
      let right  = max (self.p1.x, self.p2.x) + w
      let bottom = min (self.p1.y, self.p2.y) - w
      let top    = max (self.p1.y, self.p2.y) + w
      return CanariRect (left: left, bottom: bottom, width: right - left, height: top - bottom)
    case .square :
      let r = self.geometricRect
      return r.bounds
     }
   }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var circle1 : GeometricCircle {
    return GeometricCircle (center: self.p1, radius: self.width / 2.0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var circle2 : GeometricCircle {
    return GeometricCircle (center: self.p2, radius: self.width / 2.0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var geometricRect : GeometricRect {
    switch self.capStyle {
    case .round :
      return GeometricRect (self.p1, self.p2, self.width)
    case .square :
      let center = self.p1.mid (with: self.p2)
      let angle = self.p1.angle (to: self.p2)
      let segmentHalfLength = (self.p1.distance (to: self.p2) + self.width) / 2.0
      let p1 = CanariPoint (x: center.x + segmentHalfLength * cos (angle), y: center.y + segmentHalfLength * sin (angle))
      let p2 = CanariPoint (x: center.x - segmentHalfLength * cos (angle), y: center.y - segmentHalfLength * sin (angle))
      return GeometricRect (p1, p2, self.width)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func transformed (by inAffineTransfrom : CanariAffinity) -> GeometricOblong {
    return GeometricOblong (
      p1: inAffineTransfrom.transforming (self.p1),
      p2: inAffineTransfrom.transforming (self.p2),
      width: self.width,
      capStyle: self.capStyle
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
