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
