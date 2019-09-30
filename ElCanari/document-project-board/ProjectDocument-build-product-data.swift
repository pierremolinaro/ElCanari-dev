//
//  ProjectDocument-build-product-data.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func buildProductData () -> ProductData {
    let (frontPackageLegend, backPackageLegend) = self.buildPackageLegend ()
    let (frontComponentNames, backComponentNames) = self.buildComponentNamePathes ()
    let (frontComponentValues, backComponentValues) = self.buildComponentValuePathes ()
    let (legendFrontTexts, layoutFrontTexts, layoutBackTexts, legendBackTexts) = self.buildTextPathes ()
    let viaPads = self.buildViaPads ()
    let (frontTracks, backTracks) = self.buildTracks ()
    let (frontLines, backLines) = self.buildLines ()
    let (frontCircularPads, backCircularPads) = self.buildCircularPads ()
    let (frontOblongPads, backOblongPads) = self.buildOblongPads ()
    let (frontPolygonPads, backPolygonPads) = self.buildPolygonPads ()
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
      frontTracks: frontTracks,
      backTracks: backTracks,
      frontLines: frontLines,
      backLines: backLines,
      frontCircularPads: frontCircularPads,
      backCircularPads: backCircularPads,
      frontOblongPads: frontOblongPads,
      backOblongPads: backOblongPads,
      frontPolygonPads: frontPolygonPads,
      backPolygonPads: backPolygonPads
    )
  }
  
  //····················································································································

  private func buildBoardLimitPath () -> EBLinePath {
    var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
    for curve in self.rootObject.mBorderCurves {
      let descriptor = curve.descriptor!
      curveDictionary [descriptor.p1] = descriptor
    }
    var bp = EBBezierPath ()
    var descriptor = self.rootObject.mBorderCurves [0].descriptor!
    let p = descriptor.p1
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
    var retainedBP = EBBezierPath ()
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
  //---
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

  private func buildPackageLegend () -> ([CGFloat : [EBLinePath]], [CGFloat : [EBLinePath]]) {
    var frontPackageLegends = [CGFloat : [EBLinePath]] () // Aperture, path
    var backPackageLegends = [CGFloat : [EBLinePath]] () // Aperture, path
    let aperture = CGFloat (g_Preferences!.packageDrawingWidthMultpliedByTenForBoard) / 10.0
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let strokeBezierPath = component.strokeBezierPath!
        if !strokeBezierPath.isEmpty {
          let pathArray = strokeBezierPath.pointsByFlattening (withFlatness: 0.1)
          let af = component.packageToComponentAffineTransform ()
          var transformedPathArray = [EBLinePath] ()
          for path in pathArray {
            transformedPathArray.append (path.transformed(by: af))
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

  private func buildComponentNamePathes () -> ([CGFloat : [EBLinePath]], [CGFloat : [EBLinePath]]) {
    var frontComponentNames = [CGFloat : [EBLinePath]] () // Aperture, path
    var backComponentNames = [CGFloat : [EBLinePath]] () // Aperture, path
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

  private func buildComponentValuePathes () -> ([CGFloat : [EBLinePath]], [CGFloat : [EBLinePath]]) {
    var frontComponentValues = [CGFloat : [EBLinePath]] () // Aperture, path
    var backComponentValues = [CGFloat : [EBLinePath]] () // Aperture, path
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

  private func buildTextPathes () -> ([CGFloat : [EBLinePath]], [CGFloat : [EBLinePath]], [CGFloat : [EBLinePath]], [CGFloat : [EBLinePath]]) {
    var legendFrontTexts = [CGFloat : [EBLinePath]] () // Aperture, path
    var layoutFrontTexts = [CGFloat : [EBLinePath]] () // Aperture, path
    var layoutBackTexts = [CGFloat : [EBLinePath]] () // Aperture, path
    var legendBackTexts = [CGFloat : [EBLinePath]] () // Aperture, path
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

  private func buildTracks () -> ([ProductOblong], [ProductOblong]) {
    var frontTracks = [ProductOblong] ()
    var backTracks = [ProductOblong] ()
    for object in self.rootObject.mBoardObjects {
      if let track = object as? BoardTrack {
        let p1 = track.mConnectorP1!.location!.cocoaPoint
        let p2 = track.mConnectorP2!.location!.cocoaPoint
        let width = canariUnitToCocoa (track.actualTrackWidth!)
        let t = ProductOblong (p1: p1, p2: p2, width: width)
        switch track.mSide {
        case .back :
          backTracks.append (t)
        case .front :
          frontTracks.append (t)
        }
      }
    }
    return (frontTracks, backTracks)
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

  fileprivate func buildCircularPads () -> ([ProductCircle], [ProductCircle]) {
    var frontCircularPads = [ProductCircle] ()
    var backCircularPads = [ProductCircle] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let circle = circle (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              frontCircularPads.append (circle)
              backCircularPads.append (circle)
            case .surface :
              switch component.mSide {
              case .back :
                backCircularPads.append (circle)
              case .front :
                frontCircularPads.append (circle)
              }
            }
          }
          for slavePad in masterPad.slavePads {
            if let circle = circle (slavePad.center, slavePad.padSize, slavePad.shape, af) {
              switch slavePad.style {
              case .traversing :
                frontCircularPads.append (circle)
                backCircularPads.append (circle)
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  backCircularPads.append (circle)
                case .back :
                  frontCircularPads.append (circle)
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  backCircularPads.append (circle)
                case .front :
                  frontCircularPads.append (circle)
                }
              }
            }
          }
        }
      }
    }
    return (frontCircularPads, backCircularPads)
  }

  //····················································································································

  fileprivate func buildOblongPads () -> ([ProductOblong], [ProductOblong]) {
    var frontOblongPads = [ProductOblong] ()
    var backOblongPads = [ProductOblong] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let oblong = oblong (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              frontOblongPads.append (oblong)
              backOblongPads.append (oblong)
            case .surface :
              switch component.mSide {
              case .back :
                backOblongPads.append (oblong)
              case .front :
                frontOblongPads.append (oblong)
              }
            }
          }
          for slavePad in masterPad.slavePads {
            if let oblong = oblong (slavePad.center, slavePad.padSize, slavePad.shape, af) {
              switch slavePad.style {
              case .traversing :
                frontOblongPads.append (oblong)
                backOblongPads.append (oblong)
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  backOblongPads.append (oblong)
                case .back :
                  frontOblongPads.append (oblong)
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  backOblongPads.append (oblong)
                case .front :
                  frontOblongPads.append (oblong)
                }
              }
            }
          }
        }
      }
    }
    return (frontOblongPads, backOblongPads)
  }

  //····················································································································

  fileprivate func buildPolygonPads () -> ([ProductPolygon], [ProductPolygon]) {
    var frontPolygonPads = [ProductPolygon] ()
    var backPolygonPads = [ProductPolygon] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
          if let polygon = polygon (masterPad.center, masterPad.padSize, masterPad.shape, af) {
            switch masterPad.style {
            case .traversing :
              frontPolygonPads.append (polygon)
              backPolygonPads.append (polygon)
            case .surface :
              switch component.mSide {
              case .back :
                backPolygonPads.append (polygon)
              case .front :
                frontPolygonPads.append (polygon)
              }
            }
          }
          for slavePad in masterPad.slavePads {
           if let polygon = polygon (slavePad.center, slavePad.padSize, slavePad.shape, af) {
             switch slavePad.style {
              case .traversing :
                frontPolygonPads.append (polygon)
                backPolygonPads.append (polygon)
              case .oppositeSide :
                switch component.mSide {
                case .front :
                  backPolygonPads.append (polygon)
                case .back :
                  frontPolygonPads.append (polygon)
                }
              case .componentSide :
                switch component.mSide {
                case .back :
                  backPolygonPads.append (polygon)
                case .front :
                  frontPolygonPads.append (polygon)
                }
              }
            }
          }
        }
      }
    }
    return (frontPolygonPads, backPolygonPads)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func circle (_ inCenter : CanariPoint,
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductOblong { // All in Cocoa Unit
  let p1 : NSPoint
  let p2 : NSPoint
  let width : CGFloat
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductCircle { // All in Cocoa Unit
  let center : NSPoint
  let diameter : CGFloat
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ProductData { // All in Cocoa Unit
  let boardBoundBox : NSRect
  let boardLimitPath : EBLinePath
  let boardLimitWidth : CGFloat
  let holeDictionary : [CGFloat : [(NSPoint, NSPoint)]]
  let frontPackageLegend : [CGFloat : [EBLinePath]]
  let backPackageLegend :  [CGFloat : [EBLinePath]]
  let frontComponentNames : [CGFloat : [EBLinePath]]
  let backComponentNames:  [CGFloat : [EBLinePath]]
  let frontComponentValues : [CGFloat : [EBLinePath]]
  let backComponentValues : [CGFloat : [EBLinePath]]
  let legendFrontTexts : [CGFloat : [EBLinePath]]
  let layoutFrontTexts : [CGFloat : [EBLinePath]]
  let layoutBackTexts : [CGFloat : [EBLinePath]]
  let legendBackTexts : [CGFloat : [EBLinePath]]
  let viaPads : [ProductCircle]
  let frontTracks : [ProductOblong]
  let backTracks : [ProductOblong]
  let frontLines : [ProductOblong]
  let backLines : [ProductOblong]
  let frontCircularPads : [ProductCircle]
  let backCircularPads : [ProductCircle]
  let frontOblongPads : [ProductOblong]
  let backOblongPads : [ProductOblong]
  let frontPolygonPads : [ProductPolygon]
  let backPolygonPads : [ProductPolygon]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

