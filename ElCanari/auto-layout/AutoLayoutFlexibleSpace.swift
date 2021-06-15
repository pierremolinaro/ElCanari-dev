//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutFlexibleSpace
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutFlexibleSpace : NSView, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
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
      DEBUG_FILL_COLOR.setFill ()
      NSBezierPath.fill (inDirtyRect)
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
