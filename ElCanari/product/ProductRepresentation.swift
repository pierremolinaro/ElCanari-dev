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

  private(set) var boardBox : ProductRect
  private(set) var boardLimitWidth : ProductLength
  private(set) var oblongs = [LayeredProductOblong] ()
  private(set) var circles = [LayeredProductCircle] ()
  private(set) var polygons = [LayeredProductPolygon] ()

  //································································································
  //  Init
  //································································································

  @MainActor init (projectRoot inProjectRoot : ProjectRoot) {
    self.boardBox = ProductRect (canariRect: inProjectRoot.boardBoundBox!)
    self.boardLimitWidth = ProductLength (valueInCanariUnit: inProjectRoot.mBoardLimitsWidth)
  //--- Board limit path
    do{
      var points = inProjectRoot.buildBoardLimitPath ()
      let firstPoint = points [0]
      var currentPoint = firstPoint
      points.removeFirst ()
      for p in points {
        let oblong = LayeredProductOblong (p1: currentPoint, p2: p, width: self.boardLimitWidth, layers: .boardLimits)
        self.oblongs.append (oblong)
        currentPoint = p
      }
      let oblong = LayeredProductOblong (p1: currentPoint, p2: firstPoint, width: self.boardLimitWidth, layers: .boardLimits)
      self.oblongs.append (oblong)
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
  //  Decoding from JSON
  //································································································

  init? (fromJSONData inData : Data) {
    let decoder = JSONDecoder ()
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
      let oblong = LayeredProductOblong (p1: segment.p1, p2: segment.p2, width: inWidth, layers: inLayerSet)
      self.oblongs.append (oblong)
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
            layer = .packageLegendBottomSide
          case .front :
            layer = .packageLegendTopSide
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
            layer = .componentNamesBottomSide
          case .front :
            layer = .componentNamesTopSide
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
            layer = .componentValuesBottomSide
          case .front :
            layer = .componentValuesTopSide
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
          layer = .textsLegendTopSide
        case .layoutFront :
          layer = .textsLayoutTopSide
        case .legendBack :
          layer = .textsLegendBottomSide
        case .layoutBack :
          layer = .textsLayoutBottomSide
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
            layer = .textsLegendTopSide
          case .legendBack :
            layer = .textsLegendBottomSide
          }
          let oblong = LayeredProductOblong (
            p1: ProductPoint (cocoaPoint: clippedP1),
            p2: ProductPoint (cocoaPoint: clippedP2),
            width: width,
            layers: layer
          )
          self.oblongs.append (oblong)
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
          layers: [.padsBottomSide, .padsTopSide]
        )
        self.circles.append (pad)
        let hole = LayeredProductCircle (
          center: center,
          diameter: holeDiameter,
          layers: .padHoles
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
    switch inShape {
    case .round :
      self.appendRoundPad (
        center: inCenter,
        padSize: inPadSize,
        transformedBy: inAT,
        layers: inLayers
      )
    case .rect :
      self.appendRectPad (
        center: inCenter,
        padSize: inPadSize,
        transformedBy: inAT,
        layers: inLayers
      )
    case .octo :
      self.appendOctoPad (
        center: inCenter,
        padSize: inPadSize,
        transformedBy: inAT,
        layers: inLayers
      )
    }
  }

  //································································································

  @MainActor private mutating func appendRoundPad (center inCenter : CanariPoint,
                                                   padSize inPadSize : CanariSize,
                                                   transformedBy inAT : AffineTransform,
                                                   layers inLayers : ProductLayerSet) {
    let p = inCenter.cocoaPoint
    let padSize = inPadSize.cocoaSize
    if inPadSize.width < inPadSize.height { // Vertical oblong
      let p1 = inAT.transform (NSPoint (x: p.x, y: p.y - (padSize.height - padSize.width) / 2.0))
      let p2 = inAT.transform (NSPoint (x: p.x, y: p.y + (padSize.height - padSize.width) / 2.0))
      let oblong = LayeredProductOblong (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inPadSize.width),
        layers: inLayers
      )
      self.oblongs.append (oblong)
    }else if inPadSize.width > inPadSize.height { // Horizontal oblong
      let p1 = inAT.transform (NSPoint (x: p.x - (padSize.width - padSize.height) / 2.0, y: p.y))
      let p2 = inAT.transform (NSPoint (x: p.x + (padSize.width - padSize.height) / 2.0, y: p.y))
      let oblong = LayeredProductOblong (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inPadSize.height),
        layers: inLayers
      )
      self.oblongs.append (oblong)
    }else{ // Circular
      let center = ProductPoint (cocoaPoint: inAT.transform (inCenter.cocoaPoint))
      let padDiameter = ProductLength (valueInCanariUnit: inPadSize.width)
      let pad = LayeredProductCircle (
        center: center,
        diameter: padDiameter,
        layers: inLayers
      )
      self.circles.append (pad)
    }
  }

  //································································································

  @MainActor private mutating func appendRectPad (center inCenter : CanariPoint,
                                                  padSize inPadSize : CanariSize,
                                                  transformedBy inAT : AffineTransform,
                                                  layers inLayers : ProductLayerSet) {
    let p = inCenter.cocoaPoint
    let padSize = inPadSize.cocoaSize
    let w = padSize.width / 2.0
    let h = padSize.height / 2.0
    let p0 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x + w, y: p.y + h)))
    let p1 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x - w, y: p.y + h)))
    let p2 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x - w, y: p.y - h)))
    let p3 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x + w, y: p.y - h)))
    let polygon = LayeredProductPolygon (
      origin: p0,
      points: [p1, p2, p3],
      layers: inLayers
    )
    self.polygons.append (polygon)
  }

  //································································································

  @MainActor private mutating func appendOctoPad (center inCenter : CanariPoint,
                                                  padSize inPadSize : CanariSize,
                                                  transformedBy inAT : AffineTransform,
                                                  layers inLayers : ProductLayerSet) {
    let padSize = inPadSize.cocoaSize
    let w : CGFloat = padSize.width / 2.0
    let h : CGFloat = padSize.height / 2.0
    let p = inCenter.cocoaPoint
    let lg : CGFloat = min (w, h) / (1.0 + 1.0 / sqrt (2.0))
    let p0 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x + w - lg, y: p.y + h)))
    let p1 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x + w,      y: p.y + h - lg)))
    let p2 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x + w,      y: p.y - h + lg)))
    let p3 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x + w - lg, y: p.y - h)))
    let p4 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x - w + lg, y: p.y - h)))
    let p5 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x - w,      y: p.y - h + lg)))
    let p6 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x - w,      y: p.y + h - lg)))
    let p7 = ProductPoint (cocoaPoint: inAT.transform (NSPoint (x: p.x - w + lg, y: p.y + h)))
    let polygon = LayeredProductPolygon (
      origin: p0,
      points: [p1, p2, p3, p4, p5, p6, p7],
      layers: inLayers
    )
    self.polygons.append (polygon)
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
      let oblong = LayeredProductOblong (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inHoleSize.width),
        layers: .padHoles
      )
      self.oblongs.append (oblong)
    }else if inHoleSize.width > inHoleSize.height { // Horizontal oblong
      let p1 = inAT.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
      let p2 = inAT.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
      let oblong = LayeredProductOblong (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inHoleSize.height),
        layers: .padHoles
      )
      self.oblongs.append (oblong)
    }else{ // Circular
      let center = ProductPoint (cocoaPoint: inAT.transform (inCenter.cocoaPoint))
      let padDiameter = ProductLength (valueInCanariUnit: inHoleSize.width)
      let pad = LayeredProductCircle (
        center: center,
        diameter: padDiameter,
        layers: .padHoles
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
          layer = .packageLegendTopSide
        case .legendBack :
          layer = .packageLegendBottomSide
        }
        let rectangles = displayInfos.productRectangles
        for r in rectangles {
          let p0 = ProductPoint (cocoaPoint: r.p0)
          let p1 = ProductPoint (cocoaPoint: r.p1)
          let p2 = ProductPoint (cocoaPoint: r.p2)
          let p3 = ProductPoint (cocoaPoint: r.p3)
          let polygon = LayeredProductPolygon (origin: p0, points: [p1, p2, p3], layers: layer)
          self.polygons.append (polygon)
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
          layer = .packageLegendTopSide
        case .legendBack :
          layer = .packageLegendBottomSide
        }
        let rectangles = displayInfos.productRectangles
        for r in rectangles {
          let p0 = ProductPoint (cocoaPoint: r.p0)
          let p1 = ProductPoint (cocoaPoint: r.p1)
          let p2 = ProductPoint (cocoaPoint: r.p2)
          let p3 = ProductPoint (cocoaPoint: r.p3)
          let polygon = LayeredProductPolygon (origin: p0, points: [p1, p2, p3], layers: layer)
          self.polygons.append (polygon)
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
            layer = .padsTopSide
          }else{
            layer = .tracksTopSide
          }
        case .back :
          if track.mAddedToSolderMask_property.propval {
            layer = .padsBottomSide
          }else{
            layer = .tracksBottomSide
          }
        case .inner1 :
          layer = .tracksInner1Layer
        case .inner2 :
          layer = .tracksInner2Layer
        case .inner3 :
          layer = .tracksInner3Layer
        case .inner4 :
          layer = .tracksInner4Layer
        }
        switch track.mEndStyle_property.propval {
        case .round :
          let p1 = ProductPoint (canariPoint: track.mConnectorP1!.location!)
          let p2 = ProductPoint (canariPoint: track.mConnectorP2!.location!)
          let t = LayeredProductOblong (p1: p1, p2: p2, width: width, layers: layer)
          self.oblongs.append (t)
        case .square :
          let pA = track.mConnectorP1!.location!
          let pB = track.mConnectorP2!.location!
          let w = NSPoint.distance (pA.cocoaPoint, pB.cocoaPoint)
          let h = canariUnitToCocoa (track.actualTrackWidth!)
          let angleInRadian = CanariPoint.angleInRadian (pA, pB)
          var t = Turtle (p: pA.cocoaPoint, angleInRadian: angleInRadian)
          t.rotate270 ()
          t.forward (h / 2.0)
          t.rotate270 ()
          t.forward (w / 2.0)
          t.rotate180 ()
          let p0 = ProductPoint (cocoaPoint: t.location)
          t.forward (w + h)
          let p1 = ProductPoint (cocoaPoint: t.location)
          t.rotate90 ()
          t.forward (h)
          let p2 = ProductPoint (cocoaPoint: t.location)
          t.rotate90 ()
          t.forward (w + h)
          let p3 = ProductPoint (cocoaPoint: t.location)
          let polygon = LayeredProductPolygon (
            origin: p0,
            points: [p1, p2, p3],
            layers: layer
          )
          self.polygons.append (polygon)
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

fileprivate extension PadStyle {

  //································································································

  func layers (_ inComponentSide : ComponentSide) -> ProductLayerSet {
    switch self {
    case .traversing :
      return [.padsBottomSide, .padsTopSide]
    case .surface :
      switch inComponentSide {
      case .back :
        return .padsBottomSide
      case .front :
        return .padsTopSide
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
      return [.padsBottomSide, .padsTopSide]
    case .componentSide :
      switch inComponentSide {
      case .back :
        return .padsBottomSide
      case .front :
        return .padsTopSide
      }
    case .oppositeSide :
      switch inComponentSide {
      case .front :
        return .padsBottomSide
      case .back :
        return .padsTopSide
      }
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

