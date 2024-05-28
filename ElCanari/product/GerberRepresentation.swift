//
//  GerberRepresentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct GerberRepresentation {

  //································································································
  //  Properties
  //································································································

  private var mOblongs = [Oblong] ()

  //································································································
  //  Init
  //································································································

  init () {
  }

  //································································································
  //  Populate
  //································································································

  mutating func addOblong (p1 inP1 : ProductPoint,
                           p2 inP2 : ProductPoint,
                           width inWidth : ProductLength) {
    if inP1 != inP2 {
      let oblong = Oblong (p1: inP1, p2: inP2, width: inWidth)
      self.mOblongs.append (oblong)
    }
  }

  //································································································
  //  Gerber string
  //································································································

  func gerberString (unit inUnit : GerberRepresentation.Unit) -> String {
    var s = "%FSLAX24Y24*%\n"
    s += "%MOIN*%\n"
  //--- Aperture inventory
    var apertureDictionary = Set <ProductLength> ()
    for oblong in self.mOblongs {
      apertureDictionary.insert (oblong.width)
    }
    let apertureArray = Array (apertureDictionary).sorted ()
  //--- Write aperture declarations
    var idx = 10
    for aperture in apertureArray {
      let apertureString = "C,\(String (format: "%.4f", aperture.value (in: .inch)))"
      s += "%ADD\(idx)\(apertureString)*%\n"
      idx += 1
    }
  //--- Write aperture lines
    idx = 10
    for aperture in apertureArray {
      s += "D\(idx)*\n"
      s += "G01*\n" // Linear interpolation
      var currentPoint : ProductPoint? = nil
      for oblong in self.mOblongs {
        if oblong.width == aperture {
          if let p = currentPoint, p == oblong.p1 {
          }else{
            s += "X\(gerber (oblong.p1.x, inUnit))Y\(gerber (oblong.p1.y, inUnit))D02*\n" // Move to p1
          }
          s += "X\(gerber (oblong.p2.x, inUnit))Y\(gerber (oblong.p2.y, inUnit))D01*\n" // Line to p2
          currentPoint = oblong.p2
        }
      }
      idx += 1
    }
  //--- End
    s += "M02*\n"
    return s
  }

  //································································································
  //   Enumerations
  //································································································

  enum Unit {
    case milTenth
    case mm
  }

  //································································································
  //   Struct
  //································································································

  struct Oblong {
    let p1 : ProductPoint
    let p2 : ProductPoint
    let width : ProductLength
  }

  //································································································

  func gerber (_ inValue : ProductLength, _ inUnit : GerberRepresentation.Unit) -> String {
    return String (Int (inValue.value (in: .mil) * 10.0))
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
