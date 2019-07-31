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
    var pathes = [EBBezierPath] ()
    if inDescriptor.drawBoardLimits {
      pathes.append ([inProductData.boardLimitWidth : [inProductData.boardLimitPath]])
    }
    if inDescriptor.drawPackageLegendTopSide {
      pathes.append (inProductData.frontPackageLegend)
    }
    if inDescriptor.drawPackageLegendBottomSide {
      pathes.append (inProductData.backPackageLegend)
    }
    if inDescriptor.drawComponentNamesTopSide {
      pathes.append (inProductData.frontComponentNames)
    }
    if inDescriptor.drawComponentNamesBottomSide {
      pathes.append (inProductData.backComponentNames)
    }


    let shape = EBShape (stroke: pathes, .black)
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


}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
