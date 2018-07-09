//
//  CanariOffscreenView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum StrokeOrFill {
  case stroke
  case fill
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariViewWithZoomAndFlip
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariOffscreenView : NSView, EBUserClassNameProtocol {

  private var bezierPaths = [([NSBezierPath], NSColor, StrokeOrFill)] ()

  //····················································································································

  override init(frame frameRect: NSRect) {
    super.init (frame: frameRect)
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  Set paths
  //····················································································································

  func setPaths (_ inPaths : [([NSBezierPath], NSColor, StrokeOrFill)]) {
    self.bezierPaths = inPaths
  }

  //····················································································································
  //  Draw Rect
  //····················································································································

  override func draw (_ dirtyRect: NSRect) {
    NSColor.white.setFill ()
    NSRectFill (dirtyRect)
  //--- Draw a thin border line
//    let r = self.bounds.insetBy (dx: 0.5, dy: 0.5)
//    NSColor.black.setStroke ()
//    let bp = NSBezierPath (rect:r)
//    bp.lineWidth = 1.0
//    bp.stroke ()
  //--- Bezier paths
    for (paths, color, operation) in self.bezierPaths {
      switch operation {
      case .stroke :
        color.setStroke ()
        for bp in paths {
          bp.stroke ()
        }
      case .fill :
        color.setFill ()
        for bp in paths {
          bp.fill ()
        }
      }
    }
  }

  //····················································································································

}
