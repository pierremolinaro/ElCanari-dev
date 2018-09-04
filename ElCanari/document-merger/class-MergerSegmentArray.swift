//
//  MergerSegmentArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_segmentsToBezierPaths (_ segments : MergerSegmentArray) -> BezierPathArray {
  var result = BezierPathArray ()
  for segment in segments.segmentArray {
     let bp = NSBezierPath ()
     bp.move (to: NSPoint (x: canariUnitToCocoa(segment.x1), y: canariUnitToCocoa (segment.y1)))
     bp.line (to: NSPoint (x: canariUnitToCocoa(segment.x2), y: canariUnitToCocoa (segment.y2)))
     bp.lineWidth = canariUnitToCocoa (segment.width)
     bp.lineCapStyle = .roundLineCapStyle
     result.append (bp)
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerSegmentArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerSegmentArray : EBSimpleClass {

  //····················································································································

  let segmentArray : [CanariSegment]

  //····················································································································

  init (_ inArray : [CanariSegment]) {
    segmentArray = inArray
    super.init ()
  }

  //····················································································································

  override init () {
    segmentArray = []
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerSegmentArray " + String (self.segmentArray.count)
    }
  }

  //····················································································································

  func add (toArchiveArray : inout [String],
            dx inDx : Int,
            dy inDy: Int,
            modelWidth inModelWidth : Int,
            modelHeight inModelHeight : Int,
            instanceRotation inInstanceRotation : QuadrantRotation) {
    for segment in self.segmentArray {
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
      toArchiveArray.append (s)
    }
  }

  //····················································································································

  func add (toStrokeBezierPaths ioBezierPaths : inout [NSBezierPath],
            dx inDx : Int,
            dy inDy: Int,
            horizontalMirror inHorizontalMirror : Bool,
            boardWidth inBoardWidth : Int,
            modelWidth inModelWidth : Int,
            modelHeight inModelHeight : Int,
            instanceRotation inInstanceRotation : QuadrantRotation) {
    for segment in self.segmentArray {
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
      let bp = NSBezierPath ()
      bp.move (to:CGPoint (x:x1f, y:y1f))
      bp.line (to:CGPoint (x:x2f, y:y2f))
      bp.lineWidth = width
      bp.lineCapStyle = .roundLineCapStyle
      ioBezierPaths.append (bp)
    }
  }
  //····················································································································

  func addDrillForPDF (toStrokeBezierPaths ioBezierPaths : inout [NSBezierPath],
                       dx inDx : Int,
                       dy inDy: Int,
                       horizontalMirror inHorizontalMirror : Bool,
                       pdfDrillDiameter : CGFloat,
                       boardWidth inBoardWidth : Int,
                       modelWidth inModelWidth : Int,
                       modelHeight inModelHeight : Int,
                       instanceRotation inInstanceRotation : QuadrantRotation) {
    for segment in self.segmentArray {
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
      let bp = NSBezierPath ()
      bp.move (to:CGPoint (x:x1f, y:y1f))
      bp.line (to:CGPoint (x:x2f, y:y2f))
      bp.lineWidth = pdfDrillDiameter
      bp.lineCapStyle = .roundLineCapStyle
      ioBezierPaths.append (bp)
    }
  }

  //····················································································································

  func add (toApertures ioApertures : inout [String : [String]],
            dx inDx : Int,
            dy inDy: Int,
            horizontalMirror inHorizontalMirror : Bool,
            boardWidth inBoardWidth : Int,
            modelWidth inModelWidth : Int,
            modelHeight inModelHeight : Int,
            instanceRotation inInstanceRotation : QuadrantRotation) {
    for segment in self.segmentArray {
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

  //····················································································································

  func enterDrills (array ioHoleDiameterArray : inout [Int : [(Int, Int, Int, Int)]],
                    dx inDx : Int,
                    dy inDy: Int,
                    modelWidth inModelWidth : Int,
                    modelHeight inModelHeight : Int,
                    instanceRotation inInstanceRotation : QuadrantRotation) {
    for hole in self.segmentArray {
      var x1 = inDx ; var y1 = inDy
      var x2 = inDx ; var y2 = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x1 += hole.x1 ; y1 += hole.y1
        x2 += hole.x2 ; y2 += hole.y2
      case .rotation90 :
        x1 += inModelHeight - hole.y1 ; y1 += hole.x1
        x2 += inModelHeight - hole.y2 ; y2 += hole.x2
      case .rotation180 :
        x1 += inModelWidth - hole.x1 ; y1 += inModelHeight - hole.y1
        x2 += inModelWidth - hole.x2 ; y2 += inModelHeight - hole.y2
      case .rotation270 :
        x1 += hole.y1 ; y1 += inModelWidth - hole.x1
        x2 += hole.y2 ; y2 += inModelWidth - hole.x2
      }
      if let array : [(Int, Int, Int, Int)] = ioHoleDiameterArray [hole.width] {
        var a = array
        a.append ((x1, y1, x2, y2))
        ioHoleDiameterArray [hole.width] = a
      }else{
        ioHoleDiameterArray [hole.width] = [(x1, y1, x2, y2)]
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
