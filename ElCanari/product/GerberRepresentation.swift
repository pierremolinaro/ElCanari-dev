//
//  GerberRepresentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

fileprivate let IMPERIAL_DIGIT_COUNT = 4
fileprivate let METRIC_DIGIT_COUNT = 6

//--------------------------------------------------------------------------------------------------

struct GerberRepresentation {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mRoundSegments = [Self.Oblong] ()
  private var mFilledCircles = [Self.Circle] ()
  private var mFilledPolygons = [Self.Polygon] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Populate
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func addRoundSegment (p1 inP1 : CanariPoint,
                                 p2 inP2 : CanariPoint,
                                 width inWidth : CanariLength) {
    if inP1 == inP2 {
      let circle = Self.Circle (center: inP1, diameter: inWidth)
      self.mFilledCircles.append (circle)
    }else{
      let oblong = Self.Oblong (p1: inP1, p2: inP2, width: inWidth)
      self.mRoundSegments.append (oblong)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func addCircle (center inCenter : CanariPoint,
                           diameter inDiameter : CanariLength) {
    let circle = Self.Circle (center: inCenter, diameter: inDiameter)
    self.mFilledCircles.append (circle)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func addPolygon (origin inOrigin : CanariPoint,
                            points inPoints : [CanariPoint]) {
    let polygon = Self.Polygon (origin: inOrigin, points: inPoints)
    self.mFilledPolygons.append (polygon)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Gerber string
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func gerberString (unit inUnit : GerberUnit) -> String {
  //--- Aperture inventory
    var apertureSet = Set <CanariLength> ()
    for oblong in self.mRoundSegments {
      apertureSet.insert (oblong.width)
    }
    for circle in self.mFilledCircles {
      apertureSet.insert (circle.diameter)
    }
    let apertureArray = Array (apertureSet).sorted ()
  //--- Write header
    var s : String
    switch inUnit {
    case .imperial :
      s = "%FSLAX4\(IMPERIAL_DIGIT_COUNT)Y4\(IMPERIAL_DIGIT_COUNT)*%\n"
      s += "%MOIN*%\n" // Unit is inch
    case .metric :
      s = "%FSLAX2\(METRIC_DIGIT_COUNT)Y2\(METRIC_DIGIT_COUNT)*%\n"
      s += "%MOMM*%\n" // Unit is mm
    }
//    s += "%LPD*%\n" // §
  //--- Write aperture declarations
    var idx = 10
    for aperture in apertureArray {
      let apertureString = "C," + aperture.apertureLengthString (inUnit)
      s += "%ADD\(idx)\(apertureString)*%\n"
      idx += 1
    }
  //--- Write aperture lines
    idx = 10
    for aperture in apertureArray {
      s += "D\(idx)*\n"
   //--- Oblongs
      s += "G01*\n" // Linear interpolation
      var currentPoint : CanariPoint? = nil
      for oblong in self.mRoundSegments {
        if oblong.width == aperture {
          if let p = currentPoint, p == oblong.p1 {
          }else{
            s += oblong.p1.gerberPointString (inUnit) + "D02*\n" // Move to p1
          }
          if oblong.p1 == oblong.p2 {
            s += oblong.p1.gerberPointString (inUnit) + "D03*\n" // Flash
          }else{
            s += oblong.p2.gerberPointString (inUnit) + "D01*\n" // Line to p2
          }
          currentPoint = oblong.p2
        }
      }
    //--- Circles
      for circle in self.mFilledCircles {
        if circle.diameter == aperture {
          s += circle.center.gerberPointString (inUnit) + "D03*\n" // Flash
        }
      }
    //---
      idx += 1
    }
  //--- Fill polygons
    for polygon in self.mFilledPolygons {
      s += "G36*\n" // Start Region
      s += polygon.origin.gerberPointString (inUnit) + "D02*\n" // Move
      for p in polygon.points {
        s += p.gerberPointString (inUnit) + "D01*\n" // Line
      }
      s += polygon.origin.gerberPointString (inUnit) + "D01*\n" // Line, for closing path
      s += "G37*\n" // End Region
    }
  //--- End
    s += "M02*\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Structs
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct Oblong {
    let p1 : CanariPoint
    let p2 : CanariPoint
    let width : CanariLength
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct Circle {
    let center : CanariPoint
    let diameter : CanariLength
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct Polygon {
    let origin : CanariPoint
    let points : [CanariPoint]
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate extension CanariLength {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func gerberLengthString (_ inUnit : GerberUnit) -> String {
    switch inUnit {
    case .imperial :
      return String (Int (self.inchValue * pow (10.0, Double (IMPERIAL_DIGIT_COUNT))))
    case .metric :
      return String (Int (self.mmValue * pow (10.0, Double (METRIC_DIGIT_COUNT))))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func apertureLengthString (_ inUnit : GerberUnit) -> String {
    switch inUnit {
    case .imperial :
      return self.inchValue.strf (IMPERIAL_DIGIT_COUNT)
//      return unsafe String (format: "%.4f", self.value (in: .inch))
    case .metric :
      return self.mmValue.strf (METRIC_DIGIT_COUNT)
//      return unsafe String (format: "%.6f", self.value (in: .mm))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate extension CanariPoint {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func gerberPointString (_ inUnit : GerberUnit) -> String {
    return "X\(self.x.gerberLengthString (inUnit))Y\(self.y.gerberLengthString (inUnit))"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
