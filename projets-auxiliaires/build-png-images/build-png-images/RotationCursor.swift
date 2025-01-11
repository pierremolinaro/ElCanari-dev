//
//  RotationCursor.swift
//  build-png-images
//
//  Created by Pierre Molinaro on 23/08/2020.
//  Copyright © 2020 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func drawRotationArrow (width inWidth : CGFloat) -> NSBezierPath {
  let bp = NSBezierPath ()
  bp.lineWidth = inWidth
  bp.lineCapStyle = .round
//--- Curve
  bp.move (to: NSPoint (x: 2.0, y: 8.0))
  bp.curve (
    to: NSPoint (x: 14.0, y: 8.0),
    controlPoint1: NSPoint (x:  2.0, y: 16.0),
    controlPoint2: NSPoint (x: 14.0, y: 16.0)
)
//--- Arrows
  bp.move (to: NSPoint (x: 2.0, y: 8.0))
  bp.line (to: NSPoint (x: 0.0, y: 10.0))
  bp.move (to: NSPoint (x: 2.0, y: 8.0))
  bp.line (to: NSPoint (x: 4.0, y: 10.0))
  bp.move (to: NSPoint (x: 14.0, y: 8.0))
  bp.line (to: NSPoint (x: 12.0, y: 10.0))
  bp.move (to: NSPoint (x: 14.0, y: 8.0))
  bp.line (to: NSPoint (x: 16.0, y: 10.0))
  return bp
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class RotationCursor : NSView {

  //····················································································································

  override var isFlipped: Bool { return false }

  //····················································································································
  //  Draw
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
//    NSColor.yellow.setFill ()
//    __NSRectFill (inDirtyRect)
    drawArrow ()
  //---
    let af = AffineTransform (translationByX: 13.0, byY: 7.0)
    var bp = drawRotationArrow (width: 3.0)
    bp.transform (using: af)
    NSColor.white.setStroke ()
    bp.stroke ()
    bp = drawRotationArrow (width: 1.0)
    bp.transform (using: af)
    NSColor.black.setStroke ()
    bp.stroke ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
