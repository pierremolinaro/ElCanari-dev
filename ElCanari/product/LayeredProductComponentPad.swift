//
//  LayeredProductComponentPad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct LayeredProductComponentPad : Codable {

  //································································································
  //  Properties
  //································································································

  let x : ProductLength // Center X
  let y : ProductLength // Center Y
  let width : ProductLength
  let height : ProductLength
  let angleDegrees : Double
  let shape : PadShape
  let layers : ProductLayerSet

  //································································································

//  func polygon () -> (ProductPoint, [ProductPoint]) {
//
//
//  }
  
      //    switch inShape {
//    case .round :
//      self.appendRoundPad (
//        center: inCenter,
//        padSize: inPadSize,
//        transformedBy: inAT,
//        layers: inLayers
//      )
//    case .rect :
//      self.appendRectPad (
//        center: inCenter,
//        padSize: inPadSize,
//        transformedBy: inAT,
//        layers: inLayers
//      )
//    case .octo :
//      self.appendOctoPad (
//        center: inCenter,
//        padSize: inPadSize,
//        transformedBy: inAT,
//        layers: inLayers
//      )
//    }

  //································································································

}

//--------------------------------------------------------------------------------------------------

extension PadShape : Codable { }

//--------------------------------------------------------------------------------------------------
