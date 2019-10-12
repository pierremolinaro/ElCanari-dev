//
//  AlignmentLeft.swift
//  build-png-images
//
//  Created by Pierre Molinaro on 12/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AlignmentLeftView : NSView {

  //····················································································································

  override var isFlipped: Bool { return false }

  //····················································································································
  //  Draw
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
//      NSColor.yellow.setFill ()
//      __NSRectFill (inDirtyRect)
    let drawingRect = self.bounds.insetBy (dx: 5.0, dy: 5.0)
    NSColor.black.setStroke ()
    let bp = NSBezierPath ()
    bp.lineWidth = 2.0
    bp.lineCapStyle = .round
    let xR = drawingRect.minX + 0.8 * drawingRect.size.width
    let y0 = drawingRect.minY + 0.8 * drawingRect.size.height
    let y1 = drawingRect.minY + 0.6 * drawingRect.size.height
    let y2 = drawingRect.minY + 0.4 * drawingRect.size.height
    let y3 = drawingRect.minY + 0.2 * drawingRect.size.height
    bp.move (to: NSPoint (x: drawingRect.minX, y: y0))
    bp.line (to: NSPoint (x: drawingRect.maxX, y: y0))
    bp.move (to: NSPoint (x: drawingRect.minX, y: y1))
    bp.line (to: NSPoint (x: xR, y: y1))
    bp.move (to: NSPoint (x: drawingRect.minX, y: y2))
    bp.line (to: NSPoint (x: drawingRect.maxX, y: y2))
    bp.move (to: NSPoint (x: drawingRect.minX, y: y3))
    bp.line (to: NSPoint (x: xR, y: y3))
    bp.stroke ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
