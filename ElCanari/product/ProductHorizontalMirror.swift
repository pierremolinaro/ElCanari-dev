//
//  ProductHorizontalMirror.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

enum ProductHorizontalMirror {

  //································································································

  case noMirror
  case mirror (boardWidth : Int)

  //································································································

  func mirrored (_ inPoint : ProductPoint) -> ProductPoint {
    switch self {
    case .noMirror :
      return inPoint
    case .mirror (let boardWidth) :
      return ProductPoint (
        x: ProductLength (valueInCanariUnit: boardWidth - inPoint.x.valueInCanariUnit),
        y: inPoint.y
      )
    }
  }

  //································································································

  func mirrored (_ inPoints : [ProductPoint]) -> [ProductPoint] {
    switch self {
    case .noMirror :
      return inPoints
    case .mirror (_) :
      var points = [ProductPoint] ()
      for p in inPoints {
        points.append (self.mirrored (p))
      }
      return points
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
