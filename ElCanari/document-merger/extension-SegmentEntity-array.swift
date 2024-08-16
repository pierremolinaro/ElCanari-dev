//
//  extension-SegmentEntity-array.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/01/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

@MainActor extension Array where Element == SegmentEntity {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addToArchiveArray (_ ioArchiveArray : inout [String],
                          dx inDx : Int,
                          dy inDy: Int,
                          modelWidth inModelWidth : Int,
                          modelHeight inModelHeight : Int,
                          instanceRotation inInstanceRotation : QuadrantRotation) {
    for segment in self {
      var x1 = inDx
      var y1 = inDy
      var x2 = inDx
      var y2 = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x1 += segment.x1
        y1 += segment.y1
        x2 += segment.x2
        y2 += segment.y2
      case .rotation90 :
        x1 += inModelHeight - segment.y1
        y1 += segment.x1
        x2 += inModelHeight - segment.y2
        y2 += segment.x2
      case .rotation180 :
        x1 += inModelWidth  - segment.x1
        y1 += inModelHeight - segment.y1
        x2 += inModelWidth  - segment.x2
        y2 += inModelHeight - segment.y2
      case .rotation270 :
        x1 += segment.y1
        y1 += inModelWidth - segment.x1
        x2 += segment.y2
        y2 += inModelWidth - segment.x2
      }
      let s = "\(x1) \(y1) \(x2) \(y2) \(segment.width)"
      ioArchiveArray.append (s)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addToApertureDictionary (_ ioApertures : inout [String : [String]],
                                dx inDx : Int,
                                dy inDy: Int,
                                horizontalMirror inHorizontalMirror : Bool,
                                boardWidth inBoardWidth : Int,
                                modelWidth inModelWidth : Int,
                                modelHeight inModelHeight : Int,
                                instanceRotation inInstanceRotation : QuadrantRotation) {
    for segment in self {
      var x1 = inDx
      var y1 = inDy
      var x2 = inDx
      var y2 = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x1 += segment.x1
        y1 += segment.y1
        x2 += segment.x2
        y2 += segment.y2
      case .rotation90 :
        x1 += inModelHeight - segment.y1
        y1 += segment.x1
        x2 += inModelHeight - segment.y2
        y2 += segment.x2
      case .rotation180 :
        x1 += inModelWidth  - segment.x1
        y1 += inModelHeight - segment.y1
        x2 += inModelWidth  - segment.x2
        y2 += inModelHeight - segment.y2
      case .rotation270 :
        x1 += segment.y1
        y1 += inModelWidth - segment.x1
        x2 += segment.y2
        y2 += inModelWidth - segment.x2
      }
      let x1mt = canariUnitToMilTenth (inHorizontalMirror ? (inBoardWidth - x1) : x1)
      let y1mt = canariUnitToMilTenth (y1)
      let x2mt = canariUnitToMilTenth (inHorizontalMirror ? (inBoardWidth - x2) : x2)
      let y2mt = canariUnitToMilTenth (y2)
      let apertureString = "C,\(String(format: "%.4f", canariUnitToInch (segment.width)))"
      let moveTo = "X\(x1mt)Y\(y1mt)D02"
      let lineTo = "X\(x2mt)Y\(y2mt)D01"
      if let array = ioApertures [apertureString] {
        var a = array
        let possibleLastLineTo = "X\(x1mt)Y\(y1mt)D01"
        if possibleLastLineTo != a.last! {
          a.append (moveTo)
        }
        a.append (lineTo)
        ioApertures [apertureString] = a
      }else{
        ioApertures [apertureString] = [moveTo, lineTo]
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addToStrokeBezierPaths (_ ioBezierPaths : inout [EBBezierPath],
                               dx inDx : Int,
                               dy inDy: Int,
                               horizontalMirror inHorizontalMirror : Bool,
                               boardWidth inBoardWidth : Int,
                               modelWidth inModelWidth : Int,
                               modelHeight inModelHeight : Int,
                               instanceRotation inInstanceRotation : QuadrantRotation) {
    for segment in self {
      var x1 = inDx
      var y1 = inDy
      var x2 = inDx
      var y2 = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x1 += segment.x1
        y1 += segment.y1
        x2 += segment.x2
        y2 += segment.y2
      case .rotation90 :
        x1 += inModelHeight - segment.y1
        y1 += segment.x1
        x2 += inModelHeight - segment.y2
        y2 += segment.x2
      case .rotation180 :
        x1 += inModelWidth  - segment.x1
        y1 += inModelHeight - segment.y1
        x2 += inModelWidth  - segment.x2
        y2 += inModelHeight - segment.y2
      case .rotation270 :
        x1 += segment.y1
        y1 += inModelWidth - segment.x1
        x2 += segment.y2
        y2 += inModelWidth - segment.x2
      }
      let x1f = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - x1) : x1)
      let y1f = canariUnitToCocoa (y1)
      let x2f = canariUnitToCocoa (inHorizontalMirror ? (inBoardWidth - x2) : x2)
      let y2f = canariUnitToCocoa (y2)
      let width = canariUnitToCocoa (segment.width)
      var bp = EBBezierPath ()
      bp.move (to: NSPoint (x: x1f, y: y1f))
      bp.line (to: NSPoint (x: x2f, y: y2f))
      bp.lineWidth = width
      switch segment.endStyle {
      case .round :
        bp.lineCapStyle = .round
      case .square :
        bp.lineCapStyle = .square
      }
      ioBezierPaths.append (bp)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
