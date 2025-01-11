
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EditorInspectorView : NSView {

  //····················································································································

  override var isFlipped: Bool { return false }

  //····················································································································
  //  Draw
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
//    NSColor.yellow.setFill ()
//    __NSRectFill (inDirtyRect)
    let drawingRect = self.bounds.insetBy (dx: 5.0, dy: 5.0)
    let w = drawingRect.size.width
    let h = drawingRect.size.height
    NSColor.darkGray.setStroke ()
    NSColor.darkGray.setFill ()
    let bp = NSBezierPath ()
    bp.move (to: NSPoint (x: drawingRect.minX + w / 4.0, y: drawingRect.maxY))
    bp.line (to: NSPoint (x: drawingRect.minX + w * 3.0 / 4.0, y: drawingRect.maxY))
    bp.line (to: NSPoint (x: drawingRect.minX + w * 3.0 / 4.0, y: drawingRect.maxY - h * 2.0 / 3.0))
    bp.line (to: NSPoint (x: drawingRect.minX + w / 2.0, y: drawingRect.minY))
    bp.line (to: NSPoint (x: drawingRect.minX + w / 4.0, y: drawingRect.maxY - h * 2.0 / 3.0))
    bp.close ()
    bp.lineWidth = 3.0
    bp.stroke ()
    NSBezierPath.defaultLineWidth = 3.0
    NSBezierPath.stroke (NSRect (x: drawingRect.minX, y: drawingRect.midY, width: w / 4.0, height: h / 5.0))
    NSBezierPath.stroke (NSRect (x: drawingRect.minX + w * 3.0 / 4.0, y: drawingRect.midY, width: w / 4.0, height: h / 5.0))
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
