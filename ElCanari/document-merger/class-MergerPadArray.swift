//
//  MergerPadArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerPad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerPad : EBSimpleClass {

  //····················································································································

  let x : Int
  let y : Int
  let width : Int
  let height : Int
  let holeDiameter : Int
  let shape : PadShape
  let rotation : Int

  //····················································································································

  init (x inX : Int,
        y inY : Int,
        width inWidth : Int,
        height inHeight : Int,
        holeDiameter inHoleDiameter : Int,
        shape inShape : PadShape,
        rotation inRotation : Int) {
    x = inX
    y = inY
    width = inWidth
    height = inHeight
    holeDiameter = inHoleDiameter
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
                      holeDiameter: self.holeDiameter,
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

  func buildShape (dx inDx : Int, dy inDy : Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    var components = [CAShapeLayer] ()
    if inDisplay {
      for pad in self.padArray {
        let x = canariUnitToCocoa (pad.x)
        let y = canariUnitToCocoa (pad.y)
        let width = canariUnitToCocoa (pad.width)
        let height = canariUnitToCocoa (pad.height)
        let r = CGRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
        var transform = CGAffineTransform (translationX:x, y:y).rotated (by:canariRotationToRadians (pad.rotation))
        let path : CGPath
        switch pad.shape {
        case .rectangular :
          path = CGPath (rect:r, transform:&transform)
        case .round :
          if pad.width < pad.height {
            path = CGPath (roundedRect:r, cornerWidth:width / 2.0, cornerHeight:width / 2.0, transform:&transform)
          }else if pad.width > pad.height {
            path = CGPath (roundedRect:r, cornerWidth:height / 2.0, cornerHeight:height / 2.0, transform:&transform)
          }else{
            path = CGPath (ellipseIn:r, transform:&transform)
          }
        }
        let shape = CAShapeLayer ()
        shape.path = path
        shape.position = CGPoint (x:0.0, y:0.0)
        shape.strokeColor = nil
        shape.fillColor = inColor.cgColor
    //    shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
        shape.isOpaque = true
        components.append (shape)
      }
    }
    let result = CALayer ()
    result.position = CGPoint (x:canariUnitToCocoa (inDx), y:canariUnitToCocoa (inDy))
    result.sublayers = components
    return result
  }

  //····················································································································

  func addPads (toFilledBezierPaths ioBezierPaths : inout [NSBezierPath],
                dx inDx : Int,
                dy inDy: Int,
                horizontalMirror inHorizontalMirror : Bool,
                boardWidth inBoardWidth : Int) {
    for pad in self.padArray {
      let x = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - pad.x - inDx) : (pad.x + inDx))
      let y = canariUnitToCocoa (pad.y + inDy)
      let width = canariUnitToCocoa (pad.width)
      let height = canariUnitToCocoa (pad.height)
      let r = NSRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
      let transform = NSAffineTransform ()
      transform.translateX (by:x, yBy:y)
      if inHorizontalMirror {
        transform.scaleX (by:-1.0, yBy: 1.0)
      }
      transform.rotate (byRadians:canariRotationToRadians (pad.rotation))
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
                 boardWidth inBoardWidth : Int) {
    for pad in self.padArray {
      let x = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - pad.x - inDx) : (pad.x + inDx))
      let y = canariUnitToCocoa (pad.y + inDy)
      let r = NSRect (x: x - inHoleDiameter / 2.0, y: y - inHoleDiameter / 2.0, width:inHoleDiameter, height:inHoleDiameter)
      let bp = NSBezierPath (ovalIn:r)
      ioBezierPaths.append (bp)
    }
  }

  //····················································································································

  func addPads (toApertures ioApertureDictionary : inout [String : [String]],
                dx inDx : Int,
                dy inDy: Int,
                horizontalMirror inHorizontalMirror : Bool,
                minimumAperture inMinimumAperture : Int,
                boardWidth inBoardWidth : Int) {
    for pad in self.padArray {
      let x : Int = canariUnitToMilTenth (inHorizontalMirror ? (inBoardWidth - pad.x - inDx) : (pad.x + inDx))
      let y : Int = canariUnitToMilTenth (pad.y + inDy)
      let widthTenthMil  : Int = canariUnitToMilTenth (pad.width)
      let heightTenthMil : Int = canariUnitToMilTenth (pad.height)
      let widthTenthMilF = Double (widthTenthMil)
      let heightTenthMilF = Double (heightTenthMil)
      let widthInch  : CGFloat = canariUnitToInch (pad.width)
      let heightInch : CGFloat = canariUnitToInch (pad.height)
      switch pad.shape {
      case .rectangular :
        if (pad.rotation == 0) || (pad.rotation == 180_000) {
          let apertureString = "R,\(String (format:"%1.4f", widthInch))X\(String (format:"%1.4f", heightInch))"
          let flash = "X\(String(format: "%06d", x))Y\(String(format: "%06d", y))D03"
          if let array = ioApertureDictionary [apertureString] {
            var a = array
            a.append (flash)
            ioApertureDictionary [apertureString] = a
          }else{
            ioApertureDictionary [apertureString] = [flash]
          }
        }else if (pad.rotation == 90_000) || (pad.rotation == 270_000) {
          let apertureString = "R,\(String (format:"%1.4f", heightInch))X\(String (format:"%1.4f", widthInch))"
          let flash = "X\(String(format: "%06d", x))Y\(String(format: "%06d", y))D03"
          if let array = ioApertureDictionary [apertureString] {
            var a = array
            a.append (flash)
            ioApertureDictionary [apertureString] = a
           }else{
            ioApertureDictionary [apertureString] = [flash]
           }
        }else{ // Oblique rectangular pad
          let cosa = cos (canariRotationToRadians (pad.rotation))
          let sina = sin (canariRotationToRadians (pad.rotation))
          var currentApertureMilTenth : Int = canariUnitToMilTenth (inMinimumAperture)
          NSLog ("currentApertureMilTenth \(currentApertureMilTenth)")
          var width  : Int = widthTenthMil
          var height : Int = heightTenthMil
          while (width > 0) && (height > 0) {
            let hs = CGFloat (width  - currentApertureMilTenth) / 2.0
            let ws = CGFloat (height - currentApertureMilTenth) / 2.0
            let p1x : CGFloat = CGFloat (x) + ( hs * cosa - ws * sina)
            let p1y : CGFloat = CGFloat (y) + ( hs * sina + ws * cosa)
            let p2x : CGFloat = CGFloat (x) + (-hs * cosa - ws * sina)
            let p2y : CGFloat = CGFloat (y) + (-hs * sina + ws * cosa)
            let p3x : CGFloat = CGFloat (x) + (-hs * cosa + ws * sina)
            let p3y : CGFloat = CGFloat (y) + (-hs * sina - ws * cosa)
            let p4x : CGFloat = CGFloat (x) + ( hs * cosa + ws * sina)
            let p4y : CGFloat = CGFloat (y) + ( hs * sina - ws * cosa)
            var drawings = [String] ()
            drawings.append ("X\(String(format: "%06d", Int (p1x)))Y\(String(format: "%06d", Int (p1y)))D02") // Move to
            drawings.append ("X\(String(format: "%06d", Int (p2x)))Y\(String(format: "%06d", Int (p2y)))D01") // Line to
            drawings.append ("X\(String(format: "%06d", Int (p3x)))Y\(String(format: "%06d", Int (p3y)))D01") // Line to
            drawings.append ("X\(String(format: "%06d", Int (p4x)))Y\(String(format: "%06d", Int (p4y)))D01") // Line to
            drawings.append ("X\(String(format: "%06d", Int (p1x)))Y\(String(format: "%06d", Int (p1y)))D01") // Line to
            let apertureString = "C,\(String(format: "%.4f", CGFloat (currentApertureMilTenth * 100)))"
            if let array = ioApertureDictionary [apertureString] {
              ioApertureDictionary [apertureString] = array + drawings
            }else{
              ioApertureDictionary [apertureString] = drawings
            }
          //--- Prepare for next iteration
            width  -= currentApertureMilTenth
            height -= currentApertureMilTenth
            currentApertureMilTenth = (currentApertureMilTenth * 3) / 2
          }
        }
      case .round :
        if pad.width < pad.height {
          let transform = NSAffineTransform ()
          if inHorizontalMirror {
            transform.scaleX (by:-1.0, yBy: 1.0)
          }
          transform.rotate (byRadians:canariRotationToRadians (pad.rotation))
          let apertureString = "C,\(String(format: "%.4f", widthInch))"
          let p1 = transform.transform (NSPoint (x: 0.0,  y:  (heightTenthMilF - widthTenthMilF) / 2.0))
          let p2 = transform.transform (NSPoint (x: 0.0,  y: -(heightTenthMilF - widthTenthMilF) / 2.0))
          let p1x = Int (p1.x.rounded ())
          let p1y = Int (p1.y.rounded ())
          let p2x = Int (p2.x.rounded ())
          let p2y = Int (p2.y.rounded ())
          let moveTo = "X\(String(format: "%06d", x + p1x))Y\(String(format: "%06d", y + p1y))D02"
          let lineTo = "X\(String(format: "%06d", x + p2x))Y\(String(format: "%06d", y + p2y))D01"
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
          transform.rotate (byRadians:canariRotationToRadians (pad.rotation))
          let apertureString = "C,\(String(format: "%.4f", heightInch))"
          let p1 = transform.transform (NSPoint (x:  (widthTenthMilF - heightTenthMilF) / 2.0, y:0.0))
          let p2 = transform.transform (NSPoint (x: -(widthTenthMilF - heightTenthMilF) / 2.0, y:0.0))
          let p1x = Int (p1.x.rounded ())
          let p1y = Int (p1.y.rounded ())
          let p2x = Int (p2.x.rounded ())
          let p2y = Int (p2.y.rounded ())
          let moveTo = "X\(String(format: "%06d", x + p1x))Y\(String(format: "%06d", y + p1y))D02"
          let lineTo = "X\(String(format: "%06d", x + p2x))Y\(String(format: "%06d", y + p2y))D01"
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
          let flash = "X\(String(format: "%06d", x))Y\(String(format: "%06d", y))D03"
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
