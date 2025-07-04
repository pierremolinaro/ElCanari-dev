//--------------------------------------------------------------------------------------------------
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

struct ProductRectangle : Hashable { // All in Cocoa Unit

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let p0 : NSPoint
  let p1 : NSPoint
  let p2 : NSPoint
  let p3 : NSPoint

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

typealias MergerRectangleArray = [ProductRectangle]

//--------------------------------------------------------------------------------------------------

extension Array where Element == ProductRectangle {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bezierPathArray : [BézierPath] {
    var result = [BézierPath] ()
    for rect in self {
      var bp = BézierPath ()
      bp.move (to: rect.p0)
      bp.line (to: rect.p1)
      bp.line (to: rect.p2)
      bp.line (to: rect.p3)
      bp.close ()
      result.append (bp)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
