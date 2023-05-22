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

let CANARI_UNITS_PER_µM    = 90
let CANARI_UNITS_PER_MIL   = 2_286
let CANARI_UNITS_PER_PIXEL = 31_750
let CANARI_UNITS_PER_PC    = 381_000
let CANARI_UNITS_PER_MM    = CANARI_UNITS_PER_µM * 1000
let CANARI_UNITS_PER_CM    = CANARI_UNITS_PER_MM * 10
let CANARI_UNITS_PER_M     = CANARI_UNITS_PER_MM * 1000
let CANARI_UNITS_PER_INCH  = CANARI_UNITS_PER_MIL * 1000

let PIXELS_PER_INCH = CANARI_UNITS_PER_INCH / CANARI_UNITS_PER_PIXEL // 72

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Display string
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct DisplayComponents {
  let value : String
  let unit : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func displayComponentsFrom (valueInCanariUnit inValue : Int, unit inUnit : Int) -> DisplayComponents { // Value, Unit
  let value = CGFloat (inValue)
  if inUnit == CANARI_UNITS_PER_µM {
    return DisplayComponents (value: "\(Int (value / CGFloat (CANARI_UNITS_PER_µM)))", unit: "µm")
  }else if inUnit == CANARI_UNITS_PER_MM {
    return DisplayComponents (value: String (format:"%.2f", value / CGFloat (CANARI_UNITS_PER_MM)), unit: "mm")
  }else if inUnit == CANARI_UNITS_PER_CM {
    return DisplayComponents (value: String (format:"%.2f", value / CGFloat (CANARI_UNITS_PER_CM)), unit: "cm")
  }else if inUnit == CANARI_UNITS_PER_M {
    return DisplayComponents (value: String (format:"%.2f", value / CGFloat (CANARI_UNITS_PER_M)), unit: "m")
  }else if inUnit == CANARI_UNITS_PER_INCH {
    return DisplayComponents (value: String (format:"%.2f", value / CGFloat (CANARI_UNITS_PER_INCH)), unit: "in")
  }else if inUnit == CANARI_UNITS_PER_PIXEL {
    return DisplayComponents (value: String (format:"%.2f", value / CGFloat (CANARI_UNITS_PER_PIXEL)), unit: "pt")
  }else if inUnit == CANARI_UNITS_PER_PC {
    return DisplayComponents (value: String (format:"%.2f", value / CGFloat (CANARI_UNITS_PER_PC)), unit: "pc")
  }else{
    return DisplayComponents (value: "\(Int (value / CGFloat (CANARI_UNITS_PER_MIL)))", unit: "mil")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToCocoa (_ inValue : Int) -> CGFloat {
  return CGFloat (inValue) / CGFloat (CANARI_UNITS_PER_PIXEL)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaToCanariUnit (_ inValue : CGFloat) -> Int {
  return Int (inValue *  CGFloat (CANARI_UNITS_PER_PIXEL))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaToInch (_ inValue : CGFloat) -> CGFloat {
  return inValue / CGFloat (PIXELS_PER_INCH)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cocoaToMilTenth (_ inValue : CGFloat) -> Int {
  return Int (inValue * 10_000.0 / CGFloat (PIXELS_PER_INCH))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToInch (_ inValue : Int) -> CGFloat {
  return CGFloat (inValue) / CGFloat (CANARI_UNITS_PER_INCH)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToMilTenth (_ inValue : Int) -> Int { // 1/10 mil = 1 / 10 000 inch
  return Int ((CGFloat (inValue) / (CGFloat (CANARI_UNITS_PER_INCH) / 10.0)).rounded ())
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Conversion to Cocoa Unit (72 dots per inch)
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func milsToCocoaUnit (_ inValueInMils : CGFloat) -> CGFloat {
  return inValueInMils * CGFloat (PIXELS_PER_INCH) / 1000.0
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Conversion to Canari Unit
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func millimeterToCanariUnit (_ inValue : CGFloat) -> Int {
  return Int ((inValue * CGFloat (CANARI_UNITS_PER_MM)).rounded ())
}

//······················································································································

func milsToCanariUnit (fromInt inValue : Int) -> Int {
  return inValue * CANARI_UNITS_PER_MIL
}

//······················································································································

func milsToCanariUnit (fromDouble inValue : Double) -> Int {
  return Int (inValue * Double (CANARI_UNITS_PER_MIL))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func canariUnitToMillimeter (_ inValue : Int) -> CGFloat {
  return CGFloat (inValue) / CGFloat (CANARI_UNITS_PER_MM)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Display
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func valueAndUnitStringFrom (valueInCocoaUnit inValue : CGFloat, displayUnit : Int) -> String {
  return valueAndUnitStringFrom (valueInCanariUnit: cocoaToCanariUnit (inValue), displayUnit: displayUnit)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func valueAndUnitStringFrom (valueInCanariUnit inValue : Int, displayUnit inUnit : Int) -> String {
  let v = displayComponentsFrom (valueInCanariUnit: inValue, unit: inUnit)
  return v.value + " " + v.unit
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func unitStringFrom (displayUnit inUnit : Int) -> String {
  let v = displayComponentsFrom (valueInCanariUnit: 0, unit: inUnit)
  return v.unit
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//func valueStringFrom (valueInCanariUnit inValue : Int, unit inUnit : Int) -> String {
//  let v = displayComponentsFrom (valueInCanariUnit: inValue, unit: inUnit)
//  return v.value
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
