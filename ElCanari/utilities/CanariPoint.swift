//
//  CanariPoint.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias CanariPointArray = [CanariPoint]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct CanariPoint
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariPoint : Equatable, Hashable {

  //····················································································································

  var x : Int
  var y : Int

  //····················································································································
  //   init
  //····················································································································

  init () {
    self.x = 0
    self.y = 0
  }

  //····················································································································

  init (x inX : Int, y inY : Int) {
    self.x = inX
    self.y = inY
  }

  //····················································································································

  static func center (_ p1 : CanariPoint, _ p2 : CanariPoint) -> CanariPoint {
    return CanariPoint (x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
  }

  //····················································································································

  static func squareOfCanariDistance (_ p1 : CanariPoint, _ p2 : CanariPoint) -> Double {
    let dx = Double (p1.x - p2.x)
    let dy = Double (p1.y - p2.y)
    return dx * dx + dy * dy
  }

  //····················································································································
  //   Cocoa Point
  //····················································································································

  var cocoaPoint : NSPoint {
    return NSPoint (x: canariUnitToCocoa (self.x), y: canariUnitToCocoa (self.y))
  }

  //····················································································································
  //   millimeter Point
  //····················································································································

  var millimeterPoint : NSPoint {
    return NSPoint (x: canariUnitToMillimeter (self.x), y: canariUnitToMillimeter (self.y))
  }

  //····················································································································
  //   Aligned Point
  //····················································································································

  func point (alignedOnGrid inGrid: Int) -> CanariPoint {
    return CanariPoint (x: ((self.x + inGrid / 2) / inGrid) * inGrid, y: ((self.y + inGrid / 2) / inGrid) * inGrid)
  }

 //····················································································································

 static func segmentStrictlyContainsEBPoint (_ inP1 : CanariPoint,
                                             _ inP2 : CanariPoint,
                                             _ inP : CanariPoint) -> Bool {
   let p1x = inP1.x
   let p1y = inP1.y
   let p2x = inP2.x
   let p2y = inP2.y
   let px  = inP.x
   let py  = inP.y
   var within = ((p1x - px) * (p1y - p2y)) == ((p1y - py) * (p1x - p2x))
   if within {
     if p1x == p2x { // vertical segment
       within = (py > min (p1y, p2y)) && (py < max (p1y, p2y))
     }else if p1y == p2y { // vertical segment
       within = (px > min (p1x, p2x)) && (px < max (p1x, p2x))
     }else{ // Other segment
       within = (px > min (p1x, p2x)) && (px < max (p1x, p2x)) && (py > min (p1y, p2y)) && (py < max (p1y, p2y))
     }
   }
   return within
 }

  //····················································································································
  //   Rotation ±90° around point
  //····················································································································

  func rotated90Clockwise (_ inP : CanariPoint) -> CanariPoint {
    let dx = inP.x - self.x
    let dy = inP.y - self.y
    return CanariPoint (x: self.x + dy, y: self.y - dx)
  }

  //····················································································································

  func rotated90CounterClockwise (_ inP : CanariPoint) -> CanariPoint {
    let dx = inP.x - self.x
    let dy = inP.y - self.y
    return CanariPoint (x: self.x - dy, y: self.y + dx)
  }

  //····················································································································

  static func angleInRadian (_ p1 : CanariPoint, _ p2 : CanariPoint) -> CGFloat {
    let width  = CGFloat (p2.x - p1.x)
    let height = CGFloat (p2.y - p1.y)
    var angle = atan2 (height, width) // Result in radian
    if angle < 0.0 {
      angle += 2.0 * CGFloat.pi
    }
    return angle
  }

  //····················································································································

  static func angleInDegrees (_ p1 : CanariPoint, _ p2 : CanariPoint) -> CGFloat {
    return CanariPoint.angleInRadian (p1, p2) * 180.0 / .pi
  }

 //····················································································································

 mutating func constraintToOctolinearDirection (from inOriginPoint : CanariPoint) {
   let angle = NSPoint.angleInDegrees (self.cocoaPoint, inOriginPoint.cocoaPoint)
   let dx = self.x - inOriginPoint.x
   let dy = self.y - inOriginPoint.y
   if angle < (0.0 + 22.5) {
     self.y = inOriginPoint.y
   }else if angle < (0.0 + 45.0) {
     self.y = inOriginPoint.y + dx
   }else if angle < (0.0 + 67.5) {
     self.x = inOriginPoint.x + dy
   }else if angle < (90.0 + 22.5) {
     self.x = inOriginPoint.x
   }else if angle < (90.0 + 45.0) {
     self.x = inOriginPoint.x - dy
   }else if angle < (90.0 + 67.5) {
     self.y = inOriginPoint.y - dx
   }else if angle < (180.0 + 22.5) {
     self.y = inOriginPoint.y
   }else if angle < (180.0 + 45.0) {
     self.y = inOriginPoint.y + dx
   }else if angle < (180.0 + 67.5) {
     self.x = inOriginPoint.x + dy
   }else if angle < (270.0 + 22.5) {
     self.x = inOriginPoint.x
   }else if angle < (270.0 + 45.0) {
     self.x = inOriginPoint.x - dy
   }else if angle < (270.0 + 67.5) {
     self.y = inOriginPoint.y - dx
   }else{
     self.y = inOriginPoint.y
   }
 }

 //····················································································································

 static func octolinearNearestAngleInDegrees (_ inP1 : CanariPoint, _ inP2 : CanariPoint) -> CGFloat {
   let angle = CanariPoint.angleInDegrees (inP1, inP2)
   if angle < (0.0 + 22.5) {
     return 0.0
   }else if angle < (0.0 + 67.5) {
     return 45.0
   }else if angle < (90.0 + 22.5) {
     return 90.0
   }else if angle < (90.0 + 67.5) {
     return 135.0
   }else if angle < (180.0 + 22.5) {
     return 180.0
   }else if angle < (180.0 + 67.5) {
     return 225.0
   }else if angle < (270.0 + 22.5) {
     return 270.0
   }else if angle < (270.0 + 67.5) {
     return 315.0
   }else{
     return 0.0
   }
 }

 //····················································································································

 mutating func constraintToRectilinearDirection (from inOriginPoint : CanariPoint) {
   let angle = NSPoint.angleInDegrees (self.cocoaPoint, inOriginPoint.cocoaPoint)
   if angle < (0.0 + 45.0) {
     self.y = inOriginPoint.y
   }else if angle < (90.0 + 45.0) {
     self.x = inOriginPoint.x
   }else if angle < (180.0 + 45.0) {
     self.y = inOriginPoint.y
   }else if angle < (270.0 + 45.0) {
     self.x = inOriginPoint.x
   }else{
     self.y = inOriginPoint.y
   }
 }

 //····················································································································

 static func rectilinearNearestAngleInDegrees (_ inP1 : CanariPoint, _ inP2 : CanariPoint) -> CGFloat {
   let angle = CanariPoint.angleInDegrees (inP1, inP2)
   if angle < (0.0 + 45.0) {
     return 0.0
   }else if angle < (90.0 + 45.0) {
     return 90.0
   }else if angle < (180.0 + 45.0) {
     return 180.0
   }else if angle < (270.0 + 45.0) {
     return 270.0
   }else{
     return 0.0
   }
 }

 //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
