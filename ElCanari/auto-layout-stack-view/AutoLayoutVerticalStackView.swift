//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutVerticalStackView : AutoLayoutBase_NSStackView {

  //····················································································································
  //   INIT
  //····················································································································

  init () {
    super.init (orientation: .vertical)
    self.alignment = .width
//    self.distribution = .fill

    self.setHuggingPriority (.required, for: .horizontal)
//    self.setHuggingPriority (.required, for: .vertical)
//    self.setHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setHuggingPriority (.defaultLow, for: .vertical)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func appendHorizontalSeparator () {
    let separator = HorizontalSeparator ()
    _ = self.appendView (separator)
  }

  //····················································································································
  //   Facilities
  //····················································································································

  final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    _ = hStack.appendFlexibleSpace ()
    _ = hStack.appendView (inView)
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  final func appendViewFollowedByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    _ = hStack.appendView (inView)
    _ = hStack.appendFlexibleSpace ()
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    _ = hStack.appendFlexibleSpace ()
    _ = hStack.appendView (inView)
    _ = hStack.appendFlexibleSpace ()
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  final func setCenterAlignment () -> Self {
    self.alignment = .centerX
    return self
  }

  //····················································································································
  // SET WIDTH
  //····················································································································

  private var mWidth : CGFloat? = nil
  private var mHeight : CGFloat? = nil

  //····················································································································

  final func set (width inWidth : Int) -> Self {
    self.mWidth = CGFloat (inWidth)
    let c = NSLayoutConstraint (
      item: self,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inWidth)
    )
    self.addConstraint (c)
    return self
  }

  //····················································································································

  final func set (minimumWidth inWidth : Int) -> Self {
    self.mWidth = CGFloat (inWidth)
    let c = NSLayoutConstraint (
      item: self,
      attribute: .width,
      relatedBy: .greaterThanOrEqual,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inWidth)
    )
    self.addConstraint (c)
    return self
  }

  //····················································································································

  final func set (height inHeight : Int) -> Self {
    self.mHeight = CGFloat (inHeight)
    self.needsUpdateConstraints = true
    return self
  }

  //····················································································································
  //   equalHeight
  //····················································································································

  final func equalHeight () -> Self {
    self.distribution = .fillEqually
    return self
  }

  //····················································································································
  //   minWidth
  //····················································································································

  final func set (minWidth inMinWidth : Int) -> Self {
    let c = NSLayoutConstraint (
      item: self,
      attribute: .width,
      relatedBy: .greaterThanOrEqual,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inMinWidth)
    )
    self.addConstraint (c)
    return self
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    if let w = self.mWidth {
      s.width = w
    }
    if let h = self.mHeight {
      s.height = h
    }
    return s
  }

  //····················································································································

  private var mConstraints = [NSLayoutConstraint] ()

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
        let c = NSLayoutConstraint (item: oneSpaceView, attribute: .height, relatedBy: .equal, toItem: spaceView, attribute: .height, multiplier: 1.0, constant: 0.0)
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
      DEBUG_VERTICAL_SEPARATOR_FILL_COLOR.setFill ()
      var optionalLastView : NSView? = nil
      for view in self.subviews {
        if !view.isHidden {
          if let lastView = optionalLastView {
            let top = lastView.frame.minY
            let bottom = view.frame.maxY
            let r = NSRect (x: inDirtyRect.minX, y: bottom, width: inDirtyRect.size.width, height: top - bottom)
//            Swift.print ("r \(r)")
            NSBezierPath.fill (r)
          }
          optionalLastView = view
        }
      }
    }
  }


  //····················································································································
  // HorizontalSeparator internal class
  //····················································································································

   final class HorizontalSeparator : NSBox {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init () {
      let s = NSSize (width: 10, height: 0) // Zero size means horizontal separator
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

    deinit { noteObjectDeallocation (self) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //····················································································································
  // HorizontalDivider internal class
  //····················································································································

   final class HorizontalDivider : AutoLayoutBase_NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override init () {
      super.init ()
      self.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
      self.setContentHuggingPriority (.defaultLow, for: .horizontal)
      self.setContentCompressionResistancePriority (.required, for: .vertical)
      self.setContentHuggingPriority (.required, for: .vertical)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder : NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize: NSSize { return NSSize (width: 0.0, height: 10.0) }

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
    private var mMouseDownDy : CGFloat = 0.0

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDown (with inEvent: NSEvent) {
      if let vStack = self.superview as? AutoLayoutVerticalStackView {
        let p1 = vStack.convert (inEvent.locationInWindow, from: nil)
        let p2 = vStack.convert (NSPoint (), from: self)
        self.mMouseDownDy = p1.y - p2.y
        //Swift.print ("dy \(dy)")
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDragged (with inEvent: NSEvent) {
      if let vStack = self.superview as? AutoLayoutVerticalStackView {
        if let c = self.mDividerConstraint {
          vStack.removeConstraint (c)
        }
        let p = vStack.convert (inEvent.locationInWindow, from: nil)
        let c = NSLayoutConstraint (
          item: self,
          attribute: .bottom,
          relatedBy: .equal,
          toItem: vStack,
          attribute: .bottom,
          multiplier: 1.0,
          constant: self.mMouseDownDy - p.y
        )
        c.priority = NSLayoutConstraint.Priority.dragThatCannotResizeWindow
        self.mDividerConstraint = c
        vStack.addConstraint (c)
        self.needsUpdateConstraints = true
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseUp (with inEvent: NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

     override func updateConstraints () {
       super.updateConstraints ()
       DispatchQueue.main.async { self.updateCursor () }
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

    private func updateCursor () {
      if self.constraintIsSatisfied () {
        NSCursor.resizeUpDown.set ()
      }else{
        NSCursor.resizeDown.set ()
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseEntered (with inEvent : NSEvent) {
      self.updateCursor ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseExited (with inEvent : NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private func constraintIsSatisfied () -> Bool {
       if let constraint = self.mDividerConstraint, let vStack = self.superview as? AutoLayoutVerticalStackView {
         let p = vStack.convert (NSPoint (), from: self)
         let constant = constraint.constant
         let satisfied = (constant + p.y) > 0.0
         // Swift.print ("\(constant), p.y \(p.y) satisfied \(satisfied)")
         return satisfied
       }else{
         return true
       }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
