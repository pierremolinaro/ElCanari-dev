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

//  init (x inX : ProductPoint,
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
