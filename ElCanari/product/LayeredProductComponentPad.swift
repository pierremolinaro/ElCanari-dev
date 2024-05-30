//
//  LayeredProductComponentPad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

struct LayeredProductComponentPad : Codable {

  //································································································
  //  Properties
  //································································································

  let xCenter : ProductLength
  let yCenter : ProductLength
  let width : ProductLength
  let height : ProductLength
  let af : AffineTransform
  let shape : PadShape
  let layers : ProductLayerSet

  //································································································
  //  Bezier Pathes (for PDF)
  //································································································

  func bezierPathes () -> (stroke: NSBezierPath?, filled: NSBezierPath?) {
    var strokeBezierPath : NSBezierPath? = nil
    var filledBezierPath : NSBezierPath? = nil
    switch self.shape {
    case .round :
      (strokeBezierPath, filledBezierPath) = self.appendRoundPad ()
    case .rect :
      filledBezierPath = self.appendRectPad ()
    case .octo :
      filledBezierPath = self.appendOctoPad ()
    }
    return (strokeBezierPath, filledBezierPath)
  }

  //································································································

  private func appendRoundPad () -> (stroke: NSBezierPath?, filled: NSBezierPath?) {
    var strokeBezierPath : NSBezierPath? = nil
    var filledBezierPath : NSBezierPath? = nil
    let center = ProductPoint (x: self.xCenter, y: self.yCenter).cocoaPoint
    let width = self.width.value (in: .cocoa)
    let height = self.height.value (in: .cocoa)
    if width > height { // Oblong
      let bp = NSBezierPath ()
      bp.move (to: self.af.transform (NSPoint (x: center.x - (width - height) / 2.0, y: center.y)))
      bp.line (to: self.af.transform (NSPoint (x: center.x + (width - height) / 2.0, y: center.y)))
      bp.lineWidth = height
      bp.lineCapStyle = .round
      strokeBezierPath = bp
    }else if width < height { // Oblong
      let bp = NSBezierPath ()
      bp.move (to: self.af.transform (NSPoint (x: center.x, y: center.y - (height - width) / 2.0)))
      bp.line (to: self.af.transform (NSPoint (x: center.x, y: center.y + (height - width) / 2.0)))
      bp.lineWidth = width
      bp.lineCapStyle = .round
      strokeBezierPath = bp
    }else{ // circular
      let r = NSRect (
        center: self.af.transform (center),
        size: NSSize (width: width, height: height)
      )
      filledBezierPath = NSBezierPath (ovalIn: r)
    }
    return (strokeBezierPath, filledBezierPath)
  }

  //································································································

  private func appendRectPad () -> NSBezierPath {
    let w = self.width.value (in: .cocoa) / 2.0
    let h = self.height.value (in: .cocoa) / 2.0
    let center = ProductPoint (x: self.xCenter, y: self.yCenter).cocoaPoint
    let bp = NSBezierPath ()
    bp.move (to: self.af.transform (NSPoint (x: center.x - w, y: center.y - h)))
    bp.line (to: self.af.transform (NSPoint (x: center.x + w, y: center.y - h)))
    bp.line (to: self.af.transform (NSPoint (x: center.x + w, y: center.y + h)))
    bp.line (to: self.af.transform (NSPoint (x: center.x - w, y: center.y + h)))
    bp.close ()
    return bp
  }

  //································································································

  private func appendOctoPad () -> NSBezierPath {
    let w = self.width.value (in: .cocoa) / 2.0
    let h = self.height.value (in: .cocoa) / 2.0
    let center = ProductPoint (x: self.xCenter, y: self.yCenter).cocoaPoint
    let lg : CGFloat = min (w, h) / (1.0 + 1.0 / sqrt (2.0))
    let bp = NSBezierPath ()
    bp.move (to: self.af.transform (NSPoint (x: center.x + w - lg, y: center.y + h)))
    bp.line (to: self.af.transform (NSPoint (x: center.x + w,      y: center.y + h - lg)))
    bp.line (to: self.af.transform (NSPoint (x: center.x + w,      y: center.y - h + lg)))
    bp.line (to: self.af.transform (NSPoint (x: center.x + w - lg, y: center.y - h)))
    bp.line (to: self.af.transform (NSPoint (x: center.x - w + lg, y: center.y - h)))
    bp.line (to: self.af.transform (NSPoint (x: center.x - w,      y: center.y - h + lg)))
    bp.line (to: self.af.transform (NSPoint (x: center.x - w,      y: center.y + h - lg)))
    bp.line (to: self.af.transform (NSPoint (x: center.x - w + lg, y: center.y + h)))
    bp.close ()
    return bp
  }

