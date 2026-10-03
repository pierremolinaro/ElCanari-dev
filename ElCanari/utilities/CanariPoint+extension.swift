//
//  CanariPoint.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2018.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//  Struct CanariPoint
//--------------------------------------------------------------------------------------------------

extension CanariPoint {

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Rotation ±90° around point
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotated90Clockwise (x inX : CanariLength, y inY : CanariLength) -> CanariPoint {
    let dx = inX - self.x
    let dy = inY - self.y
    return CanariPoint (x: self.x + dy, y: self.y - dx)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotated90CounterClockwise (x inX : CanariLength, y inY : CanariLength) -> CanariPoint {
    let dx = inX - self.x
    let dy = inY - self.y
    return CanariPoint (x: self.x - dy, y: self.y + dx)
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

 mutating func constraintToOctolinearDirection (from inOriginPoint : CanariPoint) {
   let angle = self.angle (to: inOriginPoint).unsignedDegreeValue
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

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

 static func octolinearNearestAngleInDegrees (_ inP1 : CanariPoint, _ inP2 : CanariPoint) -> CGFloat {
   let angle = inP1.angle (to: inP2).unsignedDegreeValue
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

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

 mutating func constraintToRectilinearDirection (from inOriginPoint : CanariPoint) {
   let angle = self.angle (to: inOriginPoint).unsignedDegreeValue
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

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

 static func rectilinearNearestAngleInDegrees (_ inP1 : CanariPoint, _ inP2 : CanariPoint) -> CGFloat {
   let angle = inP1.angle (to: inP2).unsignedDegreeValue
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

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

}

//--------------------------------------------------------------------------------------------------

typealias CanariPointArray = [CanariPoint]

//--------------------------------------------------------------------------------------------------

extension Set where Element == CanariPoint {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func insert (x inX : CanariLength, y inY : CanariLength) {
    self.insert (CanariPoint (x: inX, y: inY))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
