//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutHorizontalStackView : AutoLayoutAbstractStackView {

  //····················································································································
  //   INIT
  //····················································································································

  init () {
    super.init (orientation: .horizontal)
    self.alignment = .height

//    self.setHuggingPriority (.required, for: .horizontal)
    self.setHuggingPriority (.required, for: .vertical)
    self.setHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
//    self.setHuggingPriority (.init (rawValue: 1.0), for: .vertical)
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

  final func appendVerticalSeparator () {
    let separator = Self.VerticalSeparator ()
    self.appendView (separator)
  }

  //····················································································································
  //   Facilities
  //····················································································································

  @discardableResult final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutVerticalStackView ()
    hStack.appendFlexibleSpace ()
    hStack.appendView (inView)
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  @discardableResult final func appendViewFollowedByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutVerticalStackView ()
    hStack.appendView (inView)
    hStack.appendFlexibleSpace ()
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  @discardableResult final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
    let hStack = AutoLayoutVerticalStackView ()
    hStack.appendFlexibleSpace ()
    hStack.appendView (inView)
    hStack.appendFlexibleSpace ()
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  class final func viewFollowedByFlexibleSpace (_ inView : NSView) -> AutoLayoutHorizontalStackView {
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendView (inView)
    hStack.appendFlexibleSpace ()
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
  // VerticalSeparator internal class
  //····················································································································

   final class VerticalSeparator : NSBox, EBUserClassNameProtocol {

    init () {
      let s = NSSize (width: 0, height: 10) // width == 0, height > 0 means vertical separator
      super.init (frame: NSRect (origin: NSPoint (), size: s))
      noteObjectAllocation (self)
      self.translatesAutoresizingMaskIntoConstraints = false
      self.boxType = .separator
    }

    required init? (coder inCoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    deinit {
      noteObjectDeallocation (self)
    }

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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
