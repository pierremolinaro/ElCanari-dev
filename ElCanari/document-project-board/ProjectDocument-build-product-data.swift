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
      backComponentValues: backComponentValues
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
      //---
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
            case .bottomSide, .topSide :
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
        if component.mNameIsVisibleInBoard, let fontDescriptor = component.mNameFont!.descriptor {
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
        if component.mValueIsVisibleInBoard, let fontDescriptor = component.mValueFont!.descriptor {
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
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

