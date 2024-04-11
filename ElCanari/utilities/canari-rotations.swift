//
//  canari-rotations.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/05/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————
// L'unité de rotation utilisée dans canari est le 1/1000° [cru = Canari Rotation Unit]
// 1_000 cru = 1°
// 90_000 cru = 90°
//——————————————————————————————————————————————————————————————————————————————————————————————————

func canariRotationToRadians (_ inCanariRotation : Int) -> CGFloat {
  return CGFloat (inCanariRotation % 360_000) * CGFloat.pi / 180_000.0
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

func degreesToCanariRotation (_ inRotationInDegrees : CGFloat) -> Int {
  return Int ((inRotationInDegrees * 1_000.0).rounded ())
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

//func angleInDegreesBetweenNSPoints (_ inP1 : NSPoint, _ inP2 : NSPoint) -> CGFloat {
//  let dx = inP2.x - inP1.x
//  let dy = inP2.y - inP1.y
//  let distance = sqrt (dx * dx + dy * dy)
//  var angle : CGFloat = 0.0
//  if distance > 0.0 {
//    angle = asin (dy / distance) * 180.0 / CGFloat.pi
//    if dx < 0.0 {
//      angle = 180.0 - angle
//    }
//    if angle < 0.0 {
//      angle += 360.0
//    }
//  }
//  return angle
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————

//func angleInRadiansBetweenNSPoints (_ inP1 : NSPoint, _ inP2 : NSPoint) -> CGFloat {
//  let dx = inP2.x - inP1.x
//  let dy = inP2.y - inP1.y
//  let distance = sqrt (dx * dx + dy * dy)
//  var angle : CGFloat = 0.0
//  if distance > 0.0 {
//    angle = asin (dy / distance)
//    if dx < 0.0 {
//      angle = CGFloat.pi - angle
//    }
//    if angle < 0.0 {
//      angle += 2.0 * CGFloat.pi
//    }
//  }
//  return angle
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————
