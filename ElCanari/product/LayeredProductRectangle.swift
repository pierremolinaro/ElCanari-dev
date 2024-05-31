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

  let xCenter : ProductLength // Center
  let yCenter : ProductLength // Center
  let width : ProductLength
  let height : ProductLength
  let angleDegrees : Double // Degrees
  let layers : ProductLayerSet

  //································································································

   var center : ProductPoint { ProductPoint (x: self.xCenter, y: self.yCenter) }

  //································································································

  func gerberPolygon () -> (ProductPoint, [ProductPoint]) {
    let w = self.width.value (in: .cocoa)
    let h = self.height.value (in: .cocoa)
    let angleRadian = self.angleDegrees * .pi / 180.0
    var t = Turtle (p: self.center.cocoaPoint, angleInRadian: angleRadian)
    t.rotate270 ()
    t.forward (h / 2.0)
    t.rotate270 ()
    t.forward (w / 2.0)
    let bottomLeft = ProductPoint (cocoaPoint: t.location)
    t.rotate180 ()
    t.forward (w)
    let bottomRight = ProductPoint (cocoaPoint: t.location)
    t.rotate90 ()
    t.forward (h)
    let topRight = ProductPoint (cocoaPoint: t.location)
    t.rotate90 ()
    t.forward (w)
    let topLeft = ProductPoint (cocoaPoint: t.location)
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
