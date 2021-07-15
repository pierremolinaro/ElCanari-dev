//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutVerticalStackView : AutoLayoutAbstractStackView {

  //····················································································································
  //   INIT
  //····················································································································

  init () {
    super.init (orientation: .vertical)
    self.alignment = .width
    self.distribution = .fill
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func appendHorizontalSeparator () {
    let separator = HorizontalSeparator ()
    self.appendView (separator)
  }

  //····················································································································

  @discardableResult final func appendFlexibleSpace (followedByView inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendFlexibleSpace ()
    hStack.appendView (inView)
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································
  // SET WIDTH
  //····················································································································

  private var mWidth = NSView.noIntrinsicMetric

  //····················································································································

  final func set (width inWidth : Int) -> Self {
    self.mWidth = CGFloat (inWidth)
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
    return NSSize (width: self.mWidth, height: NSView.noIntrinsicMetric)
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
  // HorizontalSeparator internal class
  //····················································································································

   final class HorizontalSeparator : NSBox, EBUserClassNameProtocol {

    init () {
      let s = NSSize (width: 10, height: 0) // Zero size means horizontal separator
      super.init (frame: NSRect (origin: NSPoint (), size: s))
      noteObjectAllocation (self)
      self.translatesAutoresizingMaskIntoConstraints = false
      self.boxType = .separator
    }

    required init? (coder inCoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    deinit { noteObjectDeallocation (self) }

  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
