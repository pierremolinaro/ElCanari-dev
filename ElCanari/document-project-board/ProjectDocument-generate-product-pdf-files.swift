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
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: .white)
    try data.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  internal func writePDFProductFile (atPath inPath : String,
                                     _ inDescriptor : ArtworkFileGenerationParameters,
                                     _ inProductData : ProductData) throws {
    let path = inPath + inDescriptor.fileExtension + ".pdf"
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(path.lastPathComponent)…")
    var strokePathes = [EBBezierPath] ()
    var filledPathes = [EBBezierPath] ()
    if inDescriptor.drawBoardLimits {
      strokePathes.append ([inProductData.boardLimitWidth : [inProductData.boardLimitPath]])
    }
    if inDescriptor.drawPackageLegendTopSide {
      strokePathes.append (inProductData.frontPackageLegend)
    }
    if inDescriptor.drawPackageLegendBottomSide {
      strokePathes.append (inProductData.backPackageLegend)
    }
    if inDescriptor.drawComponentNamesTopSide {
      strokePathes.append (inProductData.frontComponentNames)
    }
    if inDescriptor.drawComponentNamesBottomSide {
      strokePathes.append (inProductData.backComponentNames)
    }
    if inDescriptor.drawComponentValuesTopSide {
      strokePathes.append (inProductData.frontComponentValues)
    }
    if inDescriptor.drawComponentValuesBottomSide {
      strokePathes.append (inProductData.backComponentValues)
    }
    if inDescriptor.drawTextsLegendTopSide {
      strokePathes.append (inProductData.legendFrontTexts)
      strokePathes.append (oblongs: inProductData.frontLines)
    }
    if inDescriptor.drawTextsLayoutTopSide {
      strokePathes.append (inProductData.layoutFrontTexts)
    }
    if inDescriptor.drawTextsLayoutBottomSide {
      strokePathes.append (inProductData.layoutBackTexts)
    }
    if inDescriptor.drawTextsLegendBottomSide {
      strokePathes.append (inProductData.legendBackTexts)
      strokePathes.append (oblongs: inProductData.backLines)
    }
    if inDescriptor.drawVias {
      strokePathes.append (circles: inProductData.viaPads)
    }
    if inDescriptor.drawTracksTopSide {
      strokePathes.append (oblongs: inProductData.frontTracks)
     }
    if inDescriptor.drawTracksBottomSide {
      strokePathes.append (oblongs: inProductData.backTracks)
    }
    if inDescriptor.drawPadsTopSide {
      strokePathes.append (circles: inProductData.frontCircularPads)
      strokePathes.append (oblongs: inProductData.frontOblongPads)
      filledPathes.append (polygons: inProductData.frontPolygonPads)
    }
    if inDescriptor.drawPadsBottomSide {
      strokePathes.append (circles: inProductData.backCircularPads)
      strokePathes.append (oblongs: inProductData.backOblongPads)
      filledPathes.append (polygons: inProductData.backPolygonPads)
    }

    var shape = EBShape (stroke: strokePathes, .black)
    shape.add (filled: filledPathes, .black)
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: .white)
    try data.write (to: URL (fileURLWithPath: path))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == EBBezierPath {

  //····················································································································

  mutating func append (_ inApertureDictionary : [CGFloat : [EBLinePath]]) {
    for (aperture, pathArray) in inApertureDictionary {
      var bp = EBBezierPath ()
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.lineWidth = aperture
      for path in pathArray {
        path.appendToBezierPath (&bp)
      }
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (oblongs inLines : [ProductOblong]) {
    for segment in inLines {
      var bp = EBBezierPath ()
      bp.lineWidth = segment.width
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.move (to: segment.p1)
      bp.line (to: segment.p2)
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (circles inCircles : [ProductCircle]) {
    for circle in inCircles {
      var bp = EBBezierPath ()
      bp.lineWidth = circle.diameter
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.move (to: circle.center)
      bp.line (to: circle.center)
      self.append (bp)
    }
  }

  //····················································································································

  mutating func append (polygons inPolygons : [ProductPolygon]) {
    for polygon in inPolygons {
      var bp = EBBezierPath ()
      bp.move (to: polygon.origin)
      for p in polygon.points {
        bp.line (to: p)
      }
      bp.close ()
      self.append (bp)
    }
  }

  //····················································································································


}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
