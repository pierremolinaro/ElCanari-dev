//
//  ProjectDocument-build-product-data.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

typealias PathApertureDictionary = [CGFloat : [EBLinePath]]

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildProductData () -> ProductData {
    let cocoaBoardRect = self.rootObject.boardBoundBox!.cocoaRect
    let (frontPackageLegend, backPackageLegend) = self.buildPackageLegend (cocoaBoardRect)
    let (frontComponentNames, backComponentNames) = self.buildComponentNamePathes (cocoaBoardRect)
    let (frontComponentValues, backComponentValues) = self.buildComponentValuePathes (cocoaBoardRect)
    let (legendFrontTexts, layoutFrontTexts, layoutBackTexts, legendBackTexts) = self.buildTextPathes (cocoaBoardRect)
    let (legendFrontQRCodes, legendBackQRCodes) = self.buildQRCodePathes ()
    let (legendFrontImages, legendBackImages) = self.buildBoardImagesPathes ()
    let viaPads = self.buildViaPads ()
    let (tracks, frontTracksWithNoSilkScreen, backTracksWithNoSilkScreen) = self.buildTracks ()
    let (frontLines, backLines) = self.buildLines (cocoaBoardRect)
    let circularPads = self.buildCircularPads ()
    let oblongPads = self.buildOblongPads ()
    let polygonPads = self.buildPolygonPads ()
  //---
    return ProductData (
      boardBoundBox: cocoaBoardRect,
      boardLimitPath: self.buildBoardLimitPath (),
      boardLimitWidth: canariUnitToCocoa (self.rootObject.mBoardLimitsWidth),
      holeDictionary: self.buildHoleDictionary (),
      frontPackageLegend: frontPackageLegend,
      backPackageLegend: backPackageLegend,
      frontComponentNames: frontComponentNames,
      backComponentNames: backComponentNames,
      frontComponentValues: frontComponentValues,
      backComponentValues: backComponentValues,
      legendFrontTexts: legendFrontTexts,
      layoutFrontTexts: layoutFrontTexts,
      layoutBackTexts: layoutBackTexts,
      legendBackTexts: legendBackTexts,
      legendFrontQRCodes: legendFrontQRCodes,
      legendBackQRCodes: legendBackQRCodes,
      legendFrontImages: legendFrontImages,
      legendBackImages: legendBackImages,
      viaPads: viaPads,
      tracks: tracks,
      frontTracksWithNoSilkScreen: frontTracksWithNoSilkScreen,
      backTracksWithNoSilkScreen: backTracksWithNoSilkScreen,
      frontLines: frontLines,
      backLines: backLines,
      circularPads: circularPads,
      oblongPads: oblongPads,
      polygonPads: polygonPads
    )
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildBoardLimitPath () -> EBLinePath {
    var retainedBP = EBBezierPath ()
    switch self.rootObject.mBoardShape {
    case .bezierPathes :
      var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
      for curve in self.rootObject.mBorderCurves.values {
        let descriptor = curve.descriptor!
        curveDictionary [descriptor.p1] = descriptor
      }
      var descriptor = self.rootObject.mBorderCurves [0].descriptor!
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
      bp.lineWidth = canariUnitToCocoa (self.rootObject.mBoardLimitsWidth + self.rootObject.mBoardClearance * 2)
      let strokeBP = bp.pathToFillByStroking
      var closedPathCount = 0
      let retainedClosedPath = 2
      var points = [NSPoint] (repeating: .zero, count: 3)
      for i in 0 ..< strokeBP.nsBezierPath.elementCount {
        let type = strokeBP.nsBezierPath.element (at: i, associatedPoints: &points)
        switch type {
        case .moveTo:
          // Swift.print ("  moveTo: \(points[0].x) \(points[0].y)")
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
    case .rectangular :
      let width = canariUnitToCocoa (self.rootObject.mRectangularBoardWidth)
      let height = canariUnitToCocoa (self.rootObject.mRectangularBoardHeight)
      retainedBP.move (to : NSPoint (x: 0.0, y: 0.0))
      retainedBP.line (to : NSPoint (x: 0.0, y: height))
      retainedBP.line (to : NSPoint (x: width, y: height))
      retainedBP.line (to : NSPoint (x: width, y: 0.0))
      retainedBP.close ()
    }
    return retainedBP.linePathesByFlattening (withFlatness: 0.1) [0]
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func buildHoleDictionary () -> [CGFloat : [(NSPoint, NSPoint)]] {
    var result = [CGFloat : [(NSPoint, NSPoint)]] ()
    for object in self.rootObject.mBoardObjects.values {
      if let connector = object as? BoardConnector, let isVia = connector.isVia, isVia {
        let p = connector.location!.cocoaPoint
        let hd = canariUnitToCocoa (connector.actualHoleDiameter!)
        result [hd] = result [hd, default: []] + [(p, p)]
      }else if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          switch masterPad.style {
          case .traversing :
            let p = masterPad.center.cocoaPoint
            let holeSize = masterPad.holeSize.cocoaSize
            if masterPad.holeSize.width < masterPad.holeSize.height { // Vertical oblong
              let p1 = af.transform (NSPoint (x: p.x, y: p.y - (holeSize.height - holeSize.width) / 2.0))
              let p2 = af.transform (NSPoint (x: p.x, y: p.y + (holeSize.height - holeSize.width) / 2.0))
              let s = canariUnitToCocoa (masterPad.holeSize.width)
              result [s] = result [s, default: []] + [(p1, p2)]
            }else if masterPad.holeSize.width > masterPad.holeSize.height { // Horizontal oblong
              let p1 = af.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
              let p2 = af.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
              let s = canariUnitToCocoa (masterPad.holeSize.height)
              result [s] = result [s, default: []] + [(p1, p2)]
            }else{ // Circular
              let pp = af.transform (p)
              let s = canariUnitToCocoa (masterPad.holeSize.width)
              result [s] = result [s, default: []] + [(pp, pp)]
            }
          case .surface :
            ()
          }
          for slavePad in masterPad.slavePads {
            switch slavePad.style {
            case .traversing :
              let p = slavePad.center.cocoaPoint
              let holeSize = slavePad.holeSize.cocoaSize
              if slavePad.holeSize.width < slavePad.holeSize.height { // Vertical oblong
                let p1 = af.transform (NSPoint (x: p.x, y: p.y - (holeSize.height - holeSize.width) / 2.0))
                let p2 = af.transform (NSPoint (x: p.x, y: p.y + (holeSize.height - holeSize.width) / 2.0))
                let s = canariUnitToCocoa (slavePad.holeSize.width)
                result [s] = result [s, default: []] + [(p1, p2)]
              }else if slavePad.holeSize.width > slavePad.holeSize.height { // Horizontal oblong
                let p1 = af.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
                let p2 = af.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
                let s = canariUnitToCocoa (slavePad.holeSize.height)
                result [s] = result [s, default: []] + [(p1, p2)]
              }else{ // Circular
                let pp = af.transform (p)
                let s = canariUnitToCocoa (slavePad.holeSize.width)
                result [s] = result [s, default: []] + [(pp, pp)]
              }
            case .oppositeSide, .componentSide :
              ()
            }
          }
        }
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildPackageLegend (_ inCocoaBoardRect : NSRect) -> (PathApertureDictionary, PathApertureDictionary) {
    var frontPackageLegends = PathApertureDictionary () // Aperture, path
    var backPackageLegends = PathApertureDictionary () // Aperture, path
    let aperture = CGFloat (self.rootObject.packageDrawingWidthMultpliedByTenForBoard) / 10.0
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject, component.mDisplayLegend {
        let strokeBezierPath = component.strokeBezierPath!
        if !strokeBezierPath.isEmpty {
          let pathArray = strokeBezierPath.linePathesByFlattening (withFlatness: 0.1)
          let af = component.packageToComponentAffineTransform ()
          var transformedPathArray = [EBLinePath] ()
          for linePath in pathArray {
            let transformedLinePath = linePath.transformed (by: af)
            transformedPathArray += transformedLinePath.linePathClipped (by: inCocoaBoardRect)
          }
          switch component.mSide {
          case .back :
            backPackageLegends [aperture] = backPackageLegends [aperture, default: []] + transformedPathArray
          case .front :
            frontPackageLegends [aperture] = frontPackageLegends [aperture, default: []] + transformedPathArray
          }
        }
      }
    }
    return (frontPackageLegends, backPackageLegends)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildComponentNamePathes (_ inCocoaBoardRect : NSRect) -> (PathApertureDictionary, PathApertureDictionary) {
    var frontComponentNames = PathApertureDictionary () // Aperture, path
    var backComponentNames = PathApertureDictionary () // Aperture, path
    for object in self.rootObject.mBoardObjects.values {
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
          let aperture = textBP.lineWidth
          let pathArray = textBP.linePathesByFlattening (withFlatness: 0.1).linePathArrayClipped (by: inCocoaBoardRect)
          switch component.mSide {
          case .back :
            backComponentNames [aperture] = backComponentNames [aperture, default: []] + pathArray
          case .front :
            frontComponentNames [aperture] = frontComponentNames [aperture, default: []] + pathArray
          }
        }
      }
    }
    return (frontComponentNames, backComponentNames)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildComponentValuePathes (_ inCocoaBoardRect : NSRect) -> (PathApertureDictionary, PathApertureDictionary) {
    var frontComponentValues = PathApertureDictionary () // Aperture, path
    var backComponentValues = PathApertureDictionary () // Aperture, path
    for object in self.rootObject.mBoardObjects.values {
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
          let aperture = textBP.lineWidth
          let pathArray = textBP.linePathesByFlattening (withFlatness: 0.1).linePathArrayClipped (by: inCocoaBoardRect)
          switch component.mSide {
          case .back :
            backComponentValues [aperture] = backComponentValues [aperture, default: []] + pathArray
          case .front :
            frontComponentValues [aperture] = frontComponentValues [aperture, default: []] + pathArray
          }
        }
      }
    }
    return (frontComponentValues, backComponentValues)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildTextPathes (_ inCocoaBoardRect : NSRect) -> (PathApertureDictionary, PathApertureDictionary, PathApertureDictionary, PathApertureDictionary) {
    var legendFrontTexts = PathApertureDictionary () // Aperture, path
    var layoutFrontTexts = PathApertureDictionary () // Aperture, path
    var layoutBackTexts = PathApertureDictionary () // Aperture, path
    var legendBackTexts = PathApertureDictionary () // Aperture, path
    for object in self.rootObject.mBoardObjects.values {
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
        let aperture = textBP.lineWidth
        let pathArray = textBP.linePathesByFlattening (withFlatness: 0.1).linePathArrayClipped (by: inCocoaBoardRect)
        switch text.mLayer {
        case .legendFront :
          legendFrontTexts [aperture] = legendFrontTexts [aperture, default: []] + pathArray
        case .layoutFront :
          layoutFrontTexts [aperture] = layoutFrontTexts [aperture, default: []] + pathArray
        case .layoutBack :
          layoutBackTexts [aperture] = layoutBackTexts [aperture, default: []] + pathArray
        case .legendBack :
          legendBackTexts [aperture] = legendBackTexts [aperture, default: []] + pathArray
        }
      }
    }
    return (legendFrontTexts, layoutFrontTexts, layoutBackTexts, legendBackTexts)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildBoardImagesPathes () -> ([ProductRectangle], [ProductRectangle]) {
    var legendFront = [ProductRectangle] ()
    var legendBack = [ProductRectangle] ()
    for object in self.rootObject.mBoardObjects.values {
      if let boardImage = object as? BoardImage, let descriptor = boardImage.boardImageCodeDescriptor {
        let displayInfos = boardImage_displayInfos (
          centerX: boardImage.mCenterX,
          centerY: boardImage.mCenterY,
          descriptor,
          frontSide: boardImage.mLayer == .legendFront,
          pixelSizeInCanariUnit: boardImage.mPixelSize,
          rotation: boardImage.mRotation
        )
        let rectangles = displayInfos.productRectangles
        switch boardImage.mLayer {
        case .legendFront :
          legendFront += rectangles
        case .legendBack :
          legendBack += rectangles
        }
      }
    }
    return (legendFront, legendBack)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildQRCodePathes () -> ([ProductRectangle], [ProductRectangle]) {
    var legendFront = [ProductRectangle] ()
    var legendBack = [ProductRectangle] ()
    for object in self.rootObject.mBoardObjects.values {
      if let qrCode = object as? BoardQRCode, let descriptor = qrCode.qrCodeDescriptor {
        let displayInfos = boardQRCode_displayInfos (
          centerX: qrCode.mCenterX,
          centerY: qrCode.mCenterY,
          descriptor,
          frontSide: qrCode.mLayer == .legendFront,
          moduleSizeInCanariUnit: qrCode.mModuleSize,
          rotation: qrCode.mRotation
        )
        let rectangles = displayInfos.productRectangles
        switch qrCode.mLayer {
        case .legendFront :
          legendFront += rectangles
        case .legendBack :
          legendBack += rectangles
        }
      }
    }
    return (legendFront, legendBack)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildViaPads () -> [ProductCircle] { // Center, diameter
    var result = [ProductCircle] ()
    for object in self.rootObject.mBoardObjects.values {
      if let via = object as? BoardConnector, let isVia = via.isVia, isVia {
        let p = via.location!.cocoaPoint
        let padDiameter = canariUnitToCocoa (via.actualPadDiameter!)
        result.append (ProductCircle (center: p, diameter: padDiameter))
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildTracks () -> ([TrackSide : [ProductLine]], [ProductLine], [ProductLine]) {
    var frontTracksWithNoSilkScreen = [ProductLine] ()
    var backTracksWithNoSilkScreen = [ProductLine] ()
    var tracks = [TrackSide : [ProductLine]] ()
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        let p1 = track.mConnectorP1!.location!.cocoaPoint
        let p2 = track.mConnectorP2!.location!.cocoaPoint
        let width = canariUnitToCocoa (track.actualTrackWidth!)
        let t = ProductLine (p1: p1, p2: p2, width: width, endStyle: track.mEndStyle_property.cocoaValue)
        tracks [track.mSide] = tracks [track.mSide, default: []] + [t]
        if track.mAddedToSolderMask_property.propval {
          if track.mSide == .front {
            frontTracksWithNoSilkScreen.append (t)
          }else if track.mSide == .back {
            backTracksWithNoSilkScreen.append (t)
          }
        }
      }
    }
    return (tracks, frontTracksWithNoSilkScreen, backTracksWithNoSilkScreen)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildLines (_ inCocoaBoardRect : NSRect) -> ([ProductLine], [ProductLine]) {
    var frontLines = [ProductLine] ()
    var backLines = [ProductLine] ()
    for object in self.rootObject.mBoardObjects.values {
      if let line = object as? BoardLine {
        let p1 = CanariPoint (x: line.mX1, y: line.mY1).cocoaPoint
        let p2 = CanariPoint (x: line.mX2, y: line.mY2).cocoaPoint
        if let (clippedP1, clippedP2) = inCocoaBoardRect.clippedSegment(p1: p1, p2: p2) {
          let width = canariUnitToCocoa (line.mWidth)
          let t = ProductLine (p1: clippedP1, p2: clippedP2, width: width, endStyle: .round)
          switch line.mLayer {
          case .legendBack :
            backLines.append (t)
          case .legendFront :
            frontLines.append (t)
          }
        }
      }
    }
    return (frontLines, backLines)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func buildCircularPads () -> [PadLayer : [ProductCircle]] {
    var circularPads = [PadLayer : [ProductCircle]] ()
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let circle = productCircle (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              circularPads [.frontLayer] = circularPads [.frontLayer, default: []] + [circle]
              circularPads [.innerLayer] = circularPads [.innerLayer, default: []] + [circle]
              circularPads [.backLayer] = circularPads [.backLayer, default: []] + [circle]
            case .surface :
              switch component.mSide {
              case .back :
                circularPads [.backLayer] = circularPads [.backLayer, default: []] + [circle]
              case .front :
                circularPads [.frontLayer] = circularPads [.frontLayer, default: []] + [circle]
              }
            }
          }
          for slavePad in masterPad.slavePads {
            if let circle = productCircle (slavePad.center, slavePad.padSize, slavePad.shape, af) {
              switch slavePad.style {
              case .traversing :
                circularPads [.frontLayer] = circularPads [.frontLayer, default: []] + [circle]
                circularPads [.innerLayer] = circularPads [.innerLayer, default: []] + [circle]
                circularPads [.backLayer] = circularPads [.backLayer, default: []] + [circle]
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  circularPads [.backLayer] = circularPads [.backLayer, default: []] + [circle]
                case .back :
                  circularPads [.frontLayer] = circularPads [.frontLayer, default: []] + [circle]
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  circularPads [.backLayer] = circularPads [.backLayer, default: []] + [circle]
                case .front :
                  circularPads [.frontLayer] = circularPads [.frontLayer, default: []] + [circle]
                }
              }
            }
          }
        }
      }
    }
    return circularPads
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func buildOblongPads () -> [PadLayer : [ProductLine]] {
    var oblongPads = [PadLayer : [ProductLine]] ()
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let oblong = oblong (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              oblongPads [.frontLayer] = oblongPads [.frontLayer, default: []] + [oblong]
              oblongPads [.innerLayer] = oblongPads [.innerLayer, default: []] + [oblong]
              oblongPads [.backLayer] = oblongPads [.backLayer, default: []] + [oblong]
            case .surface :
              switch component.mSide {
              case .back :
                oblongPads [.backLayer] = oblongPads [.backLayer, default: []] + [oblong]
              case .front :
                oblongPads [.frontLayer] = oblongPads [.frontLayer, default: []] + [oblong]
              }
            }
          }
          for slavePad in masterPad.slavePads {
            if let oblong = oblong (slavePad.center, slavePad.padSize, slavePad.shape, af) {
              switch slavePad.style {
              case .traversing :
                oblongPads [.frontLayer] = oblongPads [.frontLayer, default: []] + [oblong]
                oblongPads [.innerLayer] = oblongPads [.innerLayer, default: []] + [oblong]
                oblongPads [.backLayer] = oblongPads [.backLayer, default: []] + [oblong]
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  oblongPads [.backLayer] = oblongPads [.backLayer, default: []] + [oblong]
                case .back :
                  oblongPads [.frontLayer] = oblongPads [.frontLayer, default: []] + [oblong]
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  oblongPads [.backLayer] = oblongPads [.backLayer, default: []] + [oblong]
                case .front :
                  oblongPads [.frontLayer] = oblongPads [.frontLayer, default: []] + [oblong]
                }
              }
            }
          }
        }
      }
    }
    return oblongPads
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func buildPolygonPads () -> [PadLayer : [ProductPolygon]] {
    var polygonPads = [PadLayer : [ProductPolygon]] ()
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let polygon = buildPolygon (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              polygonPads [.frontLayer] = polygonPads [.frontLayer, default: []] + [polygon]
              polygonPads [.innerLayer] = polygonPads [.innerLayer, default: []] + [polygon]
              polygonPads [.backLayer] = polygonPads [.backLayer, default: []] + [polygon]
            case .surface :
              switch component.mSide {
              case .back :
                polygonPads [.backLayer] = polygonPads [.backLayer, default: []] + [polygon]
              case .front :
                polygonPads [.frontLayer] = polygonPads [.frontLayer, default: []] + [polygon]
              }
            }
          }
          for slavePad in masterPad.slavePads {
           if let polygon = buildPolygon (slavePad.center, slavePad.padSize, slavePad.shape, af) {
             switch slavePad.style {
              case .traversing :
                polygonPads [.frontLayer] = polygonPads [.frontLayer, default: []] + [polygon]
                polygonPads [.innerLayer] = polygonPads [.innerLayer, default: []] + [polygon]
                polygonPads [.backLayer] = polygonPads [.backLayer, default: []] + [polygon]
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  polygonPads [.backLayer] = polygonPads [.backLayer, default: []] + [polygon]
                case .back :
                  polygonPads [.frontLayer] = polygonPads [.frontLayer, default: []] + [polygon]
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  polygonPads [.backLayer] = polygonPads [.backLayer, default: []] + [polygon]
                case .front :
                  polygonPads [.frontLayer] = polygonPads [.frontLayer, default: []] + [polygon]
                }
              }
            }
          }
        }
      }
    }
    return polygonPads
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func productCircle (_ inCenter : CanariPoint,
                                _ inPadSize : CanariSize,
                                _ inShape : PadShape,
                                _ inAffineTransform : AffineTransform) -> ProductCircle? {
  switch inShape {
  case .rect, .octo :
    return nil
  case .round :
    if inPadSize.width == inPadSize.height { // Circular
      let p = inAffineTransform.transform (inCenter.cocoaPoint)
      let d = canariUnitToCocoa (inPadSize.width)
      return ProductCircle (center: p, diameter: d)
    }else{
      return nil
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func buildPolygon (_ inCenter : CanariPoint,
                               _ inPadSize : CanariSize,
                               _ inShape : PadShape,
                               _ inAffineTransform : AffineTransform) -> ProductPolygon? {
  switch inShape {
  case .rect :
    let p = inCenter.cocoaPoint
    let padSize = inPadSize.cocoaSize
    let w = padSize.width / 2.0
    let h = padSize.height / 2.0
    let p0 = inAffineTransform.transform (NSPoint (x: p.x + w, y: p.y + h))
    let p1 = inAffineTransform.transform (NSPoint (x: p.x - w, y: p.y + h))
    let p2 = inAffineTransform.transform (NSPoint (x: p.x - w, y: p.y - h))
    let p3 = inAffineTransform.transform (NSPoint (x: p.x + w, y: p.y - h))
    return ProductPolygon (origin: p0, points: [p1, p2, p3])
  case .octo :
    let padSize = inPadSize.cocoaSize
    let w : CGFloat = padSize.width / 2.0
    let h : CGFloat = padSize.height / 2.0
    let p = inCenter.cocoaPoint
    let lg : CGFloat = min (w, h) / (1.0 + 1.0 / sqrt (2.0))
    let p0 = inAffineTransform.transform (NSPoint (x: p.x + w - lg, y: p.y + h))
    let p1 = inAffineTransform.transform (NSPoint (x: p.x + w,      y: p.y + h - lg))
    let p2 = inAffineTransform.transform (NSPoint (x: p.x + w,      y: p.y - h + lg))
    let p3 = inAffineTransform.transform (NSPoint (x: p.x + w - lg, y: p.y - h))
    let p4 = inAffineTransform.transform (NSPoint (x: p.x - w + lg, y: p.y - h))
    let p5 = inAffineTransform.transform (NSPoint (x: p.x - w,      y: p.y - h + lg))
    let p6 = inAffineTransform.transform (NSPoint (x: p.x - w,      y: p.y + h - lg))
    let p7 = inAffineTransform.transform (NSPoint (x: p.x - w + lg, y: p.y + h))
    return ProductPolygon (origin: p0, points: [p1, p2, p3, p4, p5, p6, p7])
  case .round :
    return nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func oblong (_ inCenter : CanariPoint,
                         _ inPadSize : CanariSize,
                         _ inShape : PadShape,
                         _ inAffineTransform : AffineTransform) -> ProductLine? {
  switch inShape {
  case .rect, .octo :
    return nil
  case .round :
    let p = inCenter.cocoaPoint
    let padSize = inPadSize.cocoaSize
    if inPadSize.width < inPadSize.height { // Vertical oblong
      let p1 = inAffineTransform.transform (NSPoint (x: p.x, y: p.y - (padSize.height - padSize.width) / 2.0))
      let p2 = inAffineTransform.transform (NSPoint (x: p.x, y: p.y + (padSize.height - padSize.width) / 2.0))
      let w = canariUnitToCocoa (inPadSize.width)
      return ProductLine (p1: p1, p2: p2, width: w, endStyle: .round)
    }else if inPadSize.width > inPadSize.height { // Horizontal oblong
      let p1 = inAffineTransform.transform (NSPoint (x: p.x - (padSize.width - padSize.height) / 2.0, y: p.y))
      let p2 = inAffineTransform.transform (NSPoint (x: p.x + (padSize.width - padSize.height) / 2.0, y: p.y))
      let w = canariUnitToCocoa (inPadSize.height)
      return ProductLine (p1: p1, p2: p2, width: w, endStyle: .round)
    }else{ // Circular
      return nil
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductLine { // All in Cocoa Unit
  let p1 : NSPoint
  let p2 : NSPoint
  let width : CGFloat
  let endStyle : EndStyle

  //------------------------------------------------------------------------------------------------

  var lineCapStyle : NSBezierPath.LineCapStyle {
    switch self.endStyle {
    case .round : return .round
    case .square : return .square
    }
  }

  //------------------------------------------------------------------------------------------------

  var endStyleIntValue : Int {
    switch self.endStyle {
    case .round : return 0
    case .square : return 1
    }
  }

  //------------------------------------------------------------------------------------------------

  public enum EndStyle {
    case round
    case square
  }

  //------------------------------------------------------------------------------------------------
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension EBStoredProperty_TrackEndStyle {

  //------------------------------------------------------------------------------------------------

  var cocoaValue : ProductLine.EndStyle {
    switch self.propval {
    case .round : return .round
    case .square : return .square
    }
  }

  //------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductCircle { // All in Cocoa Unit
  let center : NSPoint
  let diameter : CGFloat
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductPolygon { // All in Cocoa Unit
  let origin : NSPoint
  let points : [NSPoint]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func transformed (by inAffineTransform : AffineTransform) -> ProductPolygon {
    let to = inAffineTransform.transform (self.origin)
    var tps = [NSPoint] ()
    for p in self.points {
      tps.append (inAffineTransform.transform (p))
    }
    return ProductPolygon (origin: to, points: tps)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductRectangle : Hashable { // All in Cocoa Unit
  let p0 : NSPoint
  let p1 : NSPoint
  let p2 : NSPoint
  let p3 : NSPoint

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func transformed (by inAffineTransform : AffineTransform) -> ProductRectangle {
//    let tp0 = inAffineTransform.transform (self.p0)
//    let tp1 = inAffineTransform.transform (self.p1)
//    let tp2 = inAffineTransform.transform (self.p2)
//    let tp3 = inAffineTransform.transform (self.p3)
//    return ProductRectangle (p0: tp0, p1: tp1, p2: tp2, p3: tp3)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var polygon : ProductPolygon { ProductPolygon (origin: self.p0, points: [self.p1, self.p2, self.p3]) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

typealias MergerRectangleArray = [ProductRectangle]

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == ProductRectangle {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var polygons : [ProductPolygon] {
    var result = [ProductPolygon] ()
    for rect in self {
      result.append (rect.polygon)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bezierPathArray : [EBBezierPath] {
    var result = [EBBezierPath] ()
    for rect in self {
      var bp = EBBezierPath ()
      bp.move (to: rect.p0)
      bp.line (to: rect.p1)
      bp.line (to: rect.p2)
      bp.line (to: rect.p3)
      bp.close ()
      result.append (bp)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func convertToCanari (cocoaPoint inPoint : NSPoint,
                                dx inDx : Int,
                                dy inDy: Int,
                                modelWidth inModelWidth : Int,
                                modelHeight inModelHeight : Int,
                                instanceRotation inInstanceRotation : QuadrantRotation) -> CanariPoint {
    var x = inDx
    var y = inDy
    let cocoaP = inPoint.canariPoint
    switch inInstanceRotation {
    case .rotation0 :
      x += cocoaP.x
      y += cocoaP.y
    case .rotation90 :
      x += inModelHeight - cocoaP.y
      y += cocoaP.x
    case .rotation180 :
      x += inModelWidth  - cocoaP.x
      y += inModelHeight - cocoaP.y
    case .rotation270 :
      x += cocoaP.y
      y += inModelWidth - cocoaP.x
    }
    return CanariPoint (x: x, y: y)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func add (toArchiveArray ioArchiveArray : inout [String],
            dx inDx : Int,
            dy inDy: Int,
            modelWidth inModelWidth : Int,
            modelHeight inModelHeight : Int,
            instanceRotation inInstanceRotation : QuadrantRotation) {
    for rect in self {
      let p0 = self.convertToCanari (
        cocoaPoint : rect.p0,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p1 = self.convertToCanari (
        cocoaPoint : rect.p1,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p2 = self.convertToCanari (
        cocoaPoint : rect.p2,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p3 = self.convertToCanari (
        cocoaPoint : rect.p3,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let s = "\(p0.x):\(p0.y):\(p1.x):\(p1.y):\(p2.x):\(p2.y):\(p3.x):\(p3.y)"
      ioArchiveArray.append (s)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addRectangles (toFilledBezierPaths ioBezierPaths : inout [EBBezierPath],
                      dx inDx : Int,
                      dy inDy: Int,
                      horizontalMirror inHorizontalMirror : Bool,
                      boardWidth inBoardWidth : Int,
                      modelWidth inModelWidth : Int,
                      modelHeight inModelHeight : Int,
                      instanceRotation inInstanceRotation : QuadrantRotation) {
    for rect in self {
      let cP0 = self.convertToCanari (
        cocoaPoint : rect.p0,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p0 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP0.x) : cP0.x, y: cP0.y).cocoaPoint
      let cP1 = self.convertToCanari (
        cocoaPoint : rect.p1,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p1 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP1.x) : cP1.x, y: cP1.y).cocoaPoint
      let cP2 = self.convertToCanari (
        cocoaPoint : rect.p2,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p2 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP2.x) : cP2.x, y: cP2.y).cocoaPoint
      let cP3 = self.convertToCanari (
        cocoaPoint : rect.p3,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p3 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP3.x) : cP3.x, y: cP3.y).cocoaPoint
      var bp = EBBezierPath ()
      bp.move (to: p0)
      bp.line (to: p1)
      bp.line (to: p2)
      bp.line (to: p3)
      bp.close ()
      ioBezierPaths.append (bp)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addPolygons (toPolygons ioPolygons : inout [[String]],
                    dx inDx : Int,
                    dy inDy: Int,
                    horizontalMirror inHorizontalMirror : Bool,
                    boardWidth inBoardWidth : Int,
                    modelWidth inModelWidth : Int,
                    modelHeight inModelHeight : Int,
                    instanceRotation inInstanceRotation : QuadrantRotation) {
    // Swift.print ("GERBER: \(self.padArray.count)")
    for rect in self {
      let cP0 = self.convertToCanari (
        cocoaPoint : rect.p0,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p0 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP0.x) : cP0.x, y: cP0.y).milTenthPoint
      let cP1 = self.convertToCanari (
        cocoaPoint : rect.p1,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p1 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP1.x) : cP1.x, y: cP1.y).milTenthPoint
      let cP2 = self.convertToCanari (
        cocoaPoint : rect.p2,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p2 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP2.x) : cP2.x, y: cP2.y).milTenthPoint
      let cP3 = self.convertToCanari (
        cocoaPoint : rect.p3,
        dx: inDx,
        dy: inDy,
        modelWidth: inModelWidth,
        modelHeight: inModelHeight,
        instanceRotation: inInstanceRotation
      )
      let p3 = CanariPoint (x: inHorizontalMirror ? (inBoardWidth - cP3.x) : cP3.x, y: cP3.y).milTenthPoint
      var drawings = [String] ()
      drawings.append ("X\(Int (p0.x))Y\(Int (p0.y))D02") // Move to
      drawings.append ("X\(Int (p1.x))Y\(Int (p1.y))D01") // Line to
      drawings.append ("X\(Int (p2.x))Y\(Int (p2.y))D01") // Line to
      drawings.append ("X\(Int (p3.x))Y\(Int (p3.y))D01") // Line to
      drawings.append ("X\(Int (p0.x))Y\(Int (p0.y))D01") // Line to
      ioPolygons.append (drawings)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

enum PadLayer {
  case frontLayer
  case innerLayer
  case backLayer
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductData { // All in Cocoa Unit
  let boardBoundBox : NSRect
  let boardLimitPath : EBLinePath
  let boardLimitWidth : CGFloat
  let holeDictionary : [CGFloat : [(NSPoint, NSPoint)]]
  let frontPackageLegend : PathApertureDictionary
  let backPackageLegend :  PathApertureDictionary
  let frontComponentNames : PathApertureDictionary
  let backComponentNames:  PathApertureDictionary
  let frontComponentValues : PathApertureDictionary
  let backComponentValues : PathApertureDictionary
  let legendFrontTexts : PathApertureDictionary
  let layoutFrontTexts : PathApertureDictionary
  let layoutBackTexts : PathApertureDictionary
  let legendBackTexts : PathApertureDictionary
  let legendFrontQRCodes : [ProductRectangle]
  let legendBackQRCodes : [ProductRectangle]
  let legendFrontImages : [ProductRectangle]
  let legendBackImages : [ProductRectangle]
  let viaPads : [ProductCircle]
  let tracks : [TrackSide : [ProductLine]]
  let frontTracksWithNoSilkScreen : [ProductLine]
  let backTracksWithNoSilkScreen : [ProductLine]
  let frontLines : [ProductLine]
  let backLines : [ProductLine]
  let circularPads : [PadLayer : [ProductCircle]]
  let oblongPads : [PadLayer : [ProductLine]]
  let polygonPads : [PadLayer : [ProductPolygon]]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
