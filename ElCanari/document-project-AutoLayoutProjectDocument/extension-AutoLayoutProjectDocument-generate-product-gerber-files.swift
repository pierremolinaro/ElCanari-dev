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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func < (lhs: ApertureKey, rhs: ApertureKey) -> Bool {
    return (lhs.value < rhs.value)
      || ((lhs.value == rhs.value) && (lhs.shape < rhs.shape))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (circular inValue : CGFloat) {
    self.value = inValue
    self.shape = .circular
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (square inValue : CGFloat) {
    self.value = inValue
    self.shape = .square
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var gerberAperture : String {
    let a = String (format: "%.4f", cocoaToInch (self.value))
    switch self.shape {
    case .circular : return "C,\(a)"
    case .square : return "R,\(a)X\(a)"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum Shape : Comparable {
  case circular
  case square
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func writeGerberDrillFile (atURL inURL : URL,
                             _ inProduct : ProductRepresentation,
                             _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(inURL.lastPathComponent)…")
    let drillString = inProduct.excellonDrillString (unit: self.rootObject.mGerberProductUnit)
    let drillData : Data? = drillString.data (using: .ascii, allowLossyConversion: false)
    try drillData?.write (to: inURL, options: .atomic)
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func writeGerberProductFile (atURL inURL : URL,
                               _ inDescriptor : ArtworkFileGenerationParameters,
                               _ inLayerConfiguration : LayerConfiguration,
                               _ inProductData : ProductData,
                               _ inProductRepresentation : ProductRepresentation) throws {
    let url = inURL.appendingPathExtension (inDescriptor.fileExtension)
    self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(url.lastPathComponent)…")
//    if self.rootObject.mUsesNewProductGeneration {
    let mirror : ProductHorizontalMirror = inDescriptor.horizontalMirror
      ? .mirror (boardWidth: self.rootObject.boardBoundBox!.size.width)
      : .noMirror
    let gerber : GerberRepresentation = inProductRepresentation.gerber (
      items: inDescriptor.layerItems,
      mirror: mirror
    )
    let gerberString = gerber.gerberString (unit: self.rootObject.mGerberProductUnit)
    let gerberData : Data? = gerberString.data (using: .ascii, allowLossyConversion: false)
    try gerberData?.write (to: url, options: .atomic)
//    }else{
//      var af = AffineTransform ()
//      if inDescriptor.horizontalMirror {
//        let t = inProductData.boardBoundBox.origin.x + inProductData.boardBoundBox.size.width / 2.0
//        af.translate (x: t, y: 0.0)
//        af.scale (x: -1.0, y: 1.0)
//        af.translate (x: -t, y: 0.0)
//      }
//      var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
//      s += "%MOIN*%\n" // length unit is inch
//      var apertureDictionary = [ApertureKey : [String]] ()
//      var polygons = [ProductPolygon] ()
//      if inDescriptor.drawBoardLimits {
//        apertureDictionary.appendCircular ([inProductData.boardLimitWidth : [inProductData.boardLimitPath]], af)
//      }
//      if inDescriptor.drawPackageLegendTopSide {
//        apertureDictionary.appendCircular (inProductData.frontPackageLegend, af)
//      }
//      if inDescriptor.drawPackageLegendBottomSide {
//        apertureDictionary.appendCircular (inProductData.backPackageLegend, af)
//      }
//      if inDescriptor.drawComponentNamesTopSide {
//        apertureDictionary.appendCircular (inProductData.frontComponentNames, af)
//      }
//      if inDescriptor.drawComponentNamesBottomSide {
//        apertureDictionary.appendCircular (inProductData.backComponentNames, af)
//      }
//      if inDescriptor.drawComponentValuesTopSide {
//        apertureDictionary.appendCircular (inProductData.frontComponentValues, af)
//      }
//      if inDescriptor.drawComponentValuesBottomSide {
//        apertureDictionary.appendCircular (inProductData.backComponentValues, af)
//      }
//      if inDescriptor.drawTextsLegendTopSide {
//        apertureDictionary.appendCircular (inProductData.legendFrontTexts, af)
//        apertureDictionary.append (oblongs: inProductData.frontLines, af)
//        polygons += inProductData.legendFrontQRCodes.polygons.transformed (by: af)
//        polygons += inProductData.legendFrontImages.polygons.transformed (by: af)
//      }
//      if inDescriptor.drawTextsLayoutTopSide {
//        apertureDictionary.appendCircular (inProductData.layoutFrontTexts, af)
//      }
//      if inDescriptor.drawTextsLayoutBottomSide {
//        apertureDictionary.appendCircular (inProductData.layoutBackTexts, af)
//      }
//      if inDescriptor.drawTextsLegendBottomSide {
//        apertureDictionary.appendCircular (inProductData.legendBackTexts, af)
//        apertureDictionary.append (oblongs: inProductData.backLines, af)
//        polygons += inProductData.legendBackQRCodes.polygons.transformed (by: af)
//        polygons += inProductData.legendBackImages.polygons.transformed (by: af)
//      }
//      if inDescriptor.drawVias {
//        apertureDictionary.append (productCircles: inProductData.viaPads, af)
//      }
//      if inDescriptor.drawTracksTopSide {
//        apertureDictionary.append (oblongs: inProductData.tracks [.front], af)
//      }
//      if inDescriptor.drawTracksInner1Layer && (inLayerConfiguration != .twoLayers) {
//        apertureDictionary.append (oblongs: inProductData.tracks [.inner1], af)
//      }
//      if inDescriptor.drawTracksInner2Layer && (inLayerConfiguration != .twoLayers) {
//        apertureDictionary.append (oblongs: inProductData.tracks [.inner2], af)
//      }
//      if inDescriptor.drawTracksInner3Layer && (inLayerConfiguration == .sixLayers) {
//        apertureDictionary.append (oblongs: inProductData.tracks [.inner3], af)
//      }
//      if inDescriptor.drawTracksInner4Layer && (inLayerConfiguration == .sixLayers) {
//        apertureDictionary.append (oblongs: inProductData.tracks [.inner4], af)
//      }
//      if inDescriptor.drawTracksBottomSide {
//        apertureDictionary.append (oblongs: inProductData.tracks [.back], af)
//      }
//      if inDescriptor.drawPadsTopSide {
//        apertureDictionary.append (oblongs: inProductData.frontTracksWithNoSilkScreen, af)
//        apertureDictionary.append (productCircles: inProductData.circularPads [.frontLayer], af)
//        apertureDictionary.append (oblongs: inProductData.oblongPads [.frontLayer], af)
//        if let pp = inProductData.polygonPads [.frontLayer] {
//          polygons += pp.transformed (by: af)
//        }
//      }
//      if inDescriptor.drawPadsBottomSide {
//        apertureDictionary.append (oblongs: inProductData.backTracksWithNoSilkScreen, af)
//        apertureDictionary.append (productCircles: inProductData.circularPads [.backLayer], af)
//        apertureDictionary.append (oblongs: inProductData.oblongPads [.backLayer], af)
//        if let pp = inProductData.polygonPads [.backLayer] {
//          polygons += pp.transformed (by: af)
//        }
//      }
//      if inDescriptor.drawTraversingPads {
//        apertureDictionary.append (productCircles: inProductData.circularPads [.innerLayer], af)
//        apertureDictionary.append (oblongs: inProductData.oblongPads [.innerLayer], af)
//        if let pp = inProductData.polygonPads [.innerLayer] {
//          polygons += pp.transformed (by: af)
//        }
//      }
//    //--- Write aperture diameters
//      let keys = apertureDictionary.keys.sorted ()
//      var idx = 10
//      for aperture in keys {
//        let apertureString = aperture.gerberAperture
//        s += "%ADD\(idx)\(apertureString)*%\n"
//        idx += 1
//      }
//    //--- Write drawings
//      idx = 10
//      for aperture in keys {
//        s += "D\(idx)*\n"
//        s += "G01" // Linear interpolation
//        for element in apertureDictionary [aperture]! {
//          s += element + "*\n"
//        }
//        idx += 1
//      }
//    //--- Write polygon fills
//      for poly in polygons {
//        s += "G36*\n"
//        let x0 = cocoaToMilTenth (poly.origin.x)
//        let y0 = cocoaToMilTenth (poly.origin.y)
//        s.append ("X\(x0)Y\(y0)D02*")
//        s += "G01*\n"
//        for p in poly.points {
//          let x = cocoaToMilTenth (p.x)
//          let y = cocoaToMilTenth (p.y)
//          s.append ("X\(x)Y\(y)D01*")
//        }
//        s += "G37*\n"
//      }
//    //--- Write file
//      s += "M02*\n"
//      let data : Data? = s.data (using: .ascii, allowLossyConversion: false)
//      try data?.write (to: url, options: .atomic)
//    }
    self.mProductFileGenerationLogTextView?.appendSuccess (" Ok\n")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension EBLinePath {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————


extension Dictionary where Key == ApertureKey, Value == [String] {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (_ inStringArray : [String], for inAperture : ApertureKey) {
   self [inAperture] = self [inAperture, default: []] + inStringArray
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendCircular (_ inApertureDict : [CGFloat : [EBLinePath]], _ inAffineTransform : AffineTransform) {
    for (aperture, pathArray) in inApertureDict {
      var drawings = [String] ()
      for path in pathArray {
        path.appendGerberCodeTo (&drawings, inAffineTransform)
      }
      self.append (drawings, for: ApertureKey (circular: aperture))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == ProductPolygon {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func transformed (by inAffineTransform : AffineTransform) -> [ProductPolygon] {
    var result = [ProductPolygon] ()
    for polygon in self {
      result.append (polygon.transformed (by: inAffineTransform))
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
