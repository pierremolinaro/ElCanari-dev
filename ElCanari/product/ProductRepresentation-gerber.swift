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
    for segment in self.roundSegments {
      if !inItemSet.intersection (segment.layers).isEmpty {
        gerber.addRoundSegment (
          p1: inMirror.mirrored (segment.p1),
          p2: inMirror.mirrored (segment.p2),
          width: segment.width
        )
      }
    }
  //--- Add square segments
    for segment in self.squareSegments {
      if !inItemSet.intersection (segment.layers).isEmpty {
        let (origin, points) = segment.gerberPolygon ()
        gerber.addPolygon (
          origin: inMirror.mirrored (origin),
          points: inMirror.mirrored (points)
        )
      }
    }
  //--- Add rectangles
    for rect in self.rectangles {
      if !inItemSet.intersection (rect.layers).isEmpty {
        let (origin, points) = rect.gerberPolygon ()
        gerber.addPolygon (
          origin: inMirror.mirrored (origin),
          points: inMirror.mirrored (points)
        )
      }
    }
  //--- Add pads
    for pad in self.componentPads {
      if !inItemSet.intersection (pad.layers).isEmpty {
        pad.addGerberFor (&gerber, mirror: inMirror)
      }
    }
  //--- Add octogons
    for octogon in self.octogons {
      if !inItemSet.intersection (octogon.layers).isEmpty {
        let (origin, points) = octogon.productPolygon ()
        gerber.addPolygon (
          origin: inMirror.mirrored (origin),
          points: inMirror.mirrored (points)
        )
      }
    }
  //--- Add circles
    for circle in self.circles {
      if !inItemSet.intersection (circle.layers).isEmpty {
        gerber.addCircle (center: inMirror.mirrored (circle.center), diameter: circle.d)
      }
    }
  //---
    return gerber
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

