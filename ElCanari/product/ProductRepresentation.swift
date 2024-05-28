//
//  ProductRepresentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/05/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

struct ProductRepresentation : Codable {

  //································································································
  //  Properties
  //································································································

  private var boardBox : ProductRect
  private var boardLimitWidth : ProductLength
  private var boardLimitPath : [ProductPoint]
  private var layeredOblongs = [LayeredProductOblong] ()

  //································································································
  //  Init
  //································································································

  @MainActor init (projectRoot inProjectRoot : ProjectRoot) {
    self.boardBox = ProductRect (canariRect: inProjectRoot.boardBoundBox!)
    self.boardLimitWidth = ProductLength (valueInCanariUnit: inProjectRoot.mBoardLimitsWidth)
  //--- Board limit path
    self.boardLimitPath = inProjectRoot.buildBoardLimitPath ()
  //--- Package Legend
    self.appendPackageLegends (projectRoot: inProjectRoot)
  }

//    let (frontPackageLegend, backPackageLegend) = self.buildPackageLegend (cocoaBoardRect)
//    let (frontComponentNames, backComponentNames) = self.buildComponentNamePathes (cocoaBoardRect)
//    let (frontComponentValues, backComponentValues) = self.buildComponentValuePathes (cocoaBoardRect)
//    let (legendFrontTexts, layoutFrontTexts, layoutBackTexts, legendBackTexts) = self.buildTextPathes (cocoaBoardRect)
//    let (legendFrontQRCodes, legendBackQRCodes) = self.buildQRCodePathes ()
//    let (legendFrontImages, legendBackImages) = self.buildBoardImagesPathes ()
//    let viaPads = self.buildViaPads ()
//    let (tracks, frontTracksWithNoSilkScreen, backTracksWithNoSilkScreen) = self.buildTracks ()
//    let (frontLines, backLines) = self.buildLines (cocoaBoardRect)
//    let circularPads = self.buildCircularPads ()
//    let oblongPads = self.buildOblongPads ()
//    let polygonPads = self.buildPolygonPads ()

  //································································································
  //  Decoding from JSON
  //································································································

  init? (fromJSONData inData : Data) {
    let decoder = JSONDecoder()
    if let product = try? decoder.decode (Self.self, from: inData) {
      self = product
    }else{
      return nil
    }
  }

  //································································································
  //  Encoding to JSON
  //································································································

  func jsonData () throws -> Data {
    let encoder = JSONEncoder ()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    let data = try encoder.encode (self)
    return data
  }

  //································································································
  //  Get Gerber representation
  //································································································

  func gerber (items inItemSet : ProductItemSet) -> GerberRepresentation {
    var gerber = GerberRepresentation ()
  //--- Board limits ?
    if inItemSet.contains (.drawBoardLimits) {
      var points = self.boardLimitPath
      var currentPoint = points.first!
      let firstPoint = currentPoint
      points.removeFirst ()
      for p in points {
        gerber.addOblong (p1: currentPoint, p2: p, width: self.boardLimitWidth)
        currentPoint = p
      }
      gerber.addOblong (p1: currentPoint, p2: firstPoint, width: self.boardLimitWidth)
    }
  //--- Add oblongs
    for oblong in self.layeredOblongs {
      if inItemSet.contains (oblong.layers) {
        gerber.addOblong (p1: oblong.p1, p2: oblong.p2, width: oblong.width)
      }
    }
  //---
    return gerber
  }

  //································································································

  @MainActor private mutating func appendPackageLegends (projectRoot inProjectRoot : ProjectRoot) {
    let cocoaBoardRect = inProjectRoot.boardBoundBox!.cocoaRect
    let width = ProductLength (Double (inProjectRoot.packageDrawingWidthMultpliedByTenForBoard) / 10.0, .px)
    for object in inProjectRoot.mBoardObjects.values {
      if let component = object as? ComponentInProject, component.mDisplayLegend {
        let strokeBezierPath = component.strokeBezierPath!
        if !strokeBezierPath.isEmpty {
          let af = component.packageToComponentAffineTransform ()
          let segmentArray = strokeBezierPath.productSegments (
            withFlatness: 0.1,
            transformedBy: af,
            clippedBy: cocoaBoardRect
          )
          let layer : ProductItemSet
          switch component.mSide {
          case .back :
            layer = .drawPackageLegendBottomSide
          case .front :
            layer = .drawPackageLegendTopSide
          }
          for segment in segmentArray {
            let oblong = LayeredProductOblong (p1: segment.p1, p2: segment.p2, width: width, layers: layer)
            self.layeredOblongs.append (oblong)
          }
        }
      }
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

fileprivate extension ProjectRoot {

  //································································································

  func buildBoardLimitPath () -> [ProductPoint] {
    var result = [ProductPoint] ()
    switch self.mBoardShape {
    case .bezierPathes :
      var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
      for curve in self.mBorderCurves.values {
        let descriptor = curve.descriptor!
        curveDictionary [descriptor.p1] = descriptor
      }
      var descriptor = self.mBorderCurves [0].descriptor!
      let firstPoint = descriptor.p1
      var currentPoint = firstPoint
      result.append (ProductPoint (canariPoint: firstPoint))
      var loop = true
      while loop {
        switch descriptor.shape {
        case .line :
          result.append (ProductPoint (canariPoint: descriptor.p2))
        case .bezier :
          let cp1 = descriptor.cp1.cocoaPoint
          let cp2 = descriptor.cp2.cocoaPoint
          let bp = NSBezierPath ()
          bp.move (to: currentPoint.cocoaPoint)
          bp.curve (to: descriptor.p2.cocoaPoint, controlPoint1: cp1, controlPoint2: cp2)
          bp.flatness = 0.1
          let flattenedBezierPath = bp.flattened
          var points = [NSPoint] (repeating: .zero, count: 3)
          for i in 0 ..< flattenedBezierPath.elementCount {
            let type = flattenedBezierPath.element (at: i, associatedPoints: &points)
            switch type {
            case .moveTo, .cubicCurveTo, .closePath, .quadraticCurveTo:
              ()
            case .lineTo: ()
               result.append (ProductPoint (canariPoint: points[0].canariPoint))
            @unknown default:
              ()
            }
          }
        }
        currentPoint = descriptor.p2
        descriptor = curveDictionary [descriptor.p2]!
        loop = firstPoint != descriptor.p1
      }
    case .rectangular :
      let width = ProductLength (valueInCanariUnit: self.mRectangularBoardWidth)
      let height = ProductLength (valueInCanariUnit: self.mRectangularBoardHeight)
      result.append (.zero) // Bottom left
      result.append (ProductPoint (x: .zero, y: height)) // Top left
      result.append (ProductPoint (x: width, y: height)) // Top right
      result.append (ProductPoint (x: width, y: .zero)) // Bottom right
    }
    return result
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
