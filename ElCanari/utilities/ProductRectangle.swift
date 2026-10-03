//--------------------------------------------------------------------------------------------------
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

struct ProductRectangle : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let p0 : CanariPoint
  let p1 : CanariPoint
  let p2 : CanariPoint
  let p3 : CanariPoint

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

typealias MergerRectangleArray = [ProductRectangle]

//--------------------------------------------------------------------------------------------------

extension Array where Element == ProductRectangle {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bezierPathArray : [BezierPath] {
    var result = [BezierPath] ()
    for rect in self {
      var bp = BezierPath ()
      bp.move (to: rect.p0.ptValue)
      bp.line (to: rect.p1.ptValue)
      bp.line (to: rect.p2.ptValue)
      bp.line (to: rect.p3.ptValue)
      bp.close ()
      result.append (bp)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
