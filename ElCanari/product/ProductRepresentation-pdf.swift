//
//  ProductRepresentation-pdf.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension ProductRepresentation {

  //································································································
  //  Get PDF representation
  //································································································

  @MainActor func pdf (items inItemSet : ProductLayerSet,
                       mirror inMirror : ProductHorizontalMirror,
                       backColor inBackColor : NSColor,
                       grid inGrid : PDFProductGrid) -> Data {
  //--- Add round segments
    var strokeBezierPathes = [NSBezierPath] ()
    for oblong in self.roundSegments {
      if !inItemSet.intersection (oblong.layers).isEmpty {
        let bp = NSBezierPath ()
        bp.move (to: inMirror.mirrored (oblong.p1).cocoaPoint)
        bp.line (to: inMirror.mirrored (oblong.p2).cocoaPoint)
        bp.lineWidth = oblong.width.value (in: .cocoa)
        bp.lineCapStyle = .round
        strokeBezierPathes.append (bp)
      }
    }
  //--- Add circles
    var filledBezierPathes = [NSBezierPath] ()
    for circle in self.circles {
      if !inItemSet.intersection (circle.layers).isEmpty {
        let center = inMirror.mirrored (circle.center).cocoaPoint
        let diameter = circle.d.value (in: .cocoa)
        let r = NSRect (center: center, size: NSSize (width: diameter, height: diameter))
        let bp = NSBezierPath (ovalIn: r)
        filledBezierPathes.append (bp)
      }
    }
  //--- Add pads
    for pad in self.componentPads {
      if !inItemSet.intersection (pad.layers).isEmpty {
        let (strokeBP, filledBp) = pad.bezierPathes ()
        if let bp = strokeBP {
          strokeBezierPathes.append (bp)
        }
        if let bp = filledBp {
          filledBezierPathes.append (bp)
        }
      }
    }
  //--- Add square segments
    var polygons = [(ProductPoint, [ProductPoint])] ()
    for segment in self.squareSegments {
      if !inItemSet.intersection (segment.layers).isEmpty {
        polygons.append (segment.gerberPolygon ())
      }
    }
  //--- Add rectangles
    for rect in self.rectangles {
      if !inItemSet.intersection (rect.layers).isEmpty {
        polygons.append (rect.gerberPolygon ())
      }
    }
  //--- Handle polygons
    for (origin, points) in polygons {
      let bp = NSBezierPath ()
      bp.move (to: inMirror.mirrored (origin).cocoaPoint)
      for point in points {
        bp.line (to: inMirror.mirrored (point).cocoaPoint)
      }
      bp.close ()
      filledBezierPathes.append (bp)
    }
  //---
    let size = NSSize (
      width: self.boardWidth.value (in: .cocoa),
      height: self.boardHeight.value (in: .cocoa)
    )
    let view = OffscreenView (
      frame: NSRect (origin: .zero, size: size),
      strokeBezierPathes: strokeBezierPathes,
      filledBezierPathes: filledBezierPathes,
      shape: nil,
      backColor: inBackColor,
      grid: inGrid
    )
  //---
    return view.dataWithPDF (inside: view.bounds)
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
