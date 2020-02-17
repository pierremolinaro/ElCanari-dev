//
//  ProjectDocument-generate-product-pdf-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func writePDFDrillFile (atPath inPath : String, _ inProductData : ProductData) throws {
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
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: .lightGray)
    try data.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  internal func writePDFProductFile (atPath inPath : String,
                                     _ inDescriptor : ArtworkFileGenerationParameters,
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
      strokePathes.append ([inProductData.boardLimitWidth : [inProductData.boardLimitPath]], af)
    }
    if inDescriptor.drawPackageLegendTopSide {
      strokePathes.append (inProductData.frontPackageLegend, af)
    }
    if inDescriptor.drawPackageLegendBottomSide {
      strokePathes.append (inProductData.backPackageLegend, af)
    }
    if inDescriptor.drawComponentNamesTopSide {
      strokePathes.append (inProductData.frontComponentNames, af)
    }
    if inDescriptor.drawComponentNamesBottomSide {
      strokePathes.append (inProductData.backComponentNames, af)
    }
    if inDescriptor.drawComponentValuesTopSide {
      strokePathes.append (inProductData.frontComponentValues, af)
    }
    if inDescriptor.drawComponentValuesBottomSide {
      strokePathes.append (inProductData.backComponentValues, af)
    }
    if inDescriptor.drawTextsLegendTopSide {
      strokePathes.append (inProductData.legendFrontTexts, af)
      strokePathes.append (oblongs: inProductData.frontLines, af)
    }
    if inDescriptor.drawTextsLayoutTopSide {
      strokePathes.append (inProductData.layoutFrontTexts, af)
    }
    if inDescriptor.drawTextsLayoutBottomSide {
      strokePathes.append (inProductData.layoutBackTexts, af)
    }
    if inDescriptor.drawTextsLegendBottomSide {
      strokePathes.append (inProductData.legendBackTexts, af)
      strokePathes.append (oblongs: inProductData.backLines, af)
    }
    if inDescriptor.drawVias {
      strokePathes.append (circles: inProductData.viaPads, af)
    }
    if inDescriptor.drawTracksTopSide {
      strokePathes.append (tracks: inProductData.frontTracks, af)
     }
    if inDescriptor.drawTracksBottomSide {
      strokePathes.append (tracks: inProductData.backTracks, af)
    }
    if inDescriptor.drawPadsTopSide {
      strokePathes.append (circles: inProductData.frontCircularPads, af)
      strokePathes.append (oblongs: inProductData.frontOblongPads, af)
      filledPathes.append (polygons: inProductData.frontPolygonPads, af)
    }
    if inDescriptor.drawPadsBottomSide {
      strokePathes.append (circles: inProductData.backCircularPads, af)
      strokePathes.append (oblongs: inProductData.backOblongPads, af)
      filledPathes.append (polygons: inProductData.backPolygonPads, af)
    }
    var shape = EBShape (stroke: strokePathes, .black)
    shape.add (filled: filledPathes, .black)
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: .lightGray)
    try data.write (to: URL (fileURLWithPath: path))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == EBBezierPath {

  //····················································································································

  mutating func append (_ inApertureDictionary : [CGFloat : [EBLinePath]], _ inAffineTransform : AffineTransform) {
    for (aperture, pathArray) in inApertureDictionary {
      var bp = EBBezierPath ()
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.lineWidth = aperture
      for path in pathArray {
        path.appendToBezierPath (&bp, inAffineTransform)
      }
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (oblongs inLines : [ProductOblong], _ inAffineTransform : AffineTransform) {
    for segment in inLines {
      var bp = EBBezierPath ()
      bp.lineWidth = segment.width
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.move (to: inAffineTransform.transform (segment.p1))
      bp.line (to: inAffineTransform.transform (segment.p2))
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (tracks inTracks : [ProductTrack], _ inAffineTransform : AffineTransform) { // §
    for track in inTracks {
      var bp = EBBezierPath ()
      bp.lineWidth = track.width
      switch track.shape {
      case .round :
        bp.lineCapStyle = .round
      case .rect :
        bp.lineCapStyle = .square
      }
      bp.lineJoinStyle = .round
      bp.move (to: inAffineTransform.transform (track.p1))
      bp.line (to: inAffineTransform.transform (track.p2))
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (circles inCircles : [ProductCircle], _ inAffineTransform : AffineTransform) {
    for circle in inCircles {
      var bp = EBBezierPath ()
      bp.lineWidth = circle.diameter
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.move (to: inAffineTransform.transform (circle.center))
      bp.line (to: inAffineTransform.transform (circle.center))
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (polygons inPolygons : [ProductPolygon], _ inAffineTransform : AffineTransform) {
    for polygon in inPolygons {
      var bp = EBBezierPath ()
      bp.move (to: inAffineTransform.transform (polygon.origin))
      for p in polygon.points {
        bp.line (to: inAffineTransform.transform (p))
      }
      bp.close ()
      self.append (bp)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
