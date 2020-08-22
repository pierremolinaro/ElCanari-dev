//
//  ProjectDocument-build-product-data.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

typealias PathApertureDictionary = [CGFloat : [EBLinePath]]

//----------------------------------------------------------------------------------------------------------------------

extension ProjectDocument {

  //····················································································································

  internal func buildProductData () -> ProductData {
    let (frontPackageLegend, backPackageLegend) = self.buildPackageLegend ()
    let (frontComponentNames, backComponentNames) = self.buildComponentNamePathes ()
    let (frontComponentValues, backComponentValues) = self.buildComponentValuePathes ()
    let (legendFrontTexts, layoutFrontTexts, layoutBackTexts, legendBackTexts) = self.buildTextPathes ()
    let viaPads = self.buildViaPads ()
    let tracks = self.buildTracks ()
    let (frontLines, backLines) = self.buildLines ()
    let circularPads = self.buildCircularPads ()
    let oblongPads = self.buildOblongPads ()
    let polygonPads = self.buildPolygonPads ()
  //---
    return ProductData (
      boardBoundBox: self.rootObject.boardBoundBox!.cocoaRect,
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
      viaPads: viaPads,
      tracks: tracks,
      frontLines: frontLines,
      backLines: backLines,
      circularPads: circularPads,
      oblongPads: oblongPads,
      polygonPads: polygonPads
    )
  }
  
  //····················································································································

