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

   var center : ProductPoint { ProductPoint (x: self.xCenter, y: self.yCenter) }

  //································································································

  func gerberPolygon () -> (ProductPoint, [ProductPoint]) {
    let w = self.width.value (in: .cocoa) / 2.0
    let h = self.height.value (in: .cocoa) / 2.0
    let x = self.xCenter.value (in: .cocoa)
    let y = self.yCenter.value (in: .cocoa)
    let bottomLeft  = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x - w, y: y - h)))
    let bottomRight = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x + w, y: y - h)))
    let topRight    = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x + w, y: y + h)))
    let topLeft     = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: x - w, y: y + h)))
//    let angleRadian = self.angleDegrees * .pi / 180.0
//    var t = Turtle (p: self.center.cocoaPoint, angleInRadian: angleRadian)
//    t.rotate270 ()
//    t.forward (h / 2.0)
//    t.rotate270 ()
//    t.forward (w / 2.0)
//    let bottomLeft = ProductPoint (cocoaPoint: t.location)
//    t.rotate180 ()
//    t.forward (w)
//    let bottomRight = ProductPoint (cocoaPoint: t.location)
//    t.rotate90 ()
//    t.forward (h)
//    let topRight = ProductPoint (cocoaPoint: t.location)
//    t.rotate90 ()
//    t.forward (w)
//    let topLeft = ProductPoint (cocoaPoint: t.location)
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
