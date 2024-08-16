//
//  EBBezierPath.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/06/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// EBLinePath
//--------------------------------------------------------------------------------------------------

struct EBLinePath {
  let origin : NSPoint
  let lines : [NSPoint]
  let closed : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func transformed (by inAffineTransform : AffineTransform) -> EBLinePath {
    let transformedOrigin = inAffineTransform.transform (self.origin)
    var transformedLines = [NSPoint] ()
    for p in self.lines {
      transformedLines.append (inAffineTransform.transform (p))
    }
    return EBLinePath (origin: transformedOrigin, lines: transformedLines, closed: self.closed)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func linePathClipped (by inRect : NSRect) -> [EBLinePath] {
    var segments = [(NSPoint, NSPoint)] ()
    var p1 = self.origin
    for p2 in self.lines {
      if let (p1Clipped, p2Clipped) = inRect.clippedSegment (p1: p1, p2: p2) {
        segments.append ((p1Clipped, p2Clipped))
      }
      p1 = p2
    }
    if self.closed, let (p1Clipped, p2Clipped) = inRect.clippedSegment (p1: p1, p2: self.origin) {
      segments.append ((p1Clipped, p2Clipped))
    }
  //--- Build result
    var result = [EBLinePath] ()
    var possibleOrigin : NSPoint? = nil
    var points = [NSPoint] ()
    for (p1, p2) in segments {
      if let origin = possibleOrigin {
        if p1 == points.last! {
          points.append (p2)
        }else{
          result.append (EBLinePath (origin: origin, lines: points, closed: false))
          possibleOrigin = p1
          points = [p2]
        }
      }else{
        possibleOrigin = p1
        points = [p2]
      }
    }
    if let origin = possibleOrigin {
      result.append (EBLinePath (origin: origin, lines: points, closed: false))
    }
    return result
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension Array where Element == EBLinePath {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func linePathArrayClipped (by inRect : NSRect) -> [EBLinePath] {
    var result = [EBLinePath] ()
    for linePath in self {
      result += linePath.linePathClipped (by: inRect)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