  private func buildBoardLimitPath () -> EBLinePath {
    var retainedBP = EBBezierPath ()
    switch self.rootObject.mBoardShape {
    case .bezierPathes :
      var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
      for curve in self.rootObject.mBorderCurves {
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
      let strokeBP = bp.pathByStroking
      // Swift.print ("BezierPath BEGIN")
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
        @unknown default :
          ()
        }
      }
      //Swift.print ("BezierPath END")
    case .rectangular :
      let width = canariUnitToCocoa (self.rootObject.mRectangularBoardWidth)
      let height = canariUnitToCocoa (self.rootObject.mRectangularBoardHeight)
      retainedBP.move (to : NSPoint (x: 0.0, y: 0.0))
      retainedBP.line (to : NSPoint (x: 0.0, y: height))
      retainedBP.line (to : NSPoint (x: width, y: height))
      retainedBP.line (to : NSPoint (x: width, y: 0.0))
      retainedBP.close ()
    }
    return retainedBP.pointsByFlattening (withFlatness: 0.1) [0]
  }

  //····················································································································

  fileprivate func buildHoleDictionary () -> [CGFloat : [(NSPoint, NSPoint)]] {
    var result = [CGFloat : [(NSPoint, NSPoint)]] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector, let isVia = connector.isVia, isVia {
        let p = connector.location!.cocoaPoint
        let hd = canariUnitToCocoa (connector.actualHoleDiameter!)
        result [hd] = (result [hd] ?? []) + [(p, p)]
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
              result [s] = (result [s] ?? []) + [(p1, p2)]
            }else if masterPad.holeSize.width > masterPad.holeSize.height { // Horizontal oblong
              let p1 = af.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
              let p2 = af.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
              let s = canariUnitToCocoa (masterPad.holeSize.height)
              result [s] = (result [s] ?? []) + [(p1, p2)]
            }else{ // Circular
              let pp = af.transform (p)
              let s = canariUnitToCocoa (masterPad.holeSize.width)
              result [s] = (result [s] ?? []) + [(pp, pp)]
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
                result [s] = (result [s] ?? []) + [(p1, p2)]
              }else if slavePad.holeSize.width > slavePad.holeSize.height { // Horizontal oblong
                let p1 = af.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
                let p2 = af.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
                let s = canariUnitToCocoa (slavePad.holeSize.height)
                result [s] = (result [s] ?? []) + [(p1, p2)]
              }else{ // Circular
                let pp = af.transform (p)
                let s = canariUnitToCocoa (slavePad.holeSize.width)
                result [s] = (result [s] ?? []) + [(pp, pp)]
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

  //····················································································································

  private func buildPackageLegend () -> (PathApertureDictionary, PathApertureDictionary) {
    var frontPackageLegends = PathApertureDictionary () // Aperture, path
    var backPackageLegends = PathApertureDictionary () // Aperture, path
    let aperture = CGFloat (g_Preferences!.packageDrawingWidthMultpliedByTenForBoard) / 10.0
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject, component.mDisplayLegend {
        let strokeBezierPath = component.strokeBezierPath!
        if !strokeBezierPath.isEmpty {
          let pathArray = strokeBezierPath.pointsByFlattening (withFlatness: 0.1)
          let af = component.packageToComponentAffineTransform ()
          var transformedPathArray = [EBLinePath] ()
          for path in pathArray {
            transformedPathArray.append (path.transformed (by: af))
          }
          switch component.mSide {
          case .back :
            backPackageLegends [aperture] = (backPackageLegends [aperture] ?? []) + transformedPathArray
          case .front :
            frontPackageLegends [aperture] = (frontPackageLegends [aperture] ?? []) + transformedPathArray
          }
        }
      }
    }
    return (frontPackageLegends, backPackageLegends)
  }

  //····················································································································

  private func buildComponentNamePathes () -> (PathApertureDictionary, PathApertureDictionary) {
    var frontComponentNames = PathApertureDictionary () // Aperture, path
    var backComponentNames = PathApertureDictionary () // Aperture, path
    for object in self.rootObject.mBoardObjects {
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
          let pathArray = textBP.pointsByFlattening (withFlatness: 0.1)
          switch component.mSide {
          case .back :
            backComponentNames [aperture] = (backComponentNames [aperture] ?? []) + pathArray
          case .front :
            frontComponentNames [aperture] = (frontComponentNames [aperture] ?? []) + pathArray
          }
        }
      }
    }
    return (frontComponentNames, backComponentNames)
  }

  //····················································································································

  private func buildComponentValuePathes () -> (PathApertureDictionary, PathApertureDictionary) {
    var frontComponentValues = PathApertureDictionary () // Aperture, path
    var backComponentValues = PathApertureDictionary () // Aperture, path
    for object in self.rootObject.mBoardObjects {
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
          let pathArray = textBP.pointsByFlattening (withFlatness: 0.1)
          switch component.mSide {
          case .back :
            backComponentValues [aperture] = (backComponentValues [aperture] ?? []) + pathArray
          case .front :
            frontComponentValues [aperture] = (frontComponentValues [aperture] ?? []) + pathArray
          }
        }
      }
    }
    return (frontComponentValues, backComponentValues)
  }

  //····················································································································

  private func buildTextPathes () -> (PathApertureDictionary, PathApertureDictionary, PathApertureDictionary, PathApertureDictionary) {
    var legendFrontTexts = PathApertureDictionary () // Aperture, path
    var layoutFrontTexts = PathApertureDictionary () // Aperture, path
    var layoutBackTexts = PathApertureDictionary () // Aperture, path
    var legendBackTexts = PathApertureDictionary () // Aperture, path
    for object in self.rootObject.mBoardObjects {
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
        let pathArray = textBP.pointsByFlattening (withFlatness: 0.1)
        switch text.mLayer {
        case .legendFront :
          legendFrontTexts [aperture] = (legendFrontTexts [aperture] ?? []) + pathArray
        case .layoutFront :
          layoutFrontTexts [aperture] = (layoutFrontTexts [aperture] ?? []) + pathArray
        case .layoutBack :
          layoutBackTexts [aperture] = (layoutBackTexts [aperture] ?? []) + pathArray
        case .legendBack :
          legendBackTexts [aperture] = (legendBackTexts [aperture] ?? []) + pathArray
        }
      }
    }
    return (legendFrontTexts, layoutFrontTexts, layoutBackTexts, legendBackTexts)
  }

  //····················································································································

  private func buildViaPads () -> [ProductCircle] { // Center, diameter
    var result = [ProductCircle] ()
    for object in self.rootObject.mBoardObjects {
      if let via = object as? BoardConnector, let isVia = via.isVia, isVia {
        let p = via.location!.cocoaPoint
        let padDiameter = canariUnitToCocoa (via.actualPadDiameter!)
        result.append (ProductCircle (center: p, diameter: padDiameter))
      }
    }
    return result
  }

  //····················································································································

  private func buildTracks () -> [TrackSide : [ProductOblong]] {
    var tracks = [TrackSide : [ProductOblong]] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        let p1 = track.mConnectorP1!.location!.cocoaPoint
        let p2 = track.mConnectorP2!.location!.cocoaPoint
        let width = canariUnitToCocoa (track.actualTrackWidth!)
        let t = ProductOblong (p1: p1, p2: p2, width: width)
        tracks [track.mSide] = (tracks [track.mSide] ?? []) + [t]
      }
    }
    return tracks
  }

  //····················································································································

  private func buildLines () -> ([ProductOblong], [ProductOblong]) {
    var frontLines = [ProductOblong] ()
    var backLines = [ProductOblong] ()
    for object in self.rootObject.mBoardObjects {
      if let line = object as? BoardLine {
        let p1 = CanariPoint (x: line.mX1, y: line.mY1).cocoaPoint
        let p2 = CanariPoint (x: line.mX2, y: line.mY2).cocoaPoint
        let width = canariUnitToCocoa (line.mWidth)
        let t = ProductOblong (p1: p1, p2: p2, width: width)
        switch line.mLayer {
        case .legendBack :
          backLines.append (t)
        case .legendFront :
          frontLines.append (t)
        }
      }
    }
    return (frontLines, backLines)
  }

  //····················································································································

  fileprivate func buildCircularPads () -> [TrackSide : [ProductCircle]] {
    var circularPads = [TrackSide : [ProductCircle]] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let circle = productCircle (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              circularPads [.front] = (circularPads [.front] ?? []) + [circle]
              circularPads [.back] = (circularPads [.back] ?? []) + [circle]
            case .surface :
              switch component.mSide {
              case .back :
                circularPads [.back] = (circularPads [.back] ?? []) + [circle]
              case .front :
                circularPads [.front] = (circularPads [.front] ?? []) + [circle]
              }
            }
          }
          for slavePad in masterPad.slavePads {
            if let circle = productCircle (slavePad.center, slavePad.padSize, slavePad.shape, af) {
              switch slavePad.style {
              case .traversing :
                circularPads [.front] = (circularPads [.front] ?? []) + [circle]
                circularPads [.back] = (circularPads [.back] ?? []) + [circle]
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  circularPads [.back] = (circularPads [.back] ?? []) + [circle]
                case .back :
                  circularPads [.front] = (circularPads [.front] ?? []) + [circle]
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  circularPads [.back] = (circularPads [.back] ?? []) + [circle]
                case .front :
                  circularPads [.front] = (circularPads [.front] ?? []) + [circle]
                }
              }
            }
          }
        }
      }
    }
    return circularPads
  }

  //····················································································································

  fileprivate func buildOblongPads () -> [TrackSide : [ProductOblong]] {
    var oblongPads = [TrackSide : [ProductOblong]] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let oblong = oblong (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              oblongPads [.front] = (oblongPads [.front] ?? []) + [oblong]
              oblongPads [.back] = (oblongPads [.back] ?? []) + [oblong]
            case .surface :
              switch component.mSide {
              case .back :
                oblongPads [.back] = (oblongPads [.back] ?? []) + [oblong]
              case .front :
                oblongPads [.front] = (oblongPads [.front] ?? []) + [oblong]
              }
            }
          }
          for slavePad in masterPad.slavePads {
            if let oblong = oblong (slavePad.center, slavePad.padSize, slavePad.shape, af) {
              switch slavePad.style {
              case .traversing :
                oblongPads [.front] = (oblongPads [.front] ?? []) + [oblong]
                oblongPads [.back] = (oblongPads [.back] ?? []) + [oblong]
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  oblongPads [.back] = (oblongPads [.back] ?? []) + [oblong]
                case .back :
                  oblongPads [.front] = (oblongPads [.front] ?? []) + [oblong]
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  oblongPads [.back] = (oblongPads [.back] ?? []) + [oblong]
                case .front :
                  oblongPads [.front] = (oblongPads [.front] ?? []) + [oblong]
                }
              }
            }
          }
        }
      }
    }
    return oblongPads
  }

  //····················································································································

  fileprivate func buildPolygonPads () -> [TrackSide : [ProductPolygon]] {
    var polygonPads = [TrackSide : [ProductPolygon]] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let polygon = polygon (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              polygonPads [.front] = (polygonPads [.front] ?? []) + [polygon]
              polygonPads [.back] = (polygonPads [.back] ?? []) + [polygon]
            case .surface :
              switch component.mSide {
              case .back :
                polygonPads [.back] = (polygonPads [.back] ?? []) + [polygon]
              case .front :
                polygonPads [.front] = (polygonPads [.front] ?? []) + [polygon]
              }
            }
          }
          for slavePad in masterPad.slavePads {
           if let polygon = polygon (slavePad.center, slavePad.padSize, slavePad.shape, af) {
             switch slavePad.style {
              case .traversing :
                polygonPads [.front] = (polygonPads [.front] ?? []) + [polygon]
                polygonPads [.back] = (polygonPads [.back] ?? []) + [polygon]
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  polygonPads [.back] = (polygonPads [.back] ?? []) + [polygon]
                case .back :
                  polygonPads [.front] = (polygonPads [.front] ?? []) + [polygon]
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  polygonPads [.back] = (polygonPads [.back] ?? []) + [polygon]
                case .front :
                  polygonPads [.front] = (polygonPads [.front] ?? []) + [polygon]
                }
              }
            }
          }
        }
      }
    }
    return polygonPads
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

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

