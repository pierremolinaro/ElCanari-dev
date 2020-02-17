//
//  ProjectDocument-generate-product-gerber-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func writeGerberDrillFile (atPath inPath : String, _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    var s = "M48\n"
    s += "INCH\n"
    let keys = inProductData.holeDictionary.keys.sorted ()
 //--- Write hole diameters
    var idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)C\(String(format: "%.4f", cocoaToInch (diameter)))\n"
    }
 //--- Write holes
    s += "%\n"
    s += "G05\n"
    s += "M72\n"
    idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)\n"
      for (p1, p2) in inProductData.holeDictionary [diameter]! {
        if (p1.x == p2.x) && (p1.y == p2.y) { // Circular
          s += "X\(String(format: "%.4f", cocoaToInch (p1.x)))Y\(String(format: "%.4f", cocoaToInch (p1.y)))\n"
        }else{ // oblong
          s += "X\(String(format: "%.4f", cocoaToInch (p1.x)))Y\(String(format: "%.4f", cocoaToInch (p1.y)))"
          s += "G85X\(String(format: "%.4f", cocoaToInch (p2.x)))Y\(String(format: "%.4f", cocoaToInch (p2.y)))\n"
        }
      }
    }
 //--- End of file
    s += "T0\n"
    s += "M30\n" // End code
 //--- Write file
    let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
    try data?.write (to: URL (fileURLWithPath: inPath), options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  internal func writeGerberProductFile (atPath inPath : String, _ inDescriptor : ArtworkFileGenerationParameters, _ inProductData : ProductData) throws {
    let path = inPath + inDescriptor.fileExtension
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(path.lastPathComponent)…")
    var af = AffineTransform ()
    if inDescriptor.horizontalMirror {
      let t = inProductData.boardBoundBox.origin.x + inProductData.boardBoundBox.size.width / 2.0
      af.translate (x: t, y: 0.0)
      af.scale (x: -1.0, y: 1.0)
      af.translate (x: -t, y: 0.0)
    }
    var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
    s += "%MOIN*%\n" // length unit is inch
    var apertureDictionary = [CGFloat : [String]] ()
    var polygons = [ProductPolygon] ()
    if inDescriptor.drawBoardLimits {
      apertureDictionary.append ([inProductData.boardLimitWidth : [inProductData.boardLimitPath]], af)
    }
    if inDescriptor.drawPackageLegendTopSide {
      apertureDictionary.append (inProductData.frontPackageLegend, af)
    }
    if inDescriptor.drawPackageLegendBottomSide {
      apertureDictionary.append (inProductData.backPackageLegend, af)
    }
    if inDescriptor.drawComponentNamesTopSide {
      apertureDictionary.append (inProductData.frontComponentNames, af)
    }
    if inDescriptor.drawComponentNamesBottomSide {
      apertureDictionary.append (inProductData.backComponentNames, af)
    }
    if inDescriptor.drawComponentValuesTopSide {
      apertureDictionary.append (inProductData.frontComponentValues, af)
    }
    if inDescriptor.drawComponentValuesBottomSide {
      apertureDictionary.append (inProductData.backComponentValues, af)
    }
    if inDescriptor.drawTextsLegendTopSide {
      apertureDictionary.append (inProductData.legendFrontTexts, af)
      apertureDictionary.append (oblongs: inProductData.frontLines, af)
    }
    if inDescriptor.drawTextsLayoutTopSide {
      apertureDictionary.append (inProductData.layoutFrontTexts, af)
    }
    if inDescriptor.drawTextsLayoutBottomSide {
      apertureDictionary.append (inProductData.layoutBackTexts, af)
    }
    if inDescriptor.drawTextsLegendBottomSide {
      apertureDictionary.append (inProductData.legendBackTexts, af)
      apertureDictionary.append (oblongs: inProductData.backLines, af)
    }
    if inDescriptor.drawVias {
      apertureDictionary.append (circles: inProductData.viaPads, af)
    }
    if inDescriptor.drawTracksTopSide {
      apertureDictionary.append (roundTracks: inProductData.frontTracks, af)
    }
    if inDescriptor.drawTracksBottomSide {
      apertureDictionary.append (roundTracks: inProductData.backTracks, af)
    }
    if inDescriptor.drawPadsTopSide {
      apertureDictionary.append (circles: inProductData.frontCircularPads, af)
      apertureDictionary.append (oblongs: inProductData.frontOblongPads, af)
      polygons += inProductData.frontPolygonPads.transformed (by: af)
    }
    if inDescriptor.drawPadsBottomSide {
      apertureDictionary.append (circles: inProductData.backCircularPads, af)
      apertureDictionary.append (oblongs: inProductData.backOblongPads, af)
      polygons += inProductData.backPolygonPads.transformed (by: af)
    }
  //--- Write aperture diameters
    let keys = apertureDictionary.keys.sorted ()
    var idx = 10
    for aperture in keys {
      let apertureString = "C,\(String(format: "%.4f", cocoaToInch (aperture)))"
      s += "%ADD\(idx)\(apertureString)*%\n"
      idx += 1
    }
  //--- Write drawings
    idx = 10
    for aperture in keys {
      s += "D\(idx)*\n"
      s += "G01" // Linear interpolation
      for element in apertureDictionary [aperture]! {
        s += element + "*\n"
      }
      idx += 1
    }
  //--- Write polygon fills
    for poly in polygons {
      s += "G36*\n"
      let x0 = cocoaToMilTenth (poly.origin.x)
      let y0 = cocoaToMilTenth (poly.origin.y)
      s.append ("X\(x0)Y\(y0)D02*")
      s += "G01*\n"
      for p in poly.points {
        let x = cocoaToMilTenth (p.x)
        let y = cocoaToMilTenth (p.y)
        s.append ("X\(x)Y\(y)D01*")
      }
      s += "G37*\n"
    }
  //--- Write file
    s += "M02*\n"
    let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
    try data?.write (to: URL (fileURLWithPath: path), options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBLinePath {

  //····················································································································

  func appendGerberCodeTo (_ ioStringArray : inout [String], _ inAffineTransform : AffineTransform) {
    let to = inAffineTransform.transform (self.origin)
    let x = cocoaToMilTenth (to.x)
    let y = cocoaToMilTenth (to.y)
    ioStringArray.append ("X\(x)Y\(y)D02")
    for p in self.lines {
      let tp = inAffineTransform.transform (p)
      let x = cocoaToMilTenth (tp.x)
      let y = cocoaToMilTenth (tp.y)
      ioStringArray.append ("X\(x)Y\(y)D01")
    }
    if self.closed {
      ioStringArray.append ("X\(x)Y\(y)D01")
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


extension Dictionary where Key == CGFloat, Value == [String] {

  //····················································································································

  mutating func append (_ inStringArray : [String], for inAperture : CGFloat) {
   self [inAperture] = (self [inAperture] ?? []) + inStringArray
  }

  //····················································································································

  mutating func append (_ inApertureDict : [CGFloat : [EBLinePath]], _ inAffineTransform : AffineTransform) {
    for (aperture, pathArray) in inApertureDict {
      var drawings = [String] ()
      for path in pathArray {
        path.appendGerberCodeTo (&drawings, inAffineTransform)
      }
      self.append (drawings, for: aperture)
    }
  }

  //····················································································································

  mutating func append (circles inCircles : [ProductCircle], _ inAffineTransform : AffineTransform) {
    for circle in inCircles {
      let tc = inAffineTransform.transform (circle.center)
      let x = cocoaToMilTenth (tc.x)
      let y = cocoaToMilTenth (tc.y)
      let flash = ["X\(x)Y\(y)D03"]
      self.append (flash, for: circle.diameter)
    }
  }

  //····················································································································

  mutating func append (oblongs inLines : [ProductOblong], _ inAffineTransform : AffineTransform) {
    for segment in inLines {
      let p1 = inAffineTransform.transform (segment.p1)
      let x1 = cocoaToMilTenth (p1.x)
      let y1 = cocoaToMilTenth (p1.y)
      let p2 = inAffineTransform.transform (segment.p2)
      let x2 = cocoaToMilTenth (p2.x)
      let y2 = cocoaToMilTenth (p2.y)
      let lines = ["X\(x1)Y\(y1)D02", "X\(x2)Y\(y2)D01"]
      self.append (lines, for: segment.width)
    }
  }

  //····················································································································

  mutating func append (roundTracks inTracks : [ProductOblong], _ inAffineTransform : AffineTransform) {
    for track in inTracks {
      let p1 = inAffineTransform.transform (track.p1)
      let x1 = cocoaToMilTenth (p1.x)
      let y1 = cocoaToMilTenth (p1.y)
      let p2 = inAffineTransform.transform (track.p2)
      let x2 = cocoaToMilTenth (p2.x)
      let y2 = cocoaToMilTenth (p2.y)
      let lines = ["X\(x1)Y\(y1)D02", "X\(x2)Y\(y2)D01"]
      self.append (lines, for: track.width)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == ProductPolygon {

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> [ProductPolygon] {
    var result = [ProductPolygon] ()
    for polygon in self {
      result.append (polygon.transformed (by: inAffineTransform))
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
