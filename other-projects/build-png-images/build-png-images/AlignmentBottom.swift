//
//  AlignmentBottom.swift
//  build-png-images
//
//  Created by Pierre Molinaro on 13/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AlignmentBottomView : NSView {

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
    let w = 0.2 * drawingRect.size.width
    bp.move (to: NSPoint (x: drawingRect.minX, y: drawingRect.minY))
    bp.line (to: NSPoint (x: drawingRect.maxX, y: drawingRect.minY))
    bp.move (to: NSPoint (x: drawingRect.midX, y: drawingRect.minY))
    bp.line (to: NSPoint (x: drawingRect.midX, y: drawingRect.maxY))
    bp.move (to: NSPoint (x: drawingRect.midX, y: drawingRect.minY))
    bp.relativeLine (to: NSPoint (x: w, y: w))
    bp.move (to: NSPoint (x: drawingRect.midX, y: drawingRect.minY))
    bp.relativeLine (to: NSPoint (x: -w, y: w))
    bp.stroke ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
