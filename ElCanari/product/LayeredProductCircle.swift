//
//  LayeredProductCircle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct LayeredProductCircle : Codable {

  //································································································
  //  Properties
  //································································································

  let x : ProductLength // Center X
  let y : ProductLength // Center Y
  let d : ProductLength // Diameter
  let layers : ProductLayerSet

  //································································································

  init (center inCenter : ProductPoint,
        diameter inDiameter : ProductLength,
        layers inLayers : ProductLayerSet) {
    self.x = inCenter.x
    self.y = inCenter.y
    self.d = inDiameter
    self.layers = inLayers
  }

  //································································································

  var center : ProductPoint { ProductPoint (x: self.x, y: self.y) }
  
  //································································································

}

//--------------------------------------------------------------------------------------------------
