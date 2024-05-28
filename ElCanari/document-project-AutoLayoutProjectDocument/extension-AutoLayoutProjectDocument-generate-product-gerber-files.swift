//
//  ProjectDocument-generate-product-gerber-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct ApertureKey : Hashable, Comparable {

  public let value : CGFloat
  public let shape : Shape

  //································································································

  static func < (lhs: ApertureKey, rhs: ApertureKey) -> Bool {
    return (lhs.value < rhs.value)
      || ((lhs.value == rhs.value) && (lhs.shape < rhs.shape))
  }

  //································································································

  init (circular inValue : CGFloat) {
    self.value = inValue
    self.shape = .circular
  }

  //································································································

  init (square inValue : CGFloat) {
    self.value = inValue
    self.shape = .square
  }

  //································································································

  var gerberAperture : String {
    let a = String (format: "%.4f", cocoaToInch (self.value))
    switch self.shape {
    case .circular : return "C,\(a)"
    case .square : return "R,\(a)X\(a)"
    }
  }

  //································································································

  enum Shape : Comparable {
  case circular
  case square
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //································································································

  func writeGerberDrillFile (atPath inPath : String,
                             _ inProductRepresentation : ProductRepresentation,
                             _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    let gerber : GerberRepresentation = inProductRepresentation.gerber (items: [.padHoles])
    let gerberData : Data? = gerber.gerberDrillString (unit: .milTenth).data (using: .ascii, allowLossyConversion: false)
    try gerberData?.write (to: URL (fileURLWithPath: inPath), options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")



//    var s = "M48\n"
//    s += "INCH\n"
//    let keys = inProductData.holeDictionary.keys.sorted ()
// //--- Write hole diameters
//    var idx = 0
//    for diameter in keys {
//      idx += 1
//      s += "T\(idx)C\(String(format: "%.4f", cocoaToInch (diameter)))\n"
//    }
// //--- Write holes
//    s += "%\n"
//    s += "G05\n"
//    s += "M72\n"
//    idx = 0
//    for diameter in keys {
//      idx += 1
//      s += "T\(idx)\n"
//      for (p1, p2) in inProductData.holeDictionary [diameter]! {
//        if (p1.x == p2.x) && (p1.y == p2.y) { // Circular
//          s += "X\(String(format: "%.4f", cocoaToInch (p1.x)))Y\(String(format: "%.4f", cocoaToInch (p1.y)))\n"
//        }else{ // oblong
//          s += "X\(String(format: "%.4f", cocoaToInch (p1.x)))Y\(String(format: "%.4f", cocoaToInch (p1.y)))"
//          s += "G85X\(String(format: "%.4f", cocoaToInch (p2.x)))Y\(String(format: "%.4f", cocoaToInch (p2.y)))\n"
//        }
//      }
//    }
// //--- End of file
//    s += "T0\n"
//    s += "M30\n" // End code
// //--- Write file
//    let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
//    try data?.write (to: URL (fileURLWithPath: inPath), options: .atomic)
//    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //································································································

  func writeGerberProductFile (atPath inPath : String,
                               _ inDescriptor : ArtworkFileGenerationParameters,
                               _ inLayerConfiguration : LayerConfiguration,
                               _ inProductData : ProductData,
                               _ inProductRepresentation : ProductRepresentation) throws {
    let path = inPath + inDescriptor.fileExtension
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(path.lastPathComponent)…")
    var items = ProductLayerSet ()
//    if inDescriptor.horizontalMirror {
//      items.insert (.horizontalMirror)
//    }
    if inDescriptor.drawBoardLimits {
      items.insert (.boardLimits)
    }
    if inDescriptor.drawInternalBoardLimits {
      items.insert (.internalBoardLimits)
    }
    if inDescriptor.drawComponentNamesTopSide {
      items.insert (.componentNamesTopSide)
    }
    if inDescriptor.drawComponentNamesBottomSide {
      items.insert (.componentNamesBottomSide)
    }
    if inDescriptor.drawComponentValuesTopSide {
      items.insert (.componentValuesTopSide)
    }
    if inDescriptor.drawComponentValuesBottomSide {
      items.insert (.componentValuesBottomSide)
    }
    if inDescriptor.drawPackageLegendTopSide {
      items.insert (.packageLegendTopSide)
    }
    if inDescriptor.drawPackageLegendBottomSide {
      items.insert (.packageLegendBottomSide)
    }
//    if inDescriptor.drawPadHolesInPDF {
//      items.insert (.drawPadHolesInPDF)
//    }
    if inDescriptor.drawPadsTopSide {
      items.insert (.padsTopSide)
    }
    if inDescriptor.drawPadsBottomSide {
      items.insert (.padsBottomSide)
    }
    if inDescriptor.drawTextsLayoutTopSide {
      items.insert (.textsLayoutTopSide)
    }
    if inDescriptor.drawTextsLayoutBottomSide {
      items.insert (.textsLayoutBottomSide)
    }
    if inDescriptor.drawTextsLegendBottomSide {
      items.insert (.textsLegendBottomSide)
    }
    if inDescriptor.drawTracksTopSide {
      items.insert (.tracksTopSide)
    }
    if inDescriptor.drawTracksInner1Layer {
      items.insert (.tracksInner1Layer)
    }
    if inDescriptor.drawTracksInner2Layer {
      items.insert (.tracksInner2Layer)
    }
    if inDescriptor.drawTracksInner3Layer {
      items.insert (.tracksInner3Layer)
    }
    if inDescriptor.drawTracksInner4Layer {
      items.insert (.tracksInner4Layer)
    }
    if inDescriptor.drawTracksBottomSide {
      items.insert (.tracksBottomSide)
    }
    if inDescriptor.drawTraversingPads {
      items.insert (.traversingPads)
    }
    if inDescriptor.drawVias {
      items.insert (.vias)
    }

    let gerber : GerberRepresentation = inProductRepresentation.gerber (items: items)
    let gerberData : Data? = gerber.gerberString (unit: .milTenth).data (using: .ascii, allowLossyConversion: false)
    try gerberData?.write (to: URL (fileURLWithPath: path), options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")


//    var af = AffineTransform ()
//    if inDescriptor.horizontalMirror {
//      let t = inProductData.boardBoundBox.origin.x + inProductData.boardBoundBox.size.width / 2.0
//      af.translate (x: t, y: 0.0)
//      af.scale (x: -1.0, y: 1.0)
//      af.translate (x: -t, y: 0.0)
//    }
//    var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
//    s += "%MOIN*%\n" // length unit is inch
//    var apertureDictionary = [ApertureKey : [String]] ()
//    var polygons = [ProductPolygon] ()
//    if inDescriptor.drawBoardLimits {
//      apertureDictionary.appendCircular ([inProductData.boardLimitWidth : [inProductData.boardLimitPath]], af)
//    }
//    if inDescriptor.drawPackageLegendTopSide {
//      apertureDictionary.appendCircular (inProductData.frontPackageLegend, af)
//    }
//    if inDescriptor.drawPackageLegendBottomSide {
//      apertureDictionary.appendCircular (inProductData.backPackageLegend, af)
//    }
//    if inDescriptor.drawComponentNamesTopSide {
//      apertureDictionary.appendCircular (inProductData.frontComponentNames, af)
//    }
//    if inDescriptor.drawComponentNamesBottomSide {
//      apertureDictionary.appendCircular (inProductData.backComponentNames, af)
//    }
//    if inDescriptor.drawComponentValuesTopSide {
//      apertureDictionary.appendCircular (inProductData.frontComponentValues, af)
//    }
//    if inDescriptor.drawComponentValuesBottomSide {
//      apertureDictionary.appendCircular (inProductData.backComponentValues, af)
//    }
//    if inDescriptor.drawTextsLegendTopSide {
//      apertureDictionary.appendCircular (inProductData.legendFrontTexts, af)
//      apertureDictionary.append (oblongs: inProductData.frontLines, af)
//      polygons += inProductData.legendFrontQRCodes.polygons.transformed (by: af)
//      polygons += inProductData.legendFrontImages.polygons.transformed (by: af)
//    }
//    if inDescriptor.drawTextsLayoutTopSide {
//      apertureDictionary.appendCircular (inProductData.layoutFrontTexts, af)
//    }
//    if inDescriptor.drawTextsLayoutBottomSide {
//      apertureDictionary.appendCircular (inProductData.layoutBackTexts, af)
//    }
//    if inDescriptor.drawTextsLegendBottomSide {
//      apertureDictionary.appendCircular (inProductData.legendBackTexts, af)
//      apertureDictionary.append (oblongs: inProductData.backLines, af)
//      polygons += inProductData.legendBackQRCodes.polygons.transformed (by: af)
//      polygons += inProductData.legendBackImages.polygons.transformed (by: af)
//    }
//    if inDescriptor.drawVias {
//      apertureDictionary.append (productCircles: inProductData.viaPads, af)
//    }
//    if inDescriptor.drawTracksTopSide {
//      apertureDictionary.append (oblongs: inProductData.tracks [.front], af)
//    }
//    if inDescriptor.drawTracksInner1Layer && (inLayerConfiguration != .twoLayers) {
//      apertureDictionary.append (oblongs: inProductData.tracks [.inner1], af)
//    }
//    if inDescriptor.drawTracksInner2Layer && (inLayerConfiguration != .twoLayers) {
//      apertureDictionary.append (oblongs: inProductData.tracks [.inner2], af)
//    }
//    if inDescriptor.drawTracksInner3Layer && (inLayerConfiguration == .sixLayers) {
//      apertureDictionary.append (oblongs: inProductData.tracks [.inner3], af)
//    }
//    if inDescriptor.drawTracksInner4Layer && (inLayerConfiguration == .sixLayers) {
//      apertureDictionary.append (oblongs: inProductData.tracks [.inner4], af)
//    }
//    if inDescriptor.drawTracksBottomSide {
//      apertureDictionary.append (oblongs: inProductData.tracks [.back], af)
//    }
//    if inDescriptor.drawPadsTopSide {
//      apertureDictionary.append (oblongs: inProductData.frontTracksWithNoSilkScreen, af)
//      apertureDictionary.append (productCircles: inProductData.circularPads [.frontLayer], af)
//      apertureDictionary.append (oblongs: inProductData.oblongPads [.frontLayer], af)
//      if let pp = inProductData.polygonPads [.frontLayer] {
//        polygons += pp.transformed (by: af)
//      }
//    }
//    if inDescriptor.drawPadsBottomSide {
//      apertureDictionary.append (oblongs: inProductData.backTracksWithNoSilkScreen, af)
//      apertureDictionary.append (productCircles: inProductData.circularPads [.backLayer], af)
//      apertureDictionary.append (oblongs: inProductData.oblongPads [.backLayer], af)
//      if let pp = inProductData.polygonPads [.backLayer] {
//        polygons += pp.transformed (by: af)
//      }
//    }
//    if inDescriptor.drawTraversingPads {
//      apertureDictionary.append (productCircles: inProductData.circularPads [.innerLayer], af)
//      apertureDictionary.append (oblongs: inProductData.oblongPads [.innerLayer], af)
//      if let pp = inProductData.polygonPads [.innerLayer] {
//        polygons += pp.transformed (by: af)
//      }
//    }
//  //--- Write aperture diameters
//    let keys = apertureDictionary.keys.sorted ()
//    var idx = 10
//    for aperture in keys {
//      let apertureString = aperture.gerberAperture
//      s += "%ADD\(idx)\(apertureString)*%\n"
//      idx += 1
//    }
//  //--- Write drawings
//    idx = 10
//    for aperture in keys {
//      s += "D\(idx)*\n"
//      s += "G01" // Linear interpolation
//      for element in apertureDictionary [aperture]! {
//        s += element + "*\n"
//      }
//      idx += 1
//    }
//  //--- Write polygon fills
//    for poly in polygons {
//      s += "G36*\n"
//      let x0 = cocoaToMilTenth (poly.origin.x)
//      let y0 = cocoaToMilTenth (poly.origin.y)
//      s.append ("X\(x0)Y\(y0)D02*")
//      s += "G01*\n"
//      for p in poly.points {
//        let x = cocoaToMilTenth (p.x)
//        let y = cocoaToMilTenth (p.y)
//        s.append ("X\(x)Y\(y)D01*")
//      }
//      s += "G37*\n"
//    }
//  //--- Write file
//    s += "M02*\n"
//    let data : Data? = s.data (using: .ascii, allowLossyConversion: false)
//    try data?.write (to: URL (fileURLWithPath: path), options: .atomic)
//    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension EBLinePath {

  //································································································

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

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————


extension Dictionary where Key == ApertureKey, Value == [String] {

  //································································································

  mutating func append (_ inStringArray : [String], for inAperture : ApertureKey) {
   self [inAperture] = self [inAperture, default: []] + inStringArray
  }

  //································································································

  mutating func appendCircular (_ inApertureDict : [CGFloat : [EBLinePath]], _ inAffineTransform : AffineTransform) {
    for (aperture, pathArray) in inApertureDict {
      var drawings = [String] ()
      for path in pathArray {
        path.appendGerberCodeTo (&drawings, inAffineTransform)
      }
      self.append (drawings, for: ApertureKey (circular: aperture))
    }
  }

  //································································································

  mutating func append (productCircles inCircles : [ProductCircle]?,
                        _ inAffineTransform : AffineTransform) {
    if let circles = inCircles {
      for circle in circles {
        let tc = inAffineTransform.transform (circle.center)
        let x = cocoaToMilTenth (tc.x)
        let y = cocoaToMilTenth (tc.y)
        let flash = ["X\(x)Y\(y)D03"]
        self.append (flash, for: ApertureKey (circular: circle.diameter))
      }
    }
  }

  //································································································

  mutating func append (oblongs inLines : [ProductLine]?, _ inAffineTransform : AffineTransform) {
    if let lines = inLines {
      for segment in lines {
        let p1 = inAffineTransform.transform (segment.p1)
        let x1 = cocoaToMilTenth (p1.x)
        let y1 = cocoaToMilTenth (p1.y)
        let p2 = inAffineTransform.transform (segment.p2)
        let x2 = cocoaToMilTenth (p2.x)
        let y2 = cocoaToMilTenth (p2.y)
        let lines = ["X\(x1)Y\(y1)D02", "X\(x2)Y\(y2)D01"]
        switch segment.endStyle {
        case .round :
          self.append (lines, for: ApertureKey (circular: segment.width))
        case .square :
          self.append (lines, for: ApertureKey (square: segment.width))
        }
      }
    }
  }

  //································································································

//  mutating func append (tracks inTracks : [ProductLine]?, _ inAffineTransform : AffineTransform) {
//    if let tracks = inTracks {
//      for track in tracks {
//        let p1 = inAffineTransform.transform (track.p1)
//        let x1 = cocoaToMilTenth (p1.x)
//        let y1 = cocoaToMilTenth (p1.y)
//        let p2 = inAffineTransform.transform (track.p2)
//        let x2 = cocoaToMilTenth (p2.x)
//        let y2 = cocoaToMilTenth (p2.y)
//        let lines = ["X\(x1)Y\(y1)D02", "X\(x2)Y\(y2)D01"]
//        self.append (lines, for: track.width)
//      }
//    }
//  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == ProductPolygon {

  //································································································

  func transformed (by inAffineTransform : AffineTransform) -> [ProductPolygon] {
    var result = [ProductPolygon] ()
    for polygon in self {
      result.append (polygon.transformed (by: inAffineTransform))
    }
    return result
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
