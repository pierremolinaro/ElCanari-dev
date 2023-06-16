//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutHorizontalStackView : AutoLayoutBase_NSStackView {

  //····················································································································
  //   INIT
  //····················································································································

  init () {
    super.init (orientation: .horizontal)
    self.alignment = .height

    self.setHuggingPriority (.required, for: .vertical)
    self.setHuggingPriority (.defaultLow, for: .horizontal)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func setFirstBaselineAlignment () -> Self {
    self.alignment = .firstBaseline
    return self
  }

  //····················································································································

  final func setCenterYAlignment () -> Self {
    self.alignment = .centerY
    return self
  }

  //····················································································································

  final func setTopAlignment () -> Self {
    self.alignment = .top
    return self
  }

  //····················································································································

  final func equalWidth () -> Self {
    self.distribution = .fillEqually
    return self
  }

  //····················································································································

//  final func appendVerticalSeparator () {
//    let separator = Self.VerticalSeparator ()
//    _ = self.appendView (separator)
//  }

  //····················································································································

//  final func prependVerticalSeparator () {
//    let separator = Self.VerticalSeparator ()
//    _ = self.prependView (separator)
//  }

  //····················································································································
  //   Facilities
  //····················································································································

  final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutVerticalStackView ()
    _ = hStack.appendFlexibleSpace ()
    _ = hStack.appendView (inView)
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

//  final func appendViewFollowedByFlexibleSpace (_ inView : NSView) -> Self {
//    let hStack = AutoLayoutVerticalStackView ()
//    _ = hStack.appendView (inView)
//    _ = hStack.appendFlexibleSpace ()
//    self.addView (hStack, in: .leading)
//    return self
//  }

  //····················································································································

  final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
    let hStack = AutoLayoutVerticalStackView ()
    _ = hStack.appendFlexibleSpace ()
    _ = hStack.appendView (inView)
    _ = hStack.appendFlexibleSpace ()
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  class final func viewFollowedByFlexibleSpace (_ inView : NSView) -> AutoLayoutHorizontalStackView {
    let hStack = AutoLayoutHorizontalStackView ()
    _ = hStack.appendView (inView)
    _ = hStack.appendFlexibleSpace ()
    return hStack
  }

  //····················································································································

  private var mConstraints = [NSLayoutConstraint] ()

  //····················································································································

  override func updateConstraints () {
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll ()
    var spaceViewArray = [AutoLayoutFlexibleSpace] ()
    for view in self.subviews {
      if let spaceView = view as? AutoLayoutFlexibleSpace {
        spaceViewArray.append (spaceView)
      }
    }
    if let oneSpaceView = spaceViewArray.popLast () {
      for spaceView in spaceViewArray {
        let c = NSLayoutConstraint (item: oneSpaceView, attribute: .width, relatedBy: .equal, toItem: spaceView, attribute: .width, multiplier: 1.0, constant: 0.0)
        self.mConstraints.append (c)
      }
      self.addConstraints (self.mConstraints)
    }
    super.updateConstraints ()
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    super.draw (inDirtyRect)
    if debugAutoLayout () {
      DEBUG_HORIZONTAL_SEPARATOR_FILL_COLOR.setFill ()
      var optionalLastView : NSView? = nil
      for view in self.subviews {
        if !view.isHidden {
          if let lastView = optionalLastView {
            let left = lastView.frame.maxX
            let right = view.frame.minX
            let r = NSRect (x: left, y: inDirtyRect.minY, width: right - left, height: inDirtyRect.size.height)
            NSBezierPath.fill (r)
          }
          optionalLastView = view
        }
      }
    }
  }

  //····················································································································
  // VerticalSeparator internal class
  //····················································································································

  final class VerticalSeparator : NSBox {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init () {
      let s = NSSize (width: 0, height: 10) // width == 0, height > 0 means vertical separator
      super.init (frame: NSRect (origin: NSPoint (), size: s))
      noteObjectAllocation (self)
      self.translatesAutoresizingMaskIntoConstraints = false
      self.boxType = .separator
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    deinit {
      noteObjectDeallocation (self)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //····················································································································
  // VerticalDivider internal class
  //····················································································································

   final class VerticalDivider : AutoLayoutBase_NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override init () {
      super.init ()
      self.setContentCompressionResistancePriority (.required, for: .horizontal)
      self.setContentHuggingPriority (.required, for: .horizontal)
      self.setContentCompressionResistancePriority (.defaultLow, for: .vertical)
      self.setContentHuggingPriority (.defaultLow, for: .vertical)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder : NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize: NSSize { return NSSize (width: 10.0, height: 0.0) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func draw (_ inDirtyRect : NSRect) {
      let s : CGFloat = 6.0
      let r = NSRect (x: NSMidX (self.bounds) - s / 2.0, y: NSMidY (self.bounds) - s / 2.0, width: s, height: s)
      NSColor.separatorColor.setFill ()
      let bp = NSBezierPath (ovalIn: r)
      bp.fill ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
    //   Mouse
    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private var mDividerConstraint : NSLayoutConstraint? = nil

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDragged (with inEvent: NSEvent) {
      if let hStack = self.superview as? AutoLayoutHorizontalStackView {
        if let c = self.mDividerConstraint {
          hStack.removeConstraint (c)
        }
        let p = hStack.convert (inEvent.locationInWindow, from: nil)
        let c = NSLayoutConstraint (item: hStack, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: -p.x)
        c.priority = NSLayoutConstraint.Priority.dragThatCannotResizeWindow
        self.mDividerConstraint = c
        hStack.addConstraint (c)
        self.needsUpdateConstraints = true
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseUp (with inEvent: NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
    // Mouse moved events, cursor display
    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    var mTrackingArea : NSTrackingArea? = nil

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    final override func updateTrackingAreas () { // This is required for receiving mouse moved and mouseExited events
    //--- Remove current tracking area
      if let trackingArea = self.mTrackingArea {
        self.removeTrackingArea (trackingArea)
      }
    //--- Add Updated tracking area
      let trackingArea = NSTrackingArea (
        rect: self.bounds,
        options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
        owner: self,
        userInfo: nil
      )
      self.addTrackingArea (trackingArea)
      self.mTrackingArea = trackingArea
    //---
      super.updateTrackingAreas ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseEntered (with inEvent : NSEvent) {
      NSCursor.resizeLeftRight.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseExited (with inEvent : NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
