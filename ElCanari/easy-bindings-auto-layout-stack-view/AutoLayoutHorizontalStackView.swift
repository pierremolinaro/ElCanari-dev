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
 //   var optionalLastViewWithLastBaselineAlignment : NSView? = nil
    var optionalLastFlexibleSpace : AutoLayoutFlexibleSpace? = nil

    for view in self.subviews {
//      if !view.isHidden && (view.lastBaselineOffsetFromBottom != 0) {
//        if let lastViewWithLastBaselineAlignment = optionalLastViewWithLastBaselineAlignment {
//          let c = NSLayoutConstraint (item: lastViewWithLastBaselineAlignment, attribute: .lastBaseline, relatedBy: .equal, toItem: view, attribute: .lastBaseline, multiplier: 1.0, constant: 0.0)
//          self.mConstraints.append (c)
//        }
//        optionalLastViewWithLastBaselineAlignment = view
//      }
      if !view.isHidden, let spaceView = view as? AutoLayoutFlexibleSpace {
        if let lastFlexibleSpace = optionalLastFlexibleSpace {
          self.mConstraints.append (equalWidth: lastFlexibleSpace, spaceView)
        }
        optionalLastFlexibleSpace = spaceView
      }
    }
    self.addConstraints (self.mConstraints)
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
