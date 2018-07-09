//
//  ViaShapeArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerViaShapeArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerViaShapeArray : EBSimpleClass {

  //····················································································································

  let viaShapeArray : [MergerViaShape]

  //····················································································································

  init (_ inArray : [MergerViaShape]) {
    viaShapeArray = inArray
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerViaShapeArray " + String (viaShapeArray.count)
    }
  }

  //····················································································································

  func buildPadShape (dx inDx : Int, dy inDy : Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    var components = [CAShapeLayer] ()
    if inDisplay {
      for via in self.viaShapeArray {
        let x = canariUnitToCocoa (via.x)
        let y = canariUnitToCocoa (via.y)
        let diameter = canariUnitToCocoa (via.padDiameter)
        let r = CGRect (x: x - diameter / 2.0 , y: y - diameter / 2.0, width: diameter, height: diameter)
        let shape = CAShapeLayer ()
        shape.path = CGPath (ellipseIn: r, transform: nil)
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

  func addPad (toFilledBezierPaths ioBezierPaths : inout [NSBezierPath],
               dx inDx : Int,
               dy inDy: Int,
               horizontalMirror inHorizontalMirror : Bool,
               boardWidth inBoardWidth : Int) {
    for via in self.viaShapeArray {
      let x = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - via.x - inDx) : (via.x + inDx))
      let y = canariUnitToCocoa (via.y + inDy)
      let d = canariUnitToCocoa (via.padDiameter)
      let r = NSRect (x: x - d / 2.0, y: y - d / 2.0, width: d, height : d)
      let bp = NSBezierPath (ovalIn: r)
      ioBezierPaths.append (bp)
    }
  }

  //····················································································································

  func addHole (toFilledBezierPaths ioBezierPaths : inout [NSBezierPath],
                dx inDx : Int,
                dy inDy: Int,
                pdfHoleDiameter inHoleDiameter : CGFloat,
                horizontalMirror inHorizontalMirror : Bool,
                boardWidth inBoardWidth : Int) {
    for via in self.viaShapeArray {
      let x = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - via.x - inDx) : (via.x + inDx))
      let y = canariUnitToCocoa (via.y + inDy)
      let r = NSRect (x: x - inHoleDiameter / 2.0, y: y - inHoleDiameter / 2.0, width: inHoleDiameter, height : inHoleDiameter)
      let bp = NSBezierPath (ovalIn: r)
      ioBezierPaths.append (bp)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerViaShape
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerViaShape : EBSimpleClass {

  //····················································································································

  let x : Int
  let y : Int
  let padDiameter : Int

  //····················································································································

  init (x inX : Int,
        y inY : Int,
        padDiameter inPadDiameter : Int) {
    x = inX
    y = inY
    padDiameter = inPadDiameter
    super.init ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
