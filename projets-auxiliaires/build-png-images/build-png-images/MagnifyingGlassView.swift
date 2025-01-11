
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class MagnifyingGlassView : NSView {

  //····················································································································

  override var isFlipped: Bool { return false }

  //····················································································································
  //  Draw
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
//    NSColor.yellow.setFill ()
//    __NSRectFill (inDirtyRect)
    let drawingRect = self.bounds.insetBy (dx: 5.0, dy: 5.0)
    let s = drawingRect.size.width * 0.65
    let b = drawingRect.size.width * 0.4
    let r = NSRect (x: drawingRect.minX + 1.5, y: drawingRect.maxY - s - 1.5, width: s, height: s)
    NSColor.darkGray.setStroke ()
    var bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = 3.0
//    NSColor.white.setFill ()
//    bp.fill ()
    bp.stroke ()
    let p1 = NSPoint (x: drawingRect.maxY, y: drawingRect.minY)
    let p2 = NSPoint (x: p1.x - b, y: p1.y + b)
    bp = NSBezierPath ()
    bp.move (to: p1)
    bp.line (to: p2)
    bp.lineWidth = 5.0
    bp.stroke ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
