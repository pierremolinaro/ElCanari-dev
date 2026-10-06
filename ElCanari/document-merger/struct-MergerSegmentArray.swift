//
//  MergerSegmentArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/06/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//   MergerSegmentArray
//--------------------------------------------------------------------------------------------------

struct MergerSegmentArray : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let segmentArray : [CanariSegment]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inArray : [CanariSegment]) {
    self.segmentArray = inArray
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.segmentArray = []
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func bezierPathArray () -> BezierPathArray {
    var result = BezierPathArray ()
    for segment in self.segmentArray {
      var bp = BezierPath ()
      bp.move (to: CanariPoint (x: segment.x1, y: segment.y1))
      bp.line (to: CanariPoint (x: segment.x2, y: segment.y2))
      bp.lineWidth = segment.width
      switch segment.endStyle {
      case .round:
        bp.lineCapStyle = .round
      case .square:
        bp.lineCapStyle = .square
      }
      result.append (bp)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
