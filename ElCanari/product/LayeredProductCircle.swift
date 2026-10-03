//
//  LayeredProductCircle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

struct LayeredProductCircle : Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let x : CanariLength // Center X
  let y : CanariLength // Center Y
  let d : CanariLength // Diameter
  let layers : ProductLayerSet

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (center inCenter : CanariPoint,
        diameter inDiameter : CanariLength,
        layers inLayers : ProductLayerSet) {
    self.x = inCenter.x
    self.y = inCenter.y
    self.d = inDiameter
    self.layers = inLayers
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var center : CanariPoint { CanariPoint (x: self.x, y: self.y) }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
