//
//  LayeredProductRectangle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------
// Par convention, un rectangle est en fait un rectangle centré sur l'origine.
// C'est la transformation affine « af » qui définit sa position
//--------------------------------------------------------------------------------------------------

struct LayeredProductRectangle : Codable {

  //································································································
  //  Properties
  //································································································

  let width : ProductLength
  let height : ProductLength
  let af : AffineTransform
  let layers : ProductLayerSet

  //································································································

  func polygon () -> (ProductPoint, [ProductPoint]) {
    let w = self.width.value (in: .cocoa) / 2.0
    let h = self.height.value (in: .cocoa) / 2.0
    let bottomLeft  = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: -w, y: -h)))
    let bottomRight = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: +w, y: -h)))
    let topRight    = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: +w, y: +h)))
    let topLeft     = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: -w, y: +h)))
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
