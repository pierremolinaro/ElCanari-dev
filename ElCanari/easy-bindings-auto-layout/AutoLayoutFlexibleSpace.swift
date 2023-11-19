//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutFlexibleSpace
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutFlexibleSpace : NSView {

  //····················································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
//    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
//    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
      DEBUG_FLEXIBLE_SPACE_FILL_COLOR.setFill ()
      NSBezierPath.fill (self.bounds)
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
