//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let FOCUS_RING_MARGIN : Int = 5
private let RING_COLOR = NSColor (calibratedRed: 130.0 / 255.0, green: 171.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class EBFocusRingView : AutoLayoutHorizontalStackView {

  //····················································································································

  override init () {
    super.init ()
    _ = self.set (margins: FOCUS_RING_MARGIN)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  //  FOCUS RING
  //····················································································································

  private var mHasFocusRing = false {
    didSet {
      self.needsDisplay = true
    }
  }

  //····················································································································

  func setFocusRing (_ inValue : Bool) {
    self.mHasFocusRing = inValue
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    super.draw (inDirtyRect)
    if self.mHasFocusRing {
      let w = (CGFloat (FOCUS_RING_MARGIN) - 1.0) / 2.0
      let r = self.bounds.insetBy (dx: w, dy: w)
      let bp = NSBezierPath (roundedRect: r, xRadius: w / 2.0, yRadius: w / 2.0)
      bp.lineWidth = w * 2.0
      RING_COLOR.setStroke ()
      bp.stroke ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————