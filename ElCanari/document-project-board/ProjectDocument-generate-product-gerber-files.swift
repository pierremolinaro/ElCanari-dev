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
    var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
    s += "%MOIN*%\n" // length unit is inch
    var apertureDictionary = [CGFloat : [String]] ()
    var polygons = [[String]] ()
    if inDescriptor.drawBoardLimits {
      apertureDictionary.append ([inProductData.boardLimitWidth : [inProductData.boardLimitPath]])
    }
    if inDescriptor.drawPackageLegendTopSide {
      apertureDictionary.append (inProductData.frontPackageLegend)
    }
    if inDescriptor.drawPackageLegendBottomSide {
      apertureDictionary.append (inProductData.backPackageLegend)
    }
    if inDescriptor.drawComponentNamesTopSide {
      apertureDictionary.append (inProductData.frontComponentNames)
    }
    if inDescriptor.drawComponentNamesBottomSide {
      apertureDictionary.append (inProductData.backComponentNames)
    }
    if inDescriptor.drawComponentValuesTopSide {
      apertureDictionary.append (inProductData.frontComponentValues)
    }
    if inDescriptor.drawComponentValuesBottomSide {
      apertureDictionary.append (inProductData.backComponentValues)
    }
    if inDescriptor.drawTextsLegendTopSide {
      apertureDictionary.append (inProductData.legendFrontTexts)
      apertureDictionary.append (lines: inProductData.frontLines)
    }
    if inDescriptor.drawTextsLayoutTopSide {
      apertureDictionary.append (inProductData.layoutFrontTexts)
    }
    if inDescriptor.drawTextsLayoutBottomSide {
      apertureDictionary.append (inProductData.layoutBackTexts)
    }
    if inDescriptor.drawTextsLegendBottomSide {
      apertureDictionary.append (inProductData.legendBackTexts)
      apertureDictionary.append (lines: inProductData.backLines)
    }
    if inDescriptor.drawVias {
      for (location, diameter) in inProductData.viaPads {
        apertureDictionary.appendFlash (at: location, for: diameter)
      }
    }
    if inDescriptor.drawTracksTopSide {
      apertureDictionary.append (lines: inProductData.frontTracks)
    }
    if inDescriptor.drawTracksBottomSide {
      apertureDictionary.append (lines: inProductData.backTracks)
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
      for str in poly {
        s += str + "*\n"
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

  func appendGerberCodeTo (_ ioStringArray : inout [String]) {
    let x = cocoaToMilTenth (self.origin.x)
    let y = cocoaToMilTenth (self.origin.y)
    ioStringArray.append ("X\(x)Y\(y)D02")
    for p in self.lines {
      let x = cocoaToMilTenth (p.x)
      let y = cocoaToMilTenth (p.y)
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

  mutating func append (_ inApertureDict : [CGFloat : [EBLinePath]]) {
    for (aperture, pathArray) in inApertureDict {
      var drawings = [String] ()
      for path in pathArray {
        path.appendGerberCodeTo (&drawings)
      }
      self.append (drawings, for: aperture)
    }
  }

  //····················································································································

  mutating func appendFlash (at inLocation : NSPoint, for inAperture : CGFloat) {
    let x = cocoaToMilTenth (inLocation.x)
    let y = cocoaToMilTenth (inLocation.y)
    let flash = "X\(x)Y\(y)D03"
    self.append ([flash], for: inAperture)
  }

  //····················································································································

  mutating func append (lines inLines : [ProductLine]) {
    for segment in inLines {
      let x1 = cocoaToMilTenth (segment.p1.x)
      let y1 = cocoaToMilTenth (segment.p1.y)
      let x2 = cocoaToMilTenth (segment.p2.x)
      let y2 = cocoaToMilTenth (segment.p2.y)
      let line = ["X\(x1)Y\(y1)D02", "X\(x2)Y\(y2)D01"]
      self.append (line, for: segment.width)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
