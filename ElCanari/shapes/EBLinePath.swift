//
//  EBBezierPath.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/06/2019.
//

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// EBLinePath
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct EBLinePath {
  let origin : NSPoint
  let lines : [NSPoint]
  let closed : Bool

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> EBLinePath {
    let transformedOrigin = inAffineTransform.transform (self.origin)
    var transformedLines = [NSPoint] ()
    for p in self.lines {
      transformedLines.append (inAffineTransform.transform (p))
    }
    return EBLinePath (origin: transformedOrigin, lines: transformedLines, closed: self.closed)
  }

  //····················································································································

  func appendToBezierPath (_ ioBezierPath : inout EBBezierPath, _ inAffineTransform : AffineTransform) {
    ioBezierPath.move (to: inAffineTransform.transform (self.origin))
    for p in self.lines {
      ioBezierPath.line (to: inAffineTransform.transform (p))
    }
    if self.closed {
      ioBezierPath.close ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
