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

  let segmentArray : [MergerSegment]

  //····················································································································

  init (_ inArray : [MergerSegment]) {
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

  func buildLayer (color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    return self.buildLayer (dx:0, dy:0, color:inColor, display:inDisplay)
  }

  //····················································································································

  func buildLayer (dx inDx : Int, dy inDy: Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    var components = [CAShapeLayer] ()
    if inDisplay {
      for segment in self.segmentArray {
        let shape = segment.segmentShape (color:inColor.cgColor)
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerSegment : EBSimpleClass {

  //····················································································································

  let x1 : Int
  let y1 : Int
  let x2 : Int
  let y2 : Int
  let width : Int

  //····················································································································

  init (x1 inX1 : Int, y1 inY1 : Int, x2 inX2 : Int, y2 inY2 : Int, width inWidth : Int) {
    x1 = inX1
    y1 = inY1
    x2 = inX2
    y2 = inY2
    width = inWidth
    super.init ()
  }

  //····················································································································

  func segmentShape (color : CGColor) -> CAShapeLayer {
    let x1f : CGFloat = canariUnitToCocoa (self.x1)
    let y1f : CGFloat = canariUnitToCocoa (self.y1)
    let x2f : CGFloat = canariUnitToCocoa (self.x2)
    let y2f : CGFloat = canariUnitToCocoa (self.y2)
    let widthf : CGFloat = canariUnitToCocoa (self.width)
    let path = CGMutablePath ()
    // NSLog ("x1f \(x1f), y1f \(y1f), x2f \(x2f), y2f \(y2f), widthf \(widthf)")
    path.move (to:CGPoint (x:x1f, y:y1f))
    path.addLine (to:CGPoint (x:x2f, y:y2f))
    let shape = CAShapeLayer ()
    shape.path = path
    shape.position = CGPoint (x:0.0, y:0.0)
    shape.strokeColor = color
    shape.lineWidth = widthf
    shape.lineCap = kCALineCapRound
    return shape
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
