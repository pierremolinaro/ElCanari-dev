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

  private var mOblongs = [Self.Oblong] ()
  private var mFilledCircles = [Self.Circle] ()
  private var mFilledPolygons = [Self.Polygon] ()

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

  mutating func addCircle (center inCenter : ProductPoint,
                           diameter inDiameter : ProductLength) {
    let circle = Self.Circle (center: inCenter, diameter: inDiameter)
    self.mFilledCircles.append (circle)
  }

  //································································································

  mutating func addPolygon (origin inOrigin : ProductPoint,
                            points inPoints : [ProductPoint]) {
    let polygon = Self.Polygon (origin: inOrigin, points: inPoints)
    self.mFilledPolygons.append (polygon)
  }

  //································································································
  //  Gerber string
  //································································································

  func gerberString (unit inUnit : GerberRepresentation.Unit) -> String {
    var s = "%FSLAX24Y24*%\n"
    s += "%MOIN*%\n"
  //--- Aperture inventory
    var apertureSet = Set <ProductLength> ()
    for oblong in self.mOblongs {
      apertureSet.insert (oblong.width)
    }
    for circle in self.mFilledCircles {
      apertureSet.insert (circle.diameter)
    }
    let apertureArray = Array (apertureSet).sorted ()
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
   //--- Oblongs
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
    //--- Circles
      for circle in self.mFilledCircles {
        if circle.diameter == aperture {
          s += "X\(gerber (circle.center.x, inUnit))Y\(gerber (circle.center.y, inUnit))D03*\n" // Flash
        }
      }
    //---
      idx += 1
    }
  //--- Fill polygons
    for polygon in self.mFilledPolygons {
      s += "G36*\n" // Start Region
      s += "X\(gerber (polygon.origin.x, inUnit))Y\(gerber (polygon.origin.y, inUnit))D02*\n" // Move
      s += "D01*\n" // Linear interpolation
      for p in polygon.points {
        s += "X\(gerber (p.x, inUnit))Y\(gerber (p.y, inUnit))D01*\n" // Line
      }
      s += "G37*\n" // End Region
    }
  //--- End
    s += "M02*\n"
    return s
  }

  //································································································
  //  Gerber Drill string
  //································································································

  func gerberDrillString (unit inUnit : GerberRepresentation.Unit) -> String {
    var s = "M48\n"
    s += "INCH\n"
  //--- Aperture inventory
    var apertureSet = Set <ProductLength> ()
    for oblong in self.mOblongs {
      apertureSet.insert (oblong.width)
    }
    for circle in self.mFilledCircles {
      apertureSet.insert (circle.diameter)
    }
    let apertureArray = Array (apertureSet).sorted ()
 //--- Write hole diameters
    var idx = 0
    for aperture in apertureArray {
      idx += 1
      s += "T\(idx)C\(String (format: "%.4f", aperture.value (in: .inch)))\n"
    }
 //--- Write holes
    s += "%\n"
    s += "G05\n"
    s += "M72\n"
    idx = 0
    for diameter in apertureArray {
      idx += 1
      s += "T\(idx)\n"
      for circle in self.mFilledCircles {
        if circle.diameter == diameter {
          s += "X\(String(format: "%.4f", circle.center.x.value (in: .inch)))Y\(String(format: "%.4f", circle.center.y.value (in: .inch)))\n"
        }
      }
      for oblong in self.mOblongs {
        if oblong.width == diameter {
          s += "X\(String(format: "%.4f", oblong.p1.x.value (in: .inch)))Y\(String(format: "%.4f", oblong.p1.y.value (in: .inch)))\n"
          s += "G85X\(String(format: "%.4f", oblong.p2.x.value (in: .inch)))Y\(String(format: "%.4f", oblong.p2.y.value (in: .inch)))\n"
        }
      }
    }
 //--- End of file
    s += "T0\n"
    s += "M30\n" // End code
 //---
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
  //   Structs
  //································································································

  struct Oblong {
    let p1 : ProductPoint
    let p2 : ProductPoint
    let width : ProductLength
  }

  //································································································

  struct Circle {
    let center : ProductPoint
    let diameter : ProductLength
  }

  //································································································

  struct Polygon {
    let origin : ProductPoint
    let points : [ProductPoint]
  }

  //································································································

  func gerber (_ inValue : ProductLength, _ inUnit : GerberRepresentation.Unit) -> String {
    return String (Int (inValue.value (in: .mil) * 10.0))
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
