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
  //--- Add round rectangles
    for rect in self.roundRectangles {
      if !inItemSet.intersection (rect.layers).isEmpty {
        let center = inMirror.mirrored (rect.center).cocoaPoint
        let width = rect.width.value (in: .cocoa)
        let height = rect.height.value (in: .cocoa)
        let r = NSRect (center: center, size: NSSize (width: width, height: height))
        let radius = min (width, height) / 2.0
        let bp = NSBezierPath (roundedRect: r, xRadius: radius, yRadius: radius)
//        filledBezierPathes.append (bp)
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

