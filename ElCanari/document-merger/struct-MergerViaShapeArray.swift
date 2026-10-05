//
//  MergerViaShapeArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

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
      let x = via.x
      let y = via.y
      let diameter = via.padDiameter
      let r = CanariRect (left: x - diameter / 2.0 , bottom: y - diameter / 2.0, width: diameter, height: diameter)
      let bp = BezierPath (ovalIn: r)
      result.append (bp)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   MergerViaShape
//--------------------------------------------------------------------------------------------------

struct MergerViaShape : Hashable {

  let x : CanariLength
  let y : CanariLength
  let padDiameter : CanariLength

}

//--------------------------------------------------------------------------------------------------
