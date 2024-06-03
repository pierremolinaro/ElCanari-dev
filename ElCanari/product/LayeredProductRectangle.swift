//
//  LayeredProductRectangle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------
// Un rectangle est défini par une transformation affine ; celle-ci représente la transformation du
// carré de côté 1 centré sur l'origine pour aboutir au rectangle
//--------------------------------------------------------------------------------------------------

struct LayeredProductRectangle : Codable {

  //································································································
  //  Properties
  //································································································

  let af : AffineTransform
  let layers : ProductLayerSet

  //································································································

  func polygon () -> (ProductPoint, [ProductPoint]) {
    let w = 0.5 // Moitié de la largeur
    let h = 0.5 // Moitié de la hauteur
    let bottomLeft  = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: -w, y: -h)))
    let bottomRight = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: +w, y: -h)))
    let topRight    = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: +w, y: +h)))
    let topLeft     = ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: -w, y: +h)))
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
