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

  func gerber (items inItemSet : ProductLayerSet,
               mirror inMirror : ProductHorizontalMirror) -> GerberRepresentation {
    var gerber = GerberRepresentation ()
  //--- Add round segments
    for oblong in self.roundSegments {
      if !inItemSet.intersection (oblong.layers).isEmpty {
        gerber.addOblong (
          p1: inMirror.mirrored (oblong.p1),
          p2: inMirror.mirrored (oblong.p2),
          width: oblong.width
        )
      }
    }
  //--- Add circles
    for circle in self.circles {
      if !inItemSet.intersection (circle.layers).isEmpty {
        gerber.addCircle (center: inMirror.mirrored (circle.center), diameter: circle.d)
      }
    }
  //--- Add polygons
    for polygon in self.polygons {
      if !inItemSet.intersection (polygon.layers).isEmpty {
        gerber.addPolygon (
          origin: inMirror.mirrored (polygon.origin),
          points: inMirror.mirrored (polygon.points)
        )
      }
    }
  //---
    return gerber
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

