//
//  MergerViaShapeArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   MergerViaShapeArray
//--------------------------------------------------------------------------------------------------

struct MergerViaShapeArray : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let viaShapeArray : [MergerViaShape]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func shapeBezierPathes () -> BezierPathArray {
    var result = BezierPathArray ()
    for via in self.viaShapeArray {
      let x = canariUnitToCocoa (via.x)
      let y = canariUnitToCocoa (via.y)
      let diameter = canariUnitToCocoa (via.padDiameter)
      let r = NSRect (x: x - diameter / 2.0 , y: y - diameter / 2.0, width: diameter, height: diameter)
      let bp = BézierPath (ovalIn: r)
      result.append (bp)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addPad (toFilledBezierPaths ioBezierPaths : inout [BézierPath],
               dx inDx : Int,
               dy inDy: Int,
               horizontalMirror inHorizontalMirror : Bool,
               boardWidth inBoardWidth : Int,
               modelWidth inModelWidth : Int,
               modelHeight inModelHeight : Int,
               instanceRotation inInstanceRotation : QuadrantRotation) {
    for via in self.viaShapeArray {
      var x = inDx
      var y = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x += via.x
        y += via.y
      case .rotation90 :
        x += inModelHeight - via.y
        y += via.x
      case .rotation180 :
        x += inModelWidth  - via.x
        y += inModelHeight - via.y
      case .rotation270 :
        x += via.y
        y += inModelWidth - via.x
      }
      let xf = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - x) : x)
      let yf = canariUnitToCocoa (y)
      let d = canariUnitToCocoa (via.padDiameter)
      let r = NSRect (x: xf - d / 2.0, y: yf - d / 2.0, width: d, height : d)
      let bp = BézierPath (ovalIn: r)
      ioBezierPaths.append (bp)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func addHole (toFilledBezierPaths ioBezierPaths : inout [BézierPath],
//                dx inDx : Int,
//                dy inDy: Int,
//                pdfHoleDiameter inHoleDiameter : CGFloat,
//                horizontalMirror inHorizontalMirror : Bool,
//                boardWidth inBoardWidth : Int,
//                modelWidth inModelWidth : Int,
//                modelHeight inModelHeight : Int,
//                instanceRotation inInstanceRotation : QuadrantRotation) {
//    for via in self.viaShapeArray {
//      var x = inDx
//      var y = inDy
//      switch inInstanceRotation {
//      case .rotation0 :
//        x += via.x
//        y += via.y
//      case .rotation90 :
//        x += inModelHeight - via.y
//        y += via.x
//      case .rotation180 :
//        x += inModelWidth  - via.x
//        y += inModelHeight - via.y
//      case .rotation270 :
//        x += via.y
//        y += inModelWidth - via.x
//      }
//      let xf = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - x) : x)
//      let yf = canariUnitToCocoa (y)
//      let r = NSRect (x: xf - inHoleDiameter / 2.0, y: yf - inHoleDiameter / 2.0, width: inHoleDiameter, height : inHoleDiameter)
//      let bp = BézierPath (ovalIn: r)
//      ioBezierPaths.append (bp)
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addPad (toApertures ioApertureDictionary : inout [String : [String]],
               dx inDx : Int,
               dy inDy: Int,
               horizontalMirror inHorizontalMirror : Bool,
               boardWidth inBoardWidth : Int,
               modelWidth inModelWidth : Int,
               modelHeight inModelHeight : Int,
               instanceRotation inInstanceRotation : QuadrantRotation) {
    for via in self.viaShapeArray {
      var x = inDx
      var y = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x += via.x
        y += via.y
      case .rotation90 :
        x += inModelHeight - via.y
        y += via.x
      case .rotation180 :
        x += inModelWidth  - via.x
        y += inModelHeight - via.y
      case .rotation270 :
        x += via.y
        y += inModelWidth - via.x
      }
      let apertureString = "C,\(String(format: "%.4f", canariUnitToInch (via.padDiameter)))"
      let xmt = canariUnitToMilTenth (inHorizontalMirror ? (inBoardWidth - x) : x)
      let ymt = canariUnitToMilTenth (y)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   MergerViaShape
//--------------------------------------------------------------------------------------------------

struct MergerViaShape : Hashable {

  let x : Int
  let y : Int
  let padDiameter : Int

}

//--------------------------------------------------------------------------------------------------
