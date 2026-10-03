//
//  ProductHorizontalMirror.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

enum ProductHorizontalMirror {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  case noMirror
  case mirror (boardWidth : CanariLength)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func mirrored (_ inPoint : CanariPoint) -> CanariPoint {
    switch self {
    case .noMirror :
      return inPoint
    case .mirror (let boardWidth) :
      return CanariPoint (
        x: boardWidth - inPoint.x,
        y: inPoint.y
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func mirrored (_ inPoints : [CanariPoint]) -> [CanariPoint] {
    switch self {
    case .noMirror :
      return inPoints
    case .mirror (_) :
      var points = [CanariPoint] ()
      for p in inPoints {
        points.append (self.mirrored (p))
      }
      return points
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
