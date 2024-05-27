//
//  ProductRepresentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

//extension Array : Codable  where Element == ProductPoint { }

//--------------------------------------------------------------------------------------------------

struct ProductRepresentation : Codable {

  //································································································
  //  Properties
  //································································································

  private (set) var boardBox : ProductRect = .zero
  private (set) var boardLimitWidth : ProductLength = .zero
  private (set) var boardLimitPath : [ProductPoint] = [ProductPoint] ()

  //································································································
  //  Init
  //································································································

  @MainActor init (boardBox inBoardBox : CanariRect,
                   shape inBoardShape : BoardShape,
                   borderCurves inBorderCurves : EBReferenceArray <BorderCurve>,
                   boardLimitWidth inBoardLimitWidth : Int,
                   boardClearance inBoardClearance : Int,
                   rectangularBoardWidth inRectangularBoardWidth : Int,
                   rectangularBoardHeight inRectangularBoardHeight : Int) {
    self.boardBox = ProductRect (canariRect: inBoardBox)
    self.boardLimitWidth = ProductLength (valueInCanariUnit: inBoardLimitWidth)
    self.boardLimitPath = buildBoardLimitPath (
      shape: inBoardShape,
      borderCurves: inBorderCurves,
      boardLimitWidth: inBoardLimitWidth,
      boardClearance: inBoardClearance,
      rectangularBoardWidth: inRectangularBoardWidth,
      rectangularBoardHeight: inRectangularBoardHeight
    )
  }

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

  func jsonData () -> Data? {
    let encoder = JSONEncoder ()
    encoder.outputFormatting = [.sortedKeys]
    let data = try? encoder.encode (self)
    return data
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func
buildBoardLimitPath (shape inBoardShape : BoardShape,
                     borderCurves inBorderCurves : EBReferenceArray <BorderCurve>,
                     boardLimitWidth inBoardLimitWidth : Int,
                     boardClearance inBoardClearance : Int,
                     rectangularBoardWidth inRectangularBoardWidth : Int,
                     rectangularBoardHeight inRectangularBoardHeight : Int) -> [ProductPoint] {
  var retainedBP = EBBezierPath ()
  var result = [ProductPoint] ()
  switch inBoardShape {
  case .bezierPathes :
    var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
    for curve in inBorderCurves.values {
      let descriptor = curve.descriptor!
      curveDictionary [descriptor.p1] = descriptor
    }
    var descriptor = inBorderCurves [0].descriptor!
    let p = descriptor.p1
    var bp = EBBezierPath ()
    bp.move (to: p.cocoaPoint)
    var loop = true
    while loop {
      switch descriptor.shape {
      case .line :
        bp.line (to: descriptor.p2.cocoaPoint)
      case .bezier :
        let cp1 = descriptor.cp1.cocoaPoint
        let cp2 = descriptor.cp2.cocoaPoint
        bp.curve (to: descriptor.p2.cocoaPoint, controlPoint1: cp1, controlPoint2: cp2)
      }
      descriptor = curveDictionary [descriptor.p2]!
      loop = p != descriptor.p1
    }
    bp.close ()
  //---
    bp.lineJoinStyle = .round
    bp.lineCapStyle = .round
    bp.lineWidth = canariUnitToCocoa (inBoardLimitWidth + inBoardClearance * 2)
    let strokeBP = bp.pathByStroking
    // Swift.print ("BezierPath BEGIN")
    var closedPathCount = 0
    let retainedClosedPath = 2
    var points = [NSPoint] (repeating: .zero, count: 3)
    for i in 0 ..< strokeBP.nsBezierPath.elementCount {
      let type = strokeBP.nsBezierPath.element (at: i, associatedPoints: &points)
      switch type {
      case .moveTo:
        closedPathCount += 1
        if closedPathCount == retainedClosedPath {
          retainedBP.move (to: points[0])
        }
      case .lineTo:
        // Swift.print ("  lineTo: \(points[0].x) \(points[0].y)")
        if closedPathCount == retainedClosedPath {
          retainedBP.line (to: points[0])
        }
      case .curveTo:
        // Swift.print ("  curveTo")
        if closedPathCount == retainedClosedPath {
          retainedBP.curve (to: points[2], controlPoint1: points[0], controlPoint2: points[1])
        }
      case .closePath:
        // Swift.print ("  closePath")
        if closedPathCount == retainedClosedPath {
          retainedBP.close ()
        }
      case .cubicCurveTo:
        ()
      case .quadraticCurveTo:
        ()
      @unknown default :
        ()
      }
    }
    //Swift.print ("BezierPath END")
  case .rectangular :
    let width = ProductLength (valueInCanariUnit: inRectangularBoardWidth)
    let height = ProductLength (valueInCanariUnit: inRectangularBoardHeight)
    result.append (.zero) // Bottom left
    result.append (ProductPoint (x: .zero, y: height)) // Top left
    result.append (ProductPoint (x: width, y: height)) // Top right
    result.append (ProductPoint (x: width, y: .zero)) // Bottom right
  }
  return result
}

//--------------------------------------------------------------------------------------------------
