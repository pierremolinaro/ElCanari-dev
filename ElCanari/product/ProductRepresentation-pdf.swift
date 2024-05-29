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
  //--- Add oblongs
    var strokeBezierPathes = [NSBezierPath] ()
    for oblong in self.oblongs {
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
  //--- Add polygons
    for polygon in self.polygons {
      if !inItemSet.intersection (polygon.layers).isEmpty {
        let bp = NSBezierPath ()
        bp.move (to: inMirror.mirrored (polygon.origin).cocoaPoint)
        for point in polygon.points {
          bp.line (to: inMirror.mirrored (point).cocoaPoint)
        }
        bp.close ()
        filledBezierPathes.append (bp)
      }
    }
  //---
    let view = OffscreenView (
      frame: self.boardBox.cocoaRect,
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
