//
//  ProductRepresentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/05/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import Compression
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension LayerConfiguration : Codable {}

//--------------------------------------------------------------------------------------------------

struct ProductRepresentation : Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private(set) var boardWidth : CanariLength
  private(set) var boardWidthUnit : CanariLengthUnit // Canari Unit
  private(set) var boardHeight : CanariLength
  private(set) var boardHeightUnit : CanariLengthUnit // Canari Unit
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

  init (boardWidth inBoardWidth : CanariLength,
        boardWidthUnit inBoardWidthUnit : CanariLengthUnit, // Canari Unit
        boardHeight inBoardHeight : CanariLength,
        boardHeightUnit inBoardHeightUnit : CanariLengthUnit, // Canari Unit
//        boardLimitWidth inBoardLimitWidth : CanariLength,
//        boardLimitWidthUnit inBoardLimitWidthUnit : Int, // Canari Unit
        artworkName inArtworkName : String,
        layerConfiguration inLayerConfiguration : LayerConfiguration) {
    self.boardWidth = inBoardWidth
    self.boardWidthUnit = inBoardWidthUnit
    self.boardHeight = inBoardHeight
    self.boardHeightUnit = inBoardHeightUnit
//    self.boardLimitWidth = inBoardLimitWidth
//    self.boardLimitWidthUnit = inBoardLimitWidthUnit
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

  mutating func append (flattenedStrokeBezierPath inBezierPath : BezierPath,
                        transformedBy inAT : CanariAffinity,
                        clippedBy inClipRect : NSRect,
                        width inWidth : CanariLength,
                        layers inLayerSet : ProductLayerSet) {
    let segmentArray = inBezierPath.productSegments (
      withFlatness: 0.025,
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
                     x inX : CanariLength,
                     y inY : CanariLength,
                     quadrantRotation inRotation : QuadrantRotation) {
    var modelAffineTransform = CanariAffinity ()
    let width = inProduct.boardWidth
    let height = inProduct.boardHeight
    switch inRotation {
    case .rotation0, .rotation180 :
      modelAffineTransform.translate (x: width / 2.0, y: height / 2.0)
    case .rotation90, .rotation270 :
      modelAffineTransform.translate (x: height / 2.0, y: width / 2.0)
    }
    modelAffineTransform.translate (x: inX, y: inY)
    let angleInDegrees = Double (inRotation.rawValue * 90)
    modelAffineTransform.rotate (by: .degree (angleInDegrees))
    modelAffineTransform.translate (x: -width / 2.0, y: -height / 2.0)
    for circle in inProduct.circles {
      let center = modelAffineTransform.transforming (CanariPoint (x: circle.x, y: circle.y))
      let newCircle = LayeredProductCircle (
        center: center,
        diameter: circle.d,
        layers: circle.layers
      )
      self.circles.append (newCircle)
    }
    for segment in inProduct.roundSegments {
      var layers = segment.layers
      if layers.contains (.boardLimits) {
        layers.remove (.boardLimits)
        layers.insert (.internalBoardLimits)
      }
      let p1 = modelAffineTransform.transforming (CanariPoint (x: segment.x1, y: segment.y1))
      let p2 = modelAffineTransform.transforming (CanariPoint (x: segment.x2, y: segment.y2))
      let s = LayeredProductSegment (
        p1: p1,
        p2: p2,
        width: segment.width,
        layers: layers
      )
      self.roundSegments.append (s)
    }
    for segment in inProduct.squareSegments {
      let p1 = modelAffineTransform.transforming (CanariPoint (x: segment.x1, y: segment.y1))
      let p2 = modelAffineTransform.transforming (CanariPoint (x: segment.x2, y: segment.y2))
      let s = LayeredProductSegment (
        p1: p1,
        p2: p2,
        width: segment.width,
        layers: segment.layers
      )
      self.squareSegments.append (s)
    }
    for r in inProduct.rectangles {
      var af = r.af
      af.append (modelAffineTransform)
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
        s.x1 = circle.x
        s.y1 = circle.y
        s.x2 = circle.x
        s.y2 = circle.y
        s.width = circle.d
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
        r.p0x = origin.x
        r.p0y = origin.y
        r.p1x = points [0].x
        r.p1y = points [0].y
        r.p2x = points [1].x
        r.p2y = points [1].y
        r.p3x = points [2].x
        r.p3y = points [2].y
        result.append (r)
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func pads (_ inUndoManager : UndoManager?,
                        forLayers inLayers : ProductLayerSet) -> EBReferenceArray <BoardModelPad> {
    var padEntities = EBReferenceArray <BoardModelPad> ()
  //--- Pads
    for componentPad in self.componentPads {
      if !componentPad.layers.intersection (inLayers).isEmpty {
        let pad = BoardModelPad (inUndoManager)
        let relativeCenter = CanariPoint ()
        let absoluteCenter = componentPad.af.transforming (relativeCenter)
        pad.x = absoluteCenter.x
        pad.y = absoluteCenter.y
        pad.width = componentPad.width
        pad.height = componentPad.height
        pad.rotation = componentPad.af.angle
        pad.shape = componentPad.shape
        padEntities.append (pad)
      }
    }
  //--- Exposed tracks
    for segment in self.roundSegments {
      if !segment.layers.intersection (inLayers).isEmpty {
        padEntities.append (segment.boardModelPad (inUndoManager, endStyle: .round))
      }
    }
    for segment in self.squareSegments {
      if !segment.layers.intersection (inLayers).isEmpty {
        padEntities.append (segment.boardModelPad (inUndoManager, endStyle: .square))
      }
    }

  //---
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
    self.x1 = inProductSegment.p1.x
    self.y1 = inProductSegment.p1.y
    self.x2 = inProductSegment.p2.x
    self.y2 = inProductSegment.p2.y
    self.width = inProductSegment.width
    self.endStyle = inEndStyle
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
