//
//  LayeredProductPolygon.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct LayeredProductPolygon : Codable {

  //································································································
  //  Properties
  //································································································

  let x : ProductLength // First Point X
  let y : ProductLength // First Point Y
  let points : [ProductPoint]
  let layers : ProductLayerSet

  //································································································

  init (origin inOrigin : ProductPoint,
        points inPoints : [ProductPoint],
        layers inLayers : ProductLayerSet) {
    self.x = inOrigin.x
    self.y = inOrigin.y
    self.points = inPoints
    self.layers = inLayers
  }

  //································································································

  var origin : ProductPoint { ProductPoint (x: self.x, y: self.y) }
  
  //································································································

}

//--------------------------------------------------------------------------------------------------
