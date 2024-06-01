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

struct ProductRepresentation : Codable {

  //································································································
  //  Properties
  //································································································

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

  //································································································
  //  Init
  //································································································

  @MainActor init (boardWidth inBoardWidth : ProductLength,
                   boardWidthUnit inBoardWidthUnit : Int, // Canari Unit
                   boardHeight inBoardHeight : ProductLength,
                   boardHeightUnit inBoardHeightUnit : Int, // Canari Unit
                   boardLimitWidth inBoardLimitWidth : ProductLength,
                   boardLimitWidthUnit inBoardLimitWidthUnit : Int, // Canari Unit
                   artworkName inArtworkName : String) {
    self.boardWidth = inBoardWidth
    self.boardWidthUnit = inBoardWidthUnit
    self.boardHeight = inBoardHeight
    self.boardHeightUnit = inBoardHeightUnit
    self.boardLimitWidth = inBoardLimitWidth
    self.boardLimitWidthUnit = inBoardLimitWidthUnit
    self.artworkName = inArtworkName
  }

  //································································································
  //  Init
  //································································································

  @MainActor init (projectRoot inProjectRoot : ProjectRoot) {
    let boardBoundBox = inProjectRoot.boardBoundBox!
    self.boardWidth = ProductLength (valueInCanariUnit: boardBoundBox.width)
    self.boardWidthUnit = inProjectRoot.mRectangularBoardWidthUnit_property.propval
    self.boardHeightUnit = inProjectRoot.mRectangularBoardHeightUnit_property.propval
    self.boardHeight = ProductLength (valueInCanariUnit: boardBoundBox.height)
    self.boardLimitWidth = ProductLength (valueInCanariUnit: inProjectRoot.mBoardLimitsWidth)
    self.boardLimitWidthUnit = inProjectRoot.mBoardLimitsWidthUnit
    self.artworkName = inProjectRoot.mArtworkName
  //--- Board limit path
    do{
      var points = inProjectRoot.buildBoardLimitPath ()
      let firstPoint = points [0]
      var currentPoint = firstPoint
      points.removeFirst ()
      for p in points {
        let oblong = LayeredProductSegment (p1: currentPoint, p2: p, width: self.boardLimitWidth, layers: .boardLimits)
        self.roundSegments.append (oblong)
        currentPoint = p
      }
      let oblong = LayeredProductSegment (p1: currentPoint, p2: firstPoint, width: self.boardLimitWidth, layers: .boardLimits)
      self.roundSegments.append (oblong)
    }
  //--- Populate
    self.appendPackageLegends (projectRoot: inProjectRoot)
    self.appendComponentNamePathes (projectRoot: inProjectRoot)
    self.appendComponentValuePathes (projectRoot: inProjectRoot)
    self.appendTextPathes (projectRoot: inProjectRoot)
    self.appendLegendLines (projectRoot: inProjectRoot)
    self.appendVias (projectRoot: inProjectRoot)
    self.appendPads (projectRoot: inProjectRoot)
    self.appendQRCodePathes (projectRoot: inProjectRoot)
    self.appendImagesPathes (projectRoot: inProjectRoot)
    self.appendTracks (projectRoot: inProjectRoot)
  }

