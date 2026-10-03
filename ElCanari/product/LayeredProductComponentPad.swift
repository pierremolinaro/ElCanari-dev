//
//  LayeredProductComponentPad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

struct LayeredProductComponentPad : Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let width : CanariLength
  let height : CanariLength
  let af : CanariAffinity
  let shape : PadShape
  let layers : ProductLayerSet

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Bezier Pathes (for PDF)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendRoundPad () -> (stroke: NSBezierPath?, filled: NSBezierPath?) {
    var strokeBezierPath : NSBezierPath? = nil
    var filledBezierPath : NSBezierPath? = nil
    let width = self.width
    let height = self.height
    if width > height { // Oblong
      let bp = NSBezierPath ()
      bp.move (to: self.af.transforming (x: -(width - height) / 2.0).ptValue)
      bp.line (to: self.af.transforming (x: +(width - height) / 2.0).ptValue)
      bp.lineWidth = height.ptValue
      bp.lineCapStyle = .round
      strokeBezierPath = bp
    }else if width < height { // Oblong
      let bp = NSBezierPath ()
      bp.move (to: self.af.transforming (y: -(height - width) / 2.0).ptValue)
      bp.line (to: self.af.transforming (y: +(height - width) / 2.0).ptValue)
      bp.lineWidth = width.ptValue
      bp.lineCapStyle = .round
      strokeBezierPath = bp
    }else{ // circular
      let r = NSRect (
        center: self.af.transforming (.zero).ptValue,
        size: NSSize (width: width, height: height)
      )
      filledBezierPath = NSBezierPath (ovalIn: r)
    }
    return (strokeBezierPath, filledBezierPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendRectPad () -> NSBezierPath {
    let w = self.width
    let h = self.height
    let bp = NSBezierPath ()
    bp.move (to: self.af.transforming (x: -w, y: -h).ptValue)
    bp.line (to: self.af.transforming (x: +w, y: -h).ptValue)
    bp.line (to: self.af.transforming (x: +w, y: +h).ptValue)
    bp.line (to: self.af.transforming (x: -w, y: +h).ptValue)
    bp.close ()
    return bp
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendOctoPad () -> NSBezierPath {
    let w = self.width
    let h = self.height
    let lg = min (w, h) / (1.0 + 1.0 / sqrt (2.0))
    let bp = NSBezierPath ()
    bp.move (to: self.af.transforming (x: +w - lg, y: +h).ptValue)
    bp.line (to: self.af.transforming (x: +w,      y: +h - lg).ptValue)
    bp.line (to: self.af.transforming (x: +w,      y: -h + lg).ptValue)
    bp.line (to: self.af.transforming (x: +w - lg, y: -h).ptValue)
    bp.line (to: self.af.transforming (x: -w + lg, y: -h).ptValue)
    bp.line (to: self.af.transforming (x: -w,      y: -h + lg).ptValue)
    bp.line (to: self.af.transforming (x: -w,      y: +h - lg).ptValue)
    bp.line (to: self.af.transforming (x: -w + lg, y: +h).ptValue)
    bp.close ()
    return bp
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Gerber
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendRoundPadToGerber (_ ioGerber : inout GerberRepresentation,
                                       mirror inMirror : ProductHorizontalMirror) {
    let width = self.width
    let height = self.height
    if width > height { // Oblong
      let p1 = inMirror.mirrored (self.af.transforming (x: -(width - height) / 2.0))
      let p2 = inMirror.mirrored (self.af.transforming (x: +(width - height) / 2.0))
      ioGerber.addRoundSegment (p1: p1, p2: p2, width: height)
    }else if width < height { // Oblong
      let p1 = inMirror.mirrored (self.af.transforming (y: -(height - width) / 2.0))
      let p2 = inMirror.mirrored (self.af.transforming (y: +(height - width) / 2.0))
      ioGerber.addRoundSegment (p1: p1, p2: p2, width: width)
    }else{ // circular
      ioGerber.addCircle (
        center: inMirror.mirrored (self.af.transforming (.zero)),
        diameter: width
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendRectPadToGerber (_ ioGerber : inout GerberRepresentation,
                                      mirror inMirror : ProductHorizontalMirror) {
    let w = self.width
    let h = self.height
    let p0 = inMirror.mirrored (self.af.transforming (x: -w, y: -h))
    let p1 = inMirror.mirrored (self.af.transforming (x: +w, y: -h))
    let p2 = inMirror.mirrored (self.af.transforming (x: +w, y: +h))
    let p3 = inMirror.mirrored (self.af.transforming (x: -w, y: +h))
    ioGerber.addPolygon (origin: p0, points: [p1, p2, p3])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendOctoPadToGerber (_ ioGerber : inout GerberRepresentation,
                                      mirror inMirror : ProductHorizontalMirror) {
    let w = self.width / 2.0
    let h = self.height / 2.0
    let lg = min (w, h) / (1.0 + 1.0 / sqrt (2.0))
    let p0 = inMirror.mirrored (self.af.transforming (x: +w - lg, y: +h))
    let p1 = inMirror.mirrored (self.af.transforming (x: +w,      y: +h - lg))
    let p2 = inMirror.mirrored (self.af.transforming (x: +w,      y: -h + lg))
    let p3 = inMirror.mirrored (self.af.transforming (x: +w - lg, y: -h))
    let p4 = inMirror.mirrored (self.af.transforming (x: -w + lg, y: -h))
    let p5 = inMirror.mirrored (self.af.transforming (x: -w,      y: -h + lg))
    let p6 = inMirror.mirrored (self.af.transforming (x: -w,      y: +h - lg))
    let p7 = inMirror.mirrored (self.af.transforming (x: -w + lg, y: +h))
    ioGerber.addPolygon (origin: p0, points: [p1, p2, p3, p4, p5, p6, p7])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension PadShape : Codable { }

//--------------------------------------------------------------------------------------------------
