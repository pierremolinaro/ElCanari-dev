//
//  LayeredProductRectangle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------
// Un rectangle est défini par une transformation affine ; celle-ci représente la transformation du
// carré de côté 1 centré sur l'origine pour aboutir au rectangle
//--------------------------------------------------------------------------------------------------

struct LayeredProductRectangle : Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let af : AffineTransform
  let layers : ProductLayerSet

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func polygon () -> (CanariPoint, [CanariPoint]) {
    let w = 0.5 // Moitié de la largeur
    let h = 0.5 // Moitié de la hauteur
    let bottomLeft  = self.af.transform (NSPoint (x: -w, y: -h)).canariPoint
    let bottomRight = self.af.transform (NSPoint (x: +w, y: -h)).canariPoint
    let topRight    = self.af.transform (NSPoint (x: +w, y: +h)).canariPoint
    let topLeft     = self.af.transform (NSPoint (x: -w, y: +h)).canariPoint
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
