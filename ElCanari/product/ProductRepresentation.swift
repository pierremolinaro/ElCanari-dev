//
//  ProductRepresentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/05/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import Compression

//--------------------------------------------------------------------------------------------------

extension LayerConfiguration : Codable {}

//--------------------------------------------------------------------------------------------------

struct ProductRepresentation : Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private(set) var boardWidth : ProductLength
  private(set) var boardWidthUnit : Int // Canari Unit
  private(set) var boardHeight : ProductLength
  private(set) var boardHeightUnit : Int // Canari Unit
  private(set) var boardLimitWidth : ProductLength
  private(set) var boardLimitWidthUnit : Int // Canari Unit
  private(set) var artworkName = ""
  private(set) var roundSegments = [LayeredProductSegment] ()
  private(set) var squareSegments = [LayeredProductSegment] ()
  private(set) var circles = [LayeredProductCircle] ()
  private(set) var rectangles = [LayeredProductRectangle] ()
  private(set) var componentPads = [LayeredProductComponentPad] ()
  private(set) var layerConfiguration : LayerConfiguration

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (boardWidth inBoardWidth : ProductLength,
        boardWidthUnit inBoardWidthUnit : Int, // Canari Unit
        boardHeight inBoardHeight : ProductLength,
        boardHeightUnit inBoardHeightUnit : Int, // Canari Unit
        boardLimitWidth inBoardLimitWidth : ProductLength,
        boardLimitWidthUnit inBoardLimitWidthUnit : Int, // Canari Unit
        artworkName inArtworkName : String,
        layerConfiguration inLayerConfiguration : LayerConfiguration) {
    self.boardWidth = inBoardWidth
    self.boardWidthUnit = inBoardWidthUnit
    self.boardHeight = inBoardHeight
    self.boardHeightUnit = inBoardHeightUnit
    self.boardLimitWidth = inBoardLimitWidth
    self.boardLimitWidthUnit = inBoardLimitWidthUnit
    self.artworkName = inArtworkName
    self.layerConfiguration = inLayerConfiguration
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Populate
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (circle inCircle : LayeredProductCircle) {
    self.circles.append (inCircle)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (pad inPad : LayeredProductComponentPad) {
    self.componentPads.append (inPad)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (roundSegment inSegment : LayeredProductSegment) {
    if (inSegment.x1 != inSegment.x2) || (inSegment.y1 != inSegment.y2) {
      self.roundSegments.append (inSegment)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (squareSegment inSegment : LayeredProductSegment) {
    if (inSegment.x1 != inSegment.x2) || (inSegment.y1 != inSegment.y2) {
      self.squareSegments.append (inSegment)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (rectangle inRect : LayeredProductRectangle) {
    self.rectangles.append (inRect)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (flattenedStrokeBezierPath inBezierPath : EBBezierPath,
                        transformedBy inAT : AffineTransform,
                        clippedBy inClipRect : NSRect,
                        width inWidth : ProductLength,
                        layers inLayerSet : ProductLayerSet) {
    let segmentArray = inBezierPath.productSegments (
      withFlatness: 0.1,
      transformedBy: inAT,
      clippedBy: inClipRect
    )
    for segment in segmentArray {
      let oblong = LayeredProductSegment (p1: segment.p1, p2: segment.p2, width: inWidth, layers: inLayerSet)
      self.roundSegments.append (oblong)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Insert a product (used by merger)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (_ inProduct : ProductRepresentation,
                     x inX : ProductLength,
                     y inY : ProductLength,
                     quadrantRotation inRotation : QuadrantRotation) {
    var modelAffineTransform = AffineTransform ()
    let width = inProduct.boardWidth.value (in: .cocoa)
    let height = inProduct.boardHeight.value (in: .cocoa)
    switch inRotation {
    case .rotation0, .rotation180 :
      modelAffineTransform.translate (x: width / 2.0, y: height / 2.0)
    case .rotation90, .rotation270 :
      modelAffineTransform.translate (x: height / 2.0, y: width / 2.0)
    }
    modelAffineTransform.translate (x: inX.value (in: .cocoa), y: inY.value (in: .cocoa))
    let angleInDegrees = Double (inRotation.rawValue * 90)
    modelAffineTransform.rotate (byDegrees: angleInDegrees)
    modelAffineTransform.translate (x: -width / 2.0, y: -height / 2.0)
    for circle in inProduct.circles {
      let center = ProductPoint (cocoaPoint: modelAffineTransform.transform (ProductPoint (x: circle.x, y: circle.y).cocoaPoint))
      let newCircle = LayeredProductCircle (
        center: center,
        diameter: circle.d,
        layers: circle.layers
      )
      self.circles.append (newCircle)
    }
    for segment in inProduct.roundSegments {
      let p1 = ProductPoint (cocoaPoint: modelAffineTransform.transform (ProductPoint (x: segment.x1, y: segment.y1).cocoaPoint))
      let p2 = ProductPoint (cocoaPoint: modelAffineTransform.transform (ProductPoint (x: segment.x2, y: segment.y2).cocoaPoint))
      let s = LayeredProductSegment (
        p1: p1,
        p2: p2,
        width: segment.width,
        layers: segment.layers
      )
      self.roundSegments.append (s)
    }
    for segment in inProduct.squareSegments {
      let p1 = ProductPoint (cocoaPoint: modelAffineTransform.transform (ProductPoint (x: segment.x1, y: segment.y1).cocoaPoint))
      let p2 = ProductPoint (cocoaPoint: modelAffineTransform.transform (ProductPoint (x: segment.x2, y: segment.y2).cocoaPoint))
      let s = LayeredProductSegment (
        p1: p1,
        p2: p2,
        width: segment.width,
        layers: segment.layers
      )
      self.squareSegments.append (s)
    }
    for r in inProduct.rectangles {
      var af = modelAffineTransform
      af.append (r.af)
      let s = LayeredProductRectangle (af: af, layers: r.layers)
      self.rectangles.append (s)
    }
    for pad in inProduct.componentPads {
      var padAffineTransform = pad.af
      padAffineTransform.append (modelAffineTransform)
      let s = LayeredProductComponentPad (
        width: pad.width,
        height: pad.height,
        af: padAffineTransform,
        shape: pad.shape,
        layers: pad.layers
      )
      self.componentPads.append (s)
    }
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Decoding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init? (fromJSONCompressedData inData : Data,
         using inAlgorithm : compression_algorithm) {
    let uncompressedData = uncompressedData (inData, using: inAlgorithm, initialExpansionFactor: 24)
    let decoder = JSONDecoder ()
    if let product = try? decoder.decode (Self.self, from: uncompressedData) {
      self = product
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Encoding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func encodedJSONData (prettyPrinted inPrettyPrinted : Bool) throws -> Data {
    let encoder = JSONEncoder ()
    if inPrettyPrinted {
      encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    }else{
      encoder.outputFormatting = .sortedKeys
    }
    let data = try encoder.encode (self)
    return data
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func encodedJSONCompressedData (prettyPrinted inPrettyPrinted : Bool,
                                  using inAlgorithm : compression_algorithm) -> Data {
    let jsonData = try! encodedJSONData (prettyPrinted: inPrettyPrinted)
    let compressedJSONData = compressedData (jsonData, using: inAlgorithm)
    return compressedJSONData
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func roundSegments (forLayers inLayers : ProductLayerSet) -> [LayeredProductSegment] {
    var result = [LayeredProductSegment] ()
    for oblong in self.roundSegments {
      if !oblong.layers.intersection (inLayers).isEmpty {
        result.append (oblong)
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func circles (forLayers inLayers : ProductLayerSet) -> [LayeredProductCircle] {
    var result = [LayeredProductCircle] ()
    for circle in self.circles {
      if !circle.layers.intersection (inLayers).isEmpty {
        result.append (circle)
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func segmentEntities (_ inUndoManager : UndoManager?,
                        forLayers inLayers : ProductLayerSet) -> EBReferenceArray <SegmentEntity> {
    var result = EBReferenceArray <SegmentEntity> ()
    for circle in self.circles {
      if !circle.layers.intersection (inLayers).isEmpty {
        let s = SegmentEntity (inUndoManager)
        s.x1 = circle.x.valueInCanariUnit
        s.y1 = circle.y.valueInCanariUnit
        s.x2 = circle.x.valueInCanariUnit
        s.y2 = circle.y.valueInCanariUnit
        s.width = circle.d.valueInCanariUnit
        s.endStyle = .round
        result.append (s)
      }
    }
    for segment in self.roundSegments {
      if !segment.layers.intersection (inLayers).isEmpty {
       let s = SegmentEntity (inUndoManager, segment, endStyle: .round)
        result.append (s)
      }
    }
    for segment in self.squareSegments {
      if !segment.layers.intersection (inLayers).isEmpty {
        let s = SegmentEntity (inUndoManager, segment, endStyle: .square)
        result.append (s)
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func rectangleEntities (_ inUndoManager : UndoManager?,
                        forLayers inLayers : ProductLayerSet) -> EBReferenceArray <RectangleEntity> {
    var result = EBReferenceArray <RectangleEntity> ()
    for rect in self.rectangles {
      if !rect.layers.intersection (inLayers).isEmpty {
        let (origin, points) = rect.polygon ()
        let r = RectangleEntity (inUndoManager)
        r.p0x = origin.x.valueInCanariUnit
        r.p0y = origin.y.valueInCanariUnit
        r.p1x = points [0].x.valueInCanariUnit
        r.p1y = points [0].y.valueInCanariUnit
        r.p2x = points [1].x.valueInCanariUnit
        r.p2y = points [1].y.valueInCanariUnit
        r.p3x = points [2].x.valueInCanariUnit
        r.p3y = points [2].y.valueInCanariUnit
        result.append (r)
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func pads (_ inUndoManager : UndoManager?,
                        forLayers inLayers : ProductLayerSet) -> EBReferenceArray <BoardModelPad> {
    var padEntities = EBReferenceArray <BoardModelPad> ()
    for componentPad in self.componentPads {
      if !componentPad.layers.intersection (inLayers).isEmpty {
        let pad = BoardModelPad (inUndoManager)
      //  let relativeCenter = ProductPoint (x: componentPad.xCenter, y: componentPad.yCenter).cocoaPoint
        let relativeCenter = ProductPoint (x: .zero, y: .zero).cocoaPoint // $$
        let absoluteCenter = ProductPoint (cocoaPoint: componentPad.af.transform (relativeCenter))
        pad.x = absoluteCenter.x.valueInCanariUnit
        pad.y = absoluteCenter.y.valueInCanariUnit
        pad.width = componentPad.width.valueInCanariUnit
        pad.height = componentPad.height.valueInCanariUnit
        pad.rotation = Int (componentPad.af.angleInDegrees * 1000.0)
        pad.shape = componentPad.shape
        padEntities.append (pad)
      }
    }
    return padEntities
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate extension SegmentEntity {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  convenience init (_ inUndoManager : UndoManager?,
                    _ inProductSegment : LayeredProductSegment,
                    endStyle inEndStyle : TrackEndStyle) {
    self.init (inUndoManager)
    self.x1 = inProductSegment.p1.x.valueInCanariUnit
    self.y1 = inProductSegment.p1.y.valueInCanariUnit
    self.x2 = inProductSegment.p2.x.valueInCanariUnit
    self.y2 = inProductSegment.p2.y.valueInCanariUnit
    self.width = inProductSegment.width.valueInCanariUnit
    self.endStyle = inEndStyle
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
