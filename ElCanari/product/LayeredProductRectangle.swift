//
//  LayeredProductRectangle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct LayeredProductRectangle : Codable {

  //································································································
  //  Properties
  //································································································

  let x : ProductLength // Center
  let y : ProductLength // Center
  let width : ProductLength
  let height : ProductLength
  let angle : Double // Degrees
  let layers : ProductLayerSet

  //································································································

//  init (p1 inP1 : ProductPoint,
//        p2 inP2 : ProductPoint,
//        width inWidth : ProductLength,
//        layers inLayers : ProductLayerSet) {
//    self.p1x = inP1.x
//    self.p1y = inP1.y
//    self.p2x = inP2.x
//    self.p2y = inP2.y
//    self.width = inWidth
//    self.layers = inLayers
//  }

  //································································································

//  var p1 : ProductPoint { ProductPoint (x: self.p1x, y: self.p1y) }
//
//  var p2 : ProductPoint { ProductPoint (x: self.p2x, y: self.p2y) }

  //································································································

}

//--------------------------------------------------------------------------------------------------
