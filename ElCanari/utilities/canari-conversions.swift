//
//  canari-unit-conversion.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/06/2018.
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
// 1 px = 1/72 pouce = 31 750 cu
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let ONE_MILLIMETER_IN_CANARI_UNIT = 90_000
let ONE_INCH_IN_CANARI_UNIT = 2_286_000
let ONE_MIL_IN_CANARI_UNIT = 2_286
let ONE_PIXEL_IN_CANARI_UNIT = 31_750

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToCocoa (_ inValue : Int) -> CGFloat {
  return CGFloat (inValue) / 31_750.0
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaToCanariUnit (_ inValue : CGFloat) -> Int {
  return Int (inValue *  31_750.0)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaToInch (_ inValue : CGFloat) -> CGFloat {
  return inValue / 72.0
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaToMilTenth (_ inValue : CGFloat) -> Int {
  return Int (inValue * 10_000.0 / 72.0)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToInch (_ inValue : Int) -> CGFloat {
  return CGFloat (inValue) / 2_286_000.0
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToMilTenth (_ inValue : Int) -> Int { // 1/10 mil = 1 / 10 000 inch
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

func milsToCanariUnit (fromInt inValue : Int) -> Int {
  return inValue * ONE_MIL_IN_CANARI_UNIT
}

//······················································································································

func milsToCanariUnit (fromDouble inValue : Double) -> Int {
  return Int (inValue * Double (ONE_MIL_IN_CANARI_UNIT))
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
//  Value aligned on grid
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Int {

  //····················································································································

  func value (alignedOnGrid inGrid: Int) -> Int {
    return ((self + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  mutating func align (onGrid inGrid: Int) {
    self = self.value (alignedOnGrid: inGrid)
  }

  //····················································································································

  func isAlignedOnGrid (_ inGrid: Int) -> Bool {
    return self == self.value (alignedOnGrid: inGrid)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Display string
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func stringFrom (valueInCocoaUnit : CGFloat, displayUnit : Int) -> String {
  return stringFrom (valueInCanariUnit: cocoaToCanariUnit (valueInCocoaUnit), displayUnit: displayUnit)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func stringFrom (valueInCanariUnit : Int, unit inUnit : Int) -> String {
  let value = CGFloat (valueInCanariUnit)
  if inUnit == 90 {
    return "\(Int (value / 90.0))"
  }else if inUnit == 90_000 {
    return String (format:"%.2f", value / 90_000.0)
  }else if inUnit == 900_000 {
    return String (format:"%.2f", value / 900_000.0)
  }else if inUnit == 2_286_000 {
    return String (format:"%.2f", value / 2_286_000.0)
  }else if inUnit == 31_750 {
    return String (format:"%.2f", value / 31_750.0)
  }else if inUnit == 381_000 {
    return String (format:"%.2f", value / 381_000.0)
  }else{
    return "\(Int (value / 2_286.0))"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func stringFrom (valueInCanariUnit : Int, displayUnit inUnit : Int) -> String {
  let value = CGFloat (valueInCanariUnit)
  if inUnit == 90 {
    return "\(Int (value / 90.0)) µm"
  }else if inUnit == 90_000 {
    return String (format:"%.2f mm", value / 90_000.0)
  }else if inUnit == 900_000 {
    return String (format:"%.2f cm", value / 900_000.0)
  }else if inUnit == 90_000_000 {
    return String (format:"%.4f m", value / 90_000_000.0)
  }else if inUnit == 2_286_000 {
    return String (format:"%.2f in", value / 2_286_000.0)
  }else if inUnit == 31_750 {
    return String (format:"%.2f pt", value / 31_750.0)
  }else if inUnit == 381_000 {
    return String (format:"%.2f pc", value / 381_000.0)
  }else{
    return "\(Int (value / 2_286.0)) mil"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func stringFrom (displayUnit inUnit : Int) -> String {
  if inUnit == 90 {
    return "µm"
  }else if inUnit == 90_000 {
    return "mm"
  }else if inUnit == 900_000 {
    return "cm"
  }else if inUnit == 90_000_000 {
    return "m"
  }else if inUnit == 2_286_000 {
    return "in"
  }else if inUnit == 31_750 {
    return "pt"
  }else if inUnit == 381_000 {
    return "pc"
  }else{
    return "mil"
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
