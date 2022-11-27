//
//  MergerPad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/06/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerPad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct MergerPad : Hashable {

  //····················································································································

  let x : Int
  let y : Int
  let width : Int
  let height : Int
  let shape : PadShape
  let rotation : Int

  //····················································································································

  func translatedBy (x inX : Int, y inY : Int) -> MergerPad {
    return MergerPad (x: self.x + inX,
                      y: self.y + inY,
                      width: self.width,
                      height: self.height,
                      shape: self.shape,
                      rotation: self.rotation)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerPadArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct MergerPadArray : Hashable {

  //····················································································································

  let padArray : [MergerPad]

  //····················································································································

  func buildBezierPaths () -> BezierPathArray {
    var result = BezierPathArray ()
    for pad in self.padArray {
      let width = canariUnitToCocoa (pad.width)
      let height = canariUnitToCocoa (pad.height)
      let r = NSRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
      var bp : EBBezierPath
      switch pad.shape {
      case .rect :
        bp = EBBezierPath (rect:r)
      case .round :
        if pad.width < pad.height {
          bp = EBBezierPath (roundedRect:r, xRadius:width / 2.0, yRadius:width / 2.0)
        }else if pad.width > pad.height {
          bp = EBBezierPath (roundedRect:r, xRadius:height / 2.0, yRadius:height / 2.0)
        }else{
          bp = EBBezierPath (ovalIn:r)
        }
      case .octo :
        bp = EBBezierPath (octogonInRect: r)
      }
      var transform = AffineTransform (translationByX: canariUnitToCocoa (pad.x), byY: canariUnitToCocoa (pad.y))
      transform.rotate (byRadians: canariRotationToRadians (pad.rotation))
      bp.transform (using: transform)
      result.append (bp)
    }
    return result
  }

  //····················································································································

  func addPads (toFilledBezierPaths ioBezierPaths : inout [EBBezierPath],
                dx inDx : Int,
                dy inDy: Int,
                horizontalMirror inHorizontalMirror : Bool,
                boardWidth inBoardWidth : Int,
                modelWidth inModelWidth : Int,
                modelHeight inModelHeight : Int,
                instanceRotation inInstanceRotation : QuadrantRotation) {
   //  Swift.print ("PDF : \(self.padArray.count)")
    for pad in self.padArray {
      var x = inDx
      var y = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x += pad.x
        y += pad.y
      case .rotation90 :
        x += inModelHeight - pad.y
        y += pad.x
      case .rotation180 :
        x += inModelWidth  - pad.x
        y += inModelHeight - pad.y
      case .rotation270 :
        x += pad.y
        y += inModelWidth - pad.x
      }
      let xf = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - x) : x)
      let yf = canariUnitToCocoa (y)
      let width = canariUnitToCocoa (pad.width)
      let height = canariUnitToCocoa (pad.height)
      let r = NSRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
      var transform = AffineTransform ()
      transform.translate (x: xf, y:yf)
      if inHorizontalMirror {
        transform.scale (x: -1.0, y: 1.0)
      }
      transform.rotate (byRadians:canariRotationToRadians (pad.rotation + inInstanceRotation.rawValue * 90_000))
      var bp : EBBezierPath
      switch pad.shape {
      case .rect :
        bp = EBBezierPath (rect:r)
      case .round :
        if pad.width < pad.height {
          bp = EBBezierPath (roundedRect:r, xRadius:width / 2.0, yRadius:width / 2.0)
        }else if pad.width > pad.height {
          bp = EBBezierPath (roundedRect:r, xRadius:height / 2.0, yRadius:height / 2.0)
        }else{
          bp = EBBezierPath (ovalIn:r)
        }
      case .octo :
        bp = EBBezierPath (octogonInRect: r)
      }
      ioBezierPaths.append (bp.transformed (by: transform))
    }
  }

  //····················································································································

  func addHoles (toFilledBezierPaths ioBezierPaths : inout [EBBezierPath],
                 dx inDx : Int,
                 dy inDy: Int,
                 pdfHoleDiameter inHoleDiameter : CGFloat,
                 horizontalMirror inHorizontalMirror : Bool,
                 boardWidth inBoardWidth : Int,
                 modelWidth inModelWidth : Int,
                 modelHeight inModelHeight : Int,
                 instanceRotation inInstanceRotation : QuadrantRotation) {
    for pad in self.padArray {
      var x = inDx
      var y = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x += pad.x
        y += pad.y
      case .rotation90 :
        x += inModelHeight - pad.y
        y += pad.x
      case .rotation180 :
        x += inModelWidth  - pad.x
        y += inModelHeight - pad.y
      case .rotation270 :
        x += pad.y
        y += inModelWidth - pad.x
      }
      let xf = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - x) : x)
      let yf = canariUnitToCocoa (y)
      let r = NSRect (x: xf - inHoleDiameter / 2.0, y: yf - inHoleDiameter / 2.0, width:inHoleDiameter, height:inHoleDiameter)
      let bp = EBBezierPath (ovalIn: r)
      ioBezierPaths.append (bp)
    }
  }

  //····················································································································

  func addPads (toApertures ioApertureDictionary : inout [String : [String]],
                toPolygones ioPolygons : inout [[String]],
                dx inDx : Int,
                dy inDy: Int,
                horizontalMirror inHorizontalMirror : Bool,
                minimumAperture inMinimumApertureMilTenth : Int,
                boardWidth inBoardWidth : Int,
                modelWidth inModelWidth : Int,
                modelHeight inModelHeight : Int,
                instanceRotation inInstanceRotation : QuadrantRotation) {
    // Swift.print ("GERBER: \(self.padArray.count)")
    for pad in self.padArray {
      let padRotationInRadians = canariRotationToRadians (pad.rotation + inInstanceRotation.rawValue * 90_000)
      var x = inDx
      var y = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x += pad.x
        y += pad.y
      case .rotation90 :
        x += inModelHeight - pad.y
        y += pad.x
      case .rotation180 :
        x += inModelWidth  - pad.x
        y += inModelHeight - pad.y
      case .rotation270 :
        x += pad.y
        y += inModelWidth - pad.x
      }
      let xmt : Int
      if inHorizontalMirror {
        xmt = canariUnitToMilTenth (inBoardWidth - x)
      }else{
        xmt = canariUnitToMilTenth (x)
      }
      let ymt : Int = canariUnitToMilTenth (y)
      let widthTenthMil  : Int = canariUnitToMilTenth (pad.width)
      let heightTenthMil : Int = canariUnitToMilTenth (pad.height)
      let widthTenthMilF  = CGFloat (widthTenthMil)
      let heightTenthMilF = CGFloat (heightTenthMil)
      let widthInch  = canariUnitToInch (pad.width)
      let heightInch = canariUnitToInch (pad.height)
      switch pad.shape {
      case .rect :
        let cosa = cos (padRotationInRadians)
        let sina = sin (padRotationInRadians)
        let hs = widthTenthMilF  / 2.0 // Demie largeur du pad
        let ws = heightTenthMilF / 2.0 // Demie-hauteur du pad
        let p1x = CGFloat (xmt) + ( hs * cosa - ws * sina)
        let p1y = CGFloat (ymt) + ( hs * sina + ws * cosa)
        let p2x = CGFloat (xmt) + (-hs * cosa - ws * sina)
        let p2y = CGFloat (ymt) + (-hs * sina + ws * cosa)
        let p3x = CGFloat (xmt) + (-hs * cosa + ws * sina)
        let p3y = CGFloat (ymt) + (-hs * sina - ws * cosa)
        let p4x = CGFloat (xmt) + ( hs * cosa + ws * sina)
        let p4y = CGFloat (ymt) + ( hs * sina - ws * cosa)
        var drawings = [String] ()
        drawings.append ("X\(Int (p1x))Y\(Int (p1y))D02") // Move to
        drawings.append ("X\(Int (p2x))Y\(Int (p2y))D01") // Line to
        drawings.append ("X\(Int (p3x))Y\(Int (p3y))D01") // Line to
        drawings.append ("X\(Int (p4x))Y\(Int (p4y))D01") // Line to
        drawings.append ("X\(Int (p1x))Y\(Int (p1y))D01") // Line to
        ioPolygons.append (drawings)
      case .octo :
        // Swift.print ("OCTO \(xmt) \(ymt) \(widthInch) \(heightInch)")
        var af = AffineTransform ()
        af.translate (x: CGFloat (xmt), y: CGFloat (ymt))
        af.rotate (byRadians: padRotationInRadians)
        let r = NSRect (x:-widthTenthMilF / 2.0, y: -heightTenthMilF / 2.0, width: widthTenthMilF, height: heightTenthMilF)
        let bp = EBBezierPath (octogonInRect: r).transformed (by: af)
        var points = [NSPoint] (repeating: .zero, count: 3)
        var drawings = [String] ()
        var origin = NSPoint ()
        for i in 0 ..< bp.nsBezierPath.elementCount {
          let type = bp.nsBezierPath.element (at: i, associatedPoints: &points)
          switch type {
          case .moveTo:
            origin = points[0]
            drawings.append ("X\(Int (origin.x))Y\(Int (origin.y))D02") // Move to
          case .lineTo:
            drawings.append ("X\(Int (points[0].x))Y\(Int (points[0].y))D01") // Line to
          case .curveTo:
            ()
          case .closePath:
            drawings.append ("X\(Int (origin.x))Y\(Int (origin.y))D01") // Line to
          @unknown default :
            ()
          }
        }
        ioPolygons.append (drawings)

//        var drawings = [String] ()
//        drawings.append ("Octogonal pad (\(#file):\(#line)")
//        ioPolygons.append (drawings)
      case .round :
        if pad.width < pad.height {
          let transform = NSAffineTransform ()
          if inHorizontalMirror {
            transform.scaleX (by:-1.0, yBy: 1.0)
          }
          transform.rotate (byRadians: padRotationInRadians)
          let apertureString = "C,\(String(format: "%.4f", widthInch))"
          let p1 = transform.transform (NSPoint (x: 0.0,  y:  (heightTenthMilF - widthTenthMilF) / 2.0))
          let p2 = transform.transform (NSPoint (x: 0.0,  y: -(heightTenthMilF - widthTenthMilF) / 2.0))
          let p1x = Int (p1.x.rounded ())
          let p1y = Int (p1.y.rounded ())
          let p2x = Int (p2.x.rounded ())
          let p2y = Int (p2.y.rounded ())
          let moveTo = "X\(xmt + p1x)Y\(ymt + p1y)D02"
          let lineTo = "X\(xmt + p2x)Y\(ymt + p2y)D01"
          if let array = ioApertureDictionary [apertureString] {
            var a = array
            a.append (moveTo)
            a.append (lineTo)
            ioApertureDictionary [apertureString] = a
          }else{
            ioApertureDictionary [apertureString] = [moveTo, lineTo]
          }
        }else if pad.width > pad.height {
          let transform = NSAffineTransform ()
          if inHorizontalMirror {
            transform.scaleX (by:-1.0, yBy: 1.0)
          }
          transform.rotate (byRadians: padRotationInRadians)
          let apertureString = "C,\(String(format: "%.4f", heightInch))"
          let p1 = transform.transform (NSPoint (x:  (widthTenthMilF - heightTenthMilF) / 2.0, y:0.0))
          let p2 = transform.transform (NSPoint (x: -(widthTenthMilF - heightTenthMilF) / 2.0, y:0.0))
          let p1x = Int (p1.x.rounded ())
          let p1y = Int (p1.y.rounded ())
          let p2x = Int (p2.x.rounded ())
          let p2y = Int (p2.y.rounded ())
          let moveTo = "X\(xmt + p1x)Y\(ymt + p1y)D02"
          let lineTo = "X\(xmt + p2x)Y\(ymt + p2y)D01"
          if let array = ioApertureDictionary [apertureString] {
            var a = array
            a.append (moveTo)
            a.append (lineTo)
            ioApertureDictionary [apertureString] = a
          }else{
            ioApertureDictionary [apertureString] = [moveTo, lineTo]
          }
        }else{ // Circular pad
          let apertureString = "C,\(String(format: "%.4f", widthInch))"
          let flash = "X\(xmt)Y\(ymt)D03"
          if let array = ioApertureDictionary [apertureString] {
            var a = array
            a.append (flash)
            ioApertureDictionary [apertureString] = a
          }else{
            ioApertureDictionary [apertureString] = [flash]
          }
        }
      }
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
