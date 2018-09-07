//
//  MergerPadArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerPad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerPad : EBSimpleClass {

  //····················································································································

  let x : Int
  let y : Int
  let width : Int
  let height : Int
  let shape : PadShape
  let rotation : Int

  //····················································································································

  init (x inX : Int,
        y inY : Int,
        width inWidth : Int,
        height inHeight : Int,
        shape inShape : PadShape,
        rotation inRotation : Int) {
    x = inX
    y = inY
    width = inWidth
    height = inHeight
    shape = inShape
    rotation = inRotation
    super.init ()
  }

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

final class MergerPadArray : EBSimpleClass {

  //····················································································································

  let padArray : [MergerPad]

  //····················································································································

  init (_ inArray : [MergerPad]) {
    padArray = inArray
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerPadArray " + String (padArray.count)
    }
  }

  //····················································································································

  func buidBezierPaths () -> BezierPathArray {
    var result = BezierPathArray ()
    for pad in self.padArray {
      let width = canariUnitToCocoa (pad.width)
      let height = canariUnitToCocoa (pad.height)
      let r = CGRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
      let bp : NSBezierPath
      switch pad.shape {
      case .rectangular :
        bp = NSBezierPath (rect:r)
      case .round :
        if pad.width < pad.height {
          bp = NSBezierPath (roundedRect:r, xRadius:width / 2.0, yRadius:width / 2.0)
        }else if pad.width > pad.height {
          bp = NSBezierPath (roundedRect:r, xRadius:height / 2.0, yRadius:height / 2.0)
        }else{
          bp = NSBezierPath (ovalIn:r)
        }
      }
      var transform = AffineTransform (translationByX: canariUnitToCocoa (pad.x), byY: canariUnitToCocoa (pad.y))
      transform.rotate (byRadians: canariRotationToRadians (pad.rotation))
      bp.transform (using: transform)
      result.append (bp)
    }
    return result
  }

  //····················································································································

  func addPads (toFilledBezierPaths ioBezierPaths : inout [NSBezierPath],
                dx inDx : Int,
                dy inDy: Int,
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
      let width = canariUnitToCocoa (pad.width)
      let height = canariUnitToCocoa (pad.height)
      let r = NSRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
      let transform = NSAffineTransform ()
      transform.translateX (by:xf, yBy:yf)
      if inHorizontalMirror {
        transform.scaleX (by:-1.0, yBy: 1.0)
      }
      transform.rotate (byRadians:canariRotationToRadians (pad.rotation + inInstanceRotation.rawValue * 90_000))
      let bp : NSBezierPath
      switch pad.shape {
      case .rectangular :
        bp = NSBezierPath (rect:r)
      case .round :
        if pad.width < pad.height {
          bp = NSBezierPath (roundedRect:r, xRadius:width / 2.0, yRadius:width / 2.0)
        }else if pad.width > pad.height {
          bp = NSBezierPath (roundedRect:r, xRadius:height / 2.0, yRadius:height / 2.0)
        }else{
          bp = NSBezierPath (ovalIn:r)
        }
      }
      ioBezierPaths.append (transform.transform (bp))
    }
  }

  //····················································································································

  func addHoles (toFilledBezierPaths ioBezierPaths : inout [NSBezierPath],
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
      let bp = NSBezierPath (ovalIn:r)
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
    for pad in self.padArray {
      let pasRotationInRadians = canariRotationToRadians (pad.rotation + inInstanceRotation.rawValue * 90_000)
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
      let xmt : Int = canariUnitToMilTenth (inHorizontalMirror ? (inBoardWidth - x) : x)
      let ymt : Int = canariUnitToMilTenth (y)
      let widthTenthMil  : Int = canariUnitToMilTenth (pad.width)
      let heightTenthMil : Int = canariUnitToMilTenth (pad.height)
      let widthTenthMilF = Double (widthTenthMil)
      let heightTenthMilF = Double (heightTenthMil)
      let widthInch  : CGFloat = canariUnitToInch (pad.width)
      let heightInch : CGFloat = canariUnitToInch (pad.height)
      switch pad.shape {
      case .rectangular :
        let cosa = cos (pasRotationInRadians)
        let sina = sin (pasRotationInRadians)
        let hs = CGFloat (widthTenthMilF) / 2.0
        let ws = CGFloat (heightTenthMilF) / 2.0
        let p1x : CGFloat = CGFloat (xmt) + ( hs * cosa - ws * sina)
        let p1y : CGFloat = CGFloat (ymt) + ( hs * sina + ws * cosa)
        let p2x : CGFloat = CGFloat (xmt) + (-hs * cosa - ws * sina)
        let p2y : CGFloat = CGFloat (ymt) + (-hs * sina + ws * cosa)
        let p3x : CGFloat = CGFloat (xmt) + (-hs * cosa + ws * sina)
        let p3y : CGFloat = CGFloat (ymt) + (-hs * sina - ws * cosa)
        let p4x : CGFloat = CGFloat (xmt) + ( hs * cosa + ws * sina)
        let p4y : CGFloat = CGFloat (ymt) + ( hs * sina - ws * cosa)
        var drawings = [String] ()
        drawings.append ("X\(Int (p1x))Y\(Int (p1y))D02") // Move to
        drawings.append ("X\(Int (p2x))Y\(Int (p2y))D01") // Line to
        drawings.append ("X\(Int (p3x))Y\(Int (p3y))D01") // Line to
        drawings.append ("X\(Int (p4x))Y\(Int (p4y))D01") // Line to
        drawings.append ("X\(Int (p1x))Y\(Int (p1y))D01") // Line to
        ioPolygons.append (drawings)
      case .round :
        if pad.width < pad.height {
          let transform = NSAffineTransform ()
          if inHorizontalMirror {
            transform.scaleX (by:-1.0, yBy: 1.0)
          }
          transform.rotate (byRadians:pasRotationInRadians)
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
          transform.rotate (byRadians:pasRotationInRadians)
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
