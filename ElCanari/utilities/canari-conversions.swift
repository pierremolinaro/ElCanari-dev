//
//  canari-unit-conversion.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// L'unité de longueur utilisée dans canari est le 1/90 µm [cu = Canari Unit]
// 1 µm = 90 cu
// 1 mm = 90 000 cu
// 1 cm = 900 000 cu
// 1 pouce = 2,54 cm = 2 286 000 cu
// 1 mil = 0,001 pouce = 2 286 cu
// Le pixel Cocoa est 1/72 pouce
// 1 px = 1/72 pouce = 31 750
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let ONE_MILLIMETER_IN_CANARI_UNIT = 90_000
let ONE_INCH_IN_CANARI_UNIT = 2_286_000
let ONE_MIL_IN_CANARI_UNIT = 2_286

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToCocoa (_ inValue : Int) -> CGFloat {
  return (CGFloat (inValue) / 31_750.0)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaToCanariUnit (_ inValue : CGFloat) -> Int {
  return Int (inValue *  31_750.0)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToInch (_ inValue : Int) -> CGFloat {
  return (CGFloat (inValue) / 2_286_000.0)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToMilTenth (_ inValue : Int) -> Int {
  return Int ((CGFloat (inValue) / 228.6).rounded ())
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Conversion to Cocoa Unit (72 dots per inch)
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func milsToCocoaUnit (_ inValueInMils : CGFloat) -> CGFloat {
  return inValueInMils * 72.0 / 1000.0
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Conversion to Canari Unit
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func millimeterToCanariUnit (_ inValue : CGFloat) -> Int {
  return Int ((inValue * CGFloat (ONE_MILLIMETER_IN_CANARI_UNIT)).rounded ())
}

//······················································································································

func milsToCanariUnit (_ inValue : Int) -> Int {
  return inValue * ONE_MIL_IN_CANARI_UNIT
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Conversion to millimeter
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToMillimeter (_ inValue : Int) -> CGFloat {
  return CGFloat (inValue) / CGFloat (ONE_MILLIMETER_IN_CANARI_UNIT)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// L'unité de rotation utilisée dans canari est le 1/1000° [cru = Canari Rotation Unit]
// 1_000 cru = 1°
// 90_000 cru = 90°
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariRotationToRadians (_ inCanariRotation : Int) -> CGFloat {
  return CGFloat (inCanariRotation % 360_000) * CGFloat.pi / 180_000.0
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func degreesToCanariRotation (_ inRotationInDegrees : CGFloat) -> Int {
  return Int ((inRotationInDegrees * 1_000.0).rounded ())
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func angleInDegreesBetweenNSPoints (_ inP1 : NSPoint, _ inP2 : NSPoint) -> CGFloat {
  let dx = inP2.x - inP1.x
  let dy = inP2.y - inP1.y
  let distance = sqrt (dx * dx + dy * dy)
  var angle : CGFloat = 0.0
  if distance > 0.0 {
    angle = asin (dy / distance) * 180.0 / CGFloat.pi
    if dx < 0.0 {
      angle = 180.0 - angle
    }
    if angle < 0.0 {
      angle += 360.0
    }
  }
  return angle
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Display string
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func stringFrom (valueInCocoaUnit : CGFloat, displayUnit : Int) -> String {
  let value = CGFloat (cocoaToCanariUnit (valueInCocoaUnit))
  if displayUnit == 90 {
    return "\(Int (value / 90.0)) µm"
  }else if displayUnit == 90_000 {
    return String (format:"%.2f mm", value / 90_000.0)
  }else if displayUnit == 900_000 {
    return String (format:"%.2f cm", value / 900_000.0)
  }else if displayUnit == 2_286_000 {
    return String (format:"%.2f in", value / 2_286_000.0)
  }else{
    return "\(Int (value / 2_286.0)) mil"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
