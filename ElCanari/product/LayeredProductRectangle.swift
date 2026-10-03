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

  let af : CanariAffinity
  let layers : ProductLayerSet

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func polygon () -> (CanariPoint, [CanariPoint]) {
    let w = CanariLength.pt (0.5) // Moitié de la largeur
    let h = CanariLength.pt (0.5) // Moitié de la hauteur
    let bottomLeft  = self.af.transforming (CanariPoint (x: -w, y: -h))
    let bottomRight = self.af.transforming (CanariPoint (x: +w, y: -h))
    let topRight    = self.af.transforming (CanariPoint (x: +w, y: +h))
    let topLeft     = self.af.transforming (CanariPoint (x: -w, y: +h))
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
