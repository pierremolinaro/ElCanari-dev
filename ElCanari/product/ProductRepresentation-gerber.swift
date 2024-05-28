//
//  ProductRepresentation-gerber.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension ProductRepresentation {

  //································································································
  //  Get Gerber representation
  //································································································

  func gerber (items inItemSet : ProductLayerSet) -> GerberRepresentation {
    var gerber = GerberRepresentation ()
  //--- Add oblongs
    for oblong in self.oblongs {
      if inItemSet.contains (oblong.layers) {
        gerber.addOblong (p1: oblong.p1, p2: oblong.p2, width: oblong.width)
      }
    }
  //--- Add circles
    for circle in self.circles {
      if inItemSet.contains (circle.layers) {
        gerber.addCircle (center: circle.center, diameter: circle.d)
      }
    }
  //--- Add polygons
    for polygon in self.polygons {
      if inItemSet.contains (polygon.layers) {
        gerber.addPolygon (origin: polygon.origin, points: polygon.points)
      }
    }
  //---
    return gerber
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

