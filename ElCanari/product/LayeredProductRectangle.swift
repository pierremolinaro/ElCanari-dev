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

  let xCenter : ProductLength
  let yCenter : ProductLength
  let width : ProductLength
  let height : ProductLength
  let af : AffineTransform
  let layers : ProductLayerSet

  //································································································

  func polygon () -> (ProductPoint, [ProductPoint]) {
    let w = self.width.value (in: .cocoa) / 2.0
    let h = self.height.value (in: .cocoa) / 2.0
    let x = self.xCenter.value (in: .cocoa)
    let y = self.yCenter.value (in: .cocoa)
    let bottomLeft  = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x - w, y: y - h)))
    let bottomRight = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x + w, y: y - h)))
    let topRight    = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x + w, y: y + h)))
    let topLeft     = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x - w, y: y + h)))
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
