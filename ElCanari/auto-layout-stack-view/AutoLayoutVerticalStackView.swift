//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

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
    self.setHuggingPriority (.init (rawValue: 1.0), for: .vertical)
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
  //   Facilities
  //····················································································································

  @discardableResult final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendFlexibleSpace ()
    hStack.appendView (inView)
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  @discardableResult final func appendViewFollowedByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendView (inView)
    hStack.appendFlexibleSpace ()
    self.addView (hStack, in: .leading)
    return self
  }

  //····················································································································

  @discardableResult final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendFlexibleSpace ()
    hStack.appendView (inView)
    hStack.appendFlexibleSpace ()
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
    self.needsUpdateConstraints = true
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