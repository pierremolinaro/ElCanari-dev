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

  override var description : String {
    get {
      return "MergerSegmentArray " + String (segmentArray.count)
    }
  }

  //····················································································································

  func buildLayer (color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    return buildLayer (dx:0, dy:0, color:inColor, display:inDisplay)
  }

  //····················································································································

  func buildLayer (dx inDx : Int, dy inDy: Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    var components = [CAShapeLayer] ()
    if inDisplay {
      for segment in self.segmentArray {
        let shape = segment.segmentShape (color:inColor.cgColor)
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
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