  //································································································
  //  Gerber
  //································································································

  func addGerberFor (_ ioGerber : inout GerberRepresentation,
                     mirror inMirror : ProductHorizontalMirror) {
    switch self.shape {
    case .round :
      self.appendRoundPadToGerber (&ioGerber, mirror: inMirror)
    case .rect :
      self.appendRectPadToGerber (&ioGerber, mirror: inMirror)
    case .octo :
      self.appendOctoPadToGerber (&ioGerber, mirror: inMirror)
    }
  }

  //································································································

  private func appendRoundPadToGerber (_ ioGerber : inout GerberRepresentation,
                                       mirror inMirror : ProductHorizontalMirror) {
    let center = ProductPoint (x: self.xCenter, y: self.yCenter).cocoaPoint
    let width = self.width.value (in: .cocoa)
    let height = self.height.value (in: .cocoa)
    if width > height { // Oblong
      let p1 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x - (width - height) / 2.0, y: center.y))))
      let p2 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x + (width - height) / 2.0, y: center.y))))
      ioGerber.addRoundSegment (p1: p1, p2: p2, width: ProductLength (height, .cocoa))
    }else if width < height { // Oblong
      let p1 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x, y: center.y - (height - width) / 2.0))))
      let p2 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x, y: center.y + (height - width) / 2.0))))
      ioGerber.addRoundSegment (p1: p1, p2: p2, width: ProductLength (width, .cocoa))
    }else{ // circular
      ioGerber.addCircle (
        center: inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (center))),
        diameter: ProductLength (width, .cocoa)
      )
    }
  }

  //································································································

  private func appendRectPadToGerber (_ ioGerber : inout GerberRepresentation,
                                      mirror inMirror : ProductHorizontalMirror) {
    let w = self.width.value (in: .cocoa) / 2.0
    let h = self.height.value (in: .cocoa) / 2.0
    let center = ProductPoint (x: self.xCenter, y: self.yCenter).cocoaPoint
    let p0 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x - w, y: center.y - h))))
    let p1 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x + w, y: center.y - h))))
    let p2 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x + w, y: center.y + h))))
    let p3 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x - w, y: center.y + h))))
    ioGerber.addPolygon (origin: p0, points: [p1, p2, p3])
  }

  //································································································

  private func appendOctoPadToGerber (_ ioGerber : inout GerberRepresentation,
                                      mirror inMirror : ProductHorizontalMirror) {
    let w = self.width.value (in: .cocoa) / 2.0
    let h = self.height.value (in: .cocoa) / 2.0
    let center = ProductPoint (x: self.xCenter, y: self.yCenter).cocoaPoint
    let lg : CGFloat = min (w, h) / (1.0 + 1.0 / sqrt (2.0))
    let p0 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x + w - lg, y: center.y + h))))
    let p1 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x + w,      y: center.y + h - lg))))
    let p2 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x + w,      y: center.y - h + lg))))
    let p3 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x + w - lg, y: center.y - h))))
    let p4 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x - w + lg, y: center.y - h))))
    let p5 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x - w,      y: center.y - h + lg))))
    let p6 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x - w,      y: center.y + h - lg))))
    let p7 = inMirror.mirrored (ProductPoint (cocoaPoint: self.af.transform (NSPoint (x: center.x - w + lg, y: center.y + h))))
    ioGerber.addPolygon (origin: p0, points: [p1, p2, p3, p4, p5, p6, p7])
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

extension PadShape : Codable { }

//--------------------------------------------------------------------------------------------------