//----------------------------------------------------------------------------------------------------------------------

fileprivate func polygon (_ inCenter : CanariPoint,
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

//----------------------------------------------------------------------------------------------------------------------

fileprivate func oblong (_ inCenter : CanariPoint,
                         _ inPadSize : CanariSize,
                         _ inShape : PadShape,
                         _ inAffineTransform : AffineTransform) -> ProductOblong? {
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
      return ProductOblong (p1: p1, p2: p2, width: w)
    }else if inPadSize.width > inPadSize.height { // Horizontal oblong
      let p1 = inAffineTransform.transform (NSPoint (x: p.x - (padSize.width - padSize.height) / 2.0, y: p.y))
      let p2 = inAffineTransform.transform (NSPoint (x: p.x + (padSize.width - padSize.height) / 2.0, y: p.y))
      let w = canariUnitToCocoa (inPadSize.height)
      return ProductOblong (p1: p1, p2: p2, width: w)
    }else{ // Circular
      return nil
    }
  }
}

//----------------------------------------------------------------------------------------------------------------------

struct ProductOblong { // All in Cocoa Unit
  let p1 : NSPoint
  let p2 : NSPoint
  let width : CGFloat
}

//----------------------------------------------------------------------------------------------------------------------

struct ProductCircle { // All in Cocoa Unit
  let center : NSPoint
  let diameter : CGFloat
}

//----------------------------------------------------------------------------------------------------------------------

struct ProductPolygon { // All in Cocoa Unit
  let origin : NSPoint
  let points : [NSPoint]

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> ProductPolygon {
    let to = inAffineTransform.transform (self.origin)
    var tps = [NSPoint] ()
    for p in self.points {
      tps.append (inAffineTransform.transform (p))
    }
    return ProductPolygon (origin: to, points: tps)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

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
  let viaPads : [ProductCircle]
  let tracks : [TrackSide : [ProductOblong]]
  let frontLines : [ProductOblong]
  let backLines : [ProductOblong]
  let circularPads : [TrackSide : [ProductCircle]]
  let oblongPads : [TrackSide : [ProductOblong]]
  let polygonPads : [TrackSide : [ProductPolygon]]
}

//----------------------------------------------------------------------------------------------------------------------

