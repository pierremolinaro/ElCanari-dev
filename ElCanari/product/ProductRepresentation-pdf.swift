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
        bp.lineWidth = oblong.width.value (in: .px)
        bp.lineCapStyle = .round
        strokeBezierPathes.append (bp)
      }
    }
  //--- Add circles
    var filledBezierPathes = [NSBezierPath] ()
    for circle in self.circles {
      if !inItemSet.intersection (circle.layers).isEmpty {
        let center = inMirror.mirrored (circle.center).cocoaPoint
        let diameter = circle.d.value (in: .px)
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
      backColor: inBackColor,
      grid: inGrid
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

  private let mStrokeBezierPathes : [NSBezierPath]
  private let mFilledBezierPathes : [NSBezierPath]
  private let mGrid : PDFProductGrid
  private var mBackColor : NSColor

  //································································································

  override var isFlipped : Bool  { return false }

  //································································································

  init (frame inFrameRect : NSRect,
        strokeBezierPathes inStrokeBezierPathes : [NSBezierPath],
        filledBezierPathes inFilledBezierPathes : [NSBezierPath],
        backColor inBackColor : NSColor,
        grid inGrid : PDFProductGrid) {
    self.mStrokeBezierPathes = inStrokeBezierPathes
    self.mFilledBezierPathes = inFilledBezierPathes
    self.mGrid = inGrid
    self.mBackColor = inBackColor
    super.init (frame: inFrameRect)
    noteObjectAllocation (self)
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································
  //  Draw Rect
  //································································································

  override func draw (_ inDirtyRect : NSRect) {
  //--- Back color
    self.mBackColor.setFill ()
    NSBezierPath.fill (self.bounds)
  //--- Grid
    switch self.mGrid {
    case .noGrid :
      ()
    case .gridMillimeter :
      let oneMillimeter = 72.0 / 25.4
      self.drawGrid (oneMillimeter)
      self.drawHorizontalMarks (oneMillimeter)
      self.drawVerticalMarks (oneMillimeter)
    case .grid100mils :
      let hundredMils = 72.0 / 10.0
      self.drawGrid (hundredMils)
      self.drawHorizontalMarks (hundredMils)
      self.drawVerticalMarks (hundredMils)
   }
  //--- Stroke
    NSColor.black.setStroke ()
    for bp in self.mStrokeBezierPathes {
      bp.stroke ()
    }
  //--- Fill
    NSColor.black.setFill ()
    for bp in self.mFilledBezierPathes {
      bp.fill ()
    }
  }

  //································································································

  private func drawGrid (_ inGridSizeInCocoaPoints : Double) {
    let subdivisionsBP = NSBezierPath ()
    subdivisionsBP.lineWidth = inGridSizeInCocoaPoints / 50.0
    subdivisionsBP.lineJoinStyle = .round
    subdivisionsBP.lineCapStyle = .round
    let divisionsBP = NSBezierPath ()
    divisionsBP.lineWidth = inGridSizeInCocoaPoints / 50.0
    divisionsBP.lineJoinStyle = .round
    divisionsBP.lineCapStyle = .round
    let widthPt = self.bounds.width
    let heightPt = self.bounds.height
  //--- Horizontal lines
    var y = inGridSizeInCocoaPoints
    var idx = 1
    while y < heightPt {
      if (idx % 5) == 0 {
        divisionsBP.move (to: NSPoint (x: 0.0, y: y))
        divisionsBP.line (to: NSPoint (x: widthPt, y: y))
      }else{
        subdivisionsBP.move (to: NSPoint (x: 0.0, y: y))
        subdivisionsBP.line (to: NSPoint (x: widthPt, y: y))
      }
      y += inGridSizeInCocoaPoints
      idx += 1
    }
   //--- Vertical lines
    var x = inGridSizeInCocoaPoints
    idx = 1
    while x < widthPt {
      if (idx % 5) == 0 {
        divisionsBP.move (to: NSPoint (x: x, y: 0))
        divisionsBP.line (to: NSPoint (x: x, y: heightPt))
      }else{
        subdivisionsBP.move (to: NSPoint (x: x, y: 0))
        subdivisionsBP.line (to: NSPoint (x: x, y: heightPt))
      }
      idx += 1
      x += inGridSizeInCocoaPoints
    }
    NSColor.lightGray.setStroke ()
    subdivisionsBP.stroke ()
    NSColor.black.setStroke ()
    divisionsBP.stroke ()
  }

  //································································································

  private func drawHorizontalMarks (_ inGridSizeInCocoaPoints : Double) {
    let attributes : [NSAttributedString.Key : Any] = [
      .font : NSFont.systemFont (ofSize: inGridSizeInCocoaPoints * 2.5)
    ]
    var x = 5.0 * inGridSizeInCocoaPoints
    var idx = 5
    while x < self.bounds.width {
      let str = "\(idx)"
      let s = str.size (withAttributes: attributes)
      str.draw (at: NSPoint (x: x - s.width / 2.0, y: inGridSizeInCocoaPoints), withAttributes: attributes)
      idx += 5
      x += 5.0 * inGridSizeInCocoaPoints
    }
  }

  //································································································

  private func drawVerticalMarks (_ inGridSizeInCocoaPoints : Double) {
    let attributes : [NSAttributedString.Key : Any] = [
      .font : NSFont.systemFont (ofSize: inGridSizeInCocoaPoints * 2.5)
    ]
    var y = 5.0 * inGridSizeInCocoaPoints
    var idy = 5
    while y < self.bounds.height {
      let str = "\(idy)"
      let s = str.size (withAttributes: attributes)
      str.draw (at: NSPoint (x: inGridSizeInCocoaPoints, y: y - s.height / 2.0), withAttributes: attributes)
      idy += 5
      y += 5.0 * inGridSizeInCocoaPoints
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