  //································································································
  //  Insert a product (used by merger)
  //································································································

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
      let center = ProductPoint (cocoaPoint: modelAffineTransform.transform (ProductPoint (x: r.xCenter, y: r.yCenter).cocoaPoint))
      var af = modelAffineTransform
      af.append (r.af)
      let s = LayeredProductRectangle (
        xCenter: center.x,
        yCenter: center.y,
        width: r.width,
        height: r.height,
        af: af,
        layers: r.layers
      )
      self.rectangles.append (s)
    }
    for pad in inProduct.componentPads {
      var padAffineTransform = pad.af
      padAffineTransform.append (modelAffineTransform)
      let s = LayeredProductComponentPad (
        xCenter: pad.xCenter,
        yCenter: pad.yCenter,
        width: pad.width,
        height: pad.height,
        af: padAffineTransform,
        shape: pad.shape,
        layers: pad.layers
      )
      self.componentPads.append (s)
    }
  }
  
  //································································································
  //  Decoding
  //································································································

  init? (fromJSONData2 inData : Data) {
    let decoder = JSONDecoder ()
    if let product = try? decoder.decode (Self.self, from: inData) {
      self = product
    }else{
      return nil
    }
  }

  //································································································

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

  //································································································
  //  Encoding
  //································································································

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

  //································································································

  func encodedJSONCompressedData (prettyPrinted inPrettyPrinted : Bool,
                                  using inAlgorithm : compression_algorithm) -> Data {
    let jsonData = try! encodedJSONData (prettyPrinted: inPrettyPrinted)
    let compressedJSONData = compressedData (jsonData, using: inAlgorithm)
    return compressedJSONData
  }

  //································································································

  @MainActor private mutating func append (flattenedStrokeBezierPath inBezierPath : EBBezierPath,
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

  //································································································

  @MainActor private mutating func appendPackageLegends (projectRoot inProjectRoot : ProjectRoot) {
    let cocoaBoardRect = inProjectRoot.boardBoundBox!.cocoaRect
    let width = ProductLength (Double (inProjectRoot.packageDrawingWidthMultpliedByTenForBoard) / 10.0, .cocoa)
    for object in inProjectRoot.mBoardObjects.values {
      if let component = object as? ComponentInProject, component.mDisplayLegend {
        let strokeBezierPath = component.strokeBezierPath!
        if !strokeBezierPath.isEmpty {
          let af = component.packageToComponentAffineTransform ()
          let layer : ProductLayerSet
          switch component.mSide {
          case .back :
            layer = .backSidePackageLegend
          case .front :
            layer = .frontSidePackageLegend
          }
          self.append (
            flattenedStrokeBezierPath: strokeBezierPath,
            transformedBy: af,
            clippedBy: cocoaBoardRect,
            width: width,
            layers: layer
          )
        }
      }
    }
  }

  //································································································

  @MainActor private mutating func appendComponentNamePathes (projectRoot inProjectRoot : ProjectRoot) {
    let cocoaBoardRect = inProjectRoot.boardBoundBox!.cocoaRect
    for object in inProjectRoot.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        if component.mNameIsVisibleInBoard, let fontDescriptor = component.mNameFont?.descriptor {
          let (textBP, _, _, _, _) = boardText_displayInfos (
            x: component.mXName + component.mX,
            y: component.mYName + component.mY,
            string: component.componentName!,
            fontSize: component.mNameFontSize,
            fontDescriptor,
            horizontalAlignment: .center,
            verticalAlignment: .center,
            frontSide: component.mSide == .front,
            rotation: component.mNameRotation,
            weight: 1.0,
            oblique: false,
            extraWidth: 0.0
          )
          let width = ProductLength (textBP.lineWidth, .cocoa)
          let layer : ProductLayerSet
          switch component.mSide {
          case .back :
            layer = .backSideComponentName
          case .front :
            layer = .frontSideComponentName
          }
          self.append (
            flattenedStrokeBezierPath: textBP,
            transformedBy: AffineTransform (),
            clippedBy: cocoaBoardRect,
            width: width,
            layers: layer
          )
        }
      }
    }
  }

  //································································································

  @MainActor private mutating func appendComponentValuePathes (projectRoot inProjectRoot : ProjectRoot) {
    let cocoaBoardRect = inProjectRoot.boardBoundBox!.cocoaRect
    for object in inProjectRoot.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        if component.mValueIsVisibleInBoard, let fontDescriptor = component.mValueFont?.descriptor {
          let (textBP, _, _, _, _) = boardText_displayInfos (
            x: component.mXValue + component.mX,
            y: component.mYValue + component.mY,
            string: component.mComponentValue,
            fontSize: component.mValueFontSize,
            fontDescriptor,
            horizontalAlignment: .center,
            verticalAlignment: .center,
            frontSide: component.mSide == .front,
            rotation: component.mValueRotation,
            weight: 1.0,
            oblique: false,
            extraWidth: 0.0
          )
          let width = ProductLength (textBP.lineWidth, .cocoa)
          let layer : ProductLayerSet
          switch component.mSide {
          case .back :
            layer = .backSideComponentValue
          case .front :
            layer = .frontSideComponentValue
          }
          self.append (
            flattenedStrokeBezierPath: textBP,
            transformedBy: AffineTransform (),
            clippedBy: cocoaBoardRect,
            width: width,
            layers: layer
          )
        }
      }
    }
  }

  //································································································

  @MainActor private mutating func appendTextPathes (projectRoot inProjectRoot : ProjectRoot) {
    let cocoaBoardRect = inProjectRoot.boardBoundBox!.cocoaRect
    for object in inProjectRoot.mBoardObjects.values {
      if let text = object as? BoardText {
        let (textBP, _, _, _, _) = boardText_displayInfos (
          x: text.mX,
          y: text.mY,
          string: text.mText,
          fontSize: text.mFontSize,
          text.mFont!.descriptor!,
          horizontalAlignment: text.mHorizontalAlignment,
          verticalAlignment: text.mVerticalAlignment,
          frontSide: (text.mLayer == .layoutFront) || (text.mLayer == .legendFront),
          rotation: text.mRotation,
          weight: text.mWeight,
          oblique: text.mOblique,
          extraWidth: 0.0
        )
        let width = ProductLength (textBP.lineWidth, .cocoa)
        let layer : ProductLayerSet
        switch text.mLayer {
        case .legendFront :
          layer = .frontSideLegendText
        case .layoutFront :
          layer = .frontSideLayoutText
        case .legendBack :
          layer = .backSideLegendText
        case .layoutBack :
          layer = .backSideLayoutText
        }
        self.append (
          flattenedStrokeBezierPath: textBP,
          transformedBy: AffineTransform (),
          clippedBy: cocoaBoardRect,
          width: width,
          layers: layer
        )
      }
    }
  }

  //································································································

  @MainActor private mutating func appendLegendLines (projectRoot inProjectRoot : ProjectRoot) {
    let cocoaBoardRect = inProjectRoot.boardBoundBox!.cocoaRect
    for object in inProjectRoot.mBoardObjects.values {
      if let line = object as? BoardLine {
        let p1 = CanariPoint (x: line.mX1, y: line.mY1).cocoaPoint
        let p2 = CanariPoint (x: line.mX2, y: line.mY2).cocoaPoint
        if let (clippedP1, clippedP2) = cocoaBoardRect.clippedSegment(p1: p1, p2: p2) {
          let width = ProductLength (valueInCanariUnit: line.mWidth)
          let layer : ProductLayerSet
          switch line.mLayer {
          case .legendFront :
            layer = .frontSideLegendLine
          case .legendBack :
            layer = .backSideLegendLine
          }
          let oblong = LayeredProductSegment (
            p1: ProductPoint (cocoaPoint: clippedP1),
            p2: ProductPoint (cocoaPoint: clippedP2),
            width: width,
            layers: layer
          )
          self.roundSegments.append (oblong)
        }
      }
    }
  }

  //································································································

  @MainActor private mutating func appendVias (projectRoot inProjectRoot : ProjectRoot) {
    for object in inProjectRoot.mBoardObjects.values {
      if let via = object as? BoardConnector, let isVia = via.isVia, isVia {
        let center = ProductPoint (canariPoint: via.location!)
        let padDiameter = ProductLength (valueInCanariUnit: via.actualPadDiameter!)
        let holeDiameter = ProductLength (valueInCanariUnit: via.actualHoleDiameter!)
        let pad = LayeredProductCircle (
          center: center,
          diameter: padDiameter,
          layers: .viaPad
        )
        self.circles.append (pad)
        let hole = LayeredProductCircle (
          center: center,
          diameter: holeDiameter,
          layers: .hole
        )
        self.circles.append (hole)
      }
    }
  }

  //································································································

  @MainActor private mutating func appendPads (projectRoot inProjectRoot : ProjectRoot) {
    for object in inProjectRoot.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
        //--- Handle master pad
          let layers = masterPad.style.layers (component.mSide)
          self.appendPad (
            center: masterPad.center,
            padSize: masterPad.padSize,
            shape: masterPad.shape,
            transformedBy: af,
            layers: layers
          )
          if masterPad.style == .traversing {
            self.appendPadHole (center: masterPad.center, holeSize: masterPad.holeSize, transformedBy: af)
          }
        //--- Handle slave pads
          for slavePad in masterPad.slavePads {
            let layers = slavePad.style.layers (component.mSide)
            self.appendPad (
              center: slavePad.center,
              padSize: slavePad.padSize,
              shape: slavePad.shape,
              transformedBy: af,
              layers: layers
            )
            if slavePad.style == .traversing {
              self.appendPadHole (center: slavePad.center, holeSize: slavePad.holeSize, transformedBy: af)
            }
          }
        }
      }
    }
  }

  //································································································

  @MainActor private mutating func appendPad (center inCenter : CanariPoint,
                                              padSize inPadSize : CanariSize,
                                              shape inShape : PadShape,
                                              transformedBy inAT : AffineTransform,
                                              layers inLayers : ProductLayerSet) {
    let center = ProductPoint (canariPoint: inCenter)
    let p = LayeredProductComponentPad (
      xCenter: center.x,
      yCenter: center.y,
      width: ProductLength (valueInCanariUnit: inPadSize.width),
      height: ProductLength (valueInCanariUnit: inPadSize.height),
      af: inAT,
      shape: inShape,
      layers: inLayers
    )
    self.componentPads.append (p)
  }

   //································································································

  @MainActor private mutating func appendPadHole (center inCenter : CanariPoint,
                                                  holeSize inHoleSize : CanariSize,
                                                  transformedBy inAT : AffineTransform) {
    let p = inCenter.cocoaPoint
    let holeSize = inHoleSize.cocoaSize
    if inHoleSize.width < inHoleSize.height { // Vertical oblong
      let p1 = inAT.transform (NSPoint (x: p.x, y: p.y - (holeSize.height - holeSize.width) / 2.0))
      let p2 = inAT.transform (NSPoint (x: p.x, y: p.y + (holeSize.height - holeSize.width) / 2.0))
      let oblong = LayeredProductSegment (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inHoleSize.width),
        layers: .hole
      )
      self.roundSegments.append (oblong)
    }else if inHoleSize.width > inHoleSize.height { // Horizontal oblong
      let p1 = inAT.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
      let p2 = inAT.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
      let oblong = LayeredProductSegment (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inHoleSize.height),
        layers: .hole
      )
      self.roundSegments.append (oblong)
    }else{ // Circular
      let center = ProductPoint (cocoaPoint: inAT.transform (inCenter.cocoaPoint))
      let padDiameter = ProductLength (valueInCanariUnit: inHoleSize.width)
      let pad = LayeredProductCircle (
        center: center,
        diameter: padDiameter,
        layers: .hole
      )
      self.circles.append (pad)
    }
  }

  //································································································

  @MainActor private mutating func appendQRCodePathes (projectRoot inProjectRoot : ProjectRoot) {
    for object in inProjectRoot.mBoardObjects.values {
      if let qrCode = object as? BoardQRCode, let descriptor = qrCode.qrCodeDescriptor {
        let displayInfos = boardQRCode_displayInfos (
          centerX: qrCode.mCenterX,
          centerY: qrCode.mCenterY,
          descriptor,
          frontSide: qrCode.mLayer == .legendFront,
          moduleSizeInCanariUnit: qrCode.mModuleSize,
          rotation: qrCode.mRotation
        )
        let layer : ProductLayerSet
        switch qrCode.mLayer {
        case .legendFront :
          layer = .frontSideQRCode
        case .legendBack :
          layer = .backSideQRCode
        }
        for r in displayInfos.nonRotatedRectangles {
          let center = ProductPoint (cocoaPoint: r.center)
          let size = ProductSize (cocoaSize: r.size)
          let pr = LayeredProductRectangle (
            xCenter: center.x,
            yCenter: center.y,
            width: size.width,
            height: size.height,
            af: displayInfos.affineTransform,
            layers: layer
          )
          self.rectangles.append (pr)
        }
      }
    }
  }

  //································································································

  @MainActor private mutating func appendImagesPathes (projectRoot inProjectRoot : ProjectRoot) {
    for object in inProjectRoot.mBoardObjects.values {
      if let boardImage = object as? BoardImage, let descriptor = boardImage.boardImageCodeDescriptor {
        let displayInfos = boardImage_displayInfos (
          centerX: boardImage.mCenterX,
          centerY: boardImage.mCenterY,
          descriptor,
          frontSide: boardImage.mLayer == .legendFront,
          pixelSizeInCanariUnit: boardImage.mPixelSize,
          rotation: boardImage.mRotation
        )
        let layer : ProductLayerSet
        switch boardImage.mLayer {
        case .legendFront :
          layer = .frontSideImage
        case .legendBack :
          layer = .backSideImage
        }
        for r in displayInfos.nonRotatedRectangles {
          let center = ProductPoint (cocoaPoint: r.center)
          let size = ProductSize (cocoaSize: r.size)
          let pr = LayeredProductRectangle (
            xCenter: center.x,
            yCenter: center.y,
            width: size.width,
            height: size.height,
            af: displayInfos.affineTransform,
            layers: layer
          )
          self.rectangles.append (pr)
        }
      }
    }
  }

  //································································································

  @MainActor private mutating func appendTracks (projectRoot inProjectRoot : ProjectRoot) {
    for object in inProjectRoot.mBoardObjects.values {
      if let track = object as? BoardTrack {
        let width = ProductLength (valueInCanariUnit: track.actualTrackWidth!)
        let layer : ProductLayerSet
        switch track.mSide {
        case .front :
          if track.mAddedToSolderMask_property.propval {
            layer = .frontSideExposedTrack
          }else{
            layer = .frontSideTrack
          }
        case .back :
          if track.mAddedToSolderMask_property.propval {
            layer = .backSideExposedTrack
          }else{
            layer = .backSideTrack
          }
        case .inner1 :
          layer = .inner1Track
        case .inner2 :
          layer = .inner2Track
        case .inner3 :
          layer = .inner3Track
        case .inner4 :
          layer = .inner4Track
        }
        switch track.mEndStyle_property.propval {
        case .round :
          let p1 = ProductPoint (canariPoint: track.mConnectorP1!.location!)
          let p2 = ProductPoint (canariPoint: track.mConnectorP2!.location!)
          let t = LayeredProductSegment (p1: p1, p2: p2, width: width, layers: layer)
          self.roundSegments.append (t)
        case .square :
          let p1 = ProductPoint (canariPoint: track.mConnectorP1!.location!)
          let p2 = ProductPoint (canariPoint: track.mConnectorP2!.location!)
          let t = LayeredProductSegment (p1: p1, p2: p2, width: width, layers: layer)
          self.squareSegments.append (t)
        }
      }
    }
  }

  //································································································

  func roundSegments (forLayers inLayers : ProductLayerSet) -> [LayeredProductSegment] {
    var result = [LayeredProductSegment] ()
    for oblong in self.roundSegments {
      if !oblong.layers.intersection (inLayers).isEmpty {
        result.append (oblong)
      }
    }
    return result
  }

  //································································································

  func circles (forLayers inLayers : ProductLayerSet) -> [LayeredProductCircle] {
    var result = [LayeredProductCircle] ()
    for circle in self.circles {
      if !circle.layers.intersection (inLayers).isEmpty {
        result.append (circle)
      }
    }
    return result
  }

  //································································································

  @MainActor func segmentEntities (_ inUndoManager : UndoManager?,
                        forLayers inLayers : ProductLayerSet) -> EBReferenceArray <SegmentEntity> {
    var result = EBReferenceArray <SegmentEntity> ()
    for roundedSegment in self.roundSegments {
      if !roundedSegment.layers.intersection (inLayers).isEmpty {
        let segment = SegmentEntity (inUndoManager, roundedSegment, endStyle: .round)
        result.append (segment)
      }
    }
    for squareSegment in self.squareSegments {
      if !squareSegment.layers.intersection (inLayers).isEmpty {
        let segment = SegmentEntity (inUndoManager, squareSegment, endStyle: .square)
        result.append (segment)
      }
    }
    return result
  }

  //································································································

  @MainActor func rectangleEntities (_ inUndoManager : UndoManager?,
                        forLayers inLayers : ProductLayerSet) -> EBReferenceArray <RectangleEntity> {
    var result = EBReferenceArray <RectangleEntity> ()
    for rect in self.rectangles {
      if !rect.layers.intersection (inLayers).isEmpty {
        let (origin, points) = rect.gerberPolygon ()
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

  //································································································

  @MainActor func pads (_ inUndoManager : UndoManager?,
                        forLayers inLayers : ProductLayerSet) -> EBReferenceArray <BoardModelPad> {
    var padEntities = EBReferenceArray <BoardModelPad> ()
    for componentPad in self.componentPads {
      if !componentPad.layers.intersection (inLayers).isEmpty {
        let pad = BoardModelPad (inUndoManager)
        let relativeCenter = ProductPoint (x: componentPad.xCenter, y: componentPad.yCenter).cocoaPoint
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

  //································································································

}

//--------------------------------------------------------------------------------------------------

fileprivate extension SegmentEntity {

  //································································································

  convenience init (_ inUndoManager : UndoManager?,
                    _ inProductSegment : LayeredProductSegment,
                    endStyle inEndStyle : TrackEndStyle) {
    self.init (inUndoManager)
    self.x1 = inProductSegment.p1.x.valueInCanariUnit
    self.y1 = inProductSegment.p1.y.valueInCanariUnit
    self.x2 = inProductSegment.p2.x.valueInCanariUnit
    self.y2 = inProductSegment.p2.y.valueInCanariUnit
    self.width = inProductSegment.width.valueInCanariUnit
    self.endStyle = .round
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

fileprivate extension PadStyle {

  //································································································

  func layers (_ inComponentSide : ComponentSide) -> ProductLayerSet {
    switch self {
    case .traversing :
      return [.frontSideComponentPad, .backSideComponentPad, .innerComponentPad]
    case .surface :
      switch inComponentSide {
      case .back :
        return .backSideComponentPad
      case .front :
        return .frontSideComponentPad
      }
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

fileprivate extension SlavePadStyle {

  //································································································

  func layers (_ inComponentSide : ComponentSide) -> ProductLayerSet {
    switch self {
    case .traversing :
      return [.frontSideComponentPad, .backSideComponentPad, .innerComponentPad]
    case .componentSide :
      switch inComponentSide {
      case .back :
        return .backSideComponentPad
      case .front :
        return .frontSideComponentPad
      }
    case .oppositeSide :
      switch inComponentSide {
      case .front :
        return .backSideComponentPad
      case .back :
        return .frontSideComponentPad
      }
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
