//
//  ProjectDocument-generate-product-pdf-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func writePDFDrillFile (atPath inPath : String, _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    var pathes = [EBBezierPath] ()
    for (holeDiameter, segmentList) in inProductData.holeDictionary {
      var bp = EBBezierPath ()
      bp.lineWidth = holeDiameter
      bp.lineCapStyle = .round
      for segment in segmentList {
        bp.move (to: segment.0)
        bp.line (to: segment.1)
      }
      pathes.append (bp)
    }
    let shape = EBShape (stroke: pathes, .black)
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: self.rootObject.mPDFBoardBackgroundColor)
    try data.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  func writePDFProductFile (atPath inPath : String,
                            _ inDescriptor : ArtworkFileGenerationParameters,
                            _ inLayerConfiguration : LayerConfiguration,
                            _ inProductData : ProductData) throws {
    let path = inPath + inDescriptor.fileExtension + ".pdf"
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(path.lastPathComponent)…")
    var af = AffineTransform ()
    if inDescriptor.horizontalMirror {
      let t = inProductData.boardBoundBox.origin.x + inProductData.boardBoundBox.size.width / 2.0
      af.translate (x: t, y: 0.0)
      af.scale (x: -1.0, y: 1.0)
      af.translate (x: -t, y: 0.0)
    }
    var strokePathes = [EBBezierPath] ()
    var filledPathes = [EBBezierPath] ()
    if inDescriptor.drawBoardLimits {
      strokePathes.append (apertureDictionary: [inProductData.boardLimitWidth : [inProductData.boardLimitPath]], transformedBy: af)
    }
    if inDescriptor.drawPackageLegendTopSide {
      strokePathes.append (apertureDictionary: inProductData.frontPackageLegend, transformedBy: af)
    }
    if inDescriptor.drawPackageLegendBottomSide {
      strokePathes.append (apertureDictionary: inProductData.backPackageLegend, transformedBy: af)
    }
    if inDescriptor.drawComponentNamesTopSide {
      strokePathes.append (apertureDictionary: inProductData.frontComponentNames, transformedBy: af)
    }
    if inDescriptor.drawComponentNamesBottomSide {
      strokePathes.append (apertureDictionary: inProductData.backComponentNames, transformedBy: af)
    }
    if inDescriptor.drawComponentValuesTopSide {
      strokePathes.append (apertureDictionary: inProductData.frontComponentValues, transformedBy: af)
    }
    if inDescriptor.drawComponentValuesBottomSide {
      strokePathes.append (apertureDictionary: inProductData.backComponentValues, transformedBy: af)
    }
    if inDescriptor.drawTextsLegendTopSide {
      strokePathes.append (apertureDictionary: inProductData.legendFrontTexts, transformedBy: af)
      strokePathes.append (oblongs: inProductData.frontLines, transformedBy: af)
    }
    if inDescriptor.drawTextsLayoutTopSide {
      strokePathes.append (apertureDictionary: inProductData.layoutFrontTexts, transformedBy: af)
    }
    if inDescriptor.drawTextsLayoutBottomSide {
      strokePathes.append (apertureDictionary: inProductData.layoutBackTexts, transformedBy: af)
    }
    if inDescriptor.drawTextsLegendBottomSide {
      strokePathes.append (apertureDictionary: inProductData.legendBackTexts, transformedBy: af)
      strokePathes.append (oblongs: inProductData.backLines, transformedBy: af)
    }
    if inDescriptor.drawVias {
      strokePathes.append (circles: inProductData.viaPads, transformedBy: af)
    }
    if inDescriptor.drawTracksTopSide {
      strokePathes.append (oblongs: inProductData.tracks [.front], transformedBy: af)
    }
    if inDescriptor.drawTracksInner1Layer && (inLayerConfiguration != .twoLayers) {
      strokePathes.append (oblongs: inProductData.tracks [.inner1], transformedBy: af)
    }
    if inDescriptor.drawTracksInner2Layer && (inLayerConfiguration != .twoLayers) {
      strokePathes.append (oblongs: inProductData.tracks [.inner2], transformedBy: af)
    }
    if inDescriptor.drawTracksInner3Layer && (inLayerConfiguration == .sixLayers) {
      strokePathes.append (oblongs: inProductData.tracks [.inner3], transformedBy: af)
    }
    if inDescriptor.drawTracksInner4Layer && (inLayerConfiguration == .sixLayers) {
      strokePathes.append (oblongs: inProductData.tracks [.inner4], transformedBy: af)
    }
    if inDescriptor.drawTracksBottomSide {
      strokePathes.append (oblongs: inProductData.tracks [.back], transformedBy: af)
    }
    if inDescriptor.drawPadsTopSide {
      strokePathes.append (circles: inProductData.circularPads [.frontLayer], transformedBy: af)
      strokePathes.append (oblongs: inProductData.oblongPads [.frontLayer], transformedBy: af)
      filledPathes.append (polygons: inProductData.polygonPads [.frontLayer], transformedBy: af)
    }
    if inDescriptor.drawPadsBottomSide {
      strokePathes.append (circles: inProductData.circularPads [.backLayer], transformedBy: af)
      strokePathes.append (oblongs: inProductData.oblongPads [.backLayer], transformedBy: af)
      filledPathes.append (polygons: inProductData.polygonPads [.backLayer], transformedBy: af)
    }
    if inDescriptor.drawTraversingPads {
      strokePathes.append (circles: inProductData.circularPads [.innerLayer], transformedBy: af)
      strokePathes.append (oblongs: inProductData.oblongPads [.innerLayer], transformedBy: af)
      filledPathes.append (polygons: inProductData.polygonPads [.innerLayer], transformedBy: af)
    }
    var shape = EBShape (stroke: strokePathes, .black)
    shape.add (filled: filledPathes, .black)
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: self.rootObject.mPDFBoardBackgroundColor)
    try data.write (to: URL (fileURLWithPath: path))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor extension Array where Element == EBBezierPath {

  //····················································································································

  mutating func append (apertureDictionary inApertureDictionary : [CGFloat : [EBLinePath]],
                        transformedBy inAffineTransform : AffineTransform) {
    for (aperture, pathArray) in inApertureDictionary {
      var bp = EBBezierPath ()
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.lineWidth = aperture
      for path in pathArray {
        path.appendToBezierPath (&bp, transformedBy: inAffineTransform)
      }
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (oblongs inLines : [ProductOblong]?,
                        transformedBy inAffineTransform : AffineTransform) {
    if let lines = inLines {
      for segment in lines {
        var bp = EBBezierPath ()
        bp.lineWidth = segment.width
        bp.lineCapStyle = .round
        bp.lineJoinStyle = .round
        bp.move (to: inAffineTransform.transform (segment.p1))
        bp.line (to: inAffineTransform.transform (segment.p2))
        self.append (bp)
      }
    }
  }

  //····················································································································

  mutating func append (circles inCircles : [ProductCircle]?,
                        transformedBy inAffineTransform : AffineTransform) {
    if let circles = inCircles {
      for circle in circles {
        var bp = EBBezierPath ()
        bp.lineWidth = circle.diameter
        bp.lineCapStyle = .round
        bp.lineJoinStyle = .round
        bp.move (to: inAffineTransform.transform (circle.center))
        bp.line (to: inAffineTransform.transform (circle.center))
        self.append (bp)
      }
    }
  }

  //····················································································································

  mutating func append (polygons inPolygons : [ProductPolygon]?,
                        transformedBy inAffineTransform : AffineTransform) {
    if let polygons = inPolygons {
      for polygon in polygons {
        var bp = EBBezierPath ()
        bp.move (to: inAffineTransform.transform (polygon.origin))
        for p in polygon.points {
          bp.line (to: inAffineTransform.transform (p))
        }
        bp.close ()
        self.append (bp)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
