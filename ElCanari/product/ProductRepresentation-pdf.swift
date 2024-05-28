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

  @MainActor func pdf (items inItemSet : ProductLayerSet) -> Data {
  //--- Add oblongs
    var strokeBezierPathes = [NSBezierPath] ()
    for oblong in self.oblongs {
      if inItemSet.contains (oblong.layers) {
        let bp = NSBezierPath ()
        bp.move (to: oblong.p1.cocoaPoint)
        bp.line (to: oblong.p2.cocoaPoint)
        bp.lineWidth = oblong.width.value (in: .px)
        bp.lineCapStyle = .round
        strokeBezierPathes.append (bp)
      }
    }
  //--- Add circles
    var filledBezierPathes = [NSBezierPath] ()
    for circle in self.circles {
      if inItemSet.contains (circle.layers) {
        var p = circle.center.cocoaPoint
        let diameter = circle.d.value (in: .px)
        p.x -= diameter / 2.0
        p.y -= diameter / 2.0
        let r = NSRect (center: p, size: NSSize (width: diameter, height: diameter))
        let bp = NSBezierPath (ovalIn: r)
        filledBezierPathes.append (bp)
      }
    }
  //--- Add polygons
    for polygon in self.polygons {
      if inItemSet.contains (polygon.layers) {
        let bp = NSBezierPath ()
        bp.move (to: polygon.origin.cocoaPoint)
        for point in polygon.points {
          bp.line (to: point.cocoaPoint)
        }
        bp.close ()
        filledBezierPathes.append (bp)
      }
    }
  //---
    let view = OffscreenView (
      frame: self.boardBox.cocoaRect,
      strokeBezierPathes: strokeBezierPathes,
      filledBezierPathes: filledBezierPathes
    )
  //---
    return view.dataWithPDF (inside: view.bounds)
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
//   OffscreenView
//--------------------------------------------------------------------------------------------------

fileprivate final class OffscreenView : NSView {

  private var mStrokeBezierPathes : [NSBezierPath]
  private var mFilledBezierPathes : [NSBezierPath]
//  private var mBackColor : NSColor? = nil

  //································································································

  override var isFlipped : Bool  { return false }

  //································································································

  init (frame inFrameRect : NSRect,
        strokeBezierPathes inStrokeBezierPathes : [NSBezierPath],
        filledBezierPathes inFilledBezierPathes : [NSBezierPath]) {
    self.mStrokeBezierPathes = inStrokeBezierPathes
    self.mFilledBezierPathes = inFilledBezierPathes
    super.init (frame: inFrameRect)
    noteObjectAllocation (self)
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    self.mStrokeBezierPathes = []
    self.mFilledBezierPathes = []
    super.init (coder: inCoder)
    noteObjectAllocation (self)
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································
  //  Draw Rect
  //································································································

  override func draw (_ inDirtyRect : NSRect) {
//    if let backColor = self.mBackColor {
//      backColor.setFill ()
//      NSBezierPath.fill (self.bounds)
//    }
    NSColor.black.setStroke ()
    for bp in self.mStrokeBezierPathes {
      bp.stroke ()
    }
    NSColor.black.setFill ()
    for bp in self.mFilledBezierPathes {
      bp.fill ()
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

